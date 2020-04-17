FROM docker.io/siriuszg/${IMAGE_NAME}:${IMAGE_TAG}

USER root
RUN apk --no-cache add curl tzdata
ENV TZ="Europe/Warsaw"

# instaluje skrypt dla livenessProbe
RUN mkdir -p /opt/kong/
COPY liveness_probe.sh /opt/kong/
RUN chmod a+xr /opt/kong/liveness_probe.sh
