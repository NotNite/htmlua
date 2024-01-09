local HelloWorld = require("components.HelloWorld")

return function()
  local time = os.date("%Y-%m-%d %H:%M:%S")
  return document {
    html {
      head {
        meta { charset = "utf-8" },
        title "Hello, world!",
        style [[
          .header {
            color: red;
          }
        ]],
      },
      body {
        h1 {
          class = "header",
          "Hello, world!",
        },
        HelloWorld { name = "world" },
        HelloWorld { name = "Lua" },
        p("The current time is " .. time),
        img { src = "/duck.png" },
      },
    },
  }
end
