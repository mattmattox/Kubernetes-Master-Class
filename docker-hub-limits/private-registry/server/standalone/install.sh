docker run -d --restart=always --name registry \​
  -v "$(pwd)"/certs:/certs \​
  -e REGISTRY_HTTP_ADDR=0.0.0.0:443 \​
  -e REGISTRY_HTTP_TLS_CERTIFICATE=/certs/domain.crt \​
  -e REGISTRY_HTTP_TLS_KEY=/certs/domain.key \​
  -p 443:443 \​
  registry:2
