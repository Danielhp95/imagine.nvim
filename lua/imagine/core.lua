local Util = require("imagine.util")
local Telescope_util = require("imagine.telescope_util")

local M = {}

-- args:
--  - prompt: (string) input text to text-2-image model
--  - opts: (table) Imagine plugin options
M.imagine_txt2img = function(args)
  local prompt = args.prompt
  local opts = args.opts


  local config_file_content = vim.json.decode(Util.read_file(opts.path_to_cmd_config))
  local cmd_config = config_file_content.model_config or ''

  vim.ui.input({prompt='Model config: ', default = cmd_config}, function(input) cmd_config = input end)

  local prompt_extras = config_file_content.prompt_extras or ''

  vim.ui.input({prompt='Prompt: ', default = prompt .. prompt_extras}, function(input) prompt = input end)

  local path_to_executable = opts.path_to_executable
  local cmd = opts.cmd

  local results_dir = opts.results_dir

  local python_cmd = string.format(
    --'%s/%s --prompt "%s" ',
    '%s  %s --outdir %s --prompt \\"%s\\"',
    cmd, cmd_config, results_dir, prompt
  )

  local nix_cmd = string.format(
    'NIXPKGS_ALLOW_UNFREE=1 nix-shell --run "%s"', python_cmd
  )

  local full_cmd = string.format('cd %s ; %s', path_to_executable, nix_cmd)

   print('Imagine-nvim: running command: ' .. full_cmd)

  vim.cmd('tabe') -- TODO: could be set to split in any direction
  vim.cmd(string.format('term %s', full_cmd))
end

M.rembember = function(results_dir, image_viewer)
  Telescope_util.open_images(results_dir, image_viewer)
end

return M
