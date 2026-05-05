vim.g.mapleader = " "
vim.g.maplocalleader = " "
vim.g.have_nerd_font = true
vim.o.number = true
--vim.o.relativenumber = true
vim.o.mouse = "a"
vim.o.showmode = true

vim.o.termguicolors = true
vim.o.laststatus = 0

vim.schedule(function()
	vim.o.clipboard = "unnamedplus"
end)

--vim.o.breakindent = true -- Enable break indent
vim.o.undofile = true
vim.o.ignorecase = true -- Case-insensitive searching UNLESS \C or one or more capital letters in the search term
vim.o.smartcase = true
vim.o.signcolumn = "yes" -- Keep signcolumn on by default

vim.o.updatetime = 250 -- Decrease update time
vim.o.timeoutlen = 300 -- Decrease mapped sequence wait time

-- Configure how new splits should be opened
vim.o.splitright = true
vim.o.splitbelow = true

-- Disable automatic comment continuation on newline
vim.api.nvim_create_autocmd("FileType", {
	pattern = "*",
	callback = function()
		vim.opt_local.formatoptions:remove({ "c", "r", "o" })
	end,
})

-- command to open config
vim.api.nvim_create_user_command("Config", function()
	vim.cmd("e $HOME/.config/nvim/init.lua")
end, {})

-- command should clean up all nvim cache and plugins
vim.api.nvim_create_user_command("CleanAll", function()
	vim.cmd("!rm -rf $HOME/.local/share/nvim/")
	vim.cmd("!rm -rf $HOME/.local/state/nvim/")
	vim.cmd("!rm -rf $HOME/.cache/nvim/")
end, {})

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

vim.o.list = true
vim.opt.listchars = { tab = "» ", trail = "·", nbsp = "␣" }

vim.o.inccommand = "split" -- Preview substitutions live, as you type!
-- vim.o.confirm = true

vim.keymap.set("n", "<Esc>", "<cmd>nohlsearch<CR>") -- Clear highlights on search when pressing <Esc> in normal mode See `:help hlsearch`
vim.diagnostic.config({
	severity_sort = true,
	-- underline = { severity = { min = vim.diagnostic.severity.WARN } },
})
vim.keymap.set("n", "<leader>q", vim.diagnostic.setloclist, { desc = "Open diagnostic [Q]uickfix list" })
vim.keymap.set("t", "<Esc><Esc>", "<C-\\><C-n>", { desc = "Exit terminal mode" })

--  See `:help wincmd` for a list of all window commands
vim.keymap.set("n", "<C-h>", "<C-w><C-h>", { desc = "Move focus to the left window" })
vim.keymap.set("n", "<C-l>", "<C-w><C-l>", { desc = "Move focus to the right window" })
vim.keymap.set("n", "<C-j>", "<C-w><C-j>", { desc = "Move focus to the lower window" })
vim.keymap.set("n", "<C-k>", "<C-w><C-k>", { desc = "Move focus to the upper window" })
-- NOTE: Some terminals have colliding keymaps or are not able to send distinct keycodes
-- vim.keymap.set("n", "<C-S-h>", "<C-w>H", { desc = "Move window to the left" })
-- vim.keymap.set("n", "<C-S-l>", "<C-w>L", { desc = "Move window to the right" })
-- vim.keymap.set("n", "<C-S-j>", "<C-w>J", { desc = "Move window to the lower" })
-- vim.keymap.set("n", "<C-S-k>", "<C-w>K", { desc = "Move window to the upper" })

-- [[ Basic Autocommands ]]
vim.api.nvim_create_autocmd("TextYankPost", {
	desc = "Highlight when yanking (copying) text",
	group = vim.api.nvim_create_augroup("kickstart-highlight-yank", { clear = true }),
	callback = function()
		vim.hl.on_yank()
	end,
})

-- file specific indenting
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

-- [[ Install `lazy.nvim` plugin manager ]]
local lazypath = vim.fn.stdpath("data") .. "/lazy/lazy.nvim"
if not (vim.uv or vim.loop).fs_stat(lazypath) then
	local lazyrepo = "https://github.com/folke/lazy.nvim.git"
	local out = vim.fn.system({ "git", "clone", "--filter=blob:none", "--branch=stable", lazyrepo, lazypath })
	if vim.v.shell_error ~= 0 then
		error("Error cloning lazy.nvim:\n" .. out)
	end
end

---@type vim.Option
local rtp = vim.opt.rtp
rtp:prepend(lazypath)

require("lazy").setup({
	{
		"nvim-telescope/telescope.nvim",
		enabled = true,
		event = "VimEnter",
		dependencies = {
			"nvim-lua/plenary.nvim",
			{
				"nvim-telescope/telescope-fzf-native.nvim",
				build = "make",
				cond = function()
					return vim.fn.executable("make") == 1
				end,
			},
			{ "nvim-telescope/telescope-ui-select.nvim" },
			{ "nvim-tree/nvim-web-devicons", enabled = vim.g.have_nerd_font }, -- Useful for getting pretty icons, but requires a Nerd Font.
		},
		config = function()
			-- [[ Configure Telescope ]]
			require("telescope").setup({
				-- You can put your default mappings / updates / etc. in here
				--  All the info you're looking for is in `:help telescope.setup()`
				--
				-- defaults = {
				--   mappings = {
				--     i = { ['<c-enter>'] = 'to_fuzzy_refine' },
				--   },
				-- },
				-- pickers = {}
				extensions = {
					["ui-select"] = { require("telescope.themes").get_dropdown() },
				},
			})

			-- Enable Telescope extensions if they are installed
			pcall(require("telescope").load_extension, "fzf")
			pcall(require("telescope").load_extension, "ui-select")

			-- See `:help telescope.builtin`
			local builtin = require("telescope.builtin")
			--      vim.keymap.set('n', '<leader>sh', builtin.help_tags, { desc = '[S]earch [H]elp' })
			--      vim.keymap.set('n', '<leader>sk', builtin.keymaps, { desc = '[S]earch [K]eymaps' })
			--      vim.keymap.set('n', '<leader>sf', builtin.find_files, { desc = '[S]earch [F]iles' })
			--      vim.keymap.set('n', '<leader>ss', builtin.builtin, { desc = '[S]earch [S]elect Telescope' })
			--      vim.keymap.set({ 'n', 'v' }, '<leader>sw', builtin.grep_string, { desc = '[S]earch current [W]ord' })
			--      vim.keymap.set('n', '<leader>sg', builtin.live_grep, { desc = '[S]earch by [G]rep' })
			--      vim.keymap.set('n', '<leader>sd', builtin.diagnostics, { desc = '[S]earch [D]iagnostics' })
			--      vim.keymap.set('n', '<leader>sr', builtin.resume, { desc = '[S]earch [R]esume' })
			--      vim.keymap.set('n', '<leader>s.', builtin.oldfiles, { desc = '[S]earch Recent Files ("." for repeat)' })
			--      vim.keymap.set('n', '<leader>sc', builtin.commands, { desc = '[S]earch [C]ommands' })
			--      vim.keymap.set('n', '<leader><leader>', builtin.buffers, { desc = '[ ] Find existing buffers' })

			vim.keymap.set("n", "<leader>fd", builtin.find_files, { desc = "Telescope find files" })
			vim.keymap.set("n", "<leader>rg", builtin.live_grep, { desc = "Telescope live grep" })
			vim.keymap.set("n", "<leader>fb", builtin.buffers, { desc = "Telescope buffers" })
			vim.keymap.set(
				"n",
				"<leader>cb",
				builtin.current_buffer_fuzzy_find,
				{ desc = "Telescope current buffer fzf" }
			)

			-- turn on linenumbers in telescope preview
			vim.cmd("autocmd User TelescopePreviewerLoaded setlocal number")

			vim.api.nvim_create_autocmd("LspAttach", {
				group = vim.api.nvim_create_augroup("telescope-lsp-attach", { clear = true }),
				callback = function(event)
					local buf = event.buf
					-- stylua: ignore start

					--          vim.keymap.set('n', 'grr', builtin.lsp_references, { buffer = buf, desc = '[G]oto [R]eferences' })
					--          vim.keymap.set('n', 'gri', builtin.lsp_implementations, { buffer = buf, desc = '[G]oto [I]mplementation' })
					--          vim.keymap.set('n', 'grd',
					--
					--          vim.keymap.set('n', 'gO', builtin.lsp_document_symbols, { buffer = buf, desc = 'Open Document Symbols' })
					--          vim.keymap.set('n', 'gW', builtin.lsp_dynamic_workspace_symbols, { buffer = buf, desc = 'Open Workspace Symbols' })
					--
					--          vim.keymap.set('n', 'grt', builtin.lsp_type_definitions, { buffer = buf, desc = '[G]oto [T]ype Definition' })

					--vim.keymap.set("n", "gD", vim.lsp.buf.declaration, opts)

					vim.keymap.set("n", "gd", builtin.lsp_definitions, { buffer = buf, desc = "[G]oto [D]efinition" })
					vim.keymap.set( "n", "gi", builtin.lsp_implementations, { buffer = buf, desc = "[G]oto [I]mplementation" })
					vim.keymap.set("n", "<leader>rr", builtin.lsp_references, { desc = "Telescope show lsp refs" })
					vim.keymap.set( "n", "<leader>ic", builtin.lsp_incoming_calls, { desc = "Telescope show incoming calls" })
					vim.keymap.set( "n", "<leader>ci", builtin.lsp_outgoing_calls, { desc = "Telescope show ougoing calls" })
					vim.keymap.set( "n", "<leader>tds", builtin.lsp_document_symbols, { desc = "Telescope show document symbols" })
					vim.keymap.set( "n", "<leader>tws", builtin.lsp_workspace_symbols, { desc = "Telescope show workspace symbols" })

					vim.keymap.set("n", "<leader>df", function() vim.diagnostic.open_float({ border = "single" }) end, opts)

					vim.keymap.set("n", "<leader>lf", "<cmd>lua vim.lsp.buf.format()<CR>")
					vim.keymap.set("v", "<leader>lf", "<cmd>lua vim.lsp.buf.format()<CR>")

					vim.keymap.set("n", "<leader>rn", vim.lsp.buf.rename, opts)
					vim.keymap.set("n", "<leader>ss", "<cmd>lua vim.lsp.buf.document_symbol()<CR>")

					-- stylua: ignore start
				end,
			})

			vim.keymap.set("n", "<leader>/", function()
				builtin.current_buffer_fuzzy_find(require("telescope.themes").get_dropdown({
					winblend = 10,
					previewer = false,
				}))
			end, { desc = "[/] Fuzzily search in current buffer" })

			vim.keymap.set("n", "<leader>s/", function()
				builtin.live_grep({
					grep_open_files = true,
					prompt_title = "Live Grep in Open Files",
				})
			end, { desc = "[S]earch [/] in Open Files" })

			-- Shortcut for searching your Neovim configuration files
			vim.keymap.set("n", "<leader>sn", function()
				builtin.find_files({ cwd = vim.fn.stdpath("config") })
			end, { desc = "[S]earch [N]eovim files" })
		end,
	},

	{
		"neovim/nvim-lspconfig",
		dependencies = {
			{
				"mason-org/mason.nvim",
				---@module 'mason.settings'
				---@type MasonSettings
				---@diagnostic disable-next-line: missing-fields
				opts = {},
			},
			"mason-org/mason-lspconfig.nvim",
			"WhoIsSethDaniel/mason-tool-installer.nvim",

			{ "j-hui/fidget.nvim", opts = {} },
		},
		config = function()
			--  This function gets run when an LSP attaches to a particular buffer.
			--    That is to say, every time a new file is opened that is associated with
			--    an lsp (for example, opening `main.rs` is associated with `rust_analyzer`) this
			--    function will be executed to configure the current buffer
			vim.api.nvim_create_autocmd("LspAttach", {
				group = vim.api.nvim_create_augroup("kickstart-lsp-attach", { clear = true }),
				callback = function(event)
					-- NOTE: Remember that Lua is a real programming language, and as such it is possible
					-- to define small helper and utility functions so you don't have to repeat yourself.
					--
					-- In this case, we create a function that lets us more easily define mappings specific
					-- for LSP related items. It sets the mode, buffer and description for us each time.
					local map = function(keys, func, desc, mode)
						mode = mode or "n"
						vim.keymap.set(mode, keys, func, { buffer = event.buf, desc = "LSP: " .. desc })
					end

					-- Rename the variable under your cursor.
					--  Most Language Servers support renaming across files, etc.
					map("grn", vim.lsp.buf.rename, "[R]e[n]ame")

					-- Execute a code action, usually your cursor needs to be on top of an error
					-- or a suggestion from your LSP for this to activate.
					map("gra", vim.lsp.buf.code_action, "[G]oto Code [A]ction", { "n", "x" })

					-- WARN: This is not Goto Definition, this is Goto Declaration.
					--  For example, in C this would take you to the header.
					map("grD", vim.lsp.buf.declaration, "[G]oto [D]eclaration")

					-- The following two autocommands are used to highlight references of the
					-- word under your cursor when your cursor rests there for a little while.
					--    See `:help CursorHold` for information about when this is executed
					--
					-- When you move your cursor, the highlights will be cleared (the second autocommand).
					local client = vim.lsp.get_client_by_id(event.data.client_id)
					if client and client:supports_method("textDocument/documentHighlight", event.buf) then
						local highlight_augroup =
							vim.api.nvim_create_augroup("kickstart-lsp-highlight", { clear = false })
						vim.api.nvim_create_autocmd({ "CursorHold", "CursorHoldI" }, {
							buffer = event.buf,
							group = highlight_augroup,
							callback = vim.lsp.buf.document_highlight,
						})

						vim.api.nvim_create_autocmd({ "CursorMoved", "CursorMovedI" }, {
							buffer = event.buf,
							group = highlight_augroup,
							callback = vim.lsp.buf.clear_references,
						})

						vim.api.nvim_create_autocmd("LspDetach", {
							group = vim.api.nvim_create_augroup("kickstart-lsp-detach", { clear = true }),
							callback = function(event2)
								vim.lsp.buf.clear_references()
								vim.api.nvim_clear_autocmds({ group = "kickstart-lsp-highlight", buffer = event2.buf })
							end,
						})
					end

					-- The following code creates a keymap to toggle inlay hints in your
					-- code, if the language server you are using supports them
					--
					-- This may be unwanted, since they displace some of your code
					if client and client:supports_method("textDocument/inlayHint", event.buf) then
						map("<leader>th", function()
							vim.lsp.inlay_hint.enable(not vim.lsp.inlay_hint.is_enabled({ bufnr = event.buf }))
						end, "[T]oggle Inlay [H]ints")
					end
				end,
			})

			---@type table<string, vim.lsp.Config>
			local servers = {
				clangd = {

					cmd = {
						"clangd",
						"--background-index-priority=low",
						"--pch-storage=disk",
						"--clang-tidy",
						"--clang-tidy-checks=*",
						"--cross-file-rename",
						"--background-index",
						"--query-driver",
						"--clang-tidy",
						"--log=verbose",
						"--pretty",
					},
				},
				rust_analyzer = {},

				-- But for many setups, the LSP (`ts_ls`) will work just fine
				-- ts_ls = {},

				stylua = {}, -- Used to format Lua code

				-- Special Lua Config, as recommended by neovim help docs
				lua_ls = {
					on_init = function(client)
						client.server_capabilities.documentFormattingProvider = false -- Disable formatting (formatting is done by stylua)

						if client.workspace_folders then
							local path = client.workspace_folders[1].name
							if
								path ~= vim.fn.stdpath("config")
								and (vim.uv.fs_stat(path .. "/.luarc.json") or vim.uv.fs_stat(path .. "/.luarc.jsonc"))
							then
								return
							end
						end

						client.config.settings.Lua = vim.tbl_deep_extend("force", client.config.settings.Lua, {
							runtime = {
								version = "LuaJIT",
								path = { "lua/?.lua", "lua/?/init.lua" },
							},
							workspace = {
								checkThirdParty = false,
								-- NOTE: this is a lot slower and will cause issues when working on your own configuration.
								--  See https://github.com/neovim/nvim-lspconfig/issues/3189
								library = vim.tbl_extend("force", vim.api.nvim_get_runtime_file("", true), {
									"${3rd}/luv/library",
									"${3rd}/busted/library",
								}),
							},
						})
					end,
					---@type lspconfig.settings.lua_ls
					settings = {
						Lua = {
							format = { enable = false }, -- Disable formatting (formatting is done by stylua)
						},
					},
				},
			}

			local ensure_installed = vim.tbl_keys(servers or {})
			vim.list_extend(ensure_installed, {
				-- You can add other tools here that you want Mason to install
			})

			require("mason-tool-installer").setup({ ensure_installed = ensure_installed })

			for name, server in pairs(servers) do
				vim.lsp.config(name, server)
				vim.lsp.enable(name)
			end
		end,
	},

	{ -- Autoformat
		"stevearc/conform.nvim",
		event = { "BufWritePre" },
		cmd = { "ConformInfo" },
		keys = {
			{
				"<leader>f",
				function()
					require("conform").format({ async = true })
				end,
				mode = "",
				desc = "[F]ormat buffer",
			},
		},
		---@module 'conform'
		---@type conform.setupOpts
		opts = {
			notify_on_error = false,
			format_on_save = function(bufnr)
				-- You can specify filetypes to autoformat on save here:
				local enabled_filetypes = {
					-- lua = true,
					-- python = true,
				}
				if enabled_filetypes[vim.bo[bufnr].filetype] then
					return { timeout_ms = 500 }
				else
					return nil
				end
			end,
			default_format_opts = {
				lsp_format = "fallback", -- Use external formatters if configured below, otherwise use LSP formatting. Set to `false` to disable LSP formatting entirely.
			},
			-- You can also specify external formatters in here.
			formatters_by_ft = {
				-- rust = { 'rustfmt' },
				-- Conform can also run multiple formatters sequentially
				-- python = { "isort", "black" },
				--
				-- You can use 'stop_after_first' to run the first available formatter from the list
				-- javascript = { "prettierd", "prettier", stop_after_first = true },
			},
		},
	},

	{ -- Autocompletion
		"saghen/blink.cmp",
		--		{
		--			"saghen/blink.cmp",
		--			dependencies = { "rafamadriz/friendly-snippets" },
		--			version = "1.*",
		--
		--			opts = {
		--				keymap = { preset = "default" },
		--				appearance = { nerd_font_variant = "mono" },
		--				completion = {
		--					documentation = { auto_show = true },
		--					ghost_text = { enabled = true },
		--				},
		--			},
		--
		--			opts_extend = { "sources.default" },
		--		},
		event = "VimEnter",
		version = "1.*",
		dependencies = {
			-- Snippet Engine
			{
				"L3MON4D3/LuaSnip",
				version = "2.*",
				build = (function()
					-- Build Step is needed for regex support in snippets.
					-- This step is not supported in many windows environments.
					-- Remove the below condition to re-enable on windows.
					if vim.fn.has("win32") == 1 or vim.fn.executable("make") == 0 then
						return
					end
					return "make install_jsregexp"
				end)(),
				dependencies = {
					-- `friendly-snippets` contains a variety of premade snippets.
					--    See the README about individual language/framework/plugin snippets:
					--    https://github.com/rafamadriz/friendly-snippets
					-- {
					--   'rafamadriz/friendly-snippets',
					--   config = function()
					--     require('luasnip.loaders.from_vscode').lazy_load()
					--   end,
					-- },
				},
				opts = {},
			},
		},
		---@module 'blink.cmp'
		---@type blink.cmp.Config
		opts = {
			keymap = { preset = "default" },
			appearance = { nerd_font_variant = "mono" },
			completion = { documentation = { auto_show = false, auto_show_delay_ms = 500 } },
			sources = { default = { "lsp", "path", "snippets" } },
			snippets = { preset = "luasnip" },
			fuzzy = { implementation = "lua" },
			signature = { enabled = true },
		},
	},

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
				float = { color = "mantle", invert_border = false },
				completion = { color = "surface0" },
			},
		},
	},

	{ -- Highlight todo, notes, etc in comments
		"folke/todo-comments.nvim",
		event = "VimEnter",
		dependencies = { "nvim-lua/plenary.nvim" },
		---@module 'todo-comments'
		---@type TodoOptions
		---@diagnostic disable-next-line: missing-fields
		opts = { signs = false },
	},

	{ -- Collection of various small independent plugins/modules
		"nvim-mini/mini.nvim",
		config = function()
			-- Better Around/Inside textobjects
			--
			-- Examples:
			--  - va)  - [V]isually select [A]round [)]paren
			--  - yiiq - [Y]ank [I]nside [I]+1 [Q]uote
			--  - ci'  - [C]hange [I]nside [']quote
			require("mini.ai").setup({
				-- NOTE: Avoid conflicts with the built-in incremental selection mappings on Neovim>=0.12 (see `:help treesitter-incremental-selection`)
				mappings = {
					around_next = "aa",
					inside_next = "ii",
				},
				n_lines = 500,
			})

			-- Add/delete/replace surroundings (brackets, quotes, etc.)
			--
			-- - saiw) - [S]urround [A]dd [I]nner [W]ord [)]Paren
			-- - sd'   - [S]urround [D]elete [']quotes
			-- - sr)'  - [S]urround [R]eplace [)] [']
			require("mini.surround").setup()

			-- Simple and easy statusline.
			--  You could remove this setup call if you don't like it,
			--  and try some other statusline plugin
			local statusline = require("mini.statusline")
			-- set use_icons to true if you have a Nerd Font
			statusline.setup({ use_icons = vim.g.have_nerd_font })

			-- You can configure sections in the statusline by overriding their
			-- default behavior. For example, here we set the section for
			-- cursor location to LINE:COLUMN
			---@diagnostic disable-next-line: duplicate-set-field
			statusline.section_location = function()
				return "%2l:%-2v"
			end

			-- ... and there is more!
			--  Check out: https://github.com/nvim-mini/mini.nvim
		end,
	},

	{
		"nvim-treesitter/nvim-treesitter",
		lazy = false,
		build = ":TSUpdate",
		branch = "main",
		-- [[ Configure Treesitter ]] See `:help nvim-treesitter-intro`
		config = function()
			local parsers =
				{ "bash", "c", "c++", "python", "diff", "lua", "luadoc", "markdown", "markdown_inline", "vim" }
			require("nvim-treesitter").install(parsers)

			---@param buf integer
			---@param language string
			local function treesitter_try_attach(buf, language)
				-- check if parser exists and load it
				if not vim.treesitter.language.add(language) then
					return
				end
				-- enables syntax highlighting and other treesitter features
				vim.treesitter.start(buf, language)

				-- check if treesitter indentation is available for this language, and if so enable it
				-- in case there is no indent query, the indentexpr will fallback to the vim's built in one
				local has_indent_query = vim.treesitter.query.get(language, "indents") ~= nil

				--				-- enables treesitter based indentation
				--				if has_indent_query then
				--					vim.bo.indentexpr = "v:lua.require'nvim-treesitter'.indentexpr()"
				--				end
			end

			local available_parsers = require("nvim-treesitter").get_available()
			vim.api.nvim_create_autocmd("FileType", {
				callback = function(args)
					local buf, filetype = args.buf, args.match

					local language = vim.treesitter.language.get_lang(filetype)
					if not language then
						return
					end

					local installed_parsers = require("nvim-treesitter").get_installed("parsers")

					if vim.tbl_contains(installed_parsers, language) then
						-- enable the parser if it is installed
						treesitter_try_attach(buf, language)
					elseif vim.tbl_contains(available_parsers, language) then
						-- if a parser is available in `nvim-treesitter` auto install it, and enable it after the installation is done
						require("nvim-treesitter").install(language):await(function()
							treesitter_try_attach(buf, language)
						end)
					else
						-- try to enable treesitter features in case the parser exists but is not available from `nvim-treesitter`
						treesitter_try_attach(buf, language)
					end
				end,
			})
		end,
	},

	{
		"hedyhli/outline.nvim",
		config = function()
			vim.keymap.set("n", "<leader>o", "<cmd>Outline<CR>", { desc = "Toggle Outline" })
			require("outline").setup({})
		end,
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

	checker = { enabled = true, notify = false },
})

-- The line beneath this is called `modeline`. See `:help modeline`
-- vim: ts=2 sts=2 sw=2 et

vim.cmd("colorscheme evergarden")

--	},
--})
--
----------------------------------- lsp ---------------------------------
--
--vim.lsp.config["lua-language-server"] = {
--	cmd = { "lua-language-server", "--background-index" },
--	root_markers = { ".luarc.json" },
--	filetypes = { "lua" },
--}
--vim.lsp.enable("lua-language-server")
--
--vim.lsp.config["pylsp"] = {
--	cmd = { "pylsp" },
--	root_markers = {
--		"pyproject.toml",
--		"setuip.py",
--		"setup.cfg",
--		"requirements.txt",
--	},
--	plugins = {
--		ruff = {
--			enabled = true,         -- Enable the plugin
--			formatEnabled = true,   -- Enable formatting using ruffs formatter
--			extendSelect = { "I" }, -- Rules that are additionally used by ruff
--			extendIgnore = { "C90" }, -- Rules that are additionally ignored by ruff
--			format = { "I" },       -- Rules that are marked as fixable by ruff that should be fixed when running textDocument/formatting
--			severities = { ["D212"] = "I" }, -- Optional table of rules where a custom severity is desired
--			unsafeFixes = false,    -- Whether or not to offer unsafe fixes as code actions. Ignored with the "Fix All" action
--			unfixable = { "F401" }, -- Rules that are excluded when checking the code actions (including the "Fix All" action)
--
--			-- Rules that are ignored when a pyproject.toml or ruff.toml is present:
--			lineLength = 88,                        -- Line length to pass to ruff checking and formatting
--			exclude = { "__about__.py" },           -- Files to be excluded by ruff checking
--			select = { "F" },                       -- Rules to be enabled by ruff
--			ignore = { "D210" },                    -- Rules to be ignored by ruff
--			perFileIgnores = { ["__init__.py"] = "CPY001" }, -- Rules that should be ignored for specific files
--			preview = false,                        -- Whether to enable the preview style linting and formatting.
--			targetVersion = "py310",                -- The minimum python version to target (applies for both linting and formatting).
--		},
--	},
--	filetypes = { "python" },
--}
--vim.lsp.enable("pylsp")
--
--vim.lsp.config["typescript-language-server"] = {
--	cmd = { "typescript-language-server", "--stdio" },
--	root_markers = { "package.json", "tsconfig.json", "jsconfig.json", },
--	filetypes = { "javascript", },
--}
--vim.lsp.enable("typescript-language-server")
--
--
--vim.lsp.config["clangd"] = {
--	cmd = {
--		"clangd",
--		"--background-index=false",
--		"--fallback-style=Google",
--		--"--clang-tidy",
--		--"--limit-references=0",
--		--"--limit-results=0",
--	},
--	root_markers = { "compile_commands.json", "compile_flags.txt" },
--	filetypes = { "c", "cpp", "cuda" },
--}
--vim.lsp.enable("clangd")
