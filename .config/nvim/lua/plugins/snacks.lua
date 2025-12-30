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
    explorer = {
      enabled = true,
    },
  },
  keys = {
    { "<leader>ff", function() Snacks.picker.smart() end, desc = "Smart Find Files" },
    { "<leader>fg", function() Snacks.picker.grep() end, desc = "Grep" },
    { "<leader>fe", function() Snacks.explorer() end, desc = "File Explorer" },
    { "<leader>cd", function() Snacks.picker.diagnostics_buffer() end, desc = "Diagnostics Buffer" },
    { "<leader>cD", function() Snacks.picker.diagnostics() end, desc = "Diagnostics" },
  }
}
