FROM docker.io/${IMAGE_NAME}:${IMAGE_TAG}

LABEL KONG_VERSION=${IMAGE_TAG}

# instaluje dodatkowy pakiet dla środowiska LUA: pakiet lua-resty-jwt
USER root
RUN luarocks install lua-resty-jwt

USER kong
