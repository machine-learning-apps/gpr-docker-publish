FROM docker:19.03.2 as runtime

LABEL "com.github.actions.name"="Publish Docker Images to GPR"
LABEL "com.github.actions.description"="Publish Docker Images to the GitHub Package Registry"
LABEL "com.github.actions.icon"="layers"
LABEL "com.github.actions.color"="purple"

RUN apk update \
  && apk upgrade \
  && apk add --no-cache git curl jq

ADD entrypoint.sh /entrypoint.sh
RUN chmod +x /entrypoint.sh

ENTRYPOINT ["/entrypoint.sh"]
