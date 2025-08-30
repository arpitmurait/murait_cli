# 📦 murait_cli

A custom **Flutter/Dart CLI tool** to generate boilerplate code for **GetX** and **BLoC** architectures following best practices.  
Save time by scaffolding controllers, views, bindings, models, and repositories with a single command.

---
**Installation directly from GitHub:**

```bash
dart pub global activate -sgit https://github.com/arpitmurait/murait_cli.git
```
After installation, they can use the `murait_cli` command from anywhere on their system, just like you do locally:

```bash
murait_cli create my_awesome_app
cd my_new_project
murait_cli add screen home --with-repo --with-model
```

## 🚀 _Installation_

### Local Run
Run directly without installing globally:

```bash
dart run bin/murait_cli.dart make:getx home
dart /Users/mac/Documents/cli/murait_cli/bin/murait_cli.dart  make:getx home2 --with-model --with-repo
```

### Global Installation
Activate globally so you can run from anywhere:

```bash
dart pub global activate --source path ./murait_cli
```

Now you can use it like any CLI:

```bash
murait_cli make:getx home
```

---

## 🛠️ Commands

### Generate **GetX** Module
```bash
murait_cli make:getx <feature>
```

👉 Example:
```bash
murait_cli make:getx home
```

Creates:
```
lib/app/modules/home/
 ├─ controllers/home_controller.dart
 ├─ bindings/home_binding.dart
 └─ views/home_view.dart
```

---

### Generate **GetX** Module with Model + Repository
```bash
murait_cli make:getx <feature> --with-model --with-repo
```

👉 Example:
```bash
murait_cli make:getx user --with-model --with-repo
```

Creates:
```
lib/app/modules/user/
 ├─ controllers/user_controller.dart
 ├─ bindings/user_binding.dart
 ├─ views/user_view.dart
 ├─ models/user_model.dart
 └─ repositories/user_repository.dart
```

---

### Generate **BLoC** Module
```bash
murait_cli make:bloc <feature>
```

👉 Example:
```bash
murait_cli make:bloc auth
```

Creates:
```
lib/app/modules/auth/
 ├─ bloc/auth_bloc.dart
 ├─ bloc/auth_event.dart
 ├─ bloc/auth_state.dart
 └─ view/auth_view.dart
```

---

### Generate **BLoC** Module with Model + Repository
```bash
murait_cli make:bloc <feature> --with-model --with-repo
```

👉 Example:
```bash
murait_cli make:bloc product --with-model --with-repo
```

Creates:
```
lib/app/modules/product/
 ├─ bloc/product_bloc.dart
 ├─ bloc/product_event.dart
 ├─ bloc/product_state.dart
 ├─ view/product_view.dart
 ├─ models/product_model.dart
 └─ repositories/product_repository.dart
```

---

## ⚡ Utilities

The CLI automatically:
- Formats names into **PascalCase, snake_case, kebab-case** as needed.
- Ensures valid Dart class names.
- Creates missing directories automatically.

---

## 📖 Usage Help
Run without arguments to see usage:

```bash
murait_cli
```

Output:
```
Usage:
  murait_cli make:getx <feature> [--with-model] [--with-repo]
  murait_cli make:bloc <feature> [--with-model] [--with-repo]
```

---

## 📌 Roadmap
- [ ] Add Service & Provider generators
- [ ] Support Clean Architecture layers
- [ ] Interactive prompts (`murait_cli new module`)

---

## 👨‍💻 Author
**Arpit Murait** – Flutter Expert  
📧 Contact: arpit.murait@example.com  
