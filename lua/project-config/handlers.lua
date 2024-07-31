local M = {}

---@param opts DefaultConfig
---@param database Database
function M.on_config_load(opts, database, config_file)
  if opts.trust_everything then
    dofile(database.path.filename)
    return
  end

  database:trust_file(config_file)
end

---@param opts DefaultConfig
---@param database Database
function M.open_prompt(opts, database, config_file)
  local Menu = require('nui.menu')

  local popup_options = {
    position = "50%",
    border = {
      style = "rounded",
      text = {
        top = opts.prompts.title,
        top_align = "center",
      },
    },
    win_options = {
      winhighlight = "Normal:Normal,FloatBorder:Normal",
    }
  }

  local choices = {
    TRUST_AND_LOAD_CONFIG = 1,
    -- TODO: implement this
    PREVIEW = 2,
    IGNORE = 3,
  }

  local classification = database:get_config_status(config_file)
  local prompt

  if classification == "trusted" then
    dofile(config_file.filename)
    return
  elseif classification == "new" then
    prompt = opts.prompts.new
  elseif classification == "changed" then
    prompt = opts.prompts.changed
  end

  local menu = Menu(popup_options, {
    lines = {
      Menu.separator(prompt, { char = " ", text_align = "center" }),
      Menu.separator("", { char = " " }),
      Menu.item(" Trust and Load Config", { id = choices.TRUST_AND_LOAD_CONFIG }),
      -- Menu.item("󰈈 Preview", { id = 2 }),
      Menu.item(" Ignore", { id = choices.IGNORE }),
    },
    min_width = opts.dimensions.width,
    min_height = opts.dimensions.height,
    keymap = {
      focus_next = { "j", "<Down>", "<Tab>" },
      focus_prev = { "k", "<Up>", "<S-Tab>" },
      close = { "<Esc>", "<C-c>" },
      submit = { "<CR>", "<Space>" },
    },
    on_close = function() end,
    on_submit = function(item)
      if item.id == choices.TRUST_AND_LOAD_CONFIG then
        M.on_config_load(opts, database, config_file)
      end
    end,
  })

  menu:mount()
end

return M
