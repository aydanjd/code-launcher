# Code Launcher V17

A menu-driven development launcher for macOS and Apple Silicon. Quickly access coding workspaces, launch language tools, check your development environment, and manage your programming workflow from one place.

## Features

- **Dev Doctor** — Check installed development tools, versions, and PATH configuration.
- **Language Hub** — Access supported language environments and development workspaces.
- **Organized workspaces** — Keep projects grouped by language.
- **Go workspace setup** — Optionally initialize a Go module with `go mod init`.
- **Rust workspace setup** — Optionally initialize a Rust package with `cargo init`.
- **Interactive terminal menu** — Navigate development tools without remembering every command.
- **Backup directory** — Keep development-related backups organized.
- **Shell integration** — Optionally launch the menu automatically in interactive Zsh sessions.

## Requirements

- macOS
- Zsh
- Apple Silicon recommended
- Git and Homebrew recommended for managing development tools
- Programming language toolchains installed as needed

The launcher can check for tools, but selecting a language does not necessarily install that language's compiler or runtime.

## Workspace Directories

The launcher uses these directories by default:

| Directory | Purpose |
|---|---|
| `~/CodeProjects` | General coding projects |
| `~/CodeBackups` | Backups |
| `~/CWorkspace` | C projects |
| `~/CppWorkspace` | C++ projects |

Additional language workspaces may be available through the Language Hub.

## Installation

### 1. Clone the repository

```zsh
mkdir -p ~/CodeProjects
cd ~/CodeProjects
git clone https://github.com/aydanjd/code-launcher.git CodeLauncher
```

If you already have the repository, update it instead:

```zsh
cd ~/CodeProjects/CodeLauncher
git switch main
git pull origin main
```

### 2. Make the launcher executable

```zsh
chmod +x ~/CodeProjects/CodeLauncher/code.sh
```

### 3. Set up your main `code.sh`

Back up an existing launcher before replacing it:

```zsh
if [[ -f ~/code.sh ]]; then
    cp ~/code.sh ~/code.sh.backup
fi

cp ~/CodeProjects/CodeLauncher/code.sh ~/code.sh
chmod +x ~/code.sh
```

### 4. Check shell syntax

```zsh
zsh -n ~/code.sh
```

If the command returns no errors, the script passed the Zsh syntax check.

### 5. Launch Code Launcher

```zsh
~/code.sh
```

## Dev Doctor

Use **Dev Doctor** from the launcher menu to inspect your development environment.

Depending on the checks implemented in the current version, it can help identify:

- Available compilers and interpreters
- Installed tool versions
- Missing commands
- PATH configuration issues
- Development utilities that may need attention

Dev Doctor is intended as a diagnostic tool. A reported issue may require installing a dependency or adjusting your shell configuration.

## Language Hub

Use **Language Hub** to access supported programming language environments and workspaces.

The broader development setup includes languages and tools such as:

- C and C++
- Go
- Rust
- Perl
- Python
- Java
- JavaScript and Node.js
- Swift
- Ruby
- PHP
- Julia
- Zig
- Nim
- Elixir and Erlang
- Kotlin
- Scala
- Dart
- Lua
- R

The exact actions available in the menu depend on the current script version and which tools are installed.

### Go Workspace

When offered, the launcher can initialize a Go module using:

```zsh
go mod init example.com/myproject
```

Replace the example module path with one appropriate for your project.

### Rust Workspace

When offered, the launcher can initialize a Rust package using:

```zsh
cargo init
```

Review the generated files before beginning development.

## Shell Integration

To launch Code Launcher automatically when opening an interactive Zsh session, add the following block to `~/.zshrc`:

```zsh
# CODE LAUNCHER V17 AUTO-START
if [[ -o interactive && -z "$CODE_LAUNCHER_STARTED" ]]; then
    export CODE_LAUNCHER_STARTED=1
    "$HOME/CodeProjects/CodeLauncher/code.sh"
fi
```

Then reload your shell configuration:

```zsh
source ~/.zshrc
```

To stop automatic startup, remove or comment out the block in `~/.zshrc`.

## Troubleshooting

### The launcher does not start

Check permissions and syntax:

```zsh
chmod +x ~/code.sh
zsh -n ~/code.sh
```

### A language command is missing

Check whether the tool is installed:

```zsh
command -v go
command -v rustc
command -v perl
command -v python3
```

Replace the example commands with the tool you need to troubleshoot.

### A tool works in one terminal but not another

Check your PATH:

```zsh
echo "$PATH"
```

Some package managers install tools outside the default PATH. Follow the relevant tool's installation instructions before changing your shell configuration.

### Restore the previous launcher

If you created the backup shown in the installation instructions, restore it with:

```zsh
cp ~/code.sh.backup ~/code.sh
chmod +x ~/code.sh
```

Use the actual backup filename you created if it differs.

## Safety and Project Data

- Review commands before running them.
- Back up important project files before major changes.
- Confirm prompts before allowing workspace initialization.
- Keep credentials, tokens, and private configuration out of version control.

## License

Check the repository for its current license and usage terms.

## Repository

[aydanjd/code-launcher](https://github.com/aydanjd/code-launcher)
\
