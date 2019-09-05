FROM docker:19.03.2 as runtime

LABEL "com.github.actions.name"="Publish Docker Images to GPR"
LABEL "com.github.actions.description"="Publish Docker Images to the GitHub Package Registry"
LABEL "com.github.actions.icon"="layers"
LABEL "com.github.actions.color"="purple"
LABEL "repository"="https://github.com/machine-learning-apps"
LABEL "homepage"="http://github.com/actions"
LABEL "maintainer"="Hamel Husain <hamel.husain@gmail.com>"

RUN apk update \
  && apk upgrade \
  && apk add --no-cache git

ADD entrypoint.sh /entrypoint.sh
RUN chmod +x /entrypoint.sh

ENTRYPOINT ["/entrypoint.sh"]