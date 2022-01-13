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
