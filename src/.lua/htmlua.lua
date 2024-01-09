local htmlua = {}

---@alias Serializable string | number | boolean
---@alias DefaultProps table<string, Serializable>
---@alias DefaultChildren Serializable[]
---@alias PropsOrChildren<P, C> `P` | `C` | Serializable

-- LuaLS generics seem kinda broken right now lol
---@alias Element<P, C> fun(args: PropsOrChildren<`P`, `C`>): string
---@alias Component<P, C> fun(props: `P`, children: `C`): string | string[]

---@class ElementConfig
---@field close boolean?
---@field empty boolean?

---@generic P: {}
---@generic C: {}
---@param args PropsOrChildren<`P`, `C`>
---@return { props: `P`, children: `C`, valueless_props: string[] }
function htmlua.parse(args)
  local props = {}
  local children = {}
  local valueless_props = {}

  if type(args) == "table" then
    for k, v in pairs(args) do
      if type(k) == "number" then
        table.insert(children, v)
      elseif k == "_" then
        for _, prop in ipairs(v) do
          table.insert(valueless_props, prop)
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
    valueless_props = valueless_props,
  }
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
  ---@param args PropsOrChildren<`P`, `C`>
  return function(args)
    local str = "<" .. name
    local parsed = htmlua.parse(args)

    for k, v in pairs(parsed.props) do
      local entry = k .. '="' .. v .. '"'
      str = str .. " " .. entry
    end

    for _, prop in ipairs(parsed.valueless_props) do
      str = str .. " " .. prop
    end

    if cfg.empty and #parsed.children == 0 then
      str = str .. " />"
      return str
    end

    str = str .. ">"

    for _, child in ipairs(parsed.children) do
      if type(child) == "table" then
        child = htmlua.elems(child)
      end

      str = str .. child
    end

    if cfg.close then
      str = str .. "</" .. name .. ">"
    end

    return str
  end
end

---@param tbl (string | string[])[]
---@return string
local function recursive_concat(tbl)
  local str = ""
  for _, v in ipairs(tbl) do
    if type(v) == "table" then
      str = str .. recursive_concat(v)
    else
      str = str .. v
    end
  end
  return str
end

---@param args string | string[]
---@return string
function htmlua.elems(args)
  if type(args) == "table" then
    return recursive_concat(args)
  else
    return args
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
    return htmlua.elems(func(parsed.props, parsed.children))
  end
end

return htmlua
