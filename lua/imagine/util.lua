local Scandir = require("plenary.scandir")
local Path = require("plenary.path")

local M = {}


-- Completion function for user commands
-- For info on custom complete :command-complete
M.vimscript_command_completion = function(argLead, cmdLine, cusorPos)
  local completions = {}
  for _, repo in ipairs(M.get_result_directories()) do
    if string.match(repo, argLead) then
      table.insert(completions, M.get_dir_name_from_absolute_path(repo))
    end
  end
  return completions
end


M.get_result_directories = function (dir)
  return Scandir.scan_dir(dir, {only_dirs = true, depth=1})
end


M.get_dir_name_from_absolute_path = function (path)
  local split_path = vim.split(path, "/")
  return split_path[#split_path]
end


-- Ensures that a directory exists to save images
M.create_results_repository = function(dir)
  local tmp_repos_dir_path = Path:new(dir)
  if not tmp_repos_dir_path:exists() then
    tmp_repos_dir_path:mkdir()
  end
end


M.get_visual_selection = function()
  local s_start = vim.fn.getpos("'<")
  local s_end = vim.fn.getpos("'>")
  local n_lines = math.abs(s_end[2] - s_start[2]) + 1
  local lines = vim.api.nvim_buf_get_lines(0, s_start[2] - 1, s_end[2], false)
  lines[1] = string.sub(lines[1], s_start[3], -1)
  if n_lines == 1 then
    lines[n_lines] = string.sub(lines[n_lines], 1, s_end[3] - s_start[3] + 1)
  else
    lines[n_lines] = string.sub(lines[n_lines], 1, s_end[3])
  end
  return table.concat(lines, '\n')
end

M.read_file = function(path)
    local file = io.open(path, "rb") -- r read mode and b binary mode
    if not file then return nil end
    local content = file:read "*a" -- *a or *all reads the whole file
    file:close()
    return content
end

return M
