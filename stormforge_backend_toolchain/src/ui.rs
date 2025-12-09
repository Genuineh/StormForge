use anyhow::Result;
use ratatui::{
    layout::{Alignment, Constraint, Direction, Layout, Rect},
    style::{Color, Modifier, Style},
    widgets::{Block, Borders, List, ListItem, Paragraph, Wrap},
    Frame,
};

use crate::backend::{BackendManager, ServiceStatus};

#[derive(Debug, Clone, PartialEq)]
pub enum AppState {
    MainMenu,
    Status,
    Logs,
    Config,
    Confirm { action: String },
}

pub struct App {
    pub state: AppState,
    pub backend: BackendManager,
    menu_selected: usize,
    menu_items: Vec<&'static str>,
    logs: Vec<String>,
    log_scroll: usize,
}

impl App {
    pub fn new() -> Self {
        Self {
            state: AppState::MainMenu,
            backend: BackendManager::new().expect("Failed to create backend manager"),
            menu_selected: 0,
            menu_items: vec![
                "1. Setup Environment",
                "2. Start MongoDB",
                "3. Build Backend",
                "4. Start Backend",
                "5. View Status",
                "6. View Logs",
                "7. Stop Backend",
                "8. Stop MongoDB",
                "9. Cleanup All",
                "10. Configuration",
                "Q. Quit",
            ],
            logs: Vec::new(),
            log_scroll: 0,
        }
    }

    pub fn previous_menu_item(&mut self) {
        if self.menu_selected > 0 {
            self.menu_selected -= 1;
        }
    }

    pub fn next_menu_item(&mut self) {
        if self.menu_selected < self.menu_items.len() - 1 {
            self.menu_selected += 1;
        }
    }

    pub fn select_menu_item(&mut self) -> Result<()> {
        match self.menu_selected {
            0 => {
                // Setup Environment
                match self.backend.setup_environment() {
                    Ok(messages) => {
                        for msg in messages {
                            self.add_log(msg);
                        }
                    }
                    Err(e) => self.add_log(format!("Error: {}", e)),
                }
            }
            1 => {
                // Start MongoDB
                match self.backend.start_mongodb() {
                    Ok(msg) => self.add_log(msg),
                    Err(e) => self.add_log(format!("Error: {}", e)),
                }
            }
            2 => {
                // Build Backend
                self.add_log("Building backend... This may take a while.".to_string());
                match self.backend.build_backend() {
                    Ok(msg) => self.add_log(msg),
                    Err(e) => self.add_log(format!("Error: {}", e)),
                }
            }
            3 => {
                // Start Backend
                match self.backend.start_backend() {
                    Ok(msg) => self.add_log(msg),
                    Err(e) => self.add_log(format!("Error: {}", e)),
                }
            }
            4 => {
                // View Status
                self.state = AppState::Status;
            }
            5 => {
                // View Logs
                self.state = AppState::Logs;
            }
            6 => {
                // Stop Backend
                match self.backend.stop_backend() {
                    Ok(msg) => self.add_log(msg),
                    Err(e) => self.add_log(format!("Error: {}", e)),
                }
            }
            7 => {
                // Stop MongoDB
                match self.backend.stop_mongodb() {
                    Ok(msg) => self.add_log(msg),
                    Err(e) => self.add_log(format!("Error: {}", e)),
                }
            }
            8 => {
                // Cleanup All
                self.state = AppState::Confirm {
                    action: "cleanup".to_string(),
                };
            }
            9 => {
                // Configuration
                self.state = AppState::Config;
            }
            _ => {}
        }
        Ok(())
    }

    pub fn confirm_action(&mut self) -> Result<()> {
        if let AppState::Confirm { action } = &self.state {
            match action.as_str() {
                "cleanup" => {
                    self.add_log("Cleaning up all services...".to_string());
                    match self.backend.cleanup_all() {
                        Ok(messages) => {
                            for msg in messages {
                                self.add_log(msg);
                            }
                        }
                        Err(e) => self.add_log(format!("Error during cleanup: {}", e)),
                    }
                }
                _ => {}
            }
        }
        Ok(())
    }

    pub fn update(&mut self) -> Result<()> {
        // Update backend status
        self.backend.check_status()?;
        Ok(())
    }

    pub fn refresh_status(&mut self) -> Result<()> {
        self.backend.check_status()?;
        Ok(())
    }

    pub fn add_log(&mut self, message: String) {
        let timestamp = chrono::Local::now().format("%H:%M:%S");
        self.logs.push(format!("[{}] {}", timestamp, message));
        // Keep only last 1000 log entries
        if self.logs.len() > 1000 {
            self.logs.remove(0);
        }
    }

    pub fn scroll_logs_up(&mut self) {
        if self.log_scroll > 0 {
            self.log_scroll -= 1;
        }
    }

    pub fn scroll_logs_down(&mut self) {
        if self.log_scroll < self.logs.len().saturating_sub(1) {
            self.log_scroll += 1;
        }
    }

    pub fn clear_logs(&mut self) {
        self.logs.clear();
        self.log_scroll = 0;
    }
}

pub fn draw(f: &mut Frame, app: &App) {
    let chunks = Layout::default()
        .direction(Direction::Vertical)
        .constraints([
            Constraint::Length(3),
            Constraint::Min(0),
            Constraint::Length(3),
        ])
        .split(f.area());

    // Header
    draw_header(f, chunks[0]);

    // Main content
    match app.state {
        AppState::MainMenu => draw_main_menu(f, chunks[1], app),
        AppState::Status => draw_status(f, chunks[1], app),
        AppState::Logs => draw_logs(f, chunks[1], app),
        AppState::Config => draw_config(f, chunks[1], app),
        AppState::Confirm { ref action } => draw_confirm(f, chunks[1], action),
    }

    // Footer
    draw_footer(f, chunks[2], &app.state);
}

fn draw_header(f: &mut Frame, area: Rect) {
    let title = Paragraph::new("StormForge Backend Toolchain")
        .style(
            Style::default()
                .fg(Color::Cyan)
                .add_modifier(Modifier::BOLD),
        )
        .alignment(Alignment::Center)
        .block(Block::default().borders(Borders::ALL));
    f.render_widget(title, area);
}

fn draw_footer(f: &mut Frame, area: Rect, state: &AppState) {
    let help_text = match state {
        AppState::MainMenu => "↑/↓: Navigate | Enter: Select | Q/Esc: Quit",
        AppState::Status => "R: Refresh | Q/Esc: Back to Menu",
        AppState::Logs => "↑/↓: Scroll | C: Clear | Q/Esc: Back to Menu",
        AppState::Config => "Q/Esc: Back to Menu",
        AppState::Confirm { .. } => "Y: Confirm | N/Esc: Cancel",
    };

    let footer = Paragraph::new(help_text)
        .style(Style::default().fg(Color::Gray))
        .alignment(Alignment::Center)
        .block(Block::default().borders(Borders::ALL));
    f.render_widget(footer, area);
}

fn draw_main_menu(f: &mut Frame, area: Rect, app: &App) {
    let chunks = Layout::default()
        .direction(Direction::Horizontal)
        .constraints([Constraint::Percentage(40), Constraint::Percentage(60)])
        .split(area);

    // Menu
    let items: Vec<ListItem> = app
        .menu_items
        .iter()
        .enumerate()
        .map(|(i, item)| {
            let style = if i == app.menu_selected {
                Style::default()
                    .fg(Color::Black)
                    .bg(Color::Cyan)
                    .add_modifier(Modifier::BOLD)
            } else {
                Style::default().fg(Color::White)
            };
            ListItem::new(*item).style(style)
        })
        .collect();

    let menu = List::new(items)
        .block(Block::default().borders(Borders::ALL).title("Menu"))
        .highlight_style(Style::default().add_modifier(Modifier::BOLD));
    f.render_widget(menu, chunks[0]);

    // Recent logs
    let log_items: Vec<ListItem> = app
        .logs
        .iter()
        .rev()
        .take(20)
        .map(|log| ListItem::new(log.as_str()))
        .collect();

    let logs = List::new(log_items).block(
        Block::default()
            .borders(Borders::ALL)
            .title("Recent Activity"),
    );
    f.render_widget(logs, chunks[1]);
}

fn draw_status(f: &mut Frame, area: Rect, app: &App) {
    let status_text = format!(
        "MongoDB Status: {}\n\
         Backend Status: {}\n\
         Backend Path: {}\n\n\
         Press 'r' to refresh status",
        format_status(&app.backend.mongo_status),
        format_status(&app.backend.backend_status),
        app.backend.get_backend_path().display(),
    );

    let paragraph = Paragraph::new(status_text)
        .block(Block::default().borders(Borders::ALL).title("System Status"))
        .wrap(Wrap { trim: true });
    f.render_widget(paragraph, area);
}

fn draw_logs(f: &mut Frame, area: Rect, app: &App) {
    let log_items: Vec<ListItem> = app
        .logs
        .iter()
        .skip(app.log_scroll)
        .map(|log| ListItem::new(log.as_str()))
        .collect();

    let logs = List::new(log_items).block(
        Block::default()
            .borders(Borders::ALL)
            .title(format!("Logs (Total: {})", app.logs.len())),
    );
    f.render_widget(logs, area);
}

fn draw_config(f: &mut Frame, area: Rect, app: &App) {
    let config_path = app.backend.get_backend_path().join(".env");
    let config_content = std::fs::read_to_string(&config_path)
        .unwrap_or_else(|_| "Configuration file not found".to_string());

    let paragraph = Paragraph::new(config_content)
        .block(
            Block::default()
                .borders(Borders::ALL)
                .title("Configuration (.env)"),
        )
        .wrap(Wrap { trim: false });
    f.render_widget(paragraph, area);
}

fn draw_confirm(f: &mut Frame, area: Rect, action: &str) {
    let message = match action {
        "cleanup" => "Are you sure you want to cleanup all services?\nThis will stop MongoDB, Backend, and remove containers.\n\nPress Y to confirm, N to cancel.",
        _ => "Confirm action?",
    };

    let paragraph = Paragraph::new(message)
        .style(Style::default().fg(Color::Yellow))
        .alignment(Alignment::Center)
        .block(
            Block::default()
                .borders(Borders::ALL)
                .title("Confirmation"),
        )
        .wrap(Wrap { trim: true });

    // Center the confirmation dialog
    let vertical_chunks = Layout::default()
        .direction(Direction::Vertical)
        .constraints([
            Constraint::Percentage(30),
            Constraint::Percentage(40),
            Constraint::Percentage(30),
        ])
        .split(area);

    let horizontal_chunks = Layout::default()
        .direction(Direction::Horizontal)
        .constraints([
            Constraint::Percentage(20),
            Constraint::Percentage(60),
            Constraint::Percentage(20),
        ])
        .split(vertical_chunks[1]);

    f.render_widget(paragraph, horizontal_chunks[1]);
}

fn format_status(status: &ServiceStatus) -> String {
    match status {
        ServiceStatus::NotStarted => "⚪ Not Started".to_string(),
        ServiceStatus::Starting => "🟡 Starting...".to_string(),
        ServiceStatus::Running => "🟢 Running".to_string(),
        ServiceStatus::Stopping => "🟡 Stopping...".to_string(),
        ServiceStatus::Stopped => "🔴 Stopped".to_string(),
        ServiceStatus::Error(e) => format!("❌ Error: {}", e),
    }
}
