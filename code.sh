#!/bin/zsh
# ==================================================
# CODE LAUNCHER V17 - ULTIMATE EDITION
# macOS / Apple Silicon
# V17: guided dependency setup, startup checks, safer update center and guarded Ollama control
# ==================================================

export CODE_LAUNCHER_STARTED=1

# Prefer native Homebrew on Apple Silicon. If it is not installed, fall back
# to the common Intel Homebrew prefix. This helps GUI-launched Zsh sessions find
# `brew`, `gh`, `ollama`, and other Homebrew tools.
if [[ -x "/opt/homebrew/bin/brew" ]]; then
    export PATH="/opt/homebrew/bin:/opt/homebrew/sbin:$PATH"
elif [[ -x "/usr/local/bin/brew" ]]; then
    export PATH="/usr/local/bin:/usr/local/sbin:$PATH"
fi

PROJECTS="$HOME/CodeProjects"
BACKUPS="$HOME/CodeBackups"
C_WORKSPACE="$HOME/CWorkspace"
CPP_WORKSPACE="$HOME/CppWorkspace"

mkdir -p "$PROJECTS" "$BACKUPS" "$C_WORKSPACE" "$CPP_WORKSPACE"

# --------------------------------------------------
# COMMON FUNCTIONS
# --------------------------------------------------

pause() {
    echo
    read "reply?Press Enter to continue..."
}

header() {
    clear
    echo "=================================================="
    echo "             CODE LAUNCHER V17"
    echo "              ULTIMATE EDITION"
    echo "=================================================="
    echo
}

divider() {
    echo "--------------------------------------------------"
}

open_shell() {
    local directory="$1"

    mkdir -p "$directory"
    cd "$directory" || return

    echo "Workspace: $PWD"
    echo "Type 'exit' to return to the launcher."
    echo

    zsh
}

# --------------------------------------------------
# 1. INTERACTIVE C
# --------------------------------------------------

interactive_c() {
    header
    echo "INTERACTIVE C"
    divider

    if command -v clang >/dev/null 2>&1; then
        clang --version | head -n 1
    elif command -v gcc >/dev/null 2>&1; then
        gcc --version | head -n 1
    else
        echo "No C compiler found."
        echo "Install Apple's Command Line Tools with:"
        echo "xcode-select --install"
        pause
        return
    fi

    echo
    echo "Opening your C workspace."
    pause
    open_shell "$C_WORKSPACE"
}

# --------------------------------------------------
# 2. INTERACTIVE C++
# --------------------------------------------------

interactive_cpp() {
    header
    echo "INTERACTIVE C++"
    divider

    if command -v clang++ >/dev/null 2>&1; then
        clang++ --version | head -n 1
    elif command -v g++ >/dev/null 2>&1; then
        g++ --version | head -n 1
    else
        echo "No C++ compiler found."
        echo "Install Apple's Command Line Tools with:"
        echo "xcode-select --install"
        pause
        return
    fi

    echo
    echo "Opening your C++ workspace."
    pause
    open_shell "$CPP_WORKSPACE"
}

# --------------------------------------------------
# 3. INTERACTIVE PYTHON
# --------------------------------------------------

interactive_python() {
    if command -v python3 >/dev/null 2>&1; then
        python3
    else
        echo "Python 3 was not found."
        pause
    fi
}

# --------------------------------------------------
# 4. INTERACTIVE JAVASCRIPT
# --------------------------------------------------

interactive_javascript() {
    if command -v node >/dev/null 2>&1; then
        node
    else
        echo "Node.js was not found."
        pause
    fi
}

# --------------------------------------------------
# 5. INTERACTIVE JAVA
# --------------------------------------------------

interactive_java() {
    if command -v jshell >/dev/null 2>&1; then
        jshell
    else
        echo "jshell was not found."
        echo "Check your Java installation."
        pause
    fi
}

# --------------------------------------------------
# 8. QUICK COMPILE & RUN
# --------------------------------------------------

quick_compile() {
    header
    echo "QUICK COMPILE & RUN"
    divider
    echo "1. ~/main.c"
    echo "2. ~/main.cpp"
    echo "3. ~/main.py"
    echo "4. ~/main.js"
    echo "5. ~/Main.java"
    echo "6. Custom file path"
    echo "0. Back"
    echo

    read "choice?Choose a file: "

    local file=""

    case "$choice" in
        1) file="$HOME/main.c" ;;
        2) file="$HOME/main.cpp" ;;
        3) file="$HOME/main.py" ;;
        4) file="$HOME/main.js" ;;
        5) file="$HOME/Main.java" ;;
        6)
            read "file?Enter file path: "
            file="${file/#\~/$HOME}"
            ;;
        0) return ;;
        *)
            echo "Invalid choice."
            pause
            return
            ;;
    esac

    if [[ ! -f "$file" ]]; then
        echo "File not found: $file"
        pause
        return
    fi

    local tempdir
    tempdir="$(mktemp -d "${TMPDIR:-/tmp}/code-v17.XXXXXX")" || {
        echo "Could not create temporary directory."
        pause
        return
    }

    echo
    echo "Running: $file"
    divider

    case "$file" in
        *.c)
            if command -v clang >/dev/null 2>&1; then
                clang "$file" -o "$tempdir/program" &&
                    "$tempdir/program"
            elif command -v gcc >/dev/null 2>&1; then
                gcc "$file" -o "$tempdir/program" &&
                    "$tempdir/program"
            else
                echo "C compiler not found."
            fi
            ;;
        *.cpp|*.cc|*.cxx)
            if command -v clang++ >/dev/null 2>&1; then
                clang++ "$file" -o "$tempdir/program" &&
                    "$tempdir/program"
            elif command -v g++ >/dev/null 2>&1; then
                g++ "$file" -o "$tempdir/program" &&
                    "$tempdir/program"
            else
                echo "C++ compiler not found."
            fi
            ;;
        *.py)
            if command -v python3 >/dev/null 2>&1; then
                python3 "$file"
            else
                echo "Python 3 not found."
            fi
            ;;
        *.js)
            if command -v node >/dev/null 2>&1; then
                node "$file"
            else
                echo "Node.js not found."
            fi
            ;;
        *.java)
            if command -v javac >/dev/null 2>&1 &&
               command -v java >/dev/null 2>&1; then
                local classname
                classname="$(basename "$file" .java)"

                javac -d "$tempdir" "$file" &&
                    java -cp "$tempdir" "$classname"
            else
                echo "Java compiler/runtime not found."
            fi
            ;;
        *)
            echo "Unsupported file type."
            ;;
    esac

    local status=$?
    rm -rf "$tempdir"

    echo
    echo "Process finished with status: $status"
    pause
}

# --------------------------------------------------
# 9. PROJECT CREATOR
# --------------------------------------------------

project_creator() {
    header
    echo "PROJECT CREATOR"
    divider
    echo "Projects folder: $PROJECTS"
    echo
    echo "1. C"
    echo "2. C++"
    echo "3. Python"
    echo "4. JavaScript"
    echo "5. Java"
    echo "0. Back"
    echo

    read "choice?Choose project type: "

    [[ "$choice" == "0" ]] && return

    local filename=""
    local template=""

    case "$choice" in
        1)
            filename="main.c"
            template='#include <stdio.h>

int main(void) {
    printf("Hello, world!\n");
    return 0;
}'
            ;;
        2)
            filename="main.cpp"
            template='#include <iostream>

int main() {
    std::cout << "Hello, world!" << std::endl;
    return 0;
}'
            ;;
        3)
            filename="main.py"
            template='def main():
    print("Hello, world!")

if __name__ == "__main__":
    main()'
            ;;
        4)
            filename="main.js"
            template='console.log("Hello, world!");'
            ;;
        5)
            filename="Main.java"
            template='public class Main {
    public static void main(String[] args) {
        System.out.println("Hello, world!");
    }
}'
            ;;
        *)
            echo "Invalid choice."
            pause
            return
            ;;
    esac

    local name
    read "name?Project name: "

    # Replace spaces with underscores.
    name="${name// /_}"

    if [[ -z "$name" || "$name" == "." || "$name" == ".." ||
          "$name" == */* ]]; then
        echo "Invalid project name."
        pause
        return
    fi

    local destination="$PROJECTS/$name"

    if [[ -e "$destination" ]]; then
        echo "Project already exists:"
        echo "$destination"
        echo "Refusing to overwrite it."
        pause
        return
    fi

    if ! mkdir "$destination"; then
        echo "Could not create project directory."
        pause
        return
    fi

    print -r -- "$template" > "$destination/$filename"

    cat > "$destination/README.md" <<'README'
# Coding Project

Created with Code Launcher V17.

Edit the starter file and use Quick Compile & Run
or the appropriate compiler/interpreter to run it.
README

    echo
    echo "Project created successfully!"
    echo "Location: $destination"
    echo "Starter file: $filename"
    pause
}

# --------------------------------------------------
# 10. WORKSPACE MANAGER
# --------------------------------------------------

workspace_manager() {
    while true; do
        header
        echo "WORKSPACE MANAGER"
        divider
        echo "Projects: $PROJECTS"
        echo "Backups:  $BACKUPS"
        echo
        echo "PROJECTS"
        divider

        local found=0
        local item

        for item in "$PROJECTS"/*(N/); do
            echo "  ${item:t}"
            found=1
        done

        [[ "$found" == "0" ]] && echo "  No projects yet."

        echo
        echo "1. Open a project in Zsh"
        echo "2. Back up a project"
        echo "3. Open projects folder in Finder"
        echo "4. Open backups folder in Finder"
        echo "0. Back"
        echo

        read "choice?Choose an option: "

        case "$choice" in
            1)
                read "name?Project folder name: "
                local target="$PROJECTS/$name"

                if [[ -d "$target" ]]; then
                    open_shell "$target"
                else
                    echo "Project not found."
                    pause
                fi
                ;;
            2)
                read "name?Project folder name to back up: "
                local target="$PROJECTS/$name"

                if [[ ! -d "$target" ]]; then
                    echo "Project not found."
                    pause
                    continue
                fi

                local stamp
                stamp="$(date '+%Y%m%d-%H%M%S')"

                local archive="$BACKUPS/${name}-${stamp}.tar.gz"

                if tar -czf "$archive" -C "$PROJECTS" "$name"; then
                    echo "Backup created:"
                    echo "$archive"
                else
                    echo "Backup failed."
                fi

                pause
                ;;
            3)
                open "$PROJECTS"
                ;;
            4)
                open "$BACKUPS"
                ;;
            0)
                return
                ;;
            *)
                echo "Invalid choice."
                pause
                ;;
        esac
    done
}

# --------------------------------------------------
# 11. SYSTEM DASHBOARD
# --------------------------------------------------

system_dashboard() {
    header
    echo "SYSTEM DASHBOARD"
    divider

    echo "MAC MODEL AND HARDWARE"
    divider

    system_profiler SPHardwareDataType 2>/dev/null |
        grep -E 'Model Name|Model Identifier|Chip|Total Number of Cores|Memory'

    echo
    echo "MACOS VERSION"
    divider
    sw_vers

    echo
    echo "CPU ARCHITECTURE"
    divider
    uname -m

    echo
    echo "MEMORY STATISTICS"
    divider
    vm_stat

    echo
    echo "STORAGE"
    divider
    df -h "$HOME"

    echo
    echo "UPTIME"
    divider
    uptime

    echo
    echo "DEVELOPER TOOLS"
    divider

    local tool
    for tool in clang clang++ python3 node java javac git brew; do
        if command -v "$tool" >/dev/null 2>&1; then
            printf '%-12s %s\n' "$tool" "$(command -v "$tool")"
        else
            printf '%-12s %s\n' "$tool" "not found"
        fi
    done

    pause
}

# --------------------------------------------------
# 13. DEVELOPER HEALTH CHECK
# --------------------------------------------------

developer_health() {
    header
    echo "DEVELOPER HEALTH CHECK"
    divider

    local passed=0
    local failed=0
    local skipped=0
    local tempdir

    tempdir="$(mktemp -d "${TMPDIR:-/tmp}/health-v17.XXXXXX")" || {
        echo "Could not create temporary test directory."
        pause
        return
    }

    # C test
    if command -v clang >/dev/null 2>&1; then
        cat > "$tempdir/test.c" <<'TEST'
#include <stdio.h>
int main(void) {
    puts("C OK");
    return 0;
}
TEST

        if clang "$tempdir/test.c" -o "$tempdir/test-c" &&
           "$tempdir/test-c" >/dev/null; then
            echo "[PASS] C compile and run"
            (( passed++ ))
        else
            echo "[FAIL] C compile and run"
            (( failed++ ))
        fi
    else
        echo "[SKIP] C compiler not found"
        (( skipped++ ))
    fi

    # C++ test
    if command -v clang++ >/dev/null 2>&1; then
        cat > "$tempdir/test.cpp" <<'TEST'
#include <iostream>
int main() {
    std::cout << "C++ OK\n";
    return 0;
}
TEST

        if clang++ "$tempdir/test.cpp" -o "$tempdir/test-cpp" &&
           "$tempdir/test-cpp" >/dev/null; then
            echo "[PASS] C++ compile and run"
            (( passed++ ))
        else
            echo "[FAIL] C++ compile and run"
            (( failed++ ))
        fi
    else
        echo "[SKIP] C++ compiler not found"
        (( skipped++ ))
    fi

    # Python test
    if command -v python3 >/dev/null 2>&1; then
        if python3 -c 'print("Python OK")' >/dev/null; then
            echo "[PASS] Python run"
            (( passed++ ))
        else
            echo "[FAIL] Python run"
            (( failed++ ))
        fi
    else
        echo "[SKIP] Python not found"
        (( skipped++ ))
    fi

    # JavaScript test
    if command -v node >/dev/null 2>&1; then
        if node -e 'console.log("JavaScript OK")' >/dev/null; then
            echo "[PASS] JavaScript run"
            (( passed++ ))
        else
            echo "[FAIL] JavaScript run"
            (( failed++ ))
        fi
    else
        echo "[SKIP] Node.js not found"
        (( skipped++ ))
    fi

    # Java test
    if command -v javac >/dev/null 2>&1 &&
       command -v java >/dev/null 2>&1; then
        cat > "$tempdir/HealthTest.java" <<'TEST'
public class HealthTest {
    public static void main(String[] args) {
        System.out.println("Java OK");
    }
}
TEST

        if javac -d "$tempdir" "$tempdir/HealthTest.java" &&
           java -cp "$tempdir" HealthTest >/dev/null; then
            echo "[PASS] Java compile and run"
            (( passed++ ))
        else
            echo "[FAIL] Java compile and run"
            (( failed++ ))
        fi
    else
        echo "[SKIP] Java compiler/runtime not found"
        (( skipped++ ))
    fi

    rm -rf "$tempdir"

    echo
    divider
    echo "Passed:  $passed"
    echo "Failed:  $failed"
    echo "Skipped: $skipped"

    pause
}

# --------------------------------------------------
# 15. UPDATE CENTER
# --------------------------------------------------

update_center() {
    local choice failed formula cask confirm_all

    # Inventory Homebrew updates first, then ask before changing packages.
    _v16_uc_brew() {
        local confirm greedy_confirm
        if ! command -v brew >/dev/null 2>&1; then
            echo "Homebrew not found on PATH."
            echo "Checked common Apple Silicon and Intel Homebrew paths at launcher startup."
            echo "Install Homebrew or fix PATH, then reopen the launcher."
            return 1
        fi

        echo
        echo "Homebrew: $(command -v brew)"
        echo "Prefix: $(brew --prefix 2>/dev/null)"
        echo
        echo "Refreshing Homebrew package metadata..."
        brew update || return 1

        echo
        echo "OUTDATED FORMULAE"
        echo "--------------------------------------------------"
        brew outdated --formula --verbose
        local formula_status=$?
        if (( formula_status != 0 )); then
            echo "Could not fully query outdated formulae (exit $formula_status)."
        fi

        echo
        echo "OUTDATED CASKS (standard updates)"
        echo "--------------------------------------------------"
        brew outdated --cask --verbose
        local cask_status=$?
        if (( cask_status != 0 )); then
            echo "Could not fully query outdated casks (exit $cask_status)."
        fi
        echo
        echo "CASKS ONLY VISIBLE WITH --greedy (auto_updates/latest casks)"
        echo "--------------------------------------------------"
        brew outdated --cask --greedy --verbose

        echo
        echo "This can update many packages and GUI apps."
        if [[ "$1" == "--confirmed" ]]; then
            confirm="y"
            echo "Using the confirmation already given in Update Everything."
        else
            read "confirm?Upgrade all outdated Homebrew formulae and casks? (y/N): "
        fi
        if [[ "$confirm" == [yY] || "$confirm" == [yY][eE][sS] ]]; then
            echo
            echo "Upgrading outdated Homebrew packages..."
            brew upgrade || return 1
            echo
            echo "Homebrew upgrade command completed."
            read "greedy_confirm?Also upgrade casks marked auto_updates/latest using --greedy? (y/N): "
            if [[ "$greedy_confirm" == [yY] || "$greedy_confirm" == [yY][eE][sS] ]]; then
                brew upgrade --cask --greedy || return 1
            else
                echo "Greedy cask upgrades skipped."
            fi
            echo
            echo "Rechecking remaining outdated packages..."
            brew outdated --greedy --verbose
        else
            echo "Homebrew upgrades skipped; inventory completed."
        fi
    }

    # Cleanup is separate so cached downloads are never removed automatically.
    _v16_uc_cleanup() {
        local confirm
        if ! command -v brew >/dev/null 2>&1; then
            echo "Homebrew not found."
            return 1
        fi
        echo
        echo "Homebrew cleanup removes old package versions and cached downloads."
        echo "It does not uninstall currently installed formulae or casks, but it may remove rollback files."
        read "confirm?Run brew cleanup now? (y/N): "
        if [[ "$confirm" == [yY] || "$confirm" == [yY][eE][sS] ]]; then
            brew cleanup
        else
            echo "Cleanup cancelled."
        fi
    }

    # Homebrew health checks and installed-package inventory; no changes made.
    _v16_uc_brew_diagnostics() {
        if ! command -v brew >/dev/null 2>&1; then
            echo "Homebrew not found on PATH."
            return 1
        fi
        echo
        echo "HOMEBREW DIAGNOSTICS"
        echo "--------------------------------------------------"
        echo "Executable: $(command -v brew)"
        echo "Prefix: $(brew --prefix 2>/dev/null)"
        brew --version
        echo
        echo "Installed formulae: $(brew list --formula 2>/dev/null | wc -l | tr -d ' ')"
        echo "Installed casks:    $(brew list --cask 2>/dev/null | wc -l | tr -d ' ')"
        echo
        echo "Outdated packages (including auto_updates/latest casks):"
        brew outdated --greedy --verbose
        echo
        echo "Running brew doctor (diagnostic only; warnings are not automatically fixed)..."
        brew doctor
    }

    # Update Node.js using its detected installation method.
    _v16_uc_node() {
        echo
        echo "Updating Node.js..."

        if typeset -f nvm >/dev/null 2>&1; then
            nvm install --lts && nvm use --lts || return 1
        elif command -v fnm >/dev/null 2>&1; then
            fnm install --lts || return 1
            fnm default lts-latest || return 1
        elif command -v volta >/dev/null 2>&1; then
            volta install node@lts || return 1
        elif command -v brew >/dev/null 2>&1 &&
             brew list --formula 2>/dev/null | grep -qx 'node'; then
            brew upgrade node || return 1
        elif command -v node >/dev/null 2>&1; then
            echo "Node.js is installed, but its package manager was not identified."
            echo "Update it using the manager that installed it."
        else
            echo "Node.js not found. Skipping."
        fi

        if command -v node >/dev/null 2>&1; then
            echo
            node --version
            npm --version 2>/dev/null || true
        fi
    }

    # Upgrade Homebrew-managed Python and pip only in an active venv.
    _v16_uc_python() {
        echo
        echo "Updating Python..."

        if command -v brew >/dev/null 2>&1; then
            for formula in ${(f)"$(brew list --formula 2>/dev/null)"}; do
                if [[ "$formula" == "python" || "$formula" == python@* ]]; then
                    brew upgrade "$formula" || return 1
                fi
            done
        fi

        if command -v python3 >/dev/null 2>&1; then
            python3 --version

            if [[ -n "${VIRTUAL_ENV:-}" ]]; then
                echo "Updating pip in the active virtual environment..."
                python3 -m pip install --upgrade pip || return 1
            else
                echo "No virtual environment is active."
                echo "Skipping a global pip upgrade to protect managed Python installations."
                echo "Activate your project venv and run option 4 again to update its pip."
            fi
        else
            echo "Python 3 not found. Skipping."
        fi
    }

    # Upgrade Java distributions installed as known Homebrew casks.
    _v16_uc_java() {
        echo
        echo "Checking Java / JDK..."

        if command -v brew >/dev/null 2>&1; then
            for cask in ${(f)"$(brew list --cask 2>/dev/null)"}; do
                if [[ "$cask" == temurin || "$cask" == temurin@* ||
                      "$cask" == zulu || "$cask" == corretto ||
                      "$cask" == oracle-jdk || "$cask" == oracle-jdk@* ]]; then
                    echo "Upgrading JDK cask: $cask"
                    brew upgrade --cask "$cask" || return 1
                fi
            done
        fi

        if command -v java >/dev/null 2>&1; then
            java -version
        else
            echo "Java not found."
        fi

        if command -v javac >/dev/null 2>&1; then
            javac -version
        else
            echo "Java compiler (javac) not found."
        fi
    }

    # Upgrade installed C/C++ build tools managed by Homebrew.
    _v16_uc_cpp() {
        echo
        echo "Updating C/C++ tools..."

        if ! command -v brew >/dev/null 2>&1; then
            echo "Homebrew not found. Skipping."
            return 0
        fi

        for formula in llvm cmake ninja; do
            if brew list --formula 2>/dev/null | grep -qx "$formula"; then
                echo "Upgrading $formula..."
                brew upgrade "$formula" || return 1
            else
                echo "$formula is not installed; skipping."
            fi
        done

        echo
        echo "Apple Clang version:"
        if command -v clang >/dev/null 2>&1; then
            clang --version | head -n 1
        else
            echo "Clang not found."
        fi

        if command -v xcode-select >/dev/null 2>&1; then
            xcode-select -p 2>/dev/null || echo "Command Line Tools not configured."
        fi
    }

    # Update npm-managed global JavaScript developer packages.
    _v16_uc_js() {
        echo
        echo "Updating JavaScript developer tools..."

        if command -v npm >/dev/null 2>&1; then
            npm update -g || return 1
            echo "Global npm packages updated."
        else
            echo "npm not found. Skipping."
        fi

        if command -v corepack >/dev/null 2>&1; then
            echo
            echo "Corepack is available. Package-manager versions were not changed automatically."
        fi
    }

    # Update extensions through the VS Code command-line interface.
    _v16_uc_vscode() {
        echo
        echo "Updating VS Code extensions..."

        if command -v code >/dev/null 2>&1; then
            code --update-extensions
        else
            echo "VS Code CLI 'code' was not found."
            echo "Open VS Code and enable its shell command if needed."
        fi
    }

    # Display installed development-tool versions.
    _v16_uc_versions() {
        echo
        echo "DEVELOPMENT TOOL VERSIONS"
        echo "--------------------------------------------------"

        local tool
        for tool in brew gh ollama btop node npm python3 pip3 java javac clang clang++ cmake code; do
            if command -v "$tool" >/dev/null 2>&1; then
                echo
                echo "[$tool]"
                case "$tool" in
                    brew)    brew --version | head -n 1 ;;
                    gh)      gh --version | head -n 1 ;;
                    ollama)  ollama --version 2>&1 | head -n 1 ;;
                    btop)    btop --version 2>&1 | head -n 1 ;;
                    node)    node --version ;;
                    npm)     npm --version ;;
                    python3) python3 --version ;;
                    pip3)    pip3 --version ;;
                    java)    java -version 2>&1 ;;
                    javac)   javac -version 2>&1 ;;
                    clang)   clang --version | head -n 1 ;;
                    clang++) clang++ --version | head -n 1 ;;
                    cmake)   cmake --version | head -n 1 ;;
                    code)    code --version | head -n 1 ;;
                esac
            else
                echo
                echo "[$tool] Not found"
            fi
        done
    }

    # List macOS updates without installing them.
    _v16_uc_macos() {
        echo
        echo "Checking for macOS software updates..."
        echo "Updates will NOT be installed automatically."
        echo

        if command -v softwareupdate >/dev/null 2>&1; then
            softwareupdate --list
        else
            echo "The softwareupdate command is unavailable."
        fi
    }

    while true; do
        header
        echo "UPDATE CENTER"
        divider
        echo " 1. Update EVERYTHING"
        echo " 2. Update Homebrew packages"
        echo " 3. Update Node.js & npm"
        echo " 4. Update Python & pip"
        echo " 5. Update Java / JDK"
        echo " 6. Update C/C++ tools"
        echo " 7. Update JavaScript developer tools"
        echo " 8. Update VS Code extensions"
        echo " 9. Check all development versions (including gh / Ollama / btop)"
        echo "10. Check macOS software updates"
        echo "11. Homebrew diagnostics (brew doctor; no automatic fixes)"
        echo "12. Homebrew cleanup (asks before removing old caches)"
        echo "13. Check GitHub CLI / Ollama / btop PATH and versions"
        echo " 0. Back"
        divider
        echo

        read "choice?Choose an option: "

        case "$choice" in
            1)
                echo
                echo "This updates installed Homebrew packages, selected language runtimes,"
                echo "global npm packages, and VS Code extensions."
                echo "It does not install missing tools or install macOS system updates."
                read "confirm_all?Run the full developer-tool update sequence? (y/N): "
                if [[ "$confirm_all" != [yY] && "$confirm_all" != [yY][eE][sS] ]]; then
                    echo "Full update cancelled."
                    pause
                    continue
                fi

                failed=0
                echo
                echo "Starting UPDATE EVERYTHING..."
                echo "Some steps may require administrator approval."
                echo

                _v16_uc_brew --confirmed || failed=1
                _v16_uc_node   || failed=1
                _v16_uc_python || failed=1
                _v16_uc_java   || failed=1
                _v16_uc_cpp    || failed=1
                _v16_uc_js     || failed=1
                _v16_uc_vscode || failed=1

                echo
                if (( failed == 0 )); then
                    echo "Update sequence finished. Review any skipped tools above."
                else
                    echo "Update sequence finished with one or more errors."
                    echo "Review the messages above before continuing."
                fi
                pause
                ;;
            2)
                _v16_uc_brew
                pause
                ;;
            3)
                _v16_uc_node
                if command -v npm >/dev/null 2>&1; then
                    echo
                    echo "Updating npm..."
                    npm install -g npm@latest
                fi
                pause
                ;;
            4)
                _v16_uc_python
                pause
                ;;
            5)
                _v16_uc_java
                pause
                ;;
            6)
                _v16_uc_cpp
                pause
                ;;
            7)
                _v16_uc_js
                pause
                ;;
            8)
                _v16_uc_vscode
                pause
                ;;
            9)
                _v16_uc_versions
                pause
                ;;
            10)
                _v16_uc_macos
                pause
                ;;
            11)
                _v16_uc_brew_diagnostics
                pause
                ;;
            12)
                _v16_uc_cleanup
                pause
                ;;
            13)
                echo
                echo "CLI TOOL PATH CHECK"
                echo "--------------------------------------------------"
                for tool in brew gh ollama btop; do
                    if command -v "$tool" >/dev/null 2>&1; then
                        printf '%-8s %s\n' "$tool" "$(command -v "$tool")"
                    else
                        printf '%-8s %s\n' "$tool" "NOT FOUND on PATH"
                    fi
                done
                echo
                if command -v gh >/dev/null 2>&1; then
                    gh --version | head -n 1
                    gh auth status 2>&1 || true
                else
                    echo "GitHub CLI missing. If Homebrew is available, install with: brew install gh"
                fi
                if command -v ollama >/dev/null 2>&1; then
                    ollama --version 2>&1 | head -n 1
                fi
                if command -v btop >/dev/null 2>&1; then
                    btop --version 2>&1 | head -n 1
                fi
                pause
                ;;
            0)
                return
                ;;
            *)
                echo "Invalid choice."
                pause
                ;;
        esac
    done
}


# 15. APPLE SILICON DIAGNOSTICS
# --------------------------------------------------

apple_diagnostics() {
    header
    echo "APPLE SILICON DIAGNOSTICS"
    divider

    echo "CPU architecture:"
    uname -m

    echo
    echo "macOS version:"
    sw_vers

    echo
    echo "HARDWARE INFORMATION"
    divider

    system_profiler SPHardwareDataType 2>/dev/null |
        grep -E 'Model Name|Model Identifier|Chip|Total Number of Cores|Memory'

    echo
    echo "ROSETTA STATUS"
    divider

    if [[ "$(uname -m)" == "arm64" ]]; then
        echo "Shell reports native Apple Silicon architecture."
    else
        echo "Shell reports: $(uname -m)"
    fi

    if /usr/sbin/sysctl -in sysctl.proc_translated >/dev/null 2>&1; then
        if [[ "$(/usr/sbin/sysctl -in sysctl.proc_translated)" == "1" ]]; then
            echo "Current process is translated through Rosetta."
        else
            echo "Current process is not translated through Rosetta."
        fi
    else
        echo "Rosetta translation status is unavailable."
    fi

    echo
    echo "HOMEBREW"
    divider

    if command -v brew >/dev/null 2>&1; then
        echo "Location: $(command -v brew)"
        echo "Prefix: $(brew --prefix)"
        brew --version | head -n 1
    else
        echo "Homebrew not found."
    fi

    echo
    echo "DEVELOPER DIRECTORY"
    divider
    xcode-select -p 2>/dev/null || echo "Not configured"

    pause
}


# ------------------------------------------------------------
# OLLAMA AI CENTER
# ------------------------------------------------------------

# Stop only the process listening on Ollama's API port, after verifying its command.
# Never use broad pkill patterns: they can terminate unrelated Ollama processes.
ollama_stop_listener() {
    local pids pid process_cmd still_running

    if ! command -v lsof >/dev/null 2>&1; then
        echo "Cannot safely identify the Ollama listener because lsof is unavailable."
        return 1
    fi

    pids="$(lsof -nP -iTCP:11434 -sTCP:LISTEN -t 2>/dev/null | sort -u)"
    if [[ -z "$pids" ]]; then
        echo "No process is listening on port 11434."
        return 0
    fi

    # Verify every candidate before sending any signal.
    for pid in ${(f)pids}; do
        [[ "$pid" == <-> ]] || continue
        process_cmd="$(ps -p "$pid" -o command= 2>/dev/null)"
        if [[ "${process_cmd:l}" != *ollama* ]]; then
            echo "Refusing to stop PID $pid: listener command is not clearly Ollama."
            echo "Command: ${process_cmd:-unavailable}"
            return 1
        fi
    done

    for pid in ${(f)pids}; do
        [[ "$pid" == <-> ]] || continue
        echo "Sending a normal termination signal to Ollama listener PID $pid."
        kill "$pid" 2>/dev/null || {
            echo "Could not send termination signal to PID $pid."
            return 1
        }
    done

    # Give the process time to exit; never escalate to SIGKILL automatically.
    for _ in {1..5}; do
        still_running=0
        for pid in ${(f)pids}; do
            [[ "$pid" == <-> ]] || continue
            if kill -0 "$pid" 2>/dev/null; then
                still_running=1
            fi
        done
        (( still_running == 0 )) && break
        sleep 1
    done

    if (( still_running != 0 )); then
        echo "Ollama listener is still running. No force-kill was attempted."
        return 1
    fi
    return 0
}

ollama_server_manager() {
    local choice confirm listener_pids
    local log_file="$HOME/Library/Logs/ollama-code-launcher.log"

    while true; do
        echo
        echo "================================================================"
        echo "                    OLLAMA SERVER MANAGER"
        echo "================================================================"
        echo "  1. Start Ollama server"
        echo "  2. Stop Ollama server"
        echo "  3. Restart Ollama server"
        echo "  4. Check server status"
        echo "  5. Show running models"
        echo "  6. View launcher server logs"
        echo "  0. Back to Ollama AI Center"
        echo "================================================================"
        read "choice?Choose an option: "

        case "$choice" in
            1)
                if curl -fsS --max-time 2 \
                    http://127.0.0.1:11434/api/tags >/dev/null 2>&1; then
                    echo "Ollama server is already responding."
                else
                    if [[ -d "/Applications/Ollama.app" ||
                          -d "$HOME/Applications/Ollama.app" ]]; then
                        open -a Ollama
                    else
                        if ! command -v ollama >/dev/null 2>&1; then
                            echo "Ollama CLI was not found on PATH."
                            echo "Install Ollama or fix PATH, then retry."
                            pause
                            continue
                        fi
                        mkdir -p "$HOME/Library/Logs"
                        nohup ollama serve > "$log_file" 2>&1 < /dev/null &
                        disown
                    fi

                    sleep 3
                    if curl -fsS --max-time 2 \
                        http://127.0.0.1:11434/api/tags >/dev/null 2>&1; then
                        echo "Ollama server is online."
                    else
                        echo "Server did not respond yet. Check option 6 for logs."
                    fi
                fi
                pause
                ;;

            2)
                listener_pids="$(lsof -nP -iTCP:11434 -sTCP:LISTEN -t 2>/dev/null | sort -u)"
                if [[ -z "$listener_pids" ]]; then
                    echo "No listener found on port 11434; Ollama server appears offline."
                    pause
                    continue
                fi

                echo "Stopping Ollama may interrupt active chats."
                read "confirm?Stop the Ollama API listener only? (y/N): "

                if [[ "$confirm" == [yY] || "$confirm" == [yY][eE][sS] ]]; then
                    if ollama_stop_listener; then
                        sleep 2
                        if curl -fsS --max-time 2 \
                            http://127.0.0.1:11434/api/tags >/dev/null 2>&1; then
                            echo "Ollama is still responding; the app may have restarted it."
                        elif [[ -n "$(lsof -nP -iTCP:11434 -sTCP:LISTEN -t 2>/dev/null)" ]]; then
                            echo "A listener remains on port 11434, but the API is not responding."
                        else
                            echo "Ollama server is offline."
                        fi
                    else
                        echo "Ollama stop was not completed safely."
                    fi
                else
                    echo "Cancelled."
                fi
                pause
                ;;

            3)
                echo "Restarting may interrupt active chats."
                read "confirm?Restart Ollama? (y/N): "

                if [[ "$confirm" == [yY] || "$confirm" == [yY][eE][sS] ]]; then
                    if ! ollama_stop_listener; then
                        echo "Restart cancelled because the existing listener could not be stopped safely."
                        pause
                        continue
                    fi
                    sleep 2

                    if [[ -d "/Applications/Ollama.app" ||
                          -d "$HOME/Applications/Ollama.app" ]]; then
                        open -a Ollama
                    else
                        if ! command -v ollama >/dev/null 2>&1; then
                            echo "Ollama CLI was not found on PATH. Restart cannot continue."
                            pause
                            continue
                        fi
                        mkdir -p "$HOME/Library/Logs"
                        nohup ollama serve > "$log_file" 2>&1 < /dev/null &
                        disown
                    fi

                    sleep 3
                    if curl -fsS --max-time 2 \
                        http://127.0.0.1:11434/api/tags >/dev/null 2>&1; then
                        echo "Ollama server is online."
                    else
                        echo "Restart not confirmed. Check option 6 for logs."
                    fi
                else
                    echo "Cancelled."
                fi
                pause
                ;;

            4)
                if curl -fsS --max-time 2 \
                    http://127.0.0.1:11434/api/tags >/dev/null 2>&1; then
                    echo "Server status: ONLINE"
                    echo "Address: http://127.0.0.1:11434"
                else
                    echo "Server status: OFFLINE or not responding"
                fi
                pause
                ;;

            5)
                ollama ps
                pause
                ;;

            6)
                if [[ -f "$log_file" ]]; then
                    tail -n 80 "$log_file"
                else
                    echo "No launcher-managed server log found."
                    echo "The Ollama app may manage its own logs."
                fi
                pause
                ;;

            0)
                return
                ;;

            *)
                echo "Invalid choice."
                pause
                ;;
        esac
    done
}

ollama_ai_center() {
    local choice model_choice model_name confirm i
    local -a models

    if ! command -v ollama >/dev/null 2>&1; then
        echo
        echo "Ollama is not installed or is not on your PATH."
        echo "Visit https://ollama.com to install Ollama."
        pause
        return
    fi

    while true; do
        echo
        echo "================================================================"
        echo "                       OLLAMA AI CENTER"
        echo "================================================================"
        echo
        echo "  1. Chat with an installed model"
        echo "  2. List installed models"
        echo "  3. Show running models"
        echo "  4. Check Ollama server status"
        echo "  5. Download a model"
        echo "  6. Ollama Server Manager"
        echo "  0. Back to Main Menu"
        echo
        echo "================================================================"
        read "choice?Choose an option: "

        case "$choice" in
            1)
                if ! ollama list >/dev/null 2>&1; then
                    echo
                    echo "Ollama server is not responding."
                    echo "Start the Ollama app, or run 'ollama serve' in another terminal."
                    pause
                    continue
                fi

                models=("${(@f)$(ollama list 2>/dev/null | awk 'NR > 1 {print $1}')}")

                if (( ${#models[@]} == 0 )); then
                    echo "No installed models found."
                    pause
                    continue
                fi

                echo
                echo "INSTALLED MODELS"
                echo "----------------------------------------------------------------"
                for (( i=1; i<=${#models[@]}; i++ )); do
                    echo " $i. ${models[$i]}"
                done
                echo " 0. Cancel"
                echo
                read "model_choice?Choose a model number: "

                if [[ "$model_choice" == <-> ]] &&
                   (( model_choice > 0 && model_choice <= ${#models[@]} )); then
                    model_name="${models[$model_choice]}"
                    echo
                    echo "Launching $model_name ..."
                    echo "Exit the model chat with /bye."
                    ollama run "$model_name"
                    echo
                    pause
                elif [[ "$model_choice" != "0" ]]; then
                    echo "Invalid model selection."
                    pause
                fi
                ;;

            2)
                echo
                if ! ollama list; then
                    echo "Could not list models. Check that the Ollama server is running."
                fi
                pause
                ;;

            3)
                echo
                if ! ollama ps; then
                    echo "Could not query running models. Check the Ollama server."
                fi
                pause
                ;;

            4)
                echo
                if curl -fsS --max-time 2 \
                    http://127.0.0.1:11434/api/tags >/dev/null 2>&1; then
                    echo "Ollama server is responding."
                    ollama list
                else
                    echo "Ollama server is not responding on 127.0.0.1:11434."
                    echo "Open the Ollama app, or run 'ollama serve' in another terminal."
                fi
                pause
                ;;

            5)
                echo
                echo "Enter the exact model name and tag, for example: gemma3:4b"
                read "model_name?Model to download (0 to cancel): "

                if [[ -z "$model_name" || "$model_name" == "0" ]]; then
                    continue
                fi

                echo
                echo "This may download several gigabytes."
                read "confirm?Download '$model_name'? (y/N): "

                if [[ "$confirm" == [yY] || "$confirm" == [yY][eE][sS] ]]; then
                    ollama pull "$model_name"
                else
                    echo "Download cancelled."
                fi
                pause
                ;;

            6)
                ollama_server_manager
                ;;

            0)
                return
                ;;

            *)
                echo "Invalid choice."
                pause
                ;;
        esac
    done
}

# ------------------------------------------------------------
# V17 DEPENDENCY SETUP
# ------------------------------------------------------------

v17_tool_available() {
    case "$1" in
        command_line_tools) xcode-select -p >/dev/null 2>&1 ;;
        *) command -v "$1" >/dev/null 2>&1 ;;
    esac
}

v17_dependency_check() {
    local tool missing=0
    echo "DEPENDENCY CHECK"
    divider
    for tool in brew git node npm python3 java javac clang clang++ btop ollama; do
        if v17_tool_available "$tool"; then
            printf '[OK]      %-12s %s\n' "$tool" "$(command -v "$tool")"
        else
            printf '[MISSING] %s\n' "$tool"
            (( missing++ ))
        fi
    done
    if v17_tool_available command_line_tools; then
        printf '[OK]      Apple Command Line Tools (%s)\n' "$(xcode-select -p 2>/dev/null)"
    else
        echo '[MISSING] Apple Command Line Tools'
        (( missing++ ))
    fi
    echo
    if (( missing > 0 )); then
        echo "$missing item(s) are missing. The check did not install or change anything."
        return 1
    fi
    echo 'All checked tools are available on PATH.'
    return 0
}

v17_install_homebrew() {
    local installer confirm
    if command -v brew >/dev/null 2>&1; then
        echo "Homebrew is already available: $(command -v brew)"
        return 0
    fi
    echo "Homebrew is missing. This downloads the official Homebrew installer script to a temporary file."
    echo "Review the script before running it; the installer may request administrator approval."
    read "confirm?Download the official installer from brew.sh? (y/N): "
    [[ "$confirm" == [yY] || "$confirm" == [yY][eE][sS] ]] || { echo 'Cancelled.'; return 1; }
    installer="$(mktemp "${TMPDIR:-/tmp}/homebrew-install.XXXXXX")" || return 1
    if ! curl -fL --proto '=https' --tlsv1.2 --max-time 120 \
        https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh -o "$installer"; then
        rm -f "$installer"
        echo 'Download failed; Homebrew was not installed.'
        return 1
    fi
    echo "Downloaded installer: $installer"
    echo "Inspect it with: less '$installer'"
    read "confirm?Run this downloaded Homebrew installer now? (y/N): "
    if [[ "$confirm" == [yY] || "$confirm" == [yY][eE][sS] ]]; then
        /bin/bash "$installer"
        local install_status=$?
        rm -f "$installer"
        if (( install_status != 0 )); then
            echo 'Homebrew installer reported an error. Review its output.'
            return "$install_status"
        fi
        if [[ -x /opt/homebrew/bin/brew ]]; then
            export PATH="/opt/homebrew/bin:/opt/homebrew/sbin:$PATH"
        elif [[ -x /usr/local/bin/brew ]]; then
            export PATH="/usr/local/bin:/usr/local/sbin:$PATH"
        fi
        command -v brew >/dev/null 2>&1 || {
            echo 'Homebrew may be installed, but brew is not yet on PATH. Follow Homebrew’s printed shell setup instructions.'
            return 1
        }
    else
        rm -f "$installer"
        echo 'Homebrew installation cancelled.'
        return 1
    fi
}

v17_setup_dependencies() {
    local choice confirm formula setup_result=0
    local -a formulas
    header
    echo 'V17 SETUP / INSTALL DEPENDENCIES'
    divider
    echo 'This checks first, skips tools already installed, and asks before making changes.'
    echo 'No package upgrades or global npm upgrades are performed.'
    echo
    v17_dependency_check || true
    echo
    echo 'Choose what to set up:'
    echo ' 1. Core developer tools (Git, Node.js/npm, Python 3, Java JDK)'
    echo ' 2. Apple Command Line Tools (C/C++ compilers)'
    echo ' 3. Optional tools (btop and Ollama)'
    echo ' 4. All of the above'
    echo ' 5. Re-run dependency check only'
    echo ' 0. Back'
    read 'choice?Choose an option: '
    case "$choice" in
        1) formulas=(git node python openjdk) ;;
        2)
            if v17_tool_available command_line_tools; then
                echo 'Apple Command Line Tools are already configured.'
                pause
                return
            fi
            echo 'macOS will open the Apple Command Line Tools installer. Complete it in the system dialog.'
            read "confirm?Run xcode-select --install? (y/N): "
            if [[ "$confirm" == [yY] || "$confirm" == [yY][eE][sS] ]]; then
                xcode-select --install
            else
                echo 'Cancelled.'
            fi
            pause
            return
            ;;
        3) formulas=(btop ollama) ;;
        4) formulas=(git node python openjdk btop ollama) ;;
        5) v17_dependency_check; pause; return ;;
        0) return ;;
        *) echo 'Invalid choice.'; pause; return ;;
    esac

    if ! command -v brew >/dev/null 2>&1; then
        echo 'Homebrew is required to install these packages.'
        v17_install_homebrew || { pause; return 1; }
    fi

    echo
    echo 'Selected package formulas:'
    for formula in "${formulas[@]}"; do
        case "$formula" in
            openjdk) v17_tool_available java && v17_tool_available javac && echo "  $formula (Java/JDK already detected)" || echo "  $formula" ;;
            *) v17_tool_available "$formula" && echo "  $formula (command already detected)" || echo "  $formula" ;;
        esac
    done
    echo
    echo 'Homebrew may download packages and dependencies. Review any prompts it displays.'
    read "confirm?Continue installing missing selected packages? (y/N): "
    if [[ "$confirm" != [yY] && "$confirm" != [yY][eE][sS] ]]; then
        echo 'Installation cancelled.'
        pause
        return
    fi

    for formula in "${formulas[@]}"; do
        case "$formula" in
            git|node|python|btop|ollama)
                local detected_command="$formula"
                [[ "$formula" == "python" ]] && detected_command="python3"
                if command -v "$detected_command" >/dev/null 2>&1; then
                    echo "Skipping $formula: $detected_command is already available."
                elif brew list --formula "$formula" >/dev/null 2>&1; then
                    echo "$formula is installed in Homebrew; checking PATH after installation."
                else
                    echo "Installing $formula..."
                    brew install "$formula" || setup_result=1
                fi
                ;;
            openjdk)
                if command -v java >/dev/null 2>&1 && command -v javac >/dev/null 2>&1; then
                    echo 'Skipping openjdk: java and javac are already available.'
                elif brew list --formula openjdk >/dev/null 2>&1; then
                    echo 'openjdk is already installed by Homebrew; it may need PATH/JAVA_HOME setup.'
                else
                    echo 'Installing openjdk...'
                    brew install openjdk || setup_result=1
                    echo 'Note: Homebrew may print extra PATH or symlink instructions for openjdk; follow its output if java/javac are not found.'
                fi
                ;;
        esac
    done
    echo
    echo 'POST-INSTALL CHECK'
    divider
    v17_dependency_check || true
    if (( setup_result == 0 )); then
        echo 'Setup commands completed. Review any PATH instructions above.'
    else
        echo 'One or more installs failed. Review Homebrew output and retry the missing package.'
    fi
    pause
}

v17_startup_check() {
    local choice
    # Startup check is informational and never installs anything automatically.
    if ! command -v git >/dev/null 2>&1 || ! command -v node >/dev/null 2>&1 || \
       ! command -v python3 >/dev/null 2>&1 || ! command -v java >/dev/null 2>&1 || \
       ! command -v brew >/dev/null 2>&1 || ! v17_tool_available command_line_tools; then
        echo
        echo 'Some common developer dependencies are missing.'
        echo 'Nothing has been installed or changed.'
        read "choice?Open the dependency setup menu now? (y/N): "
        if [[ "$choice" == [yY] || "$choice" == [yY][eE][sS] ]]; then
            v17_setup_dependencies
        fi
    fi
}

# ------------------------------------------------------------
# V17 MAIN MENU
# ------------------------------------------------------------

main_menu() {
    while true; do
        header

        echo
        echo "                    DEVELOPMENT CENTER"
        echo "----------------------------------------------------------------"
        echo "  1. Interactive C"
        echo "  2. Interactive C++"
        echo "  3. Interactive Python"
        echo "  4. Interactive JavaScript"
        echo "  5. Interactive Java"
        echo "----------------------------------------------------------------"
        echo "                      WORKSPACE TOOLS"
        echo "----------------------------------------------------------------"
        echo "  6. C Workspace"
        echo "  7. C++ Workspace"
        echo "  8. Quick Compile & Run"
        echo "  9. Project Creator"
        echo " 10. Workspace Manager"
        echo "----------------------------------------------------------------"
        echo "                 SYSTEM & DEVELOPER TOOLS"
        echo "----------------------------------------------------------------"
        echo " 11. System Dashboard"
        echo " 12. btop - Live Resource Monitor"
        echo " 13. Developer Health Check"
        echo " 14. Update Center"
        echo " 15. Apple Silicon Diagnostics"
        echo "----------------------------------------------------------------"
        echo "                  ARTIFICIAL INTELLIGENCE"
        echo "----------------------------------------------------------------"
        echo " 16. Ollama AI Center"
        echo "----------------------------------------------------------------"
        echo " 17. Continue in normal Zsh"
        echo " 18. Setup / Install Dependencies"
        echo
        echo "================================================================"
        read "choice?Choose an option: "

        case "$choice" in
            1) interactive_c ;;
            2) interactive_cpp ;;
            3) interactive_python ;;
            4) interactive_javascript ;;
            5) interactive_java ;;
            6) open_shell "$C_WORKSPACE" ;;
            7) open_shell "$CPP_WORKSPACE" ;;
            8) quick_compile ;;
            9) project_creator ;;
            10) workspace_manager ;;
            11) system_dashboard ;;
            12)
                if command -v btop >/dev/null 2>&1; then
                    btop
                else
                    echo "btop is not installed. Run: brew install btop"
                    pause
                fi
                ;;
            13) developer_health ;;
            14) update_center ;;
            15) apple_diagnostics ;;
            16) ollama_ai_center ;;
            18) v17_setup_dependencies ;;
            17)
                echo
                echo "Returning to your normal Zsh session."
                unset CODE_LAUNCHER_STARTED
                return
                ;;
            *)
                echo "Invalid choice."
                pause
                ;;
        esac
    done
}
v17_startup_check
main_menu
