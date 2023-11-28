local Util = require("lazyvim.util")

return {
  -- Fuzzy Finder (files, lsp, etc)
  {
    "nvim-telescope/telescope.nvim",
    branch = "0.1.x",
    dependencies = {
      "nvim-lua/plenary.nvim",
      -- Fuzzy Finder Algorithm which requires local dependencies to be built.
      -- Only load if `make` is available. Make sure you have the system
      -- requirements installed.
      {
        "nvim-telescope/telescope-fzf-native.nvim",
        -- NOTE: If you are having trouble with this installation,
        --       refer to the README for telescope-fzf-native for more instructions.
        build = "make",
        enabled = vim.fn.executable("make") == 1,
        config = function()
          Util.on_load("telescope.nvim", function()
            require("telescope").load_extension("fzf")
          end)
        end,
      },
    },
    keys = {
      -- { "<leader><space>", "<leader>ff", desc = "[ ] Find Files", remap = true },
      {
        "<leader><space>",
        function()
          require("telescope.builtin").buffers()
        end,
        desc = "[ ] Find existing buffers",
        remap = true,
      },
      {
        "<leader>/",
        function()
          require("telescope.builtin").live_grep()
        end,
        desc = "[/] Grep Files",
      },
      {
        "<leader>ff",
        function()
          require("telescope.builtin").find_files()
        end,
        desc = "find [f]iles",
      },
    },
    opts = {
      defaults = {
        mappings = {
          i = {
            ["<C-u>"] = false,
            ["<C-d>"] = false,
          },
        },
      },
    },
  },
  -- file explorer
  -- {
  --   "nvim-neo-tree/neo-tree.nvim",
  --   branch = "v3.x",
  --   dependencies = {
  --     "nvim-lua/plenary.nvim",
  --     "nvim-tree/nvim-web-devicons", -- not strictly required, but recommended
  --     "MunifTanjim/nui.nvim",
  --     -- "3rd/image.nvim", -- Optional image support in preview window: See `# Preview Mode` for more information
  --   },
  --   cmd = "Neotree",
  --   keys = {
  --     {
  --       "<leader>fe",
  --       function()
  --         require("neo-tree.command").execute({ toggle = true, dir = Util.root() })
  --       end,
  --       desc = "File [e]xplorer",
  --     },
  --     { "<leader>e", "<leader>fe", desc = "File [e]xplorer", remap = true },
  --   },
  --   deactivate = function()
  --     vim.cmd([[Neotree close]])
  --   end,
  --   init = function()
  --     if vim.fn.argc(-1) == 1 then
  --       local stat = vim.loop.fs_stat(vim.fn.argv(0))
  --       if stat and stat.type == "directory" then
  --         require("neo-tree")
  --       end
  --     end
  --   end,
  --   opts = {
  --     sources = { "filesystem", "buffers", "git_status", "document_symbols" },
  --     open_files_do_not_replace_types = { "terminal", "Trouble", "trouble", "qf", "Outline" },
  --     filesystem = {
  --       bind_to_cwd = false,
  --       follow_current_file = { enabled = true },
  --       use_libuv_file_watcher = true,
  --     },
  --     window = {
  --       mappings = {
  --         ["<space>"] = "none",
  --       },
  --     },
  --     default_component_configs = {
  --       indent = {
  --         with_expanders = true, -- if nil and file nesting is enabled, will enable expanders
  --         expander_collapsed = "",
  --         expander_expanded = "",
  --         expander_highlight = "NeoTreeExpander",
  --       },
  --     },
  --   },
  --   config = function(_, opts)
  --     local function on_move(data)
  --       Util.lsp.on_rename(data.source, data.destination)
  --     end
  --     local events = require("neo-tree.events")
  --     opts.event_handlers = opts.event_handlers or {}
  --     vim.list_extend(opts.event_handlers, {
  --       { event = events.FILE_MOVED, handler = on_move },
  --       { event = events.FILE_RENAMED, handler = on_move },
  --     })
  --     require("neo-tree").setup(opts)
  --     vim.api.nvim_create_autocmd("TermClose", {
  --       pattern = "*lazygit",
  --       callback = function()
  --         if package.loaded["neo-tree.sources.git_status"] then
  --           require("neo-tree.sources.git_status").refresh()
  --         end
  --       end,
  --     })
  --   end,
  -- },
  -- mini.files explorer
  {
    "echasnovski/mini.files",
    opts = {
      windows = {
        preview = true,
        width_focus = 30,
        width_preview = 30,
      },
      options = {
        -- Whether to use for editing directories
        -- Disabled by default in LazyVim because neo-tree is used for that
        use_as_default_explorer = false,
      },
    },
    keys = function(_, keys)
      local minifiles_toggle = function(...)
        if not require("mini.files").close() then
          require("mini.files").open(...)
        end
      end
      return {
        {
          "<leader>fe",
          -- minifiles_toggle(Util.root(), true),
          function()
            if not require("mini.files").close() then
              require("mini.files").open(Util.root(), true)
            end
          end,
          desc = "File [e]xplorer",
        },
        { "<leader>e", "<leader>fe", desc = "File [e]xplorer", remap = true },
        {
          "<leader>fm",
          -- minifiles_toggle(vim.api.nvim_buf_get_name(0), true),
          function()
            if not require("mini.files").close() then
              require("mini.files").open(vim.api.nvim_buf_get_name(0), true)
            end
          end,
          desc = "Open mini.files (directory of current file)",
        },
        {
          "<leader>fM",
          function()
            require("mini.files").open(vim.loop.cwd(), true)
          end,
          desc = "Open mini.files (cwd)",
        },
      }
    end,
    config = function(_, opts)
      require("mini.files").setup(opts)

      local show_dotfiles = true
      local filter_show = function(fs_entry)
        return true
      end
      local filter_hide = function(fs_entry)
        return not vim.startswith(fs_entry.name, ".")
      end

      local toggle_dotfiles = function()
        show_dotfiles = not show_dotfiles
        local new_filter = show_dotfiles and filter_show or filter_hide
        require("mini.files").refresh({ content = { filter = new_filter } })
      end

      vim.api.nvim_create_autocmd("User", {
        pattern = "MiniFilesBufferCreate",
        callback = function(args)
          local buf_id = args.data.buf_id
          -- Tweak left-hand side of mapping to your liking
          vim.keymap.set("n", "g.", toggle_dotfiles, { buffer = buf_id })
        end,
      })

      vim.api.nvim_create_autocmd("User", {
        pattern = "MiniFilesActionRename",
        callback = function(event)
          require("lazyvim.util").lsp.on_rename(event.data.from, event.data.to)
        end,
      })
    end,
  },
  -- Displays a popup with possible key bindings of the command you started typing
  {
    "folke/which-key.nvim",
    event = "VeryLazy",
    opts = {
      plugins = { spelling = true },
      defaults = {
        mode = { "n", "v" },
        ["<leader>f"] = { name = "+[f]ile/[f]ind" },
        ["<leader>u"] = { name = "+[u]i" },
        ["<leader>w"] = { name = "+[w]indow" },
        ["<leader>q"] = { name = "+[q]uit/session" },
      },
    },
    config = function(_, opts)
      local wk = require("which-key")
      wk.setup(opts)
      wk.register(opts.defaults)
    end,
  },
  -- create and manage predefined window layouts
  -- {
  --   "folke/edgy.nvim",
  --   event = "VeryLazy",
  --   keys = {
  --     {
  --       "<leader>ue",
  --       function()
  --         require("edgy").toggle()
  --       end,
  --       desc = "Edgy Toggle",
  --     },
  --     -- stylua: ignore
  --     { "<leader>uE", function() require("edgy").select() end, desc = "Edgy Select Window" },
  --   },
  --   opts = function()
  --     local opts = {
  --       bottom = {
  --         {
  --           ft = "toggleterm",
  --           size = { height = 0.4 },
  --           filter = function(buf, win)
  --             return vim.api.nvim_win_get_config(win).relative == ""
  --           end,
  --         },
  --         {
  --           ft = "noice",
  --           size = { height = 0.4 },
  --           filter = function(buf, win)
  --             return vim.api.nvim_win_get_config(win).relative == ""
  --           end,
  --         },
  --         {
  --           ft = "lazyterm",
  --           title = "LazyTerm",
  --           size = { height = 0.4 },
  --           filter = function(buf)
  --             return not vim.b[buf].lazyterm_cmd
  --           end,
  --         },
  --         "Trouble",
  --         {
  --           ft = "trouble",
  --           filter = function(buf, win)
  --             return vim.api.nvim_win_get_config(win).relative == ""
  --           end,
  --         },
  --         { ft = "qf", title = "QuickFix" },
  --         {
  --           ft = "help",
  --           size = { height = 20 },
  --           -- don't open help files in edgy that we're editing
  --           filter = function(buf)
  --             return vim.bo[buf].buftype == "help"
  --           end,
  --         },
  --         { title = "Spectre", ft = "spectre_panel", size = { height = 0.4 } },
  --         { title = "Neotest Output", ft = "neotest-output-panel", size = { height = 15 } },
  --       },
  --       left = {
  --         {
  --           title = "Neo-Tree",
  --           ft = "neo-tree",
  --           filter = function(buf)
  --             return vim.b[buf].neo_tree_source == "filesystem"
  --           end,
  --           pinned = true,
  --           open = function()
  --             vim.api.nvim_input("<esc><space>e")
  --           end,
  --           size = { height = 0.5 },
  --         },
  --         { title = "Neotest Summary", ft = "neotest-summary" },
  --         {
  --           title = "Neo-Tree Git",
  --           ft = "neo-tree",
  --           filter = function(buf)
  --             return vim.b[buf].neo_tree_source == "git_status"
  --           end,
  --           pinned = true,
  --           open = "Neotree position=right git_status",
  --         },
  --         {
  --           title = "Neo-Tree Buffers",
  --           ft = "neo-tree",
  --           filter = function(buf)
  --             return vim.b[buf].neo_tree_source == "buffers"
  --           end,
  --           pinned = true,
  --           open = "Neotree position=top buffers",
  --         },
  --         "neo-tree",
  --       },
  --       keys = {
  --         -- increase width
  --         ["<c-Right>"] = function(win)
  --           win:resize("width", 2)
  --         end,
  --         -- decrease width
  --         ["<c-Left>"] = function(win)
  --           win:resize("width", -2)
  --         end,
  --         -- increase height
  --         ["<c-Up>"] = function(win)
  --           win:resize("height", 2)
  --         end,
  --         -- decrease height
  --         ["<c-Down>"] = function(win)
  --           win:resize("height", -2)
  --         end,
  --       },
  --     }
  --     return opts
  --   end,
  -- },
  -- buffer remove
  {
    "echasnovski/mini.bufremove",
    keys = {
      {
        "<leader>bd",
        function()
          local bd = require("mini.bufremove").delete
          if vim.bo.modified then
            local choice = vim.fn.confirm(("Save changes to %q?"):format(vim.fn.bufname()), "&Yes\n&No\n&Cancel")
            if choice == 1 then -- Yes
              vim.cmd.write()
              bd(0)
            elseif choice == 2 then -- No
              bd(0, true)
            end
          else
            bd(0)
          end
        end,
        desc = "Delete Buffer",
      },
      -- stylua: ignore
      { "<leader>bD", function() require("mini.bufremove").delete(0, true) end, desc = "Delete Buffer (Force)" },
    },
  },
  {
    "akinsho/toggleterm.nvim",
    event = "VeryLazy",
    version = "*",
    keys = {
      { "<esc><esc>", "<c-\\><c-n>", mode = "t", desc = "Enter Normal Mode" },
      {
        "<c-/>",
        function()
          local count = vim.v.count1
          require("toggleterm").toggle(count, 10, vim.loop.cwd(), "horizontal")
        end,
        mode = { "n", "t" },
        desc = "ToggleTerm (horizontal)",
      },
      {
        "<c-_>",
        function()
          local count = vim.v.count1
          require("toggleterm").toggle(count, 10, vim.loop.cwd(), "horizontal")
        end,
        mode = { "n", "t" },
        desc = "which_key_ignore",
      },
    },
    opts = {
      shading_factor = "-10",
      close_on_exit = true, -- close the terminal window when the process exits
    },
  },
}
