local Util = require('imagine.util')
local Core = require('imagine.core')
local Path = require('plenary.path')

local Imagine = {}

local setup_user_commands = function()
  local cmd = vim.api.nvim_create_user_command

  -- TODO: I think the visual "ImagineSelected" should not be here?
  cmd("Imagine", function(argtable) Core.imagine_txt2img({
      prompt = argtable.fargs[1],
      cmd_config = Imagine.opts.path_to_cmd_config,
      opts = Imagine.opts,
    }) end,
      {nargs = "?", -- One or neither
       complete = nil
     })
  cmd("ImagineRemember", function(argtable) print("TODO") end,
      {nargs = "?",
      complete = nil,
    })

  -- Config file operations
  cmd("ImagineOpenConfigFile", function() vim.cmd(":vs " .. Imagine.opts.path_to_cmd_config) end,
      {nargs = 0})
  cmd("ImagineSetConfigFile", function(argtable)
         local new_config_file = argtable.fargs[1]
         if not Path:new(new_config_file):exists() then
           error("File " .. new_config_file .. " does not exist so it was not set")
         else
           Imagine.opts.path_to_cmd_config = new_config_file
         end
       end,
      {nargs = 1, complete="file"})
end


-- Highest level plugin function.
-- opts:
--   - results_dir (string): Directory where images are
Imagine.setup = function(opts)
  opts = opts or {}  -- Ensures that if nothing is passed, we have an empty set
  opts.results_dir = opts.results_dir or vim.fn.stdpath('data') .. '/imagine.nvim/images'
  opts.path_to_cmd_config = opts.path_to_cmd_config or opts.results_dir .. '/config.txt'
  opts.path_to_executable = opts.path_to_executable or "TODO"
  opts.cmd = opts.cmd or "TODO"

  Imagine.opts = opts

  setup_user_commands()
  Util.create_results_repository(opts.results_dir)

  vim.keymap.set('v', '<Leader>i', ':<C-u>lua vim.cmd("Imagine " .. require("imagine.util").get_visual_selection())<CR>', { silent = false })
end


return Imagine
