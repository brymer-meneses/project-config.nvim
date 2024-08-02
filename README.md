# `project-config.nvim`

The missing plugin for running project specific configuration in neovim!

![preview](https://github.com/user-attachments/assets/48d08838-4907-458b-bb2f-981331e9774d)

## What does it do?

What does it do? This plugin checks for the existence of `.nvim/config.lua` in
the current directory. If it finds the file, it prompts the user to decide
whether to load it or not. This precaution prevents arbitrary code execution
from merely opening a directory. If the user chooses to load the file, the
plugin hashes and caches its contents to track changes. If the file changes,
the user will be prompted again.

## Setup and Installation

Using [Lazy](https://github.com/folke/lazy.nvim)

```lua
{ 
    'brymer-meneses/project-config.nvim',
    dependencies = {
         'MunifTanjim/nui.nvim',
         'nvim-lua/plenary.nvim', 
         'nvim-treesitter/nvim-treesitter'
    },
    opts = {},
}
```

Here are the default options passed to the setup function

```lua
{
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

  -- whether to show the contents of `.nvim/config.lua`
  enable_preview = true,
}
```

## Limitations

- I initially made it so that importing other lua files in the
same directory works by modifying `package.path`, but that would entail
having to hash each file in the directory. I do not really know whether 
this should be added because of the additional complexity, but I'm open to
changing my mind!

- Even though it hashes the contents of `.nvim/config.lua` it can still be a vector for
arbitrary code execution, for instance if the user decides to import a file
that is originally safe but has now been tampered to do something
malicious.

