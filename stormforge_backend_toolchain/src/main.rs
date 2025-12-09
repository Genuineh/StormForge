use anyhow::Result;
use crossterm::{
    event::{self, Event, KeyCode, KeyEvent, KeyEventKind},
    terminal::{disable_raw_mode, enable_raw_mode, EnterAlternateScreen, LeaveAlternateScreen},
    ExecutableCommand,
};
use ratatui::prelude::*;
use std::io::{stdout, Stdout};
use std::time::Duration;

mod backend;
mod ui;

use ui::{App, AppState};

fn main() -> Result<()> {
    // Setup terminal
    enable_raw_mode()?;
    stdout().execute(EnterAlternateScreen)?;
    let mut terminal = Terminal::new(CrosstermBackend::new(stdout()))?;

    // Create app state
    let mut app = App::new();

    // Run app
    let res = run_app(&mut terminal, &mut app);

    // Restore terminal
    disable_raw_mode()?;
    stdout().execute(LeaveAlternateScreen)?;

    if let Err(err) = res {
        eprintln!("Error: {}", err);
    }

    Ok(())
}

fn run_app(terminal: &mut Terminal<CrosstermBackend<Stdout>>, app: &mut App) -> Result<()> {
    loop {
        terminal.draw(|f| ui::draw(f, app))?;

        if event::poll(Duration::from_millis(100))? {
            if let Event::Key(key) = event::read()? {
                if key.kind == KeyEventKind::Press && handle_key_event(key, app)? {
                    return Ok(());
                }
            }
        }

        // Update app state (check status, read logs, etc.)
        app.update()?;
    }
}

fn handle_key_event(key: KeyEvent, app: &mut App) -> Result<bool> {
    match app.state {
        AppState::MainMenu => match key.code {
            KeyCode::Char('q') | KeyCode::Esc => return Ok(true),
            KeyCode::Up | KeyCode::Char('k') => app.previous_menu_item(),
            KeyCode::Down | KeyCode::Char('j') => app.next_menu_item(),
            KeyCode::Enter => app.select_menu_item()?,
            _ => {}
        },
        AppState::Status => match key.code {
            KeyCode::Char('q') | KeyCode::Esc => app.state = AppState::MainMenu,
            KeyCode::Char('r') => app.update()?,
            _ => {}
        },
        AppState::Logs => match key.code {
            KeyCode::Char('q') | KeyCode::Esc => app.state = AppState::MainMenu,
            KeyCode::Up | KeyCode::Char('k') => app.scroll_logs_up(),
            KeyCode::Down | KeyCode::Char('j') => app.scroll_logs_down(),
            KeyCode::Char('c') => app.clear_logs(),
            _ => {}
        },
        AppState::Config => match key.code {
            KeyCode::Char('q') | KeyCode::Esc => app.state = AppState::MainMenu,
            _ => {}
        },
        AppState::Confirm { .. } => match key.code {
            KeyCode::Char('y') | KeyCode::Char('Y') => {
                app.confirm_action()?;
                app.state = AppState::MainMenu;
            }
            KeyCode::Char('n') | KeyCode::Char('N') | KeyCode::Esc => {
                app.state = AppState::MainMenu;
            }
            _ => {}
        },
    }
    Ok(false)
}
