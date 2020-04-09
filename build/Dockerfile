FROM docker.io/${IMAGE_NAME}:${IMAGE_TAG}

LABEL KONG_VERSION=${IMAGE_TAG}

# instaluje dodatkowy pakiet dla środowiska LUA: pakiet lua-resty-jwt
USER root
RUN luarocks install lua-resty-jwt
# konfiguracja pluginów
COPY plugins /opt/kong/plugins
ENV KONG_PLUGINS="bundled${KONG_PLUGINS}"
ENV KONG_LUA_PACKAGE_PATH="/opt/?.lua;;"

USER kong
