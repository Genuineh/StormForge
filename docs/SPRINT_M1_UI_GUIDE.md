# Sprint M1 UI Implementation Guide

## Overview

This document describes the UI implementation for Sprint M1 of the StormForge Modeler 2.0 upgrade, which adds project management, user authentication, and team collaboration features.

## Features Implemented

### 1. User Authentication
- **Login Screen** (`screens/auth/login_screen.dart`)
  - Username/email and password authentication
  - Form validation
  - Error handling
  - Navigation to registration

- **Registration Screen** (`screens/auth/register_screen.dart`)
  - New user registration
  - Role selection (Admin, Developer, Viewer)
  - Password confirmation
  - Form validation

### 2. Project Management
- **Projects List** (`screens/projects/projects_list_screen.dart`)
  - Display all user's projects
  - Quick actions: Open, Settings, Team, Delete
  - Create new project button
  - Empty state handling

- **Project Form** (`screens/projects/project_form_screen.dart`)
  - Create new projects
  - Edit existing projects
  - Namespace validation
  - Visibility settings (Private, Team, Public)

- **Project Settings** (`screens/settings/project_settings_screen.dart`)
  - Git integration configuration
    - Enable/disable Git sync
    - Repository URL
    - Branch name
    - Auto-commit settings
  - AI generation settings
    - AI provider and model selection
    - Temperature control

### 3. Team Management
- **Team Members** (`screens/users/team_members_screen.dart`)
  - List all team members
  - Add new members
  - Change member roles
  - Remove members
  - Role descriptions

### 4. API Integration
- **API Client** (`services/api/api_client.dart`)
  - HTTP client with authentication
  - Error handling
  - JSON serialization

- **Services**
  - `auth_service.dart` - Authentication operations
  - `user_service.dart` - User management
  - `project_service.dart` - Project CRUD
  - `team_member_service.dart` - Team management

### 5. State Management
- **Providers** (`services/providers.dart`)
  - Riverpod state management
  - Authentication state
  - Service providers
  - Reactive UI updates

### 6. Routing
- **Router** (`router.dart`)
  - Go Router configuration
  - Route guards
  - Deep linking support

## Architecture

```
lib/
├── screens/
│   ├── auth/
│   │   ├── login_screen.dart
│   │   └── register_screen.dart
│   ├── projects/
│   │   ├── projects_list_screen.dart
│   │   └── project_form_screen.dart
│   ├── settings/
│   │   └── project_settings_screen.dart
│   └── users/
│       └── team_members_screen.dart
├── services/
│   ├── api/
│   │   ├── api_client.dart
│   │   ├── auth_service.dart
│   │   ├── user_service.dart
│   │   ├── project_service.dart
│   │   └── team_member_service.dart
│   └── providers.dart
├── models/
│   ├── user_model.dart
│   ├── project_model.dart
│   └── team_member_model.dart
├── router.dart
└── app.dart
```

## Setup Instructions

### 1. Install Dependencies

```bash
cd stormforge_modeler
flutter pub get
```

### 2. Start the Backend

```bash
cd ../stormforge_backend
# Configure .env file
cp .env.example .env
# Edit .env with MongoDB URI and JWT secret

# Run the backend
cargo run
```

The backend will start on `http://localhost:3000`.

### 3. Run the Flutter App

```bash
cd ../stormforge_modeler
flutter run
```

## Usage Flow

### First Time User

1. **Launch App** → Redirects to Login Screen
2. **Click "Register"** → Registration Screen
3. **Fill Registration Form**
   - Username (min 3 characters)
   - Email
   - Display Name
   - Password (min 6 characters)
   - Select Role
4. **Submit** → Auto-login → Projects List
5. **Create First Project**
   - Click "New Project" button
   - Enter project details
   - Choose visibility
   - Submit
6. **Access Project** → Click project card → Opens canvas

### Existing User

1. **Launch App** → Login Screen
2. **Enter Credentials** → Projects List
3. **Select Project** → Opens canvas
4. **Manage Project**
   - Click ⋮ menu on project card
   - Access Settings, Team, or Delete

### Managing Team Members

1. **From Projects List** → Click ⋮ → "Team Members"
2. **Add Member**
   - Click "Add Member" button
   - Enter user ID
   - Select role (Owner, Admin, Editor, Viewer)
   - Submit
3. **Change Role**
   - Click ⋮ on member → "Change Role"
   - Select new role
   - Confirm
4. **Remove Member**
   - Click ⋮ on member → "Remove"
   - Confirm deletion

### Configuring Project Settings

1. **From Projects List** → Click ⋮ → "Settings"
2. **Git Integration**
   - Toggle "Enable Git Integration"
   - Enter repository URL
   - Set branch name
   - Configure auto-commit
3. **AI Settings**
   - Toggle "Enable AI Generation"
   - Select provider (e.g., "claude")
   - Enter model name
   - Adjust temperature
4. **Save Settings** → Click "Save Settings" button

## API Endpoints Used

### Authentication
- `POST /api/auth/register` - User registration
- `POST /api/auth/login` - User login

### Users
- `GET /api/users` - List users
- `GET /api/users/:id` - Get user
- `PUT /api/users/:id` - Update user

### Projects
- `POST /api/projects` - Create project
- `GET /api/projects/:id` - Get project
- `GET /api/projects/owner/:owner_id` - List user's projects
- `PUT /api/projects/:id` - Update project
- `DELETE /api/projects/:id` - Delete project

### Team Members
- `POST /api/projects/:project_id/members` - Add member
- `GET /api/projects/:project_id/members` - List members
- `PUT /api/projects/:project_id/members/:user_id` - Update role
- `DELETE /api/projects/:project_id/members/:user_id` - Remove member

## Security Features

### Authentication
- JWT token-based authentication
- Token storage using `shared_preferences`
- Automatic token injection in API requests

### Password Security
- Client-side validation (min 6 characters)
- Server-side bcrypt hashing
- Password confirmation on registration

### Authorization
- Role-based access control (RBAC)
- 3 global roles: Admin, Developer, Viewer
- 4 team roles: Owner, Admin, Editor, Viewer
- 12 granular permissions

## UI Components

### Material Design 3
- Uses Material 3 design system
- Light and dark theme support
- System theme detection

### Common Patterns
- **Cards** - Project items, team members
- **Forms** - Input validation, error messages
- **Dialogs** - Confirmations, quick actions
- **Snackbars** - Success/error feedback
- **Loading States** - Progress indicators
- **Empty States** - Helpful messages when no data

### Responsive Design
- Max-width constraints for forms (400-600px)
- Scrollable content areas
- Adaptive layouts

## Error Handling

### Network Errors
- Connection failures → Retry button
- Timeout errors → User feedback
- API errors → Error messages with details

### Validation Errors
- Form field validation
- Real-time feedback
- Clear error messages

### State Errors
- Loading states
- Error states with retry
- Empty states with actions

## Testing

### Manual Testing Checklist

#### Authentication
- [ ] Can register new user
- [ ] Can login with username
- [ ] Can login with email
- [ ] Cannot login with wrong password
- [ ] Can logout
- [ ] Token persists after app restart

#### Projects
- [ ] Can create project
- [ ] Can view projects list
- [ ] Can edit project
- [ ] Can delete project
- [ ] Empty state shows when no projects

#### Team Management
- [ ] Can add team member
- [ ] Can change member role
- [ ] Can remove member
- [ ] Role permissions work correctly

#### Settings
- [ ] Can enable/disable Git integration
- [ ] Can save Git settings
- [ ] Can enable/disable AI generation
- [ ] Settings persist after navigation

## Known Limitations

1. **No Profile Screen** - User profile management not yet implemented
2. **No Password Reset** - Password reset flow not implemented
3. **No Email Verification** - Email verification not implemented
4. **Basic User Search** - Team member addition requires knowing user ID
5. **No Real-time Updates** - Team changes require manual refresh
6. **No Pagination** - All lists load complete data

## Future Enhancements

### Planned for Sprint M2+
- Real-time collaboration
- User profile management
- Advanced search and filtering
- Pagination for large lists
- Activity feed/history
- Notifications system
- Password reset flow
- Email verification
- OAuth integration (Google, GitHub)
- Avatar uploads
- Project templates
- Project sharing via links

## Troubleshooting

### Backend Connection Issues
**Problem**: Cannot connect to backend
**Solution**: 
1. Check backend is running: `curl http://localhost:3000/health`
2. Check CORS configuration in backend
3. Verify API base URL in `api_client.dart`

### Authentication Issues
**Problem**: Login fails with valid credentials
**Solution**:
1. Check JWT secret matches in backend `.env`
2. Verify token storage permissions
3. Clear app data and try again

### Build Issues
**Problem**: Flutter build fails
**Solution**:
1. Run `flutter clean`
2. Run `flutter pub get`
3. Check Dart SDK version (>=3.5.0)
4. Restart IDE/editor

## Contributing

When adding new features:
1. Follow existing file structure
2. Use Riverpod for state management
3. Add proper error handling
4. Include loading states
5. Validate user input
6. Update this documentation

## Support

For issues or questions:
- Check backend logs: `stormforge_backend/logs/`
- Check Flutter console output
- Review API documentation: `http://localhost:3000/swagger-ui`
- Refer to main project documentation

---

**Status**: ✅ Sprint M1 UI Implementation Complete  
**Date**: 2025-12-04  
**Version**: 0.1.0
