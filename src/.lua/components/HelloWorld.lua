---@type Element<{ name: string }, {}>
return require("htmlua").component(function(props, children)
  return {
    p("Hello, " .. props.name .. "!"),
    children,
  }
end)
