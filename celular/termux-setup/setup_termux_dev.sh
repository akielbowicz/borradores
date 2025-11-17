#!/data/data/com.termux/files/usr/bin/bash
# Termux Development Environment Setup Script
# Optimized for monochromacy with high-contrast themes

set -e

echo "╔════════════════════════════════════════════════════╗"
echo "║  Termux Development Environment Setup             ║"
echo "║  High-contrast configuration for monochromacy     ║"
echo "╚════════════════════════════════════════════════════╝"
echo ""

# Step 1: Install packages
echo "[1/8] Installing core packages..."
pkg install -y nushell zoxide yazi starship ripgrep bat helix zk carapace

# Step 2: Create directory structure
echo "[2/8] Creating directory structure..."
mkdir -p ~/.config/{nushell,yazi,bat,ripgrep,helix/themes,babashka}
mkdir -p ~/notes/{daily,.zk/templates}

# Step 3: Configure Nushell
echo "[3/8] Configuring Nushell..."
cat > ~/.config/nushell/config.nu << 'EOF'
# Nushell Configuration - High-contrast for monochromacy
$env.EDITOR = "helix"
$env.VISUAL = "helix"

let high_contrast_theme = {
    separator: white
    header: { fg: white attr: b }
    bool: { fg: white attr: b }
    int: white
    string: white
    hints: dark_gray
    search_result: { fg: black bg: white }
}

$env.config = {
    show_banner: false
    color_config: $high_contrast_theme
    edit_mode: vi
    shell_integration: true
    completions: {
        case_sensitive: false
        quick: true
        partial: true
        algorithm: "fuzzy"
        external: {
            enable: true
            max_results: 100
            completer: {|spans|
                carapace $spans.0 nushell ...$spans | from json | get completions
            }
        }
    }
}

# Zoxide
def --env __zoxide_z [...rest: string] {
    let arg0 = ($rest | append '~').0
    let path = if (($rest | length) <= 1) and ($arg0 == '-' or ($arg0 | path expand | path type) == dir) {
        $arg0
    } else {
        (zoxide query --exclude $env.PWD -- ...$rest | str trim -r -c "\n")
    }
    cd $path
}

alias z = __zoxide_z
alias bbk = LD_PRELOAD='' bb

# Carapace completions
$env.CARAPACE_BRIDGES = 'zsh,fish,bash,inshellisense'

alias cat = bat
alias grep = rg

# Starship
$env.STARSHIP_SHELL = "nu"
def create_left_prompt [] {
    starship prompt --status $env.LAST_EXIT_CODE
}
$env.PROMPT_COMMAND = { || create_left_prompt }

# Update zoxide on cd
$env.config = ($env.config | upsert hooks {
    env_change: {
        PWD: [{|before, after| zoxide add -- $after }]
    }
})
EOF

# Step 4: Environment config
echo "[4/8] Configuring environment..."
cat > ~/.config/nushell/env.nu << 'EOF'
$env.BAT_THEME = "ansi"
$env.FZF_DEFAULT_OPTS = "--color=bw --layout=reverse --border"
$env.RIPGREP_CONFIG_PATH = "~/.config/ripgrep/config"
$env.EDITOR = "helix"
EOF

# Step 5: Tool configs
echo "[5/8] Configuring tools..."

# Bat
cat > ~/.config/bat/config << 'EOF'
--theme="ansi"
--style="numbers,grid"
--tabs=4
--wrap=auto
EOF

# Ripgrep
cat > ~/.config/ripgrep/config << 'EOF'
--follow
--hidden
--glob=!.git/*
--glob=!node_modules/*
--smart-case
--line-number
--column
EOF

# Starship
cat > ~/.config/starship.toml << 'EOF'
format = """[┌─](bold white)$username$hostname$directory$git_branch$git_status
[└─>](bold white) """

[character]
success_symbol = "[▶](bold white)"
error_symbol = "[✗](bold white)"

[username]
style_user = "bold white"
format = "[$user]($style) "
show_always = true

[directory]
style = "bold white"
format = "[$path]($style) "
truncation_length = 3

[git_branch]
symbol = "GIT:"
style = "bold white"
format = "[$symbol$branch]($style) "

[git_status]
style = "bold white"
format = "([$all_status]($style) )"
EOF

# Step 6: Yazi
echo "[6/8] Configuring Yazi..."
cat > ~/.config/yazi/yazi.toml << 'EOF'
[manager]
show_hidden = false

[opener]
edit = [{ run = 'helix "$@"', block = true }]

[tool]
editor = "helix"
pager = "bat"
EOF

# Step 7: Helix
echo "[7/8] Configuring Helix..."
cat > ~/.config/helix/config.toml << 'EOF'
theme = "monochrome"

[editor]
line-number = "relative"
auto-save = true
color-modes = true

[editor.cursor-shape]
insert = "bar"
normal = "block"

[keys.normal]
C-s = ":w"
EOF

# Helix theme (minimal version)
cat > ~/.config/helix/themes/monochrome.toml << 'EOF'
"ui.background" = { fg = "white", bg = "black" }
"ui.text" = "white"
"ui.cursor" = { fg = "black", bg = "white" }
"ui.selection" = { fg = "black", bg = "white" }
"ui.linenr" = "gray"
"ui.statusline" = { fg = "black", bg = "white" }
"comment" = { fg = "gray" }
"keyword" = { fg = "white", modifiers = ["bold"] }
"function" = { fg = "white", modifiers = ["bold"] }

[palette]
black = "#000000"
gray = "#808080"
white = "#FFFFFF"
EOF

# Step 8: Initialize zk
echo "[8/8] Initializing zk notebook..."
cd ~/notes
if [ ! -f .zk/config.toml ]; then
    zk init --no-input
fi

# Configure zk
sed -i 's/#editor = "vim"/editor = "helix"/' ~/.notes/.zk/config.toml 2>/dev/null || true
sed -i 's/#pager = "less -FIRX"/pager = "bat"/' ~/.notes/.zk/config.toml 2>/dev/null || true

# Babashka config
echo "[EXTRA] Configuring Babashka..."
cat > ~/.config/babashka/bb.edn << 'EOF'
{:paths ["." "src"]
 :deps {}
 :tasks
 {:requires ([babashka.fs :as fs])
  hello {:doc "Print hello" :task (println "Hello from Babashka!")}}}
EOF

echo ""
echo "✓ Setup complete!"
echo ""
echo "Next steps:"
echo "  1. Run 'nu' to start Nushell"
echo "  2. Babashka: use 'bbk' alias (LD_PRELOAD='' bb)"
echo "  3. GitHub CLI: 'gh auth login' (if needed)"
echo "  4. Notes: 'cd ~/notes && zk today'"
echo ""
echo "Installed tools:"
echo "  - Nushell (shell)"
echo "  - Zoxide (smart cd)"
echo "  - Yazi (file manager)"
echo "  - Starship (prompt)"
echo "  - Ripgrep (search)"
echo "  - Bat (cat with highlighting)"
echo "  - Helix (editor)"
echo "  - Zk (notes)"
echo "  - Carapace (completions)"
echo "  - GitHub CLI (gh)"
echo "  - Babashka (already installed)"
echo ""
