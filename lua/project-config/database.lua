---@class Database
---@field contents table<{file: string, hash: string}>
---@field path any
Database = {}

---@return string
local function hashfile(path)
  local data = path:read()
  return vim.fn.sha256(data)
end

---@return Database
function Database.new(path)
  local self = setmetatable({}, { __index = Database })
  self.path = path
  self.contents = {}

  if not path:exists() then
    path:touch()
  end

  local lines = path:readlines()

  for _, line in ipairs(lines) do
    if line == "" then
      break
    end

    local contents = vim.split(line, ",", { trimempty = true })
    table.insert(self.contents, { file = contents[1], hash = contents[2] })
  end

  return self
end

--- computes the SHA 256 of a file and saves it to `self.path`
--- if the file doesn't exist then we add it to the database
function Database:trust_file(file)
  local is_found = false

  local hash = hashfile(file)
  for _, content in ipairs(self.contents) do
    if content.file == file.filename then
      is_found = true

      -- if the hashes do not equal then we update our hash
      if content.hash ~= hash then
        content.hash = hash
        self:write()
        break
      end
    end
  end

  if not is_found then
    table.insert(self.contents, { file = file.filename, hash = hashfile(file) })
    self:write()
  end

  local utils = require("project-config.utils")
  utils.source_config(file)
end

---@return "new" | "changed" | "trusted"
function Database:get_config_status(file)
  local hash = hashfile(file)
  for _, content in ipairs(self.contents) do
    if content.file == file.filename then
      -- if the hashes do not equal then we update our hash
      if content.hash ~= hash then
        return "changed"
      end

      return "trusted"
    end
  end

  return "new"
end

function Database:write()
  local serialized_data = ""
  for _, content in ipairs(self.contents) do
    serialized_data = serialized_data .. string.format("%s,%s\n", content.file, content.hash)
  end
  self.path:write(serialized_data, "w")
end

return Database
