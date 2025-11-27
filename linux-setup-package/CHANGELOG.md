# Changelog

All notable changes to this linux-setup-package.

## [1.1.0] - 2025-11-26

### Added
- **Discord** - Communication platform
  - Voice, video, and text chat
  - Installed via Snap

- **Flameshot** - Screenshot tool
  - Feature-rich screenshot utility
  - Annotation and editing capabilities

- **Claude Code CLI** - AI coding assistant
  - Automatic installation via official install script
  - Command-line interface for Claude

- **GitHub Desktop** - Git GUI client
  - Automatic repository configuration (shiftkey PPA)
  - Simplified git workflow interface

- **curl and wget** - Download utilities
  - Essential tools for command-line downloads
  - Required for various installations

- **CUDA Toolkit 13.0** installation option
  - gcc, g++, make, cmake, build-essential
  - htop and nvtop system monitoring tools
  - NVIDIA open kernel modules
  - Automatic environment variable configuration
  - Interactive prompt (optional installation)

- **Documentation**
  - CUDA_INFO.md - Comprehensive CUDA installation guide
  - Verification steps for CUDA installation
  - Troubleshooting section for common CUDA issues

### Changed
- Updated install.sh section numbering (1-9)
- Enhanced final summary to show CUDA status
- Updated README.md with CUDA information
- Updated QUICKSTART.md with CUDA prompt
- Updated INSTALLATION_SUMMARY.md with CUDA verification
- Archive size increased from 19KB to 24KB

### Technical Details
- CUDA installation downloads from official NVIDIA repository
- Installs cuda-toolkit-13-0 package (~3-4GB)
- Adds /usr/local/cuda-13.0/bin to PATH
- Adds /usr/local/cuda-13.0/lib64 to LD_LIBRARY_PATH
- Cleans up temporary keyring file after installation

## [1.0.0] - 2025-11-26

### Initial Release

#### Features
- **File Managers**: Nemo and Nautilus with extensions
- **Applications**: Remmina, VLC, Extension Manager, Sunshine
- **Network Storage**: Samba/CIFS automount configuration (6 shares)
- **Windows Drives**: NTFS-3g support with optional mounting
- **Nemo Actions**: 11 custom context menu actions
  - Change Owner Recursively
  - Claude Here (2 variants)
  - Copy Path and Name
  - Create/Save Symlinks
  - Make Link
  - Merge GGUF Shards
  - Open in VS Code
  - Open in Cursor
  - Run with Sudo
- **Helper Scripts**: 6 bash scripts for Nemo actions
- **File Manager Bookmarks**: Automatic bookmark creation
- **GNOME Extensions**: Documentation for 14 extensions

#### Scripts
- install.sh - Main installation script
- collect-scripts.sh - Gather scripts from existing installation
- create-archive.sh - Create portable .tar.gz package

#### Documentation
- README.md - Main documentation
- QUICKSTART.md - Quick start guide
- INSTALLATION_SUMMARY.md - Chat history summary
- INSTALL_CHECKLIST.txt - Printable checklist
- VERIFICATION_REPORT.txt - Verification results
- nemo-scripts/README.md - Nemo actions documentation
- gnome-extensions/EXTENSIONS.md - Extension list

#### Package Details
- Archive size: 19KB
- Total files: 34
- All scripts validated for syntax
- Portable (uses $HOME variable)
- Ubuntu 24.04 compatible

---

Generated from Claude Code chat history
