#!/bin/bash

# A simple bash script to configure convenience when developing this plugin

cat << 'EOF' > /tmp/setup.lua
require('project-config').setup({})
local entry_point = vim.fn.getcwd() .. '/lua/project-config/init.lua'
vim.api.nvim_create_autocmd('BufWritePost', {
    pattern = entry_point,
    callback = function()
      local ok, _ = pcall(vim.cmd, 'source ' .. entry_point)
      if not ok then
        return
      end
    end,
})
EOF

nvim -c "set rtp+=. | lua dofile('/tmp/setup.lua')"
