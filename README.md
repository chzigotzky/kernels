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
wget \
tree \
ncat \
sysstat \
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

COPY renesas_usb_fw.mem /lib/firmware/

# Preparing kernel compilation
RUN export KERNEL_SRC_LINK="https://cdn.kernel.org/pub/linux/kernel/v5.x/linux-5.10.247.tar.xz" \
&& export KERNEL_SRC_FILE="/root/kernel_src.tar.xz" \
&& export KERNEL_SRC_DEST="/root/" \
&& wget -O ${KERNEL_SRC_FILE} ${KERNEL_SRC_LINK} \
&& tar xvf ${KERNEL_SRC_FILE} -C ${KERNEL_SRC_DEST}

CMD ["sh", "-c", "while true; do BODY=\"The Docker container for the cross compiling of A-EON PowerPC Linux kernels works! $(uname -a) $(mpstat -P ALL 1 1)\"; { printf \"HTTP/1.1 200 OK\\r\\nContent-Type: text/plain\\r\\nContent-Length: %s\\r\\nConnection: close\\r\\n\\r\\n%s\" \"${#BODY}\" \"$BODY\"; } | nc -l -p 8080; done"]
 
# sudo usermod -aG docker $USER
# docker build -t ubuntu_kernel_dev .
# Create a container and start it (Container status: <HOSTNAME/FQDN/IP ADDRESS>:9090): docker run -d -p 9090:8080 --name ubuntu_kernel_dev-container -v /kernel_dev:/kernel_dev ubuntu_kernel_dev 
# List all Docker containers: docker ps -a
# Connect to a container: docker exec -it ubuntu_kernel_dev-container bash
# Stop a docker container: docker stop <CONTAINER ID> (Changes remain in the image) 
# Start a docker container: docker start <CONTAINER ID>  
# Delete all Docker containers: docker rm $(docker ps -aq)
# Delete all Docker images: docker rmi $(docker images -q)
#
# Minikube (Kubernetes):
#
# minikube start
# minikube image load ubuntu_kernel_dev:latest
# minikube image ls
# minikube mount /kernel_dev:/kernel_dev &
# Deployment: kubectl apply -f Kubernetes.yaml
# Check default namespace: kubectl get pods && kubectl get deployments && kubectl get services 
# Check all namespaces: kubectl get pods -A && kubectl get deployments -A && kubectl get services -A 
# kubectl port-forward <Name of the pod> 9090:8080 &
# Connect to a pod: kubectl exec -it <Name of the pod> -- bash
# Delete deployment: kubectl delete deployment kernel-dev 
# Delete pod: kubectl delete pod <Name of the pod>
# Delete service: kubectl delete service kernel-dev-service
# minikube dashboard
```
