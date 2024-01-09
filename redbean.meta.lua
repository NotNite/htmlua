---@meta

---@param data string
function Write(data) end

---@param host string?
---@param path string?
function Route(host, path) end

---@return string
function GetPath() end

---@param path string
---@return string
function EscapePath(path) end

---@param path string
---@return string?
function LoadAsset(path) end

---@param name string
---@param value string
function SetHeader(name, value) end

---@return string
function GetMethod() end

---@param code number
---@param reason string?
function ServeError(code, reason) end
