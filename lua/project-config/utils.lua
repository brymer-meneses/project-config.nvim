local M = {}

function M.source_config(config_path)
  -- NOTE:
  -- This would incur other problems since we would need to then hash each file in `.nvim` directory.
  -- I think it's better if we limit the user to just one file--`config.lua`
  --local config_folder = config_path:parent()
  --package.path = package.path .. string.format(";%s/?.lua", config_folder.filename)

  dofile(config_path.filename)
end

return M
