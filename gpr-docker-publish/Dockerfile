FROM docker:19.03.2 as runtime
LABEL "maintainer"="Hamel Husain"

RUN apk update \
  && apk upgrade \
  && apk add --no-cache git

ADD entrypoint.sh /entrypoint.sh
RUN chmod +x /entrypoint.sh'

ENTRYPOINT ["/entrypoint.sh"]