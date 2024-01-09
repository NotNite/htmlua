local htmlua = require("htmlua")

---@diagnostic disable: lowercase-global
-- These can optionally be passed settings for their behavior - see the README.
document = htmlua.elem("!DOCTYPE html", { close = false })
html = htmlua.elem("html")
head = htmlua.elem("head")
meta = htmlua.elem("meta", { empty = true })
title = htmlua.elem("title")
body = htmlua.elem("body")
h1 = htmlua.elem("h1")
h2 = htmlua.elem("h2")
p = htmlua.elem("p")
style = htmlua.elem("style")
input = htmlua.elem("input", { empty = true })
br = htmlua.elem("br", { empty = true })

---@type table<string, (fun(): string) | false>
local load_cache = {}

---@param path string
local function populate_cache(path)
  if type(load_cache[path]) ~= "nil" then
    return
  end

  local paths = {
    path .. "/index",
    path .. "/index.html",
    path .. ".html",
    path,
  }

  for _, try_path in ipairs(paths) do
    local asset = LoadAsset("pages" .. try_path .. ".lua")
    if asset then
      local load_attempt = load(asset)
      if load_attempt then
        load_cache[path] = load_attempt()
        return
      end
    end
  end

  load_cache[path] = false
end

local function do_htmlua()
  local path = EscapePath(GetPath())
  -- Remove trailing slash
  path = string.gsub(path, "/$", "")

  -- Reject access to /pages, as we don't want redbean to execute it
  if string.match(path, "^/pages") then
    ServeError(404)
    return
  end

  populate_cache(path)
  local handler = load_cache[path]

  if handler then
    local result = handler()

    SetHeader("Content-Type", "text/html; charset=utf-8")
    Write(result)
  else
    Route()
  end
end

function OnHttpRequest()
  if GetMethod() == "GET" then
    do_htmlua()
  else
    Route()
  end
end
