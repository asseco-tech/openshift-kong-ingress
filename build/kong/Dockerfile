FROM docker.io/${IMAGE_NAME}:${IMAGE_TAG}
LABEL KONG_VERSION=${IMAGE_TAG}

USER root
RUN apk --no-cache add tzdata
ENV TZ="Europe/Warsaw"

# instaluje dodatkowy pakiet dla środowiska LUA: pakiet lua-resty-jwt
RUN luarocks install lua-resty-jwt

# instaluje skrypt dla livenessProbe
COPY liveness_probe.sh /opt/kong/
RUN chmod a+xr /opt/kong/liveness_probe.sh

# konfiguracja pluginów
COPY plugins /opt/kong/plugins
ENV KONG_PLUGINS="bundled${KONG_PLUGINS}"
ENV KONG_LUA_PACKAGE_PATH="/opt/?.lua;;"

USER kong
