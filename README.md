# Code Launcher V17 — Ultimate Edition

**A terminal-based developer toolkit for macOS and Apple Silicon.**

Code Launcher V17 brings interactive programming environments, workspace management, compilation tools, system diagnostics, dependency setup, and local AI tools together in one convenient Zsh launcher.

---

## Features

### Development Center
Launch interactive programming environments directly from the main menu.

- **Interactive C** — Open the C programming environment.
- **Interactive C++** — Access the C++ development environment.
- **Interactive Python** — Launch the Python interpreter.
- **Interactive JavaScript** — Start the JavaScript environment.
- **Interactive Java** — Access the Java development environment.
- **Language Hub** — Open installed language shells and dedicated Go, Rust, Nim, and Zig workspaces.

### Workspace Tools
Tools for creating, compiling, and managing development projects.

- **C Workspace** — Access the C workspace.
- **C++ Workspace** — Access the C++ workspace.
- **Quick Compile & Run** — Compile and run supported code.
- **Project Creator** — Create development projects.
- **Workspace Manager** — Manage development workspaces.

### System & Developer Tools

- **System Dashboard** — Access system information.
- **btop Resource Monitor** — Monitor system resources in real time.
- **Developer Health Check** — Check aspects of your development environment.
- **Dev Doctor** — Read-only PATH and version checks for common compilers, interpreters, and developer tools, including Rust, Go, Perl, Ruby, PHP, Dart, Swift, Julia, Kotlin, Scala, Elixir, Erlang, Lua, R, Nim, and Zig.
- **Update Center** — Access launcher update tools.
- **Apple Silicon Diagnostics** — Run diagnostics for your Mac environment.

### Artificial Intelligence

- **Ollama AI Center** — Access the launcher's Ollama integration for local AI workflows.

### Dependency Setup

V17 introduces a guided dependency setup feature.

- Check development dependencies.
- Guide the user through installing supported dependencies.
- Use Homebrew where applicable.
- Help prepare the development environment.

The available dependencies and installation requirements depend on the selected tools and the system configuration.

---

## What's New in V17?

V17 introduces improvements focused on developer setup and launcher management.

- **Guided Dependency Setup** — A dedicated menu option for setting up development dependencies.
- **Startup Checks** — Check the development environment when the launcher starts.
- **Update Center Improvements** — Updated launcher maintenance workflows.
- **Guarded Ollama Controls** — Improved safeguards around Ollama management.
- **Developer Workflow Tools** — Programming environments, workspaces, compilation, and system diagnostics in one menu.

---

## Requirements

Code Launcher is designed for macOS, particularly Apple Silicon Macs.

Depending on the features you use, your environment may require:

- macOS
- Zsh
- Git
- Homebrew
- Python 3
- A C compiler
- A C++ compiler
- Node.js or another JavaScript runtime
- Java development tools
- Optional utilities such as `btop`
- Ollama for local AI features

**Note:** Not every dependency is required for every feature. Use the launcher's dependency setup and health-check options to help determine what your environment needs.

---

## Installation

### 1. Clone the repository

Open Terminal and run:

```zsh
git clone https://github.com/aydanjd/code-launcher.git
```

### 2. Enter the project directory

```zsh
cd code-launcher
```

### 3. Check the script syntax

```zsh
zsh -n code.sh
```

If the command produces no errors, Zsh has successfully parsed the script.

### 4. Make the launcher executable

```zsh
chmod +x code.sh
```

### 5. Start Code Launcher

```zsh
./code.sh
```

---

## Main Menu

Code Launcher V17 provides the following menu options:

| Option | Feature |
|---:|---|
| 1 | Interactive C |
| 2 | Interactive C++ |
| 3 | Interactive Python |
| 4 | Interactive JavaScript |
| 5 | Interactive Java |
| 6 | C Workspace |
| 7 | C++ Workspace |
| 8 | Quick Compile & Run |
| 9 | Project Creator |
| 10 | Workspace Manager |
| 11 | System Dashboard |
| 12 | btop — Live Resource Monitor |
| 13 | Developer Health Check |
| 14 | Update Center |
| 15 | Apple Silicon Diagnostics |
| 16 | Ollama AI Center |
| 17 | Continue in normal Zsh |
| 18 | Setup / Install Dependencies |
| 19 | Dev Doctor — Check toolchains |
| 20 | Language Hub — Open language shells/workspaces |

Select an option from the menu to access the corresponding feature.

---

## Updating

To retrieve the latest committed version from GitHub, navigate to your local repository and run:

```zsh
cd ~/CodeProjects/CodeLauncher
git pull origin main
```

Then check the script syntax:

```zsh
zsh -n code.sh
```

**Important:** If you have local changes, review them before updating so you don't lose work.

---

## Troubleshooting

### The launcher will not start

Check the script syntax:

```zsh
zsh -n code.sh
```

Ensure the script is executable:

```zsh
chmod +x code.sh
```

Then try:

```zsh
./code.sh
```

### A development tool is missing

Open the launcher and select:

**Option 18 — Setup / Install Dependencies**

Follow the prompts and review installation choices before confirming them.

### btop is unavailable

Check whether it is installed:

```zsh
command -v btop
```

If it is missing, use the dependency setup feature or install it through your preferred package-management method.

### Ollama is unavailable

Check whether the Ollama command is available:

```zsh
command -v ollama
```

The Ollama AI Center may require Ollama to be installed and configured before its features can work.

---

## Safety & Best Practices

- Review installation prompts before installing dependencies.
- Keep backups of important source files.
- Review code changes before committing them.
- Avoid running commands you do not understand.
- Keep your local repository synchronized with GitHub.
- Test launcher features after making changes.

---

## Project Roadmap

Potential areas for future improvements include:

- More programming language integrations.
- Expanded dependency detection.
- Additional workspace automation.
- Improved diagnostics and error reporting.
- Further improvements to Ollama management.
- Enhanced installation and update workflows.

These are possible future improvements, not promises of features already implemented.

---

## 📂 Repository

**GitHub:** https://github.com/aydanjd/code-launcher

**Main launcher:** `code.sh`

**Current version:** V17 — Ultimate Edition

---

## License

Check the repository for its license and applicable terms before redistributing or modifying the project.

---

**Code Launcher V17 — Your development tools, one terminal away.** 
