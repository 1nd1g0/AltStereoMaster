from setuptools import setup
from torch.utils.cpp_extension import BuildExtension, CUDAExtension
import sys
import platform

# Detect platform and set appropriate compiler flags
is_windows = platform.system() == 'Windows'
is_linux = platform.system() == 'Linux'

if is_windows:
    cxx_flags = [
        '/std:c++17',  # Force C++17 on MSVC
        '/MD',         # Runtime multithreaded DLL
    ]
    nvcc_flags = [
        '-std=c++17',
        '-allow-unsupported-compiler',
        '-Xcompiler', '/MD',
        '--expt-relaxed-constexpr',
    ]
elif is_linux:
    cxx_flags = [
        '-std=c++17',
        '-fPIC',
        '-O2',
    ]
    nvcc_flags = [
        '-std=c++17',
        '--expt-relaxed-constexpr',
        '-Xcompiler', '-fPIC',
        # Optional: specify gencode according to your GPU architecture
        # '-gencode=arch=compute_75,code=sm_75',
    ]
else:
    raise RuntimeError(f"Unsupported platform: {platform.system()}")

setup(
    name='forward_warp_cuda',
    ext_modules=[
        CUDAExtension(
            name='forward_warp_cuda',
            sources=[
                'forward_warp_cuda.cpp',
                'forward_warp_cuda_kernel.cu',
            ],
            extra_compile_args={
                'cxx': cxx_flags,
                'nvcc': nvcc_flags,
            }
        ),
    ],
    cmdclass={
        'build_ext': BuildExtension.with_options(use_ninja=True)
    }
)
