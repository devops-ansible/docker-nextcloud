# Remove image/tag from Docker Hub using its API

=> has to be done with `devopsansiblede/nextcloud:tmp` after build of `devopsansiblede/nextcloud:full` ...

https://devopsheaven.com/docker/dockerhub/2018/04/09/delete-docker-image-tag-dockerhub.html

```bash
#!/usr/bin/env bash

USERNAME="docker_username"
PASSWORD="docker_password"
ORGANIZATION="organization"
IMAGE="image"
TAG="tag"

login_data() {
cat <<EOF
{
  "username": "$USERNAME",
  "password": "$PASSWORD"
}
EOF
}

TOKEN=`curl -s -H "Content-Type: application/json" -X POST -d "$(login_data)" "https://hub.docker.com/v2/users/login/" | jq -r .token`

curl "https://hub.docker.com/v2/repositories/${ORGANIZATION}/${IMAGE}/tags/${TAG}/" \
-X DELETE \
-H "Authorization: JWT ${TOKEN}"
```

# Include basic test in docker build process

For the simple tests, the Workflow should start a container of a built image, give it up to one minute to boot and expect a valid HTTP response on the default HTTP port (within the container).

Also the home directory of NC should contain files after container start.
