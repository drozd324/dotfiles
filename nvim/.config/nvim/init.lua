-- Init lazy
local lazypath = vim.fn.stdpath("data") .. "/lazy/lazy.nvim"
if not (vim.uv or vim.loop).fs_stat(lazypath) then
	local lazyrepo = "https://github.com/folke/lazy.nvim.git"
	local out = vim.fn.system({ "git", "clone", "--filter=blob:none", "--branch=stable", lazyrepo, lazypath })
	if vim.v.shell_error ~= 0 then
		vim.api.nvim_echo({
			{ "Failed to clone lazy.nvim:\n", "ErrorMsg" },
			{ out, "WarningMsg" },
			{ "\nPress any key to exit..." },
		}, true, {})
		vim.fn.getchar()
		os.exit(1)
	end
end
vim.opt.rtp:prepend(lazypath)

vim.g.mapleader = " "
vim.g.maplocalleader = "\\"

------------------------------------- Setup lazy.nvim ------------------------------------
require("lazy").setup({
	spec = {
		{
			"everviolet/nvim",
			name = "evergarden",
			priority = 1000, -- Colorscheme plugin is loaded first before any other plugins
			opts = {
				theme = {
					variant = "fall", -- 'winter'|'fall'|'spring'|'summer'
					accent = "green",
				},
				editor = {
					transparent_background = false,
					sign = { color = "none" },
					float = {
						color = "mantle",
						invert_border = false,
					},
					completion = {
						color = "surface0",
					},
				},
			},
		},

		{
			"nvim-treesitter/nvim-treesitter",
			build = ":TSUpdate",
			config = function()
				local configs = require("nvim-treesitter.configs")

				configs.setup({
					ensure_installed = { "c", "cpp", "python", "bash", "lua", "html" },
					sync_install = false,
					highlight = { enable = true },
					indent = { enable = true },
				})
			end,
		},

		{
			"mason-org/mason.nvim",
			opts = {},
		},

		{
			"nvim-telescope/telescope.nvim",
			tag = "0.1.8",
			dependencies = {
				"nvim-lua/plenary.nvim",
				{ "nvim-telescope/telescope-fzf-native.nvim", build = "make" },
			},
		},

		{
			"saghen/blink.cmp",
			dependencies = { "rafamadriz/friendly-snippets" },
			version = "1.*",

			opts = {
				keymap = { preset = "default" },
				appearance = { nerd_font_variant = "mono" },
				completion = {
					documentation = { auto_show = true },
					ghost_text = { enabled = true },
				},
			},

			opts_extend = { "sources.default" },
		},

		{
			"stevearc/conform.nvim",
			opts = {
				formatters_by_ft = {
					c = { "clang-format" },
					lua = { "stylua" },
				},
			},
		},

		{
			"rcarriga/nvim-dap-ui",
			dependencies = {
				"mfussenegger/nvim-dap",
				"nvim-neotest/nvim-nio",
			},
		},

		{
			"stevearc/oil.nvim",
			opts = {},
			lazy = false,
		},

		{
			"sphamba/smear-cursor.nvim",
			opts = {
				stiffess = 0.99,
				trailing_stifness = 0.99,
				distance_stop_animating = 0.5,
				damping = 0.9,
				never_draw_over_target = true,
			},
		},
	},

	checker = { enabled = true, notify = false },
})

--------------------------------- lsp stuff -------------------------------------------------

vim.lsp.config["lua-language-server"] = {
	cmd = { "lua-language-server", "--background-index" },
	root_markers = { ".luarc.json" },
	filetypes = { "lua" },
}
vim.lsp.enable("lua-language-server")

vim.lsp.config["clangd"] = {
	cmd = { "clangd", "--background-index" },
	root_markers = { "compile_commands.json", "compile_flags.txt" },
	filetypes = { "c", "cpp", "cuda" },
}
vim.lsp.enable("clangd")

-- Easy switching bewteen source and header (.h and .cpp) files
vim.keymap.set("n", "<leader>h", function()
	vim.lsp.buf_request(0, "textDocument/switchSourceHeader", { uri = vim.uri_from_bufnr(0) }, function(_, result)
		if result then
			vim.cmd("edit " .. vim.uri_to_fname(result))
		else
			vim.notify("No corresponding header/source found", vim.log.levels.INFO)
		end
	end)
end, { desc = "Switch between source/header" })

vim.lsp.config["bash-language-server"] = {
	cmd = { "bash-language-server", "--stdio" },
	--root_markers = { 'compile_commands.json', 'compile_flags.txt' },
	filetypes = { "sh", "bash" },
}
vim.lsp.enable("bash-language-server")

vim.lsp.config["pyright"] = {
	cmd = { "pyright-langserver", "--stdio" },
	filetypes = { "python" },
	root_markers = { ".git", "pyproject.toml", "setup.py", "setup.cfg", "requirements.txt" },
}
vim.lsp.enable("pyright")

vim.api.nvim_create_autocmd("lspattach", {
	callback = function(ev)
		vim.keymap.set("n", "gd", vim.lsp.buf.definition, opts)
		vim.keymap.set("n", "gD", vim.lsp.buf.declaration, opts)
		vim.keymap.set("n", "gi", vim.lsp.buf.implementation, opts)
		--vim.keymap.set("n", "<leader>gd", vim.lsp.buf.type_definition, opts)
		--vim.keymap.set("n", "K", vim.lsp.buf.hover, opts)
		vim.keymap.set("n", "<leader>vws", vim.lsp.buf.workspace_symbol, opts)

		vim.keymap.set("n", "<leader>fd", function()
			vim.diagnostic.open_float({ border = "single" })
		end, opts)
		vim.keymap.set("n", "<leader>td", function()
			toggle_buffer_disgnostics()
		end, opts)

		vim.keymap.set("n", "<leader>lf", '<cmd>lua require("conform").format()<CR>')
		vim.keymap.set("v", "<leader>lf", '<cmd>lua require("conform").format()<CR>')

		vim.keymap.set("n", "[d", vim.diagnostic.goto_next, opts)
		vim.keymap.set("n", "]d", vim.diagnostic.goto_prev, opts)
		vim.keymap.set({ "n", "v" }, "<leader>ca", vim.lsp.buf.code_action, opts)
		vim.keymap.set("n", "<leader>ref", vim.lsp.buf.references, opts)
		vim.keymap.set("n", "<leader>rn", vim.lsp.buf.rename, opts)
		-- vim.keymap.set("i", "Find Appropriate Keymap", vim.lsp.buf.signature_help, opts)
	end,
})

------------------------------ File specific indenting ---------------------------

vim.api.nvim_create_autocmd("FileType", {
	pattern = "*",
	callback = function()
		vim.opt_local.expandtab = false
		vim.opt_local.tabstop = 4
		vim.opt_local.shiftwidth = 4
		vim.opt_local.softtabstop = 4
	end,
})

vim.api.nvim_create_autocmd("FileType", {
	pattern = { "cpp", "c", "h", "cuda" },
	callback = function()
		vim.opt_local.expandtab = true
		vim.opt_local.tabstop = 2
		vim.opt_local.shiftwidth = 2
		vim.opt_local.softtabstop = 2
	end,
})

-------------------------- Telescope Keymaps -------------------------------------

local builtin = require("telescope.builtin")
vim.keymap.set("n", "<leader>fd", builtin.find_files, { desc = "Telescope find files" })
vim.keymap.set("n", "<leader>rg", builtin.live_grep, { desc = "Telescope live grep" })
vim.keymap.set("n", "<leader>fb", builtin.buffers, { desc = "Telescope buffers" })
vim.keymap.set("n", "<leader>fh", builtin.help_tags, { desc = "Telescope help tags" })

-- Lsp
vim.keymap.set("n", "<leader>rf", builtin.lsp_references, { desc = "Telescope show lsp refs" })
vim.keymap.set("n", "<leader>tds", builtin.lsp_document_symbols, { desc = "Telescope show document symbols" })
vim.keymap.set("n", "<leader>tws", builtin.lsp_workspace_symbols, { desc = "Telescope show workspace symbols" })

----------------------------------------------------------------------------------

vim.cmd("colorscheme evergarden")

-- Toggle these for line number shenanigans
vim.o.termguicolors = true
vim.opt.termguicolors = true
vim.opt.number = true
--vim.opt.relativenumber = true
vim.cmd([[
  highlight LineNr guifg=#444444
]])

vim.o.laststatus = 0
vim.opt.clipboard = "unnamedplus"

---- Disable automatic comment continuation on newline
vim.api.nvim_create_autocmd("FileType", {
	pattern = "*",
	callback = function()
		vim.opt_local.formatoptions:remove({ "c", "r", "o" })
	end,
})

---- transparent backgound
vim.cmd([[
  hi Normal guibg=NONE ctermbg=NONE
  hi NormalNC guibg=NONE ctermbg=NONE
  hi Pmenu guibg=NONE ctermbg=NONE
  hi SignColumn guibg=NONE ctermbg=NONE
  hi VertSplit guibg=NONE ctermbg=NONE
  hi StatusLine guibg=NONE ctermbg=NONE
]])

---- saves history even when closed
vim.o.undofile = true
