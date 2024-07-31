local M = {}

function M.source_config(config_path)
  local config_folder = config_path:parent()
  package.path = package.path .. string.format(";%s/?.lua", config_folder.filename)
  dofile(config_path.filename)
end

return M
