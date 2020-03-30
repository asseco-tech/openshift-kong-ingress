-- inspiration: https://github.com/brndmg/kong-plugin-hello-world

return {
  no_consumer = true,
  fields = {
    header_flag = { type = "boolean", default = true },
    header_value = { type = "string", default = "mobile" }
  }
}
