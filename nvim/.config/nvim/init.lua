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

vim.o.undofile = true
vim.o.ignorecase = true -- Case-insensitive searching UNLESS \C or one or more capital letters in the search term
vim.o.smartcase = true
vim.o.signcolumn = "yes" -- Keep signcolumn on by default

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

-- command should clean up all nvim cache and plugins
vim.api.nvim_create_user_command("CleanAll", function()
	vim.cmd("!rm -rf $HOME/.local/share/nvim/")
	vim.cmd("!rm -rf $HOME/.local/state/nvim/")
	vim.cmd("!rm -rf $HOME/.cache/nvim/")
end, {})

-- Easy switching between source and header (.h and .cpp) files
vim.keymap.set("n", "<leader>h", function()
	local params = { uri = vim.uri_from_bufnr(0) }
	vim.lsp.buf_request(0, "textDocument/switchSourceHeader", params, function(err, result)
		if err then
			vim.notify("Error: " .. tostring(err), vim.log.levels.ERROR)
			return
		end
		if result then
			vim.cmd("edit " .. vim.uri_to_fname(result))
		else
			vim.notify("No corresponding header/source found", vim.log.levels.INFO)
		end
	end)
end, { desc = "Switch between source/header" })

vim.keymap.set("t", "<Esc><Esc>", "<C-\\><C-n>", { desc = "Exit terminal mode" })
vim.keymap.set("n", "<leader>q", vim.diagnostic.setloclist, { desc = "Open diagnostic [Q]uickfix list" })
vim.keymap.set("n", "<leader>df", function()
	vim.diagnostic.open_float({ border = "single" })
end)

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
		},
		config = function()
			require("telescope").setup({
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

					-- stylua: ignore end
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

			vim.keymap.set("n", "<leader>sn", function()
				builtin.find_files({ cwd = vim.fn.stdpath("config") })
			end, { desc = "[S]earch [N]eovim files" })
		end,
	},

	{
		"neovim/nvim-lspconfig",
		dependencies = {
			{ "mason-org/mason.nvim", opts = {} },
			"mason-org/mason-lspconfig.nvim",
			{ "j-hui/fidget.nvim", opts = {} }, -- gives lsp initialisation progress
		},

		config = function()
			vim.api.nvim_create_autocmd("LspAttach", {
				group = vim.api.nvim_create_augroup("kickstart-lsp-attach", { clear = true }),
				callback = function(event)
					local map = function(keys, func, desc, mode)
						mode = mode or "n"
						vim.keymap.set(mode, keys, func, { buffer = event.buf, desc = "LSP: " .. desc })
					end

					map("grn", vim.lsp.buf.rename, "[R]e[n]ame")
					map("gra", vim.lsp.buf.code_action, "[G]oto Code [A]ction", { "n", "x" })
					map("grD", vim.lsp.buf.declaration, "[G]oto [D]eclaration")

					vim.keymap.set("n", "<leader>lf", "<cmd>lua vim.lsp.buf.format()<CR>")
					vim.keymap.set("v", "<leader>lf", "<cmd>lua vim.lsp.buf.format()<CR>")
					vim.keymap.set("n", "<leader>rn", vim.lsp.buf.rename)
					vim.keymap.set("n", "<leader>ss", "<cmd>lua vim.lsp.buf.document_symbol()<CR>")
				end,
			})

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

				ruff = {},
				pylsp = { cmd = { "pylsp" } },

				-- Special Lua Config, as recommended by neovim help docs
				stylua = {}, -- Used to format Lua code
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

			for name, server in pairs(servers) do
				vim.lsp.config(name, server)
				vim.lsp.enable(name)
			end
		end,
	},

	{
		"nvim-treesitter/nvim-treesitter",
		lazy = false,
		build = ":TSUpdate",
		branch = "main",
		config = function()
			local function treesitter_try_attach(buf, language)
				if not vim.treesitter.language.add(language) then
					return
				end
				vim.treesitter.start(buf, language)
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
						treesitter_try_attach(buf, language)
					elseif vim.tbl_contains(available_parsers, language) then
						require("nvim-treesitter").install(language):await(function()
							treesitter_try_attach(buf, language)
						end)
					else
						treesitter_try_attach(buf, language)
					end
				end,
			})
		end,
	},

	{
		"saghen/blink.cmp",
		event = "VimEnter",
		version = "1.*",
		opts = {
			keymap = { preset = "default" },
			appearance = { nerd_font_variant = "mono" },
			completion = {
				documentation = { auto_show = true },
				ghost_text = { enabled = true },
			},
			sources = { default = { "lsp", "path", "snippets" } },
		},
		opts_extend = { "sources.default" },
	},

	{
		"hedyhli/outline.nvim",
		config = function()
			vim.keymap.set("n", "<leader>o", "<cmd>Outline<CR>", { desc = "Toggle Outline" })
			require("outline").setup({})
		end,
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

vim.cmd("colorscheme evergarden")
