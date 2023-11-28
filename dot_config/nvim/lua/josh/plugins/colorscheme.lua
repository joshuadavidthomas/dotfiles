return {
  -- colorscheme
  {
    "marko-cerovac/material.nvim",
    priority = 1000,
    init = function()
      vim.cmd.colorscheme("material")
      vim.g.material_style = "palenight"
    end,
    opts = {
      high_visibility = {
        darker = true,
      },
      custom_highlights = {
        Comment = { fg = "#00BCD4" },
      },
    },
  },
}
