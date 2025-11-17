# Termux Development Environment Setup

High-contrast configuration optimized for monochromacy (complete color blindness).

## Quick Start

Run the setup script:

```bash
bash ~/setup_termux_dev.sh
```

Then start Nushell:

```bash
nu
```

## Installed Tools

### Shell & Navigation
- **Nushell** - Modern shell with structured data
- **Zoxide** - Smart directory jumping (use `z dirname`)
- **Starship** - Fast, customizable prompt

### File Management
- **Yazi** - Terminal file manager (run with `yazi`)
- **Bat** - Better `cat` with syntax highlighting
- **Ripgrep** - Fast search tool (aliased as `grep`)
- **fd** - Better `find` command

### Development
- **Helix** - Modern modal editor (run with `hx` or `helix`)
- **GitHub CLI** - Manage GitHub from terminal (`gh`)
- **Babashka** - Fast Clojure scripting (use `bbk` alias)
- **Carapace** - Multi-shell completion engine (auto-enabled in Nushell)

### Note-Taking
- **Zk** - Plain text note-taking with linking

## Key Aliases & Commands

### Nushell Aliases & Features
- `z <dir>` - Jump to directory (zoxide)
- `cat` → `bat` - Syntax-highlighted file viewing
- `grep` → `rg` - Fast searching
- `bbk` - Run babashka (handles LD_PRELOAD issue)
- **Tab completion** - Enhanced by Carapace for 600+ commands (git, npm, docker, etc.)

### Zk Note Commands
- `zk today` - Open/create today's daily note
- `zk list` - List all notes
- `zk recent` - Show recent notes
- `zk edit --interactive` - Interactively select notes

## Configuration Files

All configurations use high-contrast themes with:
- Black and white color scheme
- Bold, underline, and dim for emphasis
- No reliance on color hues
- Maximum brightness contrast

### Locations
```
~/.config/
├── nushell/
│   ├── config.nu      # Shell configuration
│   └── env.nu         # Environment variables
├── helix/
│   ├── config.toml    # Editor settings
│   └── themes/
│       └── monochrome.toml  # High-contrast theme
├── yazi/
│   ├── yazi.toml      # File manager config
│   └── theme.toml     # High-contrast theme
├── bat/
│   └── config         # Syntax highlighter config
├── ripgrep/
│   └── config         # Search tool config
├── starship.toml      # Prompt configuration
└── babashka/
    └── bb.edn         # Babashka tasks

~/notes/
├── .zk/
│   ├── config.toml    # Zk configuration
│   └── templates/     # Note templates
└── daily/             # Daily notes
```

## Special Considerations

### Babashka on Termux
Babashka requires LD_PRELOAD to be empty on Termux. Use the `bbk` alias:
```bash
bbk your-script.clj
```

### Helix Editor
- Theme: `monochrome` (high-contrast)
- Line numbers: relative
- Vi-mode keybindings
- Auto-save enabled

### Nushell
- Vi editing mode
- Zoxide integration for smart `cd`
- Starship prompt
- Modern tool aliases

### GitHub CLI
Authenticate with:
```bash
gh auth login
```

## Usage Examples

### Navigate with Zoxide
```bash
z projects      # Jump to ~/projects or similar
z documents     # Jump to ~/Documents
zi              # Interactive directory picker
```

### File Management with Yazi
```bash
yazi            # Launch file manager
# Use arrow keys to navigate
# Enter to open with helix
# q to quit
```

### Note-Taking with Zk
```bash
cd ~/notes
zk new --title "My Note"  # Create new note
zk today                   # Today's daily note
zk list --interactive      # Browse notes
zk edit --interactive      # Edit notes
```

### Searching with Ripgrep
```bash
rg "search term"          # Search current directory
rg "pattern" ~/projects   # Search specific directory
rg -i "case insensitive"  # Case-insensitive search
```

### Editing with Helix
```bash
hx file.txt              # Open file
# Normal mode: hjkl for movement
# Insert mode: i
# Save: :w
# Quit: :q
# Save & quit: :wq
```

## Monochromacy Optimizations

All tools are configured with:

1. **ANSI theme** (bat) - Uses only black/white/gray
2. **Monochrome theme** (helix) - No color hues, only brightness
3. **Bold/underline/dim** - For visual hierarchy
4. **High contrast** - Maximum brightness differences
5. **Clear symbols** - Text-based indicators instead of colors

## Customization

To modify themes, edit:
- Nushell: `~/.config/nushell/config.nu` (theme section)
- Helix: `~/.config/helix/themes/monochrome.toml`
- Starship: `~/.config/starship.toml`
- Yazi: `~/.config/yazi/theme.toml`

## Troubleshooting

### Nushell not starting
Ensure installation completed:
```bash
pkg install -y nushell
```

### Babashka errors
Always use the `bbk` alias, not `bb` directly:
```bash
bbk script.clj
```

### Zoxide not working
Initialize the database:
```bash
cd ~
cd ~/projects  # Visit directories to build database
```

## Backup & Restore

Backup your configuration:
```bash
tar -czf termux-config-backup.tar.gz ~/.config ~/notes
```

Restore:
```bash
tar -xzf termux-config-backup.tar.gz -C ~
```

## Updates

Update all packages:
```bash
pkg upgrade
```

Update tools:
```bash
pkg upgrade nushell zoxide yazi starship ripgrep bat helix zk
```

## Additional Resources

- Helix: https://helix-editor.com/
- Nushell: https://nushell.sh/
- Zk: https://github.com/zk-org/zk
- Yazi: https://yazi-rs.github.io/
- Starship: https://starship.rs/

---

**Note**: This setup is optimized for phone screens with monochromacy enabled.
All configurations prioritize contrast and clarity over color.
