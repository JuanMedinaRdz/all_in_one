import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../features/calendar/presentation/calendar_screen.dart';
import '../../features/finance/presentation/finance_screen.dart';
import '../../features/notes/presentation/note_editor_screen.dart';
import '../../features/notes/presentation/notes_screen.dart';
import '../../features/recipes/presentation/recipe_editor_screen.dart';
import '../../features/todos/presentation/todo_editor_screen.dart';
import '../../features/todos/presentation/todos_screen.dart';
import '../widgets/app_shell.dart';
import '../widgets/fade_through_branches.dart';

/// Rutas de la app en un solo lugar, para no repetir strings sueltos.
abstract final class AppRoutes {
  const AppRoutes._();

  static const calendar = '/calendario';
  static const finance = '/mensualidades';
  static const notes = '/notas';
  static const todos = '/todos';
}

final _rootNavigatorKey = GlobalKey<NavigatorState>();

/// Router de la app. Cada sección vive en su propia rama con su propio
/// historial de navegación, de forma que cambiar de pestaña no pierde el
/// contexto de donde estabas.
final goRouterProvider = Provider<GoRouter>((ref) {
  return GoRouter(
    navigatorKey: _rootNavigatorKey,
    initialLocation: AppRoutes.calendar,
    routes: [
      StatefulShellRoute(
        builder: (context, state, navigationShell) =>
            AppShell(navigationShell: navigationShell),
        navigatorContainerBuilder: (context, navigationShell, children) =>
            FadeThroughBranches(
          currentIndex: navigationShell.currentIndex,
          children: children,
        ),
        branches: [
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: AppRoutes.calendar,
                builder: (context, state) => const CalendarScreen(),
              ),
            ],
          ),
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: AppRoutes.finance,
                builder: (context, state) => const FinanceScreen(),
              ),
            ],
          ),
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: AppRoutes.notes,
                builder: (context, state) => const NotesScreen(),
                routes: [
                  // El editor de recetas va antes que `:id` para que "receta"
                  // no se interprete como un id de nota.
                  GoRoute(
                    path: 'receta/:id',
                    builder: (context, state) => RecipeEditorScreen(
                      recipeId: state.pathParameters['id']!,
                    ),
                  ),
                  // El editor vive dentro de la rama de Notas para conservar
                  // la barra de navegación y el historial de la sección.
                  GoRoute(
                    path: ':id',
                    builder: (context, state) => NoteEditorScreen(
                      noteId: state.pathParameters['id']!,
                    ),
                  ),
                ],
              ),
            ],
          ),
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: AppRoutes.todos,
                builder: (context, state) => const TodosScreen(),
                routes: [
                  GoRoute(
                    path: ':id',
                    builder: (context, state) => TodoEditorScreen(
                      todoId: state.pathParameters['id']!,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ],
      ),
    ],
  );
});
