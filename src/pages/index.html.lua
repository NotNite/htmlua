local htmlua = require("htmlua")

-- Components can be defined with htmlua.component. They return a wrapper
-- function that parses the arguments into separate props and children.
-- It is suggested to store reused components in src/.lua/components, which can
-- be loaded with require("components.<filename>").
local HelloWorld = htmlua.component(function(props, children)
  return {
    -- "p" is a global in the Lua state (defined in .init.lua), created with
    -- htmlua.elem. These are actually functions that take a table as arguments
    -- and return a string. To add missing elements, declare them in .init.lua.
    h2("Hello, " .. props.name .. "!"),

    -- Components can either be called with a string, number, boolean, or table.
    p {
      "Your lucky number is ",
      -- Numbers and booleans are converted to strings.
      props.lucky_number,
      ".",
      -- Nil values are ignored.
      nil,
    },

    -- Simply pass the children into the table to use them. Tables in tables
    -- will be flattened by htmlua for you.
    children,
  }
end)

-- Components can return strings, numbers, booleans, or tables.
local UnixTimestamp = htmlua.component(function(props, children)
  return os.time()
end)

local App = htmlua.component(function(props, children)
  local time = os.date("%Y-%m-%d %H:%M:%S")
  return {
    h1 {
      -- Pass props into the table as key-value pairs.
      class = "header",
      -- Props are mixed with children.
      "Hello, htmlua!",
    },

    -- p(value) and p { value } are equivalent.
    p { "The current time is " .. time },

    -- Reuse components by calling them like elements.
    HelloWorld {
      name = "world",
      lucky_number = 7,
      span "This is a child element!",
    },
    HelloWorld { name = "Lua", lucky_number = 42 },

    input {
      type = "checkbox",
      -- Boolean props can be passed as a table of strings with the "_" key.
      _ = { "checked" },

      "Check me!",
    },

    -- Elements with no data must either be invoked with an empty table...
    br {},
    -- or no arguments at all.
    UnixTimestamp(),

    -- Props are escaped automatically.
    p { title = 'This is a title "with quotes".', "Hover over me!" },
  }
end)

-- htmlua files return functions that return strings. These are called every request.
return function()
  return document {
    html {
      head {
        meta { charset = "utf-8" },
        title "Hello, htmlua!",
        style [[
          .header {
            color: blue;
          }
        ]],
      },

      body {
        App {},
      },
    },
  }
end
