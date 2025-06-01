# Terminal Multiplexer Keybinding Strategy

This document defines a portable keybinding strategy for terminal multiplexers that can be adapted across different terminals (WezTerm, Kitty, iTerm2, etc.).

## Philosophy

- **Portability**: Bindings should work across different terminals and platforms
- **Frequency-based access**: Direct modifiers for frequent actions, leader key for infrequent ones
- **Consistency**: Similar actions use similar key patterns
- **Muscle memory**: Leverage common patterns from vim, tmux, and other tools

## Modifier Key Strategy

- `ALT`: Primary multiplexer navigation (workspaces, tabs, panes)
- `CTRL`: Application-level (vim, shell commands)  
- `CMD`: System-level and macOS enhancements (conditional)
- `Leader`: Infrequent actions (rename, configuration)

## Keybinding Hierarchy

### Workspace Level (Cross-platform compatible)
```
ALT+j       Previous workspace (universal, fast)
ALT+k       Next workspace (universal, fast)
Leader+0-9  Jump to specific workspace (universal)
CMD+0-9     Jump to specific workspace (macOS only, conditional)
```

### Session/Tab Level (ALT modifier)
```
ALT+1-9     Switch to tab 1-9
ALT+h       Previous tab
ALT+l       Next tab
ALT+c       Create new tab
ALT+x       Close current tab
ALT+,       Move tab left
ALT+.       Move tab right
```

### Pane Level (ALT+Shift modifier)
```
ALT+Shift+l             Split vertical (left/right panes)
ALT+Shift+j             Split horizontal (top/bottom panes)
ALT+Shift+\             Split horizontal (alternative)
ALT+Shift+-             Split vertical (alternative)
ALT+Shift+z             Toggle pane zoom
ALT+Shift+x             Close pane
ALT+Shift+Ctrl+h/j/k/l  Resize panes
```

### Application Integration (CTRL modifier)
```
CTRL+h/j/k/l    Vim pane navigation (seamless with multiplexer)
```

### System Level (CMD modifier)
```
CMD+Enter   Toggle fullscreen
CMD+;       Command palette
CMD+f       Find/search
```

### Leader Key Actions (Ctrl+, + key)
```
Leader+0-9  Jump to specific workspace (universal)
Leader+n    Rename current tab
Leader+N    Rename current workspace
Leader+f    Font selector
Leader+r    Reload configuration
Leader+?    Show help/keybindings
```

## Frequency Analysis

### Very Frequent (Direct single modifier)
- Workspace switching: `ALT+j/k` (universal), `CMD+0-9` (macOS)
- Tab switching: `ALT+1-9`, `ALT+h/l`
- Pane navigation: `ALT+Shift+h/j/k/l`

### Frequent (Direct with modifier combinations)
- Tab management: `ALT+c`, `ALT+x`
- Pane splits: `ALT+Shift+\`, `ALT+Shift+-`
- Pane zoom: `ALT+Shift+z`

### Occasional (Leader key)
- Renaming: `Leader+n`, `Leader+N`
- Configuration: `Leader+f`, `Leader+r`

## Special Integrations

### Vim Integration
- Seamless pane navigation between vim and multiplexer
- Use same `CTRL+h/j/k/l` pattern in both contexts
- Multiplexer detects vim process and forwards commands appropriately

### Git Integration
```
ALT+g       Open lazygit in current directory
```

### Development Tools
```
ALT+d       Debug overlay
ALT+Esc     Copy mode
```

## Implementation Notes

### Cross-Platform Implementation
- **Primary strategy**: `ALT+j/k` for workspace navigation (universal)
- **Secondary access**: `Leader+0-9` for direct workspace jumping (universal)
- **macOS enhancement**: `CMD+0-9` for additional direct access (conditional)
- **Linux compatibility**: Avoid Super/Windows key conflicts by using ALT-based bindings

### Terminal-Specific Notes

**WezTerm:** Full support for all modifiers and seamless vim integration  
**Kitty:** Good modifier support, adapt vim integration as needed  
**iTerm2:** Focus on tab/window management, may need tmux integration

## Current Issues in WezTerm Implementation

### Inconsistencies to Fix
1. **Mixed patterns**: Workspace bindings use different action styles
2. **Missing workspace navigation**: No fast previous/next workspace switching
3. **Incomplete coverage**: Missing symmetrical bindings for hjkl pattern
4. **Cross-platform conflicts**: CMD bindings don't work well on Linux

