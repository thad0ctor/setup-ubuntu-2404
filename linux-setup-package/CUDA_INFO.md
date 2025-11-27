# CUDA Installation Information

This document provides information about the CUDA installation option in the setup package.

## What Gets Installed

When you choose to install CUDA during setup, the following will be installed:

### Development Tools
- **gcc** - GNU C Compiler
- **g++** - GNU C++ Compiler
- **make** - Build automation tool
- **cmake** - Cross-platform build system
- **build-essential** - Meta-package with essential build tools

### System Monitoring
- **htop** - Interactive process viewer
- **nvtop** - NVIDIA GPU monitoring tool

### CUDA Components
- **CUDA Toolkit 13.0** - Complete CUDA development toolkit
  - CUDA compiler (nvcc)
  - CUDA libraries
  - CUDA samples
  - Development headers
- **NVIDIA Open Kernel Modules** - Open-source NVIDIA drivers

## Installation Process

The script performs these steps:

1. Downloads CUDA keyring from NVIDIA
2. Adds NVIDIA CUDA repository to APT sources
3. Updates package lists
4. Installs CUDA Toolkit 13.0
5. Installs NVIDIA open kernel modules
6. Configures environment variables in ~/.bashrc:
   - Adds CUDA binaries to PATH
   - Adds CUDA libraries to LD_LIBRARY_PATH

## Environment Variables

The following are automatically added to your ~/.bashrc:

```bash
export PATH=/usr/local/cuda-13.0/bin${PATH:+:${PATH}}
export LD_LIBRARY_PATH=/usr/local/cuda-13.0/lib64${LD_LIBRARY_PATH:+:${LD_LIBRARY_PATH}}
```

## Verification

After installation and reboot, verify CUDA is working:

### Check NVIDIA Driver
```bash
nvidia-smi
```
Expected output: GPU information, driver version, CUDA version

### Check CUDA Compiler
```bash
nvcc --version
```
Expected output: nvcc compiler version 13.0

### Monitor GPU
```bash
nvtop
```
Shows real-time GPU usage, memory, temperature

### Test CUDA (Optional)
```bash
cd /usr/local/cuda-13.0/samples/1_Utilities/deviceQuery
sudo make
./deviceQuery
```

## Compatible GPUs

CUDA 13.0 supports:
- RTX 50 Series (Blackwell)
- RTX 40 Series (Ada Lovelace)
- RTX 30 Series (Ampere)
- RTX 20 Series (Turing)
- GTX 16 Series
- Tesla/Quadro/A-series datacenter GPUs
- Compute Capability 3.5 and higher

## Disk Space Requirements

- CUDA Toolkit: ~3-4 GB
- NVIDIA drivers: ~500 MB
- Total: ~4-5 GB free space needed

## Troubleshooting

### nvidia-smi shows "NVIDIA-SMI has failed"
- Reboot is required after NVIDIA driver installation
- Run: `sudo reboot`

### nvcc not found
- Source your bashrc: `source ~/.bashrc`
- Or log out and log back in
- Verify PATH: `echo $PATH | grep cuda`

### Driver conflicts with Nouveau
If open-source Nouveau driver conflicts:
```bash
sudo bash -c "echo blacklist nouveau > /etc/modprobe.d/blacklist-nvidia-nouveau.conf"
sudo bash -c "echo options nouveau modeset=0 >> /etc/modprobe.d/blacklist-nvidia-nouveau.conf"
sudo update-initramfs -u
sudo reboot
```

### Different CUDA version needed
To install a different version, edit install.sh:
- Line 122: Change `cuda-toolkit-13-0` to desired version
  - CUDA 12.0: `cuda-toolkit-12-0`
  - CUDA 11.8: `cuda-toolkit-11-8`
- Line 133-134: Update paths to match version

## Uninstalling CUDA

If you need to remove CUDA:

```bash
sudo apt-get --purge remove "*cuda*" "*nvidia*"
sudo apt-get autoremove
sudo apt-get autoclean
```

Then remove from ~/.bashrc:
```bash
nano ~/.bashrc
# Remove the CUDA Toolkit section
source ~/.bashrc
```

## Using CUDA

### Compile CUDA code
```bash
nvcc my_program.cu -o my_program
./my_program
```

### CMake with CUDA
```cmake
project(MyProject CUDA CXX)
find_package(CUDA REQUIRED)
cuda_add_executable(my_app main.cu)
```

### Python with CUDA
```bash
# PyTorch with CUDA
pip install torch torchvision torchaudio --index-url https://download.pytorch.org/whl/cu130

# TensorFlow with CUDA
pip install tensorflow[and-cuda]
```

## Additional Resources

- [NVIDIA CUDA Documentation](https://docs.nvidia.com/cuda/)
- [CUDA Installation Guide](https://docs.nvidia.com/cuda/cuda-installation-guide-linux/)
- [CUDA Samples](https://github.com/NVIDIA/cuda-samples)
- [CUDA Toolkit Archive](https://developer.nvidia.com/cuda-toolkit-archive)

## Notes

- CUDA installation is **optional** - skip it if you don't have an NVIDIA GPU
- Installation takes 10-20 minutes depending on internet speed
- Reboot is required for drivers to load
- The script uses CUDA 13.0 which supports the latest GPUs
- Environment variables only take effect in new terminal sessions
