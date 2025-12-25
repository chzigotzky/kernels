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
wget \
tree \
&& update-alternatives --install /usr/bin/powerpc-linux-gnu-gcc powerpc-linux-gnu-gcc /usr/bin/powerpc-linux-gnu-gcc-9 10 \
&& update-alternatives --install /usr/bin/powerpc-linux-gnu-g++ powerpc-linux-gnu-g++ /usr/bin/powerpc-linux-gnu-g++-9 10 \
&& useradd -m -d /home/amigaone -p $(openssl passwd -1 --salt xyz amigaone) amigaone \
&& echo "patch -p0 <" >> /home/amigaone/.bash_history \
&& echo "nproc" >> /home/amigaone/.bash_history \
&& echo "make CROSS_COMPILE=powerpc-linux-gnu- ARCH=powerpc oldconfig" >> /home/amigaone/.bash_history \
&& echo "time make -j$(nproc) CROSS_COMPILE=powerpc-linux-gnu- ARCH=powerpc vmlinux" >> /home/amigaone/.bash_history \
&& echo "make CROSS_COMPILE=powerpc-linux-gnu- ARCH=powerpc zImage" >> /home/amigaone/.bash_history \
&& echo "gzip -9 vmlinux.strip" >> /home/amigaone/.bash_history \
&& echo "time make -j$(nproc) CROSS_COMPILE=powerpc-linux-gnu- ARCH=powerpc modules" >> /home/amigaone/.bash_history \
&& echo "# make CROSS_COMPILE=powerpc-linux-gnu- ARCH=powerpc modules_install" >> /home/amigaone/.bash_history \
&& echo "time make -j$(nproc) CROSS_COMPILE=powerpc-linux-gnu- ARCH=powerpc uImage" >> /home/amigaone/.bash_history \
&& echo "time make -j$(nproc) CROSS_COMPILE=powerpc-linux-gnu- ARCH=powerpc modules" >> /home/amigaone/.bash_history \
&& echo "# make CROSS_COMPILE=powerpc-linux-gnu- ARCH=powerpc modules_install" >> /home/amigaone/.bash_history

# A good directory for the volume mount point in the container
WORKDIR /kernel_dev

# Creating the volume on the host (directory on the host) 
VOLUME ["/kernel_dev"]
