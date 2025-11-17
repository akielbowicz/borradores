#!/usr/bin/env nu
# Termux Development Environment Setup Script
# Optimized for monochromacy with high-contrast themes
# Run with: nu setup_termux_dev.nu

print "╔════════════════════════════════════════════════════╗"
print "║  Termux Development Environment Setup             ║"
print "║  High-contrast configuration for monochromacy     ║"
print "╚════════════════════════════════════════════════════╝"
print ""

# Step 1: Install packages
print "[1/8] Installing core packages..."
pkg install -y nushell zoxide yazi starship ripgrep bat helix zk

# Step 2: Create directory structure
print "[2/8] Creating directory structure..."
mkdir ~/.config/nushell
mkdir ~/.config/yazi
mkdir ~/.config/bat
mkdir ~/.config/ripgrep
mkdir ~/.config/helix
mkdir ~/.config/helix/themes
mkdir ~/.config/babashka
mkdir ~/notes
mkdir ~/notes/daily
mkdir ~/notes/.zk/templates

# Step 3: Configure Nushell
print "[3/8] Configuring Nushell..."
"# Nushell Configuration
# Optimized for monochromacy with high contrast

$env.EDITOR = \"helix\"
$env.VISUAL = \"helix\"

let high_contrast_theme = {
    separator: white
    leading_trailing_space_bg: { attr: r }
    header: { fg: white attr: b }
    empty: white
    bool: { fg: white attr: b }
    int: white
    filesize: white
    duration: white
    date: { fg: white attr: b }
    range: white
    float: white
    string: white
    nothing: white
    binary: white
    cellpath: white
    row_index: { fg: white attr: b }
    record: white
    list: white
    block: white
    hints: dark_gray
    search_result: { fg: black bg: white }
}

$env.config = {
    show_banner: false
    color_config: $high_contrast_theme
    use_grid_icons: true
    edit_mode: vi
    shell_integration: true
    history: {
        max_size: 100000
        sync_on_enter: true
        file_format: \"sqlite\"
    }
}

# Zoxide integration
def --env __zoxide_z [...rest: string] {
    let arg0 = ($rest | append '~').0
    let path = if (($rest | length) <= 1) and ($arg0 == '-' or ($arg0 | path expand | path type) == dir) {
        $arg0
    } else {
        (zoxide query --exclude $env.PWD -- ...$rest | str trim -r -c \"\\n\")
    }
    cd $path
}

alias z = __zoxide_z
alias bbk = LD_PRELOAD='' bb
alias cat = bat
alias find = fd
alias grep = rg

# Starship prompt
$env.STARSHIP_SHELL = \"nu\"
def create_left_prompt [] {
    starship prompt --status $env.LAST_EXIT_CODE
}
$env.PROMPT_COMMAND = { || create_left_prompt }
" | save -f ~/.config/nushell/config.nu

# Step 4: Configure environment
print "[4/8] Configuring environment..."
"$env.BAT_THEME = \"ansi\"
$env.RIPGREP_CONFIG_PATH = \"~/.config/ripgrep/config\"
$env.FZF_DEFAULT_OPTS = \"--color=bw --layout=reverse --border\"
" | save -f ~/.config/nushell/env.nu

# Step 5: Configure tools
print "[5/8] Configuring tools (bat, ripgrep, starship)..."

# Bat config
"--theme=\"ansi\"
--style=\"numbers,grid\"
--tabs=4
--wrap=auto
" | save -f ~/.config/bat/config

# Ripgrep config
"--follow
--hidden
--glob=!.git/*
--glob=!node_modules/*
--smart-case
--line-number
" | save -f ~/.config/ripgrep/config

# Starship config
"format = \"\"\"[┌─](bold white)$username$hostname$directory$git_branch$git_status
[└─>](bold white) \"\"\"

[character]
success_symbol = \"[▶](bold white)\"
error_symbol = \"[✗](bold white)\"

[username]
style_user = \"bold white\"
format = \"[$user]($style) \"
disabled = false
show_always = true

[directory]
style = \"bold white\"
format = \"[$path]($style) \"

[git_branch]
symbol = \"GIT:\"
style = \"bold white\"
format = \"[$symbol$branch]($style) \"

[git_status]
style = \"bold white\"
format = \"([$all_status]($style) )\"
" | save -f ~/.config/starship.toml

# Step 6: Configure Yazi
print "[6/8] Configuring Yazi..."
"[manager]
show_hidden = false

[opener]
edit = [{ run = 'helix \"$@\"', block = true }]

[tool]
editor = \"helix\"
pager = \"bat\"
" | save -f ~/.config/yazi/yazi.toml

# Step 7: Configure Helix
print "[7/8] Configuring Helix..."
"theme = \"monochrome\"

[editor]
line-number = \"relative\"
auto-save = true
color-modes = true

[editor.cursor-shape]
insert = \"bar\"
normal = \"block\"
" | save -f ~/.config/helix/config.toml

# Step 8: Initialize zk
print "[8/8] Initializing zk notebook..."
cd ~/notes
zk init --no-input

print ""
print "✓ Setup complete!"
print ""
print "Next steps:"
print "  1. Run 'nu' to start Nushell"
print "  2. For babashka, use: bbk (alias for LD_PRELOAD='' bb)"
print "  3. GitHub CLI: gh auth login (if needed)"
print "  4. Notes: cd ~/notes && zk today"
print ""
