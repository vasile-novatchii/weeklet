# Project: Weeklet

Weeklet is a Flutter app for personal finance management using Clean Architecture.

## Architecture

This project follows **Clean Architecture** with three distinct layers:
- **Domain** (`lib/domain`): Entities, Use Cases, Repositories Interfaces (Pure Dart, no Flutter dependencies).
- **Data** (`lib/data`): Models, Data Sources, Repositories Implementation (Hive, APIs).
- **Presentation** (`lib/presentation`): BLoCs, Screens, Widgets.

## Key Actions

- **Run App**: `flutter run`
- **Run Tests**: `flutter test`
- **Build Runner**: `dart run build_runner build --delete-conflicting-outputs` (Run this after changing potential Hive models or Freezed classes).

## Skills

The following specialized skills are fully configured in `.agent/skills`:

- **Create Feature**: Scaffolds a new feature (Domain -> Data -> Presentation).
- **Run Build Runner**: Helper to re-generate code.

You can invoke these by asking "Create a feature called [Name]" or "Run build runner".
