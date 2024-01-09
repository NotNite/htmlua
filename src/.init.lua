local htmlua = require("htmlua")

---@diagnostic disable: lowercase-global
html = htmlua.elem("html")
head = htmlua.elem("head")
meta = htmlua.elem("meta", { empty = true })
title = htmlua.elem("title")
body = htmlua.elem("body")
h1 = htmlua.elem("h1")
p = htmlua.elem("p")
document = htmlua.elem("!DOCTYPE html", { close = false })
img = htmlua.elem("img", { empty = true })
style = htmlua.elem("style")

local function do_htmlua()
  ---@type string
  local path = EscapePath(GetPath())
  -- remove trailing slash
  path = string.gsub(path, "/$", "")

  -- Reject access to /pages, as we don't want Redbean to execute it
  if string.match(path, "^/pages") then
    ServeError(404)
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
        local handler = load_attempt()
        local result = handler()

        SetHeader("Content-Type", "text/html; charset=utf-8")
        Write(result)
        return
      end
    end
  end

  Route()
end

function OnHttpRequest()
  if GetMethod() == "GET" then
    do_htmlua()
  else
    Route()
  end
end
