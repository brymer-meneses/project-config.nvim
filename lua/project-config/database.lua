---@class Database
---@field file_and_hashes table<{file: string, hash: string}>
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
  self.file_and_hashes = {}

  if not path:exists() then
    path:touch()
  end

  local lines = path:readlines()

  for _, line in ipairs(lines) do
    if line == "" then
      break
    end

    local contents = vim.split(line, ",", { trimempty = true })
    table.insert(self.file_and_hashes, { file = contents[1], hash = contents[2] })
  end

  return self
end

--- computes the SHA256 of a file and saves it to `self.path`
--- if it the file doesn't exist then we append to it and write it
--- to the database
function Database:trust_file(file)
  local is_found = false

  local hash = hashfile(file)
  for _, content in ipairs(self.file_and_hashes) do
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
    table.insert(self.file_and_hashes, { file = file.filename, hash = hashfile(file) })
    self:write()
  end

  -- finally we run it
  dofile(file.filename)
end

function Database:is_trusted(file)
  for _, content in ipairs(self.file_and_hashes) do
    if content.file == file.filename then
      return content.hash == hashfile(file)
    end
  end

  return false
end

function Database:write()
  local serialized_data = ""
  for _, content in ipairs(self.file_and_hashes) do
    serialized_data = serialized_data .. string.format("%s,%s\n", content.file, content.hash)
  end
  self.path:write(serialized_data, "w")
end

return Database
