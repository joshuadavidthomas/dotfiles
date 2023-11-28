return {
  -- formatter
  {
    "stevearc/conform.nvim",
    event = { "BufWritePre" },
    cmd = { "ConformInfo" },
    dependencies = {
      {
        "williamboman/mason.nvim",
        opts = {
          ensure_installed = {
            "shfmt",
            "stylua",
          },
        },
      },
    },
    opts = {
      -- These options will be passed to conform.format()
      format_on_save = {
        timeout_ms = 500,
        lsp_fallback = true,
      },
      formatters_by_ft = {
        lua = { "stylua" },
        sh = { "shfmt" },
      },
    },
  },
}
