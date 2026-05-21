# StereoMaster

**AltStereoMaster** is a Linux version of GUI application for converting 2D videos into impressive 3D content using AI. It combines:
- [DepthCrafter](https://huggingface.co/tencent/DepthCrafter)  
- [Video Depth Anything](https://huggingface.co/depth-anything/Video-Depth-Anything)  
- [StereoCrafter](https://huggingface.co/TencentARC/StereoCrafter)


## 📣 News
- `2025/02/09` Initial commit.
- `2025/02/16` Update: Added downscale inpainting, anaglyph file merging, enhanced partial frames, improved StereoCrafter (mask dilation, blur, configurable chunking), refined color matcher (fixed preview vs. SBS mismatch), new outputs (4KHSBS, Right-Only, EXR export), plus various bug fixes.
- `2025/02/28` Early Blackwell support, improved color matching in inpainting, new mixed inpainting system, fixed missing frames and repeated frames at the end of each chunk, UI/UX enhancements, VDA split fix for batch_size, and improved installation process.
- `2026/05/21` Linux-only release: Cross-distribution compatible, dynamic dependency management, no hardcoded versions.


## Features

- **Depth map generation** using DepthCrafter or Video Depth Anything.
- **Splatting** (stereo shift) and **filling** (inpainting) with StereoCrafter.
- **User-friendly GUI** with:
  - Dynamic adjustments for disparity, convergence, and depth parameters.
  - Keyframes to modify 3D intensity over time.
  - Multiple preview modes (Original, Depth, Anaglyph, etc.).
  - Scene detection and merging of clips for longer videos.


## System Requirements

- **OS:** Linux (any modern distribution - Ubuntu, Debian, Fedora, Arch, etc.)  
- **GPU:** NVIDIA with CUDA support (RTX 3000/4000/5000 series or equivalent)  
  - **Required VRAM:** 12 GB (16 GB recommended)   
- **Python:** 3.10 or higher (3.12 recommended)  
- **Git:** Required for dependency management  
- **FFmpeg:** Required for video processing (installed automatically or via system package manager)  
- **NVIDIA Drivers:** Latest proprietary drivers with CUDA support  


## Installation Guide (Cross-Linux Portable)

> **Note:** After completing all installation steps, you can launch StereoMaster by running **`./launch_stereomaster.sh`** from the repository's root folder.

---

### 1. Install System Dependencies

First, install the required system packages. Choose the command appropriate for your distribution:

**Ubuntu/Debian-based:**
```bash
sudo apt update
sudo apt install -y python3 python3-venv python3-pip git ffmpeg curl wget build-essential cmake
```

**Fedora/RHEL-based:**
```bash
sudo dnf install -y python3 python3-pip python3-virtualenv git ffmpeg curl wget gcc gcc-c++ make cmake
```

**Arch Linux/Manjaro:**
```bash
sudo pacman -S --noconfirm python python-pip python-virtualenv git ffmpeg curl wget base-devel cmake
```

**OpenSUSE:**
```bash
sudo zypper install -y python3 python3-pip python3-virtualenv git ffmpeg curl wget patterns-devel-C-C++-devel_C_C++ cmake
```

> **Note:** FFmpeg is dynamically detected at runtime. If not installed via package manager, the app will attempt to use `imageio-ffmpeg` or search common paths.

---

### 2. Verify Python Installation

Ensure you have Python 3.10 or higher:

```bash
python3 --version
```

You should see something like:
```
Python 3.12.x
```

If `python3` is not found, try:
```bash
python --version
```

---

### 3. Clone the StereoMaster Repository

Navigate to your preferred installation directory and clone the repository:

```bash
cd ~
git clone https://github.com/murdavs/StereoMaster.git
cd StereoMaster
```

---

### 4. Create a Virtual Environment & Install Dependencies

1. **Create a new virtual environment:**
   ```bash
   python3 -m venv stereomaster_env
   ```

2. **Activate the virtual environment:**
   ```bash
   source stereomaster_env/bin/activate
   ```

3. **Upgrade pip and build tools:**
   ```bash
   pip install --upgrade pip setuptools wheel ninja
   ```

4. **Install dependencies:**
   ```bash
   pip install --use-pep517 --no-cache-dir -r requirements_linux.txt
   ```

   This installs PyTorch with automatic CUDA detection and all required packages without hardcoded versions.

5. **Build and install Forward-Warp extension:**
   ```bash
   pip install -e dependency/Forward-Warp
   cd dependency/Forward-Warp/Forward_Warp/cuda
   python setup.py install
   cd ../../../../
   ```

**Verify PyTorch & CUDA:**
```bash
python -c "import torch; print(f'PyTorch: {torch.__version__}'); print(f'CUDA Available: {torch.cuda.is_available()}')"
```

Expected output:
```
PyTorch: 2.x.x
CUDA Available: True
```

---

### 5. Install NVIDIA CUDA Toolkit (if not already installed)

Most distributions provide CUDA through their package managers. Alternatively, download from NVIDIA:

**Option A: Distribution Package (Recommended)**

- **Ubuntu/Debian:** `sudo apt install nvidia-cuda-toolkit`
- **Fedora:** `sudo dnf install cuda-toolkit`
- **Arch:** `sudo pacman -S cuda`

**Option B: NVIDIA Official Installer**

Download from: [NVIDIA CUDA Toolkit](https://developer.nvidia.com/cuda-toolkit)

Follow the installation instructions for your distribution.

---

### 6. Login to Hugging Face CLI & Download Model Weights

1. **Login to Hugging Face:**
   ```bash
   huggingface-cli login
   ```

   **How to get your token:**
   - [Create a Hugging Face account](https://huggingface.co/join) if you don't have one.
   - Go to [Settings > Access Tokens](https://huggingface.co/settings/tokens).
   - Click **New token**, give it a name, and select appropriate permissions (read access is sufficient).
   - Copy the token.

   > **Note:** When pasting your token in the terminal, it won't be visible for security reasons, but it is being entered correctly.

2. **Clone the required models into a `weights` folder:**
   ```bash
   cd ~/StereoMaster
   mkdir -p weights
   cd weights
   git clone https://huggingface.co/stabilityai/stable-video-diffusion-img2vid-xt-1-1
   git clone https://huggingface.co/tencent/DepthCrafter
   git clone https://huggingface.co/TencentARC/StereoCrafter
   ```

   **Troubleshooting:**
   - If cloning fails, visit the model page in your browser first (e.g., [stable-video-diffusion-img2vid-xt-1-1](https://huggingface.co/stabilityai/stable-video-diffusion-img2vid-xt-1-1)).
   - Go to the **Files** tab and accept the license agreement if prompted.
   - After accepting, retry the `git clone` command.

3. **Download depth models:**
   ```bash
   cd ~/StereoMaster
   mkdir -p checkpoints
   cd checkpoints
   curl -L -o video_depth_anything_vits.pth https://huggingface.co/depth-anything/Video-Depth-Anything-Small/resolve/main/video_depth_anything_vits.pth
   curl -L -o video_depth_anything_vitl.pth https://huggingface.co/depth-anything/Video-Depth-Anything-Large/resolve/main/video_depth_anything_vitl.pth
   ```

---

## Launch StereoMaster

After completing all installation steps:

### Option 1: Using the Launch Script (Recommended)

```bash
cd ~/StereoMaster
./launch_stereomaster.sh
```

The script will:
- Automatically detect your Python version (3.10+)
- Create a virtual environment if needed
- Activate the environment
- Launch StereoMaster

### Option 2: Manual Launch

```bash
cd ~/StereoMaster
source stereomaster_env/bin/activate
python StereoMaster.py
```

### Making the Launch Script Executable

If you get a "Permission denied" error, make the script executable:
```bash
chmod +x launch_stereomaster.sh
```

---

## Ko-fi Support

[![ko-fi](https://ko-fi.com/img/githubbutton_sm.svg)](https://ko-fi.com/3dultraenhancer)

If you find StereoMaster helpful or would like to support further development, consider [buying me a coffee](https://ko-fi.com/3dultraenhancer)). Thank you!

---

## License

Provided "as is." Use at your own risk; no warranty is given for potential data loss or system problems.

---

## Screenshot

Below is a sample image of **StereoMaster** in action:

![StereoMaster Screenshot](assets/screenshot.png)
