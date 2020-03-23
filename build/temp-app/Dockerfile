FROM docker.io/kong:2.0.1

LABEL KONG_VERSION=2.0.1

# instaluje dodatkowy pakiet dla środowiska LUA: pakiet lua-resty-jwt
USER root
RUN luarocks install lua-resty-jwt

USER kong
