#!/bin/bash

DockerHubUsername=""
DockerHubPassword=""  #It's recommend that you use a PAT instead of a password https://docs.docker.com/docker-hub/access-tokens/
IMAGE="ratelimitpreview/test"
TOKEN=$(curl -s "https://auth.docker.io/token?service=registry.docker.io&scope=repository:$IMAGE:pull" 2>/dev/null | jq -r .token)
curl --head -H "Authorization: Bearer $TOKEN" https://registry-1.docker.io/v2/$IMAGE/manifests/latest 2>/dev/null | grep ^RateLimit-
