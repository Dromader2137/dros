return {
  {
    "nvim-lualine/lualine.nvim",
    event = "VeryLazy",
    opts = function(_, opts)
      table.remove(opts.sections.lualine_c, 3)
      table.insert(opts.sections.lualine_c, 3, { "filetype", })
      table.remove(opts.sections.lualine_c, 1)
      opts.sections.lualine_z = {
        function()
          return os.date("%R")
        end
      }
    end,
  },
}
