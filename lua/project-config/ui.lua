local M = {}

local choices = {
  TRUST_AND_LOAD_CONFIG = 1,
  IGNORE = 2,
}

---@param opts DefaultConfig
---@param database Database
local function show_with_preview(opts, database, prompt, config_file)
  local Menu = require('nui.menu')
  local Layout = require('nui.layout')
  local Popup = require('nui.popup')

  local menu = Menu(
    {
      border = {
        style = "rounded",
        text = {
          top = opts.prompts.title,
          top_align = "center",
        },
      },
    },
    {
      lines = {
        Menu.separator(prompt, { char = " ", text_align = "center" }),
        Menu.separator("", { char = " " }),
        Menu.item(" Trust and Load Config", { id = choices.TRUST_AND_LOAD_CONFIG }),
        Menu.item(" Ignore", { id = choices.IGNORE }),
      },
      keymap = {
        focus_next = { "j", "<Down>", "<Tab>" },
        focus_prev = { "k", "<Up>", "<S-Tab>" },
        close = { "<Esc>", "<C-c>" },
        submit = { "<CR>", "<Space>" },
      },
      on_close = function() end,
      on_submit = function(item)
        if item.id == choices.TRUST_AND_LOAD_CONFIG then
          if opts.trust_everything then
            dofile(database.path.filename)
            return
          end

          database:trust_file(config_file)
        end
      end,
    })

  local preview = Popup({
    border = "single",
    text = {
      top = "Preview",
      top_align = "center",
    }
  })

  vim.api.nvim_buf_set_lines(preview.bufnr, 0, -1, false, config_file:readlines())
  require 'nvim-treesitter.highlight'.attach(preview.bufnr, 'lua')

  local layout = Layout(
    {
      position = "50%",
      border = {
        style = "rounded",
      },
      size = {
        width = "50%",
        height = "60%",
      },
      text = {
        top = opts.prompts.title,
        top_align = "center",
      },
    },
    Layout.Box({
      Layout.Box(menu, { size = "20%" }),
      Layout.Box(preview, { size = "70%" }),
    }, { dir = "col" })
  )

  layout:mount()
end

local function show_without_preview(opts, database, prompt, config_file)
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

---@param opts DefaultConfig
---@param database Database
function M.open_prompt(opts, database, config_file)
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


  if opts.enable_preview then
    show_with_preview(opts, database, prompt, config_file)
  else
    show_without_preview(opts, database, prompt, config_file)
  end
end

return M
