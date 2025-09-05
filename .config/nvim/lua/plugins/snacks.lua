return {
  "folke/snacks.nvim",
  priority = 1000,
  lazy = false,
  ---@type snacks.Config
  opts = {
    picker = {
      enabled = true,
    },
    statuscolumn = {
      enabled = true,
    },
    git = {
      enabled = true,
    },
    dashboard = {
      enabled = true,
    },
    terminal = {
      enabled = true,
      win = { position = "float" } 
    },
    explorer = {
      enabled = true,
    },
  },
  keys = {
    { "<leader>ff", function() Snacks.picker.smart() end, desc = "Smart Find Files" },
    { "<leader>fg", function() Snacks.picker.grep() end, desc = "Grep" },
    { "<leader>fu", function() Snacks.picker.undo() end, desc = "Undo History" },
    { "<leader>cd", function() Snacks.picker.diagnostics_buffer() end, desc = "Diagnostics Buffer" },
    { "<leader>cD", function() Snacks.picker.diagnostics() end, desc = "Diagnostics" },
    { "<leader>fe", function() Snacks.explorer() end, desc = "File Explorer" },
    { "<leader>t", function() Snacks.terminal.toggle() end, desc = "Toggle Terminal" },
  }
}
