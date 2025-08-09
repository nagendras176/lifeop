# Task Tracker App - New Architecture

This document describes the new clean architecture structure implemented for the Task Tracker app.

## Directory Structure

```
lib/src/
├── app.dart                    # Main app widget
├── bootstrap.dart              # App initialization
├── core/                       # Core functionality
│   ├── config/
│   │   └── env.dart           # Environment configuration
│   ├── error/
│   │   └── failures.dart      # Error handling
│   ├── utils/
│   │   └── date_time.dart     # Utility functions
│   ├── db/                    # Database layer
│   │   ├── connection/
│   │   │   ├── open_connection.dart      # Conditional imports
│   │   │   ├── open_connection_io.dart   # Native implementation
│   │   │   └── open_connection_web.dart  # Web implementation
│   │   ├── app_database.dart             # Main database class
│   │   ├── tables/                       # Table definitions
│   │   │   ├── tasks.dart
│   │   │   └── projects.dart
│   │   ├── daos/                        # Data Access Objects
│   │   │   ├── task_dao.dart
│   │   │   └── project_dao.dart
│   │   └── migrations/                  # Database migrations
│   │       └── drift_migrations.dart
│   ├── di/
│   │   └── providers.dart               # Dependency injection
│   ├── router/
│   │   └── app_router.dart              # App routing
│   └── theme/
│       └── theme.dart                   # App theming
├── features/                   # Feature modules
│   └── tasks/                 # Tasks feature
│       ├── domain/            # Business logic
│       │   ├── entities/      # Domain entities
│       │   │   └── task.dart
│       │   ├── repositories/  # Repository interfaces
│       │   │   └── task_repository.dart
│       │   └── usecases/      # Use cases
│       │       ├── create_task.dart
│       │       └── get_tasks.dart
│       ├── data/              # Data layer
│       │   ├── models/        # Data models
│       │   │   └── task_model.dart
│       │   ├── repositories/  # Repository implementations
│       │   │   └── task_repository_impl.dart
│       │   └── local/         # Local data sources
│       │       └── drift/     # Database-specific code
│       │           └── mappers.dart
│       └── presentation/      # UI layer
│           ├── providers/     # State management
│           │   └── task_providers.dart
│           ├── pages/         # Screen implementations
│           │   ├── task_queue_screen.dart
│           │   └── task_definition_screen.dart
│           └── widgets/       # Reusable widgets
│               └── task_tile.dart
└── l10n/                      # Localization
    └── app_en.arb            # English strings
```

## Architecture Principles

### 1. Clean Architecture
- **Domain Layer**: Contains business logic, entities, and use cases
- **Data Layer**: Handles data operations and external dependencies
- **Presentation Layer**: Manages UI and user interactions

### 2. Separation of Concerns
- Each feature is self-contained with its own domain, data, and presentation layers
- Core functionality is shared across features
- Database operations are abstracted through DAOs and repositories

### 3. Dependency Injection
- Uses a simple service locator pattern (can be replaced with Riverpod later)
- Dependencies are injected rather than created directly
- Easy to test and mock

### 4. Platform Abstraction
- Database connections are platform-specific (IO vs Web)
- Conditional imports handle platform differences
- Core business logic remains platform-agnostic

## Key Components

### Core
- **Environment Configuration**: Centralized app configuration
- **Error Handling**: Structured error types and failure handling
- **Database**: Abstracted database operations with platform-specific implementations
- **Routing**: Centralized navigation management
- **Theming**: Consistent UI appearance across the app

### Features
- **Tasks**: Complete CRUD operations with objectives and progress tracking
- **Projects**: Future feature for organizing tasks (placeholder)

### Data Flow
1. UI triggers a user action
2. Presentation layer calls appropriate use case
3. Use case executes business logic through repository
4. Repository interacts with data sources (local database, API, etc.)
5. Data flows back through the same path to update UI

## Migration Notes

### From Old Structure
- `lib/components/` → `lib/src/features/tasks/presentation/`
- `lib/utils/` → `lib/src/core/utils/`
- Models moved to domain entities
- Screens moved to presentation pages

### Dependencies
- Currently uses simple service locator for DI
- Can be upgraded to Riverpod when added to pubspec.yaml
- Database layer is prepared for Drift integration

## Next Steps

1. **Add Dependencies**: Add Riverpod, Drift, and other packages to pubspec.yaml
2. **Implement Database**: Complete Drift table definitions and migrations
3. **Add State Management**: Implement Riverpod providers for reactive UI
4. **Add Tests**: Create unit tests for domain logic and integration tests
5. **Add More Features**: Implement projects, user management, etc.

## Benefits

- **Maintainable**: Clear separation of concerns
- **Testable**: Easy to unit test business logic
- **Scalable**: New features can be added without affecting existing code
- **Platform Agnostic**: Core logic works on all platforms
- **Team Friendly**: Clear structure for multiple developers
