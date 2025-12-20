------------------------------------- Setup lazy.nvim ------------------------------------
local lazypath = vim.fn.stdpath("data") .. "/lazy/lazy.nvim"
if not (vim.uv or vim.loop).fs_stat(lazypath) then
	local lazyrepo = "https://github.com/folke/lazy.nvim.git"
	local out = vim.fn.system({ "git", "clone", "--filter=blob:none", "--branch=stable", lazyrepo, lazypath })
	if vim.v.shell_error ~= 0 then
		vim.api.nvim_echo({
			{ "Failed to clone lazy.nvim:\n", "ErrorMsg" },
			{ out,                            "WarningMsg" },
			{ "\nPress any key to exit..." },
		}, true, {})
		vim.fn.getchar()
		os.exit(1)
	end
end
vim.opt.rtp:prepend(lazypath)

vim.g.mapleader = " "
vim.g.maplocalleader = "\\"

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
					transparent_background = true,
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
			config = function()
				local builtin = require("telescope.builtin")
				vim.keymap.set("n", "<leader>fd", builtin.find_files, { desc = "Telescope find files" })
				vim.keymap.set("n", "<leader>rg", builtin.live_grep, { desc = "Telescope live grep" })
				vim.keymap.set("n", "<leader>fb", builtin.buffers, { desc = "Telescope buffers" })
				vim.keymap.set("n", "<leader>rr", builtin.lsp_references, { desc = "Telescope show lsp refs" })

				vim.keymap.set("n", "<leader>ic", builtin.lsp_incoming_calls, { desc = "Telescope show incoming calls" })
				vim.keymap.set("n", "<leader>ci", builtin.lsp_outgoing_calls, { desc = "Telescope show ougoing calls" })
				vim.keymap.set("n", "<leader>tds", builtin.lsp_document_symbols,
					{ desc = "Telescope show document symbols" })
				vim.keymap.set("n", "<leader>tws", builtin.lsp_workspace_symbols,
					{ desc = "Telescope show workspace symbols" })

				vim.keymap.set("n", "<leader>fh", builtin.help_tags, { desc = "Telescope help tags" })

				-- turn on linenumbers in telescope preview
				vim.cmd("autocmd User TelescopePreviewerLoaded setlocal number")
			end,

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
			"hedyhli/outline.nvim",
			config = function()
				vim.keymap.set("n", "<leader>o", "<cmd>Outline<CR>", { desc = "Toggle Outline" })
				require("outline").setup {}
			end,
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

		{ -- avante config seems quite delicate dont recommend touching it too much
			"yetone/avante.nvim",
			-- if you want to build from source then do `make BUILD_FROM_SOURCE=true`
			-- ⚠️ must add this setting! ! !
			build = vim.fn.has("win32") ~= 0
				and "powershell -ExecutionPolicy Bypass -File Build.ps1 -BuildFromSource false"
				or "make",
			event = "VeryLazy",
			version = false, -- Never set this value to "*"! Never!
			---@module 'avante'
			---@type avante.Config
			hints = {
				enabled = false,
			},
			opts = {
				-- add any opts here this file can contain specific instructions for your project
				instructions_file = "avante.md",
				-- for example
				provider = "copilot",
				--mode = "legacy", -- Switch from "agentic" to "legacy"
				web_search_engine = {
					provider = "tavily",
					proxy = nil, -- proxy support, e.g., http://127.0.0.1:7890
				},
			},
			dependencies = {
				"nvim-lua/plenary.nvim",
				"MunifTanjim/nui.nvim",
				--- The below dependencies are optional,
				"nvim-mini/mini.pick", -- for file_selector provider mini.pick
				"nvim-telescope/telescope.nvim", -- for file_selector provider telescope
				"hrsh7th/nvim-cmp",  -- autocompletion for avante commands and mentions
				"ibhagwan/fzf-lua",  -- for file_selector provider fzf
				"stevearc/dressing.nvim", -- for input provider dressing
				"folke/snacks.nvim", -- for input provider snacks
				"nvim-tree/nvim-web-devicons", -- or echasnovski/mini.icons
				"zbirenbaum/copilot.lua", -- for providers='copilot'
				{
					-- support for image pasting
					"HakonHarnes/img-clip.nvim",
					event = "VeryLazy",
					opts = {
						-- recommended settings
						default = {
							embed_image_as_base64 = false,
							prompt_for_file_name = false,
							drag_and_drop = {
								insert_mode = true,
							},
							-- required for Windows users
							use_absolute_path = true,
						},
					},
				},
				{
					-- Make sure to set this up properly if you have lazy=true
					'MeanderingProgrammer/render-markdown.nvim',
					opts = {
						file_types = { "markdown", "Avante" },
					},
					ft = { "markdown", "Avante" },
				},
			},
		},

		{
			"gruvw/strudel.nvim",
			build = "npm ci",
			ft = { "strudel", "javascript", "typescript" },
			config = function()
				local strudel = require("strudel")
				strudel.setup()

				vim.keymap.set("n", "<leader>sl", strudel.launch, { desc = "Launch Strudel" })
				vim.keymap.set("n", "<leader>sq", strudel.quit, { desc = "Quit Strudel" })
				vim.keymap.set("n", "<leader>st", strudel.toggle, { desc = "Strudel Toggle Play/Stop" })
				vim.keymap.set("n", "<leader>su", strudel.update, { desc = "Strudel Update" })
				vim.keymap.set("n", "<leader>ss", strudel.stop, { desc = "Strudel Stop Playback" })
				vim.keymap.set("n", "<leader>sb", strudel.set_buffer, { desc = "Strudel set current buffer" })
				vim.keymap.set("n", "<leader>sx", strudel.execute, { desc = "Strudel execute buffer" })
			end,
		},

	},

	checker = { enabled = true, notify = false },
})

--------------------------------- lsp ---------------------------------

vim.lsp.config["lua-language-server"] = {
	cmd = { "lua-language-server", "--background-index" },
	root_markers = { ".luarc.json" },
	filetypes = { "lua" },
}
vim.lsp.enable("lua-language-server")

vim.lsp.config["pyright"] = {
	cmd = { "pyright-langserver", "--stdio" },
	filetypes = { "python" },
	root_markers = { ".git", "pyproject.toml", "setup.py", "setup.cfg", "requirements.txt" },
}
vim.lsp.enable("pyright")

vim.lsp.config["typescript-language-server"] = {
	cmd = { "typescript-language-server", "--stdio" },

	filetypes = {
		"javascript",
		"javascriptreact",
		"javascript.jsx",
		"typescript",
		"typescriptreact",
		"typescript.tsx",
	},

	root_markers = {
		"package.json",
		"tsconfig.json",
		"jsconfig.json",
		".git",
	},
}

vim.lsp.enable("typescript-language-server")


vim.lsp.config["clangd"] = {
	cmd = { "clangd", "--background-index" },
	root_markers = { "compile_commands.json", "compile_flags.txt" },
	filetypes = { "c", "cpp", "cuda", "h" },
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
end, { desc = "Switch between source/header" }
)

vim.api.nvim_create_autocmd("lspattach", {
	callback = function(ev)
		vim.keymap.set("n", "gd", vim.lsp.buf.definition, opts)
		vim.keymap.set("n", "gD", vim.lsp.buf.declaration, opts)
		vim.keymap.set("n", "gi", vim.lsp.buf.implementation, opts)
		--vim.keymap.set("n", "<leader>gd", vim.lsp.buf.type_definition, opts)
		--vim.keymap.set("n", "K", vim.lsp.buf.hover, opts)
		vim.keymap.set("n", "<leader>vws", vim.lsp.buf.workspace_symbol, opts)

		vim.keymap.set("n", "<leader>df", function() vim.diagnostic.open_float({ border = "single" }) end, opts)
		vim.keymap.set("n", "<leader>td", function() toggle_buffer_disgnostics() end, opts)

		-- vim.keymap.set("n", "<leader>lf", '<cmd>lua require("conform").format()<CR>')
		-- vim.keymap.set("v", "<leader>lf", '<cmd>lua require("conform").format()<CR>')
		vim.keymap.set('n', "<leader>lf", '<cmd>lua vim.lsp.buf.format()<CR>')
		vim.keymap.set('v', "<leader>lf", '<cmd>lua vim.lsp.buf.format()<CR>')

		vim.keymap.set("n", "[d", vim.diagnostic.goto_next, opts)
		vim.keymap.set("n", "]d", vim.diagnostic.goto_prev, opts)
		vim.keymap.set({ "n", "v" }, "<leader>ca", vim.lsp.buf.code_action, opts)
		-- vim.keymap.set("n", "<leader>ref", vim.lsp.buf.references, opts)
		-- vim.keymap.set("n", "<leader>rn", vim.lsp.buf.rename, opts)
		-- vim.keymap.set("i", "Find Appropriate Keymap", vim.lsp.buf.signature_help, opts)
		--		vim.keymap.set("n", "<leader>ic", '<cmd>lua vim.lsp.buf.incoming_calls()<CR>')
		--		vim.keymap.set("n", "<leader>ci", '<cmd>lua vim.lsp.buf.outgoing_calls()<CR>')
		--		vim.keymap.set("n", "<leader>ss", '<cmd>lua vim.lsp.buf.document_symbol()<CR>')
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

------------------------------------------------------------------------------------

vim.cmd("colorscheme evergarden")

-- Toggle these for line number shenanigans
vim.o.termguicolors = true
vim.opt.termguicolors = true
vim.opt.number = true
--vim.opt.relativenumber = true

vim.o.laststatus = 0
vim.opt.clipboard = "unnamedplus"

-- Disable automatic comment continuation on newline
vim.api.nvim_create_autocmd("FileType", {
	pattern = "*",
	callback = function()
		vim.opt_local.formatoptions:remove({ "c", "r", "o" })
	end,
})

-- saves history even when closed
vim.o.undofile = true

-- convenient command to open config
vim.api.nvim_create_user_command(
	"Config",
	function()
		vim.cmd("e $HOME/.config/nvim/init.lua")
	end,
	{}
)
