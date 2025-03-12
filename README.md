# Docker

```
docker pull <image_name>              # Pull an image
docker run -it --name <container_name> <image_name> /bin/bash  # Create and start a container
docker ps                              # List running containers
docker ps -a                           # List all containers
docker start -ai <container_name>      # Restart and attach to a container
docker exec -it <container_name> /bin/bash  # Open a new shell in a running container
docker exit                            # Exit container
docker commit <container_name> <new_image_name>  # Save container as an image
docker rm <container_name>             # Remove a container
docker rmi <image_name>                # Remove an image
docker cp container_id:/path/in/container /path/on/host


```