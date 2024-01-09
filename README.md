# htmlua

htmlua converts this:

```lua
document {
  html {
    head {
      meta { charset = "utf-8" },
      title "Hello, world!"
    },

    body {
      h1 "Hello, world!",
      p "This is a paragraph."
    }
  }
}
```

into this:

```html
<!DOCTYPE html>
<html>
  <head>
    <meta charset="utf-8" />
    <title>Hello, world!</title>
  </head>
  <body>
    <h1>Hello, world!</h1>
    <p>This is a paragraph.</p>
  </body>
</html>
```

...all dynamically at request time. It is effectively serverside rendering where your output file is being rendered from Lua functions. It supports a component-like system for reusing blocks of HTML. It runs on six operating systems with a single file thanks to the [redbean](https://redbean.dev/) web server.

It is suggested to read `src/pages/index.html.lua`, as it is heavily commented.

## Why?

I recently read [Ben Visness](https://bvisness.me/luax/)'s article about their custom Lua dialect for JSX-like elements. I thought I could build a system just as flexible to use in vanilla Lua.

## Installation

- Copy the contents of this repository into a new folder.
- Download `redbean.com` from the redbean website.
- Execute `./run.sh` to pack the web server and run it.

## How it works

This abuses a few tricks in the Lua language spec:

- Functions that take a single argument can be called without parenthesis (`ident("a")` = `ident "a"`)
- Key value pairs and array-like entries into tables can be mixed (`{ a = "b", "c" }`)

The keywords are actually functions in the global scope that create the HTML element and return a string. Props are identified by key/value pairs and children are identified as entries in the table. Valueluess props (such as `autoplay` on the `video` element) can be specified with `_ = { "autoplay" }`.

## Using htmlua

### Creating your first page

Create `pages/index.html.lua`:

```lua
return function()
  return document {
    html {
      head {
        meta { charset = "utf-8" },
        title "Hello, world!"
      },

      body {
        h1 "Hello, world!",
        p "This is a paragraph."
      }
    }
  }
end
```

### Adding more HTML elements

Put a line like this in your `.init.lua`:

```lua
h2 = htmlua.elem("h2")
```

You can provide a second argument for options for this element:

- `close: boolean = true` - whether to close the element with `</name>`
- `empty: boolean = false` - whether to close the element wiith `/>` if there are no children

### Creating a reusable component

```lua
local htmlua = require("htmlua")

local MyComponent = htmlua.component(function(props, children)
  return {
    h1("Hello, " .. props.name .. "!"),
    p "This is a reusable component."
  }
end)

return function()
  return document {
    html {
      head {
        meta { charset = "utf-8" }
      },

      body {
        MyComponent { name = "world" },
        hr {},
        MyComponent { name = "Lua" }
      }
    }
  }
end
```

### Routing

Paths get tried in this order:

- `pages/:path/index.lua`
- `pages/:path/index.html.lua`
- `pages/:path.html.lua`
- `pages/:path.lua`
