docker run --rm --name docker_registry_proxy -it \​
-p 0.0.0.0:3128:3128 \​
-v $(pwd)/docker_mirror_cache:/docker_mirror_cache \​
-v $(pwd)/docker_mirror_certs:/ca \​
-e REGISTRIES="k8s.gcr.io gcr.io quay.io your.own.registry another.public.registry" \​
-e AUTH_REGISTRIES="auth.docker.io:dockerhub_username:dockerhub_password your.own.registry:username:password" \​
tiangolo/docker-registry-proxy:latest
