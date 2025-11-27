# Nemo Actions and Scripts

This directory contains Nemo file manager context menu actions (.nemo_action files) and their associated helper scripts.

## Installed Actions

### File Operations

1. **Copy Path and Name** (`copy_path_and_name.nemo_action`)
   - Copies the full path and filename to clipboard
   - Useful for referencing files in commands or documentation

2. **Create Symlink Here** (`create-symlink-here.nemo_action`)
   - Creates a symbolic link in the current directory
   - Works with the saved symlink target

3. **Make Link** (`make-link.nemo_action`)
   - Creates a link to selected file/folder
   - Alternative symlink creation method

4. **Save for Symlink** (`save-for-symlink.nemo_action`)
   - Saves a file/folder path to create a symlink later
   - Use with "Create Symlink Here"

### System Administration

5. **Change Owner Recursively** (`chown-recursive.nemo_action` + `chown-recursive.sh`)
   - Changes ownership of directory and all contents to current user
   - Uses zenity for confirmation dialogs
   - Requires sudo access (configured for passwordless sudo)
   - **Dependencies**: zenity

6. **Run with Sudo** (`run-with-sudo.nemo_action`)
   - Executes selected file with sudo privileges
   - Useful for scripts that need elevated permissions

### Development Tools

7. **Open in VS Code** (`open-in-vscode.nemo_action`)
   - Opens file or directory in Visual Studio Code
   - **Dependencies**: code (VS Code CLI)

8. **Open in Cursor** (`open-in-cursor.nemo_action`)
   - Opens file or directory in Cursor editor
   - **Dependencies**: cursor

9. **Claude Here** (`claude_here.nemo_action`)
   - Opens Claude Code CLI in a terminal at the current directory
   - Interactive bash session
   - **Dependencies**: claude CLI, gnome-terminal

10. **Claude Here (Skip)** (`claude_here_skip.nemo_action`)
    - Alternative Claude Code launcher
    - **Dependencies**: claude CLI, gnome-terminal

### Specialized Tools

11. **Merge GGUF Shards** (`merge_gguf.nemo_action` + `merge_gguf.sh`)
    - Merges GGUF model shards into a single file
    - Uses llama.cpp's llama-gguf-split tool
    - Shows progress in terminal
    - **Dependencies**:
      - llama.cpp with llama-gguf-split built
      - Path: `~/Desktop/llama.cpp/build/bin/llama-gguf-split` (or update merge_gguf.sh)

## Installation

The install.sh script automatically:
1. Copies .nemo_action files to `~/.local/share/nemo/actions/`
2. Copies .sh helper scripts to `~/bin/`
3. Makes all scripts executable
4. Updates paths in actions to reference ~/bin
5. Adds ~/bin to PATH if needed

## Dependencies

### Required
- **zenity**: Dialog boxes for some actions
  ```bash
  sudo apt install zenity
  ```

### Optional (depending on which actions you use)
- **VS Code**: `sudo snap install code --classic` or from https://code.visualstudio.com/
- **Cursor**: Download from https://cursor.sh/
- **Claude CLI**: For Claude Code actions
- **llama.cpp**: For GGUF merging
  ```bash
  git clone https://github.com/ggerganov/llama.cpp
  cd llama.cpp
  mkdir build && cd build
  cmake .. -DLLAMA_CUDA=ON  # or without CUDA
  cmake --build . --config Release
  ```

## Customization

### Modifying Actions

Nemo action files use a simple INI-like format:

```ini
[Nemo Action]
Name=Action Name
Comment=Description
Exec=command %F
Icon-Name=icon-name
Selection=s    # s=single, m=multiple, any, none
Extensions=ext;dir;   # File types to show for
```

Common placeholders:
- `%F` - Selected file(s) path(s)
- `%P` - Current directory path
- `%U` - Selected file(s) URI(s)

### Adding New Actions

1. Create a `.nemo_action` file in this directory
2. If it needs a helper script, create a `.sh` file
3. Run install.sh again, or manually:
   ```bash
   cp your-action.nemo_action ~/.local/share/nemo/actions/
   cp your-script.sh ~/bin/
   chmod +x ~/bin/your-script.sh
   ```

4. Restart Nemo: `nemo -q`

### Modifying Paths

If you need to change where scripts are located:

1. **For merge_gguf.sh**: Edit line 6 to point to your llama.cpp build:
   ```bash
   MERGER="/path/to/your/llama.cpp/build/bin/llama-gguf-split"
   ```

2. **For .nemo_action files**: Edit the `Exec=` line to update paths

## Troubleshooting

### Actions don't appear in Nemo
1. Check files are in correct location:
   ```bash
   ls ~/.local/share/nemo/actions/
   ```
2. Restart Nemo: `nemo -q`
3. Check file permissions (should be readable)

### Action doesn't work
1. Check if dependencies are installed
2. Test the helper script directly:
   ```bash
   ~/bin/your-script.sh /path/to/test/file
   ```
3. Check script has execute permission:
   ```bash
   chmod +x ~/bin/your-script.sh
   ```

### Sudo actions fail
For chown-recursive and similar actions, you may need passwordless sudo:
```bash
echo "$USER ALL=(ALL) NOPASSWD: /usr/bin/chown" | sudo tee /etc/sudoers.d/nemo-chown
sudo chmod 440 /etc/sudoers.d/nemo-chown
```

### Claude/Cursor/VS Code actions don't work
Make sure the application is installed and available in PATH:
```bash
which code    # For VS Code
which cursor  # For Cursor
which claude  # For Claude
```

## Location Reference

After installation:
- **Actions**: `~/.local/share/nemo/actions/`
- **Helper scripts**: `~/bin/`
- **Nemo config**: `~/.config/nemo/`

## Included Files

### Action Files (.nemo_action)
- chown-recursive.nemo_action
- claude_here.nemo_action
- claude_here_skip.nemo_action
- copy_path_and_name.nemo_action
- create-symlink-here.nemo_action
- make-link.nemo_action
- merge_gguf.nemo_action
- open-in-cursor.nemo_action
- open-in-vscode.nemo_action
- run-with-sudo.nemo_action
- save-for-symlink.nemo_action

### Helper Scripts (.sh)
- chown-recursive.sh - Changes ownership recursively
- merge_gguf.sh - Merges GGUF model shards
