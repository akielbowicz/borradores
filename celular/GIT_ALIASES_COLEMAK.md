# Git Aliases for Two-Thumb Colemak DH Typing

Optimized git aliases for phone typing with both thumbs on Colemak DH keyboard layout.

## Design Principles

1. **Center column keys** (d, h, t, n) - easiest thumb reach
2. **Easy reach keys** (s, r, e, i) - comfortable for both thumbs
3. **Alternating hands** - natural left-right-left rhythm
4. **Mnemonic** - aliases match command meaning when possible

## Quick Workflow Aliases

These use center/easy keys for the most common git workflow:

| Alias | Command | Hand | Key Position | Usage |
|-------|---------|------|--------------|-------|
| `gn` | `git status` | Right | Center 'n' | Quick status check |
| `ge` | `git add .` | Right | Easy 'e' | Stage current directory |
| `gt` | `git commit` | Left | Center 't' | Commit changes |
| `gh` | `git push` | Right | Center 'h' | Push to remote (h = hub/home) |
| `gd` | `git diff` | Left | Center 'd' | View differences |
| `gr` | `git pull` | Left | Easy 'r' | Pull from remote (r = retrieve) |
| `gi` | `git commit -m` | Right | Easy 'i' | Commit with inline message |

### Example Workflow

```bash
gn          # Check status
ge          # Add current changes
gt          # Start commit (opens editor)
# OR
gi "fix bug"  # Commit with message directly
gh          # Push to remote
```

## Standard Aliases

Traditional single-letter aliases (still available):

| Alias | Command | Description |
|-------|---------|-------------|
| `gs` | `git status` | Status |
| `ga` | `git add` | Add files |
| `gc` | `git commit` | Commit |
| `gp` | `git push` | Push |
| `gl` | `git log --oneline --graph` | Log with graph |
| `gd` | `git diff` | Diff (duplicate of thumb-optimized) |

## Extended Aliases

More specific operations:

### Staging
- `gaa` - `git add --all` - Stage all files
- `ge` - `git add .` - Stage current directory (thumb-optimized)

### Committing
- `gcm` - `git commit -m` - Commit with message
- `gca` - `git commit --amend` - Amend last commit
- `gi` - `git commit -m` - Inline commit (thumb-optimized)

### Viewing Changes
- `gd` - `git diff` - View unstaged changes
- `gds` - `git diff --staged` - View staged changes
- `gl` - `git log --oneline --graph` - Graphical log

### Branching
- `gb` - `git branch` - List/create branches
- `gco` - `git checkout` - Switch branches
- `gm` - `git merge` - Merge branches

### Remote Operations
- `gr` - `git pull` - Pull from remote (thumb-optimized)
- `gh` - `git push` - Push to remote (thumb-optimized)
- `gcl` - `git clone` - Clone repository

### Stashing
- `gst` - `git stash` - Stash changes

## Keyboard Layout Reference

Colemak DH layout (QWERTY positions shown):
```
q w f p b   j l u y ;
a r s t g   m n e i o
z x c d v   k h , . /
```

**Best for thumbs:**
- Center: d, h, t, n (⭐ easiest)
- Easy: s, r, e, i (✓ comfortable)
- Avoid: edges like q, p, z, / (harder to reach)

## Tips

1. **Muscle Memory**: Focus on learning the thumb-optimized aliases (gn, ge, gt, gh)
2. **Alternating Pattern**: The quick workflow naturally alternates thumbs for rhythm
3. **Fallback**: Standard aliases (gs, ga, gc, gp) still work if you prefer them
4. **Carapace**: Tab completion works with all aliases for flags and arguments

## Common Patterns

### Quick commit and push
```bash
gn              # Check what changed
ge              # Add everything
gi "message"    # Commit with message
gh              # Push
```

### Check before staging
```bash
gd              # See what changed
ge              # Add current dir
gt              # Commit (opens editor)
```

### Branch workflow
```bash
gb new-feature  # Create branch
gco new-feature # Switch to it
# ... make changes ...
ge && gi "add feature" && gh
```

### Review changes
```bash
gn              # Status overview
gd              # Unstaged diff
gds             # Staged diff
gl              # Recent commits
```

## Configuration Location

Aliases are defined in: `~/.config/nushell/config.nu`

To add more aliases, edit that file and restart Nushell.
