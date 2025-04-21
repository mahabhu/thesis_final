```
# Pull an Ubuntu image (replace <version> with specific version like 22.04, 20.04 etc.)
docker pull ubuntu:<version>

# Create and start an Ubuntu container with bash shell
docker run -it --name my_ubuntu_container ubuntu:<version> /bin/bash

# List running containers
docker ps

# List all containers (including stopped ones)
docker ps -a

# Restart and attach to an Ubuntu container
docker start -ai my_ubuntu_container

# Open a new shell in a running Ubuntu container
docker exec -it my_ubuntu_container /bin/bash

# To exit from a container (run inside container)
exit

# Save Ubuntu container as a new image
docker commit my_ubuntu_container my_custom_ubuntu_image

# Remove an Ubuntu container
docker rm my_ubuntu_container

# Remove an Ubuntu image
docker rmi ubuntu:<version>

```