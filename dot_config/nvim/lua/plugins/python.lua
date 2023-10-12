return {
  {
    "williamboman/mason.nvim",
    opts = function(_, opts)
      vim.list_extend(opts.ensure_installed, {
        -- "pyright",
        "black",
        "ruff-lsp",
        "ruff",
      })
    end,
  },
  {
    "stevearc/conform.nvim",
    opts = {
      formatters_by_ft = {
        python = { "black", "ruff_fix", "rust_format" },
      },
      format_on_save = {
        lsp_fallback = true,
        timeout_ms = 500,
      },
    },
  },
}
