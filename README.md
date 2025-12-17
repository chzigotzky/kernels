![amilinux1](https://github.com/user-attachments/assets/5241f6bf-3519-4c40-8694-13cacefa5fe9)

Linux kernels for X1000 and e5500 (X5000/20, X5000/40, Mirari, and QEMU VMs) PowerPC computers.

Older Linux kernels and further downloads for X1000 and X5000 computers:

http://www.supertuxkart-amiga.de/amiga/x1000.html#downloads

Linux kernels for the A1222:

http://www.fun-kart-racer.de/2bb57b2bbf87b668a94c/lxtest.html

User Name: tabor

Password: amigaone

Dockerfile for a PowerPC cross compiling environment:

```
# Base image: Ubuntu 20.04
FROM ubuntu:20.04

# Deactive interactive inputs
ENV DEBIAN_FRONTEND=noninteractive

# Upgrading the userland and installing the kernel cross compiling environment 
RUN apt-get update && apt-get upgrade -y && apt-get install -y \
bash \
vim \
git \
curl \
gcc-9-powerpc-linux-gnu \
g++-9-powerpc-linux-gnu \
build-essential \
libncurses5-dev \
u-boot-tools \
flex \
bison \
libssl-dev \
bc \
linux-firmware \
kmod \
libelf-dev \
neofetch \
&& update-alternatives --install /usr/bin/powerpc-linux-gnu-gcc powerpc-linux-gnu-gcc /usr/bin/powerpc-linux-gnu-gcc-9 10 \
&& update-alternatives --install /usr/bin/powerpc-linux-gnu-g++ powerpc-linux-gnu-g++ /usr/bin/powerpc-linux-gnu-g++-9 10 \
&& useradd -m -d /home/amigaone -p $(openssl passwd -1 --salt xyz amigaone) amigaone

# Mount point in the container
WORKDIR /kernel_dev

# Creating the volume on the host (directory on the host) 
VOLUME ["/kernel_dev"]

```
