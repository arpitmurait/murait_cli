# Murait CLI

<p align="center">
  <img src="https://img.shields.io/badge/version-1.0.0-blue.svg" alt="Version">
  <img src="https://img.shields.io/badge/license-MIT-green.svg" alt="License">
</p>

A powerful CLI tool to supercharge your Flutter workflow. Instantly scaffold new projects with a production-ready GetX architecture, and generate screens, models, and repositories with a single command.

## 🚀 Get Started

### Installation

You can install murait_cli directly from GitHub. Just make sure you have the Dart SDK installed.

```bash
dart pub global activate -sgit https://github.com/arpitmurait/murait_cli.git
```

After installation, you can use the `murait_cli` command from anywhere on your system.

## ✨ Features & Commands

Here's a breakdown of everything you can do with Murait CLI.

### 1. Create a New Project

Kickstart a new Flutter project with your complete GetX boilerplate, including all dependencies, assets, and folder structures.

```bash
murait_cli create <project_name>
```

👉 **Example:**

```bash
murait_cli create my_awesome_app
```

This command creates a new Flutter project named `my_awesome_app` and replaces the default `lib` and `assets` folders with your production-ready templates.

### 2. Add Components to Your Project

Once you're inside a project folder, you can use the `add` command to generate new components.

#### Add a New Screen

This command creates a new screen with its own controller and a widgets folder. It also automatically updates your `app_routes.dart` and `app_pages.dart` files.

```bash
murait_cli add screen <screen_name> [--with-repo]
```

`--with-repo`: An optional flag to also generate a matching model and repository for the screen.

👉 **Example (Screen only):**

```bash
murait_cli add screen profile
```

This creates:
- `lib/screens/profile/profile_screen.dart`
- `lib/screens/profile/profile_controller.dart`
- `lib/screens/profile/widgets/`
- Updates your routing files

👉 **Example (Screen with Model & Repository):**

```bash
murait_cli add screen product --with-repo
```

This creates all of the above, plus:
- `lib/data/model/product_model.dart`
- `lib/data/repository/product_repository.dart`

#### Add a New Model

Quickly generate a new model file in `lib/data/model/`.

```bash
murait_cli add model <model_name>
```

👉 **Example:**

```bash
murait_cli add model user
```

This creates `lib/data/model/user_model.dart`.

#### Add a New Repository

Quickly generate a new repository file in `lib/data/repository/`.

```bash
murait_cli add repository <repository_name>
```

👉 **Example:**

```bash
murait_cli add repository cart
```

This creates `lib/data/repository/cart_repository.dart`.

### 3. Integrate Firebase Services

Add and configure Firebase services with a single command. The CLI handles adding dependencies and required boilerplate code.

```bash
murait_cli add firebase <service_name>
```

**Available services:**
- `all`: Installs Auth, Analytics, Notifications, and Crashlytics
- `auth`: Installs Firebase Auth with Google and Apple Sign-In
- `notification`: Installs Firebase Cloud Messaging
- `analytics`: Installs Firebase Analytics and auto-logs screen views
- `crashlytics`: Installs Firebase Crashlytics
- `ads`: Installs Google Mobile Ads SDK

👉 **Example:**

```bash
murait_cli add firebase auth
```

This adds the necessary packages for Firebase Auth and prints the required platform-specific setup steps for you to follow.

### 4. Add Common Utilities

Add pre-configured utility functions to your project.

#### Add Share Functionality

```bash
murait_cli add share
```

This adds the `share_plus` package and injects a `shareApp()` method into your `lib/core/utils/utils.dart` file.

## License

This project is licensed under the MIT License - see the LICENSE.md file for details.