-- inspiration: https://github.com/brndmg/kong-plugin-hello-world

return {
  name = "asseco-myheader",
  --  no_consumer = true,
  fields = {
    { config = {
        type = "record",
        fields = {
            {header_flag = { type = "boolean", default = true },},
            {header_value = { type = "string", default = "plugin asseco myheader" }},
        }
    }}
  }
}
