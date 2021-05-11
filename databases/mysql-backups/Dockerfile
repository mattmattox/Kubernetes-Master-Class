FROM alpine:3.8

MAINTAINER Matthew Mattox matthew.mattox@rancher.com

RUN apk --no-cache add curl mariadb-client bash

ADD run.sh /run.sh
RUN chmod +x /run.sh
CMD bash /run.sh
