import 'package:go_router/go_router.dart';
import 'package:stormforge_modeler/app.dart';
import 'package:stormforge_modeler/screens/auth/login_screen.dart';
import 'package:stormforge_modeler/screens/auth/register_screen.dart';
import 'package:stormforge_modeler/screens/entities/entity_editor_screen.dart';
import 'package:stormforge_modeler/screens/projects/project_form_screen.dart';
import 'package:stormforge_modeler/screens/projects/projects_list_screen.dart';
import 'package:stormforge_modeler/screens/read_models/read_model_designer_screen.dart';
import 'package:stormforge_modeler/screens/settings/project_settings_screen.dart';
import 'package:stormforge_modeler/screens/users/team_members_screen.dart';

/// Router configuration for the app.
final router = GoRouter(
  initialLocation: '/login',
  routes: [
    // Auth routes
    GoRoute(
      path: '/login',
      builder: (context, state) => const LoginScreen(),
    ),
    GoRoute(
      path: '/register',
      builder: (context, state) => const RegisterScreen(),
    ),

    // Projects routes
    GoRoute(
      path: '/projects',
      builder: (context, state) => const ProjectsListScreen(),
    ),
    GoRoute(
      path: '/projects/new',
      builder: (context, state) => const ProjectFormScreen(),
    ),
    GoRoute(
      path: '/projects/:id/edit',
      builder: (context, state) {
        final projectId = state.pathParameters['id']!;
        return ProjectFormScreen(projectId: projectId);
      },
    ),
    GoRoute(
      path: '/projects/:id/settings',
      builder: (context, state) {
        final projectId = state.pathParameters['id']!;
        return ProjectSettingsScreen(projectId: projectId);
      },
    ),
    GoRoute(
      path: '/projects/:id/team',
      builder: (context, state) {
        final projectId = state.pathParameters['id']!;
        return TeamMembersScreen(projectId: projectId);
      },
    ),
    GoRoute(
      path: '/projects/:id/entities',
      builder: (context, state) {
        final projectId = state.pathParameters['id']!;
        return EntityEditorScreen(projectId: projectId);
      },
    ),
    GoRoute(
      path: '/projects/:id/read-models',
      builder: (context, state) {
        final projectId = state.pathParameters['id']!;
        return ReadModelDesignerScreen(projectId: projectId);
      },
    ),

    // Canvas route (existing modeler UI)
    GoRoute(
      path: '/canvas/:id',
      builder: (context, state) {
        // For now, redirect to the existing modeler home page
        // In the future, this will load the specific project
        return const ModelerHomePage();
      },
    ),

    // Root redirect
    GoRoute(
      path: '/',
      redirect: (context, state) => '/login',
    ),
  ],
);
