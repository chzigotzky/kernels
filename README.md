![amilinux1](https://github.com/user-attachments/assets/5241f6bf-3519-4c40-8694-13cacefa5fe9)

Linux kernels for X1000 and e5500 (X5000/20, X5000/40, Mirari, and QEMU VMs) PowerPC computers.

Older Linux kernels and further downloads for X1000 and X5000 computers:

http://www.supertuxkart-amiga.de/amiga/x1000.html#downloads

Linux kernels for the A1222:

http://www.fun-kart-racer.de/2bb57b2bbf87b668a94c/lxtest.html

User Name: tabor

Password: amigaone

Clone this git repository with branches:

1. git clone git@github.com:chzigotzky/kernels.git 
2. cd kernels
3. git branch --track 5_10 origin/5_10
4. git branch --track 6_12 origin/6_12

There are some Dockerfiles for building the Linux PPC cross compiling and test images.

These images can be used for Docker containers or for pods in Kubernetes.

The biggest advantage is, that the Linux PowerPC cross-compiling environment can be easily rolled out and is always the same on a wide variety of computers.

Local (You must be in the directory containing the Dockerfile) docker build -t ubuntu_kernel_dev .

From git: docker build -t ubuntu_kernel_dev https://github.com/chzigotzky/kernels.git#main

From git with buildx: docker buildx build -t ubuntu_kernel_dev https://github.com/chzigotzky/kernels.git#main

Using the Dockerfile_kernel_test for the Linux PPC kernel test image:

Local (You must be in the directory containing the Dockerfile) docker build -t ubuntu_kernel_test -f Dockerfile_kernel_test .

From git: docker build -t ubuntu_kernel_test -f Dockerfile_kernel_test https://github.com/chzigotzky/kernels.git#main

From git with buildx: docker buildx build -t ubuntu_kernel_test -f Dockerfile_kernel_test https://github.com/chzigotzky/kernels.git#main

Network between ubuntu_kernel_dev and ubuntu_kernel_test:

1. docker network create my-network
2. docker run -d -p 9090:8080 --name ubuntu_kernel_dev-container --network my-network -v /kernel_dev:/kernel_dev ubuntu_kernel_dev
3. docker run -d -p 9080:3389 -p 9091:8080 --name ubuntu_kernel_test-container --network my-network -v /kernel_dev:/kernel_dev ubuntu_kernel_test

With Docker compose:

1. docker compose up -d --build (In the directory where the compose.yaml file is located. --build deletes also the cache)
2. docker compose push (Push the images to the local registry)
3. curl http://localhost:5000/v2/_catalog (Display the images in the local registry)

Delete the complete local registry volume:

1. docker ps -a
2. docker stop f352821ed760
3. docker inspect f352821ed760 | grep -A5 Mounts
4. docker volume ls
5. docker rm f352821ed760
6. docker volume rm 0a3510ae1c236f3fc856f403b3a411446a7ad4a880da879b25fc3f3b68c2e1b0

Minikube (Kubernetes):

1. minikube start
2. minikube image load ubuntu_kernel_dev:latest
3. minikube image ls
4. minikube mount /kernel_dev:/kernel_dev &
5. Deployment: kubectl apply -f Kubernetes.yaml
6. Check default namespace: kubectl get pods && kubectl get deployments && kubectl get services 
7. Check all namespaces: kubectl get pods -A && kubectl get deployments -A && kubectl get services -A
8. Check LoadBalancer: kubectl get services 
9. kubectl port-forward Name_of_the_pod 9090:8080 & or kubectl proxy --address='0.0.0.0' --accept-hosts='^.*$' and http://<IP ADDRESS>:8001/api/v1/namespaces/default/services/kernel-dev-service:9090/proxy/
10. Connect to a pod: kubectl exec -it Name_of_the_pod -- bash
11. Delete deployment: kubectl delete deployment kernel-dev 
12. Delete pod: kubectl delete pod Name_of_the_pod
13. Delete service: kubectl delete service kernel-dev-service
14. minikube image ls
15. minikube image remove <image:tag>
16. minikube dashboard

Delete images that are no longer needed. Otherwise, the worker node will eventually run out of space:

1. docker buildx prune 
2. crictl rmi --prune

Building the images with Docker compose:

<img width="1920" height="1080" alt="Docker_compose_with_local_registry" src="https://github.com/user-attachments/assets/4479cb76-d07e-4397-b1e8-aaa39a469233" />

Monitoring the Docker container while compiling the kernel:

<img width="1600" height="1200" alt="Dockerfile_for_a_Linux_PPC_cross_compiling_image" src="https://github.com/user-attachments/assets/3b2c96de-e4d6-4f57-9fe3-9bdc9c5b26d6" />

Monitoring the Docker containers while compiling and testing the kernel (Docker Swarm):

<img width="1600" height="1200" alt="Kernel_6 12 67_PowerPC" src="https://github.com/user-attachments/assets/a91291aa-0587-46b7-9613-6fc5b2df24e2" />

Monitoring the Kubernetes pod while compiling the kernel:

<img width="1600" height="1200" alt="Kernel_6 12 64_PowerPC" src="https://github.com/user-attachments/assets/4e555bf4-f934-4ad2-a6dd-47df6815c29a" />

Monitoring the Docker containers in Portainer while compiling the kernel for e5500 machines (1600% = 16 CPU cores fully utilized):

<img width="1600" height="1200" alt="Kernel_6 12 65_PowerPC-2" src="https://github.com/user-attachments/assets/8e761f73-6617-4be8-bca1-15383efa8bf1" />

Testing the Linux PPC kernel in a Docker container:

<img width="1280" height="1024" alt="Linux_PPC_kernel_test_docker_image" src="https://github.com/user-attachments/assets/74e4e291-ff2b-4617-ae02-434b48f47fc0" />

