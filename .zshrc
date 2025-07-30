# KEEP - PATH export (needed for ICU tools)
export PATH="/usr/local/opt/icu4c/bin:$PATH"

# Terminal-specific PS1 configuration
if [[ "$TERM_PROGRAM" == "WarpTerminal" ]]; then
    # === WARP TERMINAL - Dracula PS1 with Powerline & Icons ===

    # Powerline Unicode separators
    local SEP=$'\uE0B0'        #
    local LEFT_SEP=$'\uE0B2'   #
    local THIN_SEP=$'\uE0B1'   #
    local THIN_LEFT_SEP=$'\uE0B3' #

    # Icons (requires Nerd Font)
    local APPLE_ICON=$'\uF179'      #
    local WINDOWS_ICON=$'\uF17A'    #
    local LINUX_ICON=$'\uF17C'      #
    local FOLDER_ICON=$'\uF07B'     #
    local GIT_ICON=$'\uF1D3'        #
    local PYTHON_ICON=$'\uF81F'     #
    local SSH_ICON=$'\uF489'        #

    # Function to get OS icon
    get_os_icon() {
        case "$(uname)" in
            Darwin) echo "$APPLE_ICON" ;;
            Linux) echo "$LINUX_ICON" ;;
            CYGWIN*|MINGW*|MSYS*) echo "$WINDOWS_ICON" ;;
            *) echo "💻" ;;
        esac
    }

    # Function to get remote SSH info with icons
    remote_info() {
        if [[ -n "$SSH_CONNECTION" ]]; then
            echo "%K{25}%F{22}$SEP%f%F{white} $SSH_ICON @$(hostname) %f%K{54}%F{25}$SEP%f"
        else
            echo "%K{54}%F{22}$SEP%f"
        fi
    }

    # Function to get Python environment with icons and conditional separator
    python_env() {
        if [[ -n "$CONDA_DEFAULT_ENV" ]]; then
            echo "%K{94}%F{54}$SEP%f%F{black} $PYTHON_ICON $CONDA_DEFAULT_ENV %f"
        elif [[ -n "$VIRTUAL_ENV" ]]; then
            echo "%K{94}%F{54}$SEP%f%F{black} $PYTHON_ICON $(basename $VIRTUAL_ENV) %f"
        elif [[ -n "$PYENV_VERSION" ]]; then
            echo "%K{94}%F{54}$SEP%f%F{black} $PYTHON_ICON $PYENV_VERSION %f"
        elif command -v pyenv > /dev/null 2>&1; then
            local pyenv_version=$(pyenv version-name 2>/dev/null)
            if [[ "$pyenv_version" != "system" ]]; then
                echo "%K{94}%F{54}$SEP%f%F{black} $PYTHON_ICON $pyenv_version %f"
            else
                echo ""
            fi
        else
            echo ""
        fi
    }

    # Function to get git branch
    git_branch() {
        if git rev-parse --git-dir > /dev/null 2>&1; then
            local branch=$(git branch --show-current 2>/dev/null)
            echo "$branch"
        fi
    }

    # Function to get file changes count
    git_file_changes() {
        if git rev-parse --git-dir > /dev/null 2>&1; then
            local changes=$(git status --porcelain 2>/dev/null | wc -l | tr -d ' ')
            echo "$changes"
        fi
    }

    # Function to get diff changes (ahead/behind)
    git_diff_changes() {
        if git rev-parse --git-dir > /dev/null 2>&1; then
            local ahead=$(git rev-list --count @{upstream}..HEAD 2>/dev/null || echo "0")
            local behind=$(git rev-list --count HEAD..@{upstream} 2>/dev/null || echo "0")
            echo "↑$ahead↓$behind"
        fi
    }

    # Function to build git info with icons and dynamic separator
    git_info() {
        if git rev-parse --git-dir > /dev/null 2>&1; then
            local branch=$(git_branch)
            local file_changes=$(git_file_changes)
            local diff_changes=$(git_diff_changes)

            # Determine the previous segment color for separator
            local has_python_env=""
            if [[ -n "$CONDA_DEFAULT_ENV" ]] || [[ -n "$VIRTUAL_ENV" ]] || [[ -n "$PYENV_VERSION" ]]; then
                has_python_env="yes"
            elif command -v pyenv > /dev/null 2>&1; then
                local pyenv_version=$(pyenv version-name 2>/dev/null)
                if [[ "$pyenv_version" != "system" ]]; then
                    has_python_env="yes"
                fi
            fi

            # Set separator color based on previous segment
            local sep_color="54"  # default (path color)
            if [[ -n "$has_python_env" ]]; then
                sep_color="94"  # python env color
            fi

            # Different colors based on git status
            if [[ $file_changes -gt 0 ]]; then
                # Red background for uncommitted changes
                echo "%K{88}%F{${sep_color}}$SEP%f%F{white} $GIT_ICON $branch %f%K{52}%F{88}$SEP%f%F{white} $file_changes %f%K{54}%F{52}$SEP%f%F{white} $diff_changes %f%k%F{54}$SEP%f"
            else
                # Green background for clean repo
                echo "%K{28}%F{${sep_color}}$SEP%f%F{white} $GIT_ICON $branch %f%K{22}%F{28}$SEP%f%F{white} $file_changes %f%K{54}%F{22}$SEP%f%F{white} $diff_changes %f%k%F{54}$SEP%f"
            fi
        else
            # No git repo - add closing separator only if python env exists
            if [[ -n "$has_python_env" ]]; then
                echo "%k%F{94}$SEP%f"
            else
                echo ""
            fi
        fi
    }

    # Enable command substitution in prompt
    setopt PROMPT_SUBST

    # Dracula-themed prompt with icons and powerline separators
    PS1='%K{22}%F{white} $(get_os_icon) %n %f$(remote_info)%F{white} $FOLDER_ICON %~ %f$(python_env)$(git_info)
%B%F{84}❯%f%b '

    # Right prompt with correct colors and date format
    RPROMPT='%F{240}$LEFT_SEP%f%K{240}%F{white} %D{%Y/%m/%d} %f%K{240}%F{236}$LEFT_SEP%f%K{236}%f%F{white} %D{%H:%M} %f%k'

else
    # === VS CODE & OTHER TERMINALS - Simple PS1 ===
    setopt PROMPT_SUBST

    # Simple git branch function
    simple_git_branch() {
        if git rev-parse --git-dir > /dev/null 2>&1; then
            local branch=$(git branch --show-current 2>/dev/null)
            echo " (⎇ $branch)"
        fi
    }

    # Simple Python environment
    simple_python_env() {
        if [[ -n "$CONDA_DEFAULT_ENV" ]]; then
            echo "(🐍 $CONDA_DEFAULT_ENV) "
        elif [[ -n "$VIRTUAL_ENV" ]]; then
            echo "(🐍 $(basename $VIRTUAL_ENV)) "
        fi
    }

    # Simple PS1 for VS Code with basic icons
    PS1='$(simple_python_env)📁 %F{cyan}%n%f:%F{blue}%~%f$(simple_git_branch) %F{white}>%f '
    RPROMPT=''
fi
