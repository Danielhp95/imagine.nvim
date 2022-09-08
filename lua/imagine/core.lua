local util = require("imagine.util")

local M = {}

-- TODO: document
--
-- args:
--  - prompt: (string) input text to text-2-image model
--  - cmd_config: cmd_config
--  - opts: Imagine plugin options
M.imagine_txt2img = function(args)
  print(args)
  local prompt = args.prompt
  local opts = args.opts
  -- local config = command_opts.cmd_config -- Currently not used
  --local cmd_config = "--H 512 --W 768 --n_iter 1 --n_samples 1 --ddim_steps 10"  --TODO: read config from file
  local cmd_config = util.read_file(opts.path_to_cmd_config)  --TODO: read config from file
  local path_to_executable = opts.path_to_executable
  local cmd = opts.cmd

  local results_dir = opts.results_dir

  local inference_cmd = string.format(
    --'%s/%s --prompt "%s" ',
    '%s/%s  %s --outdir %s, --prompt "%s" ',
    path_to_executable, cmd, cmd_config, results_dir, prompt
  )

  -- TODO: Add debug option
   print("Imagine-nvim: running command: " .. inference_cmd)

  -- TODO: could be set to split in any direction
  vim.cmd("split")
  vim.cmd(string.format("term NIXPKGS_ALLOW_UNFREE=1 nix-shell --argstr command \"%s\"",inference_cmd))

  -- Current issues are:
  --  - The models being loaded take relative paths, so we need to be in correct path
  --  - Don't know how to call the term properly, shell hook is not really working
  --  - Ideally we turn this into a flake, right?
end


return M
