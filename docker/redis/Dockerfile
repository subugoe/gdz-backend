FROM redis:3.0


#ENV EFFECTIVE_UID=10021
ENV EFFECTIVE_GID=999

#RUN usermod  --uid "${EFFECTIVE_UID}" redis > /dev/null 
RUN groupmod --gid "${EFFECTIVE_GID}" redis > /dev/null

USER redis
