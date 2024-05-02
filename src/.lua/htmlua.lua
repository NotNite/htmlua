local htmlua = {}

---@alias Displayable string | number | boolean
---@alias DefaultProps table<string, Displayable>
---@alias DefaultChildren Displayable[]
---@alias PropsOrChildren<P, C> `P` | `C` | Displayable

-- LuaLS generics seem kinda broken right now lol
---@alias Element<P, C> fun(args: PropsOrChildren<`P`, `C`>?): Displayable
---@alias Component<P, C> fun(props: `P`, children: `C`): Displayable | Displayable[]

---@class ElementConfig
---@field close boolean?
---@field empty boolean?

---@generic P: {}
---@generic C: {}
---@param args PropsOrChildren<`P`, `C`>?
---@return { props: `P`, children: `C`, boolean_props: string[] }
function htmlua.parse(args)
  local props = {}
  local children = {}
  local boolean_props = {}

  if type(args) == "table" then
    for k, v in pairs(args) do
      if type(k) == "number" then
        table.insert(children, v)
      elseif k == "_" then
        for _, prop in ipairs(v) do
          table.insert(boolean_props, prop)
        end
      else
        props[k] = tostring(v)
      end
    end
  elseif args then
    table.insert(children, args)
  end

  return {
    props = props,
    children = children,
    boolean_props = boolean_props,
  }
end

---@param str string
---@return string
function htmlua.escape(str)
  local ret = str:gsub("&", "&amp;")
  ret = ret:gsub("<", "&lt;")
  ret = ret:gsub(">", "&gt;")
  ret = ret:gsub('"', "&quot;")
  ret = ret:gsub("'", "&#39;")
  return ret
end

---@param config ElementConfig?
---@return ElementConfig
local function assign_config(config)
  local default = {
    close = true,
    empty = false,
  }

  if config then
    for k, v in pairs(config) do
      default[k] = v
    end
  end

  return default
end

---@generic P: { _props: string[]? }
---@generic C: {}
---@param name string
---@param config ElementConfig?
---@return Element<`P`, `C`>
function htmlua.elem(name, config)
  local cfg = assign_config(config)
  ---@param args PropsOrChildren<`P`, `C`>?
  return function(args)
    local str = "<" .. name
    local parsed = htmlua.parse(args)

    for k, v in pairs(parsed.props) do
      local display = htmlua.display(v)
      if display then
        display = htmlua.escape(display)
        local entry = k .. '="' .. display .. '"'
        str = str .. " " .. entry
      end
    end

    for _, prop in ipairs(parsed.boolean_props) do
      str = str .. " " .. prop
    end

    if cfg.empty and #parsed.children == 0 then
      str = str .. " />"
      return str
    end

    str = str .. ">"

    for _, child in ipairs(parsed.children) do
      local display = htmlua.display(child)
      if display then
        str = str .. display
      end
    end

    if cfg.close then
      str = str .. "</" .. name .. ">"
    end

    return str
  end
end

---@param tbl (Displayable | Displayable[])[]
---@return string
local function recursive_concat(tbl)
  local str = ""

  for _, v in ipairs(tbl) do
    str = str .. htmlua.display(v)
  end

  return str
end

---@return string?
function htmlua.display(value)
  if type(value) == "table" then
    return recursive_concat(value)
  elseif
    type(value) == "string"
    or type(value) == "number"
    or type(value) == "boolean"
  then
    return tostring(value)
  end
end

---@generic P
---@generic C
---@param func Component<`P`, `C`>
---@return Element<`P`, `C`>
function htmlua.component(func)
  ---@param args PropsOrChildren<`P`, `C`>
  return function(args)
    local parsed = htmlua.parse(args)
    return htmlua.display(func(parsed.props, parsed.children))
  end
end

return htmlua
