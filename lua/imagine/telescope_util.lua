local pickers = require "telescope.pickers"
local finders = require "telescope.finders"
local conf = require("telescope.config").values
local actions = require "telescope.actions"
local action_state = require "telescope.actions.state"

local M = {}

function M.open_images(image_dirs, image_viewer_cmd)
  -- TODO: figure out a way of passing user defined options
  local opts = {}
  pickers.new(opts, {
    prompt_title = 'Select image folder to open with ' .. image_viewer_cmd,
    attach_mappings = function(prompt_bufnr, _)
      actions.select_default:replace(function()
        actions.close(prompt_bufnr)
        print(image_viewer_cmd .. action_state.get_selected_entry().path)
        require"os".execute(image_viewer_cmd .. ' ' .. action_state.get_selected_entry().path)
      end)
      return true
    end,
    finder = finders.new_table {
      results = M.generate_telescope_results(require("plenary.scandir").scan_dir(image_dirs, {only_dirs = true, depth=1})),
      entry_maker = M.entry_maker,
    },
    sorter = conf.generic_sorter(opts),
  }):find()
end

-- Entry maker for telescope picker
function M.entry_maker(entry)
  return {
    value = entry,
    path = entry[1],
    display = entry[2],
    ordinal = entry[2],
  }
end

-- Creates an array containing entries of {absolute_path_to_repo, repo_name}
M.generate_telescope_results = function (image_dirs)
  local entries = {}
  for _, image_dir in ipairs(image_dirs) do
    table.insert(entries, { image_dir, M.get_name_from_absolute_path(image_dir) })
  end
  return entries
end

-- Returns last value from :arg: path
M.get_name_from_absolute_path = function (path)
  local split_path = vim.split(path, "/")
  return split_path[#split_path]
end

return M
