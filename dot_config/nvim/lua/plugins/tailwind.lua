return {
  {
    "neovim/nvim-lspconfig",
    opts = {
      servers = {
        tailwindcss = {},
      },
    },
  },
  {
    "NvChad/nvim-colorizer.lua",
    opts = {
      user_default_options = {
        tailwind = true,
      },
    },
  },
  {
    "hrsh7th/nvim-cmp",
    dependencies = {
      "roobert/tailwindcss-colorizer-cmp.nvim",
      config = true,
    },
    opts = function(_, opts)
      -- original lazyvim kind icon formatter
      local format_kinds = opts.formatting.format
      opts.formatting.format = function(entry, item)
        format_kinds(entry, item)
        return require("tailwindcss-colorizer-cmp").formatter(entry, item)
      end
    end,
  },
  {
    "laytan/tailwind-sorter.nvim",
    dependencies = { "nvim-treesitter/nvim-treesitter", "nvim-lua/plenary.nvim" },
    build = "cd formatter && npm i && npm run build",
    config = true,
  },
  -- {
  --   "hrsh7th/nvim-cmp",
  --   dependencies = {
  --     "js-everts/cmp-tailwind-colors",
  --     config = true,
  --   },
  --   opts = function(_, opts)
  --     -- original lazyvim kind icon formatter
  --     local format_kinds = opts.formatting.format
  --     opts.formatting.format = function(entry, item)
  --       format_kinds(entry, item)
  --       return require("cmp-tailwind-colors").format(entry, item)
  --     end
  --   end,
  -- },
}
