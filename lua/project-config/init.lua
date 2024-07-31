local M = {}

---@class DefaultConfig
local DEFAULT_CONFIG = {

  -- where to store the project path that are trusted
  trusted_projects_folder = vim.fn.stdpath('cache') .. '/project-config.csv',

  -- whether to trust every project without prompting the user
  -- **WARNING:** opening neovim in a directory will run arbitrary code automatically
  trust_everything = false,

  prompts = {
    title = " Project Config Detected ",
    changed = "A change has been detected to the `.nvim` in this folder.",
    new = "A previously unseen `.nvim` config is in this folder."
  },

  dimensions = {
    width = 60,
    height = 5,
  },

  enable_preview = true,
}

---@param opts DefaultConfig
function M.setup(opts)
  opts = vim.tbl_deep_extend('force', DEFAULT_CONFIG, opts)

  -- check first if `nui.nvim` is installed
  local found_nui, _ = pcall(require, "nui.menu")
  if not found_nui then
    vim.notify("error: nui.nvim is a required dependency of `project-config.nvim`", vim.log.levels.ERROR)
    return
  end

  local found_treesitter, _ = pcall(require, "nvim-treesitter")
  if not found_treesitter then
    vim.notify("error: `nvim-treesitter` is a required dependency of `project-config.nvim`", vim.log.levels.ERROR)
    return
  end

  local found_plenary, Path = pcall(require, "plenary.path")
  if not found_plenary then
    vim.notify("error: plenary is a required dependency of `project-config.nvim`", vim.log.levels.ERROR)
    return
  end

  local ui = require("project-config.ui")
  local Database = require("project-config.database")

  local database = Database.new(Path:new(opts.trusted_projects_folder))

  vim.api.nvim_create_autocmd({ "VimEnter", "DirChanged" }, {
    callback = function()
      vim.schedule(function()
        local dot_nvim = Path:new(vim.fn.getcwd() .. "/.nvim")
        if dot_nvim:is_dir() then
          local config_file = dot_nvim:joinpath("config.lua")
          if not config_file:is_file() then
            vim.notify("error: expected a `config.lua` inside `.nvim`", vim.log.levels.ERROR)
          else
            ui.open_prompt(opts, database, config_file)
          end
        end
      end)
    end,
    group = vim.api.nvim_create_augroup("ProjectConfig", { clear = true }),
  })
end

return M
