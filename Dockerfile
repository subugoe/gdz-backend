FROM redis:3.0


ENV EFFECTIVE_UID=10021
ENV EFFECTIVE_GID=999

RUN usermod  --uid "${EFFECTIVE_UID}" --shell /bin/bash --home /home daemon > /dev/null && \
  groupmod --gid "${EFFECTIVE_GID}" daemon > /dev/null


USER $EFFECTIVE_UID
