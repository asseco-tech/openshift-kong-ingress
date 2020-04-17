# Check HTTP Health for OpenShift livenessProbe.
# Workaround for kong 404 error "no Route matched" and 503 error (cache failed)

# Script Parameters:
# liveness_probe.sh <internal_kong_port> <internal_health_path> <proxy_kong_port> <proxy_health_path>

[ -d /usr/local/kong ] \
  && echo "$(hostname) proxy: " \
  || echo "$(hostname) controller: "

# health on internal kong port
HTTP_PORT=${1:-9001}
HTTP_PATH="${2:-/health}"
#echo "CHECK: http://localhost:${HTTP_PORT}${HTTP_PATH}"
curl -i -s "http://localhost:${HTTP_PORT}${HTTP_PATH}" \
  | grep -E "HTTP.*200" > /dev/null
if [ $? -ne 0 ]; then
  echo "Internal server health: http://localhost:${HTTP_PORT}${HTTP_PATH}"
  return 1
fi

# external service health on proxy kong port
HTTP_PORT=${3:-8000}
HTTP_PATH="${4:-/health}"
#echo "CHECK: http://localhost:${HTTP_PORT}${HTTP_PATH}"
curl -i -s "http://localhost:${HTTP_PORT}${HTTP_PATH}" \
  | tr '\r\n' ' ' \
  | grep -E "HTTP.*(404|500|502)" \
  | grep -E "Server:.*kong" > /dev/null
if [ $? -eq 0 ]; then
  echo "External service health: http://localhost:${HTTP_PORT}${HTTP_PATH}"
  return 1
fi

#echo "RET 0"
return 0
