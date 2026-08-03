local theme_state_file = vim.fn.stdpath("state") .. "/theme"
local theme_state = (vim.fn.filereadable(theme_state_file) == 1) and vim.fn.readfile(theme_state_file)[1] or nil
COLOR_SCHEME = (theme_state == "light") and "light" or "dark"

vim.g.mapleader = " "
vim.g.maplocalleader = " "
vim.g.have_nerd_font = true
local map = vim.keymap.set
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
map("n", "<leader>h", function()
	local params = { uri = vim.uri_from_bufnr(0) }
	---@diagnostic disable-next-line: param-type-mismatch
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

map("n", "<leader>ld", function()
	vim.cmd("LeanInfoviewToggle")
end, { desc = "Toggle Lean [D]iagnostics" })

map("n", "<leader>lo", function()
  local ok, iv = pcall(require("lean.infoview").get_current_infoview)
  if ok and iv then
    if iv.window then
      local new = iv.__orientation_pref == "horizontal" and "vertical" or "horizontal"
      iv.__orientation_pref = new
      iv:close()
      iv:open()
    else
      iv:open()
    end
  end
end, { desc = "Toggle Lean infoview orientation" })

map("t", "<Esc><Esc>", "<C-\\><C-n>", { desc = "Exit terminal mode" })
map("n", "<leader>q", vim.diagnostic.setloclist, { desc = "Open diagnostic [Q]uickfix list" })
map("n", "<leader>df", function()
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

vim.api.nvim_create_autocmd("FileType", {
	pattern = { "python" },
	callback = function()
		vim.opt_local.expandtab = true
		vim.opt_local.tabstop = 4
		vim.opt_local.shiftwidth = 4
		vim.opt_local.softtabstop = 4
	end,
})

vim.api.nvim_create_autocmd("FileType", {
	pattern = { "lean" },
	callback = function()
		vim.opt_local.expandtab = true
		vim.opt_local.tabstop = 2
		vim.opt_local.shiftwidth = 2
		vim.opt_local.softtabstop = 2
	end,
})

vim.api.nvim_create_autocmd("QuitPre", {
	callback = function()
		if vim.bo.filetype == "lean" then
			pcall(require("lean.infoview").close_all)
		end
	end,
})

-- dark = evergarden (everviolet/nvim, fall variant / green accent)
-- light = rose-pine-dawn
local theme_files = {
	["dark"] = "evergarden",
	["light"] = "rose-pine-dawn",
}

local ghostty_themes = {
	["light"] = "3024 Day",
}

local function apply_colorscheme()
	local name = theme_files[COLOR_SCHEME]
	if name then
		pcall(vim.cmd.colorscheme, name)
	end
end

local function sync_ghostty_theme()
	local ghostty_config = vim.fn.expand("~/.config/ghostty/config")
	local lines = {}
	if vim.fn.filereadable(ghostty_config) == 1 then
		lines = vim.fn.readfile(ghostty_config)
	end

	-- remove any existing `theme = ...` entries, keep everything else
	local out = {}
	for _, line in ipairs(lines) do
		if not line:match("^%s*theme%s*=") then
			out[#out + 1] = line
		end
	end
	local theme = ghostty_themes[COLOR_SCHEME]
	if theme then
		out[#out + 1] = "theme = " .. theme
	end
	vim.fn.writefile(out, ghostty_config)

	-- ghostty does not watch the config file: hot-reload it via SIGUSR2
	-- opencode's `system` theme re-queries the terminal palette on SIGUSR2,
	-- so it repaints light/dark to match the new ghostty background
	if vim.fn.executable("pkill") == 1 then
		vim.fn.system("pkill -USR2 ghostty")
		vim.fn.system("pkill -USR2 opencode")
	end
end

local function save_theme_state()
	vim.fn.mkdir(vim.fn.fnamemodify(theme_state_file, ":h"), "p")
	vim.fn.writefile({ COLOR_SCHEME }, theme_state_file)
end

vim.api.nvim_create_autocmd("FileType", {
	pattern = { "*" },
	callback = function()
		apply_colorscheme()
	end,
})

vim.api.nvim_create_user_command("ToggleTheme", function()
	COLOR_SCHEME = (COLOR_SCHEME == "dark") and "light" or "dark"
	apply_colorscheme()
	sync_ghostty_theme()
	save_theme_state()
	vim.notify("Theme: " .. COLOR_SCHEME)
end, { desc = "Toggle between dark (evergarden) and light (rose-pine-dawn), syncing ghostty" })

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
			--      map('n', '<leader>sh', builtin.help_tags, { desc = '[S]earch [H]elp' })
			--      map('n', '<leader>sk', builtin.keymaps, { desc = '[S]earch [K]eymaps' })
			--      map('n', '<leader>sf', builtin.find_files, { desc = '[S]earch [F]iles' })
			--      map('n', '<leader>ss', builtin.builtin, { desc = '[S]earch [S]elect Telescope' })
			--      map({ 'n', 'v' }, '<leader>sw', builtin.grep_string, { desc = '[S]earch current [W]ord' })
			--      map('n', '<leader>sg', builtin.live_grep, { desc = '[S]earch by [G]rep' })
			--      map('n', '<leader>sd', builtin.diagnostics, { desc = '[S]earch [D]iagnostics' })
			--      map('n', '<leader>sr', builtin.resume, { desc = '[S]earch [R]esume' })
			map("n", "<leader>s.", builtin.oldfiles, { desc = '[S]earch Recent Files ("." for repeat)' })
			map("n", "<leader>sc", builtin.commands, { desc = "[S]earch [C]ommands" })
			map("n", "<leader><leader>", builtin.buffers, { desc = "[ ] Find existing buffers" })

			map("n", "<leader>fd", builtin.find_files, { desc = "Telescope find files" })
			map("n", "<leader>rg", builtin.live_grep, { desc = "Telescope live grep" })
			map("n", "<leader>fb", builtin.buffers, { desc = "Telescope buffers" })

			-- turn on linenumbers in telescope preview
			vim.cmd("autocmd User TelescopePreviewerLoaded setlocal number")

			vim.api.nvim_create_autocmd("LspAttach", {
				group = vim.api.nvim_create_augroup("telescope-lsp-attach", { clear = true }),
				callback = function(event)
					local buf = event.buf
					-- stylua: ignore start

					--          map('n', 'grr', builtin.lsp_references, { buffer = buf, desc = '[G]oto [R]eferences' })
					--          map('n', 'gri', builtin.lsp_implementations, { buffer = buf, desc = '[G]oto [I]mplementation' })
					--          map('n', 'grd',
					--
					--          map('n', 'gO', builtin.lsp_document_symbols, { buffer = buf, desc = 'Open Document Symbols' })
					--          map('n', 'gW', builtin.lsp_dynamic_workspace_symbols, { buffer = buf, desc = 'Open Workspace Symbols' })
					--
					--          map('n', 'grt', builtin.lsp_type_definitions, { buffer = buf, desc = '[G]oto [T]ype Definition' })

					--map("n", "gD", vim.lsp.buf.declaration, opts)

					map("n", "gd", builtin.lsp_definitions, { buffer = buf, desc = "[G]oto [D]efinition" })
					map( "n", "gi", builtin.lsp_implementations, { buffer = buf, desc = "[G]oto [I]mplementation" })
					map("n", "<leader>rr", builtin.lsp_references, { desc = "Telescope show lsp refs" })
					map( "n", "<leader>ic", builtin.lsp_incoming_calls, { desc = "Telescope show incoming calls" })
					map( "n", "<leader>ci", builtin.lsp_outgoing_calls, { desc = "Telescope show ougoing calls" })
					map( "n", "<leader>tds", builtin.lsp_document_symbols, { desc = "Telescope show document symbols" })
					map( "n", "<leader>tws", builtin.lsp_workspace_symbols, { desc = "Telescope show workspace symbols" })

					-- stylua: ignore end
				end,
			})

			map("n", "<leader>/", function()
				builtin.current_buffer_fuzzy_find(require("telescope.themes").get_dropdown({
					winblend = 10,
					previewer = false,
				}))
			end, { desc = "[/] Fuzzily search in current buffer" })

			map("n", "<leader>s/", function()
				builtin.live_grep({
					grep_open_files = true,
					prompt_title = "Live Grep in Open Files",
				})
			end, { desc = "[S]earch [/] in Open Files" })

			map("n", "<leader>sn", function()
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

					local function refs_by_kind(kind)
						local varname = vim.fn.expand("<cword>"):match("[%a_][%w_]*")
						if not varname then
							vim.notify("No identifier under cursor", vim.log.levels.WARN)
							return
						end
						if vim.fn.executable("clang-query") ~= 1 then
							vim.notify("Install clang-query for read/write references", vim.log.levels.WARN)
							return
						end

						local file = vim.fn.expand("%:p")
						local all_matcher = 'declRefExpr(to(varDecl(hasName("'
							.. varname ..
							'"))), unless(isExpansionInSystemHeader()))'
						local write_matcher = 'declRefExpr(to(varDecl(hasName("'
							.. varname ..
							'"))), hasParent(anyOf(binaryOperator(isAssignmentOperator()), unaryOperator(anyOf(hasOperatorName("++"), hasOperatorName("--"))))), unless(isExpansionInSystemHeader()))'

						local function run(m)
							return vim.fn.system({ "clang-query", file }, "match " .. m .. "\n")
						end

						local function parse(output)
							local seen, locs = {}, {}
							for line in output:gmatch("[^\n]+") do
								local f, l, c = line:match("^(.-):(%d+):(%d+): note:")
								if f and l and c then
									local key = f .. ":" .. l .. ":" .. c
									if not seen[key] then
										seen[key] = true
										locs[#locs + 1] = { filename = f, lnum = tonumber(l), col = tonumber(c) }
									end
								end
							end
							return locs
						end

						local all_locs = parse(run(all_matcher))
						local write_locs = parse(run(write_matcher))

						if #all_locs == 0 then
							vim.notify("No references to '" .. varname .. "'", vim.log.levels.INFO)
							return
						end

						local write_set = {}
						for _, w in ipairs(write_locs) do
							write_set[w.filename .. ":" .. w.lnum .. ":" .. w.col] = true
						end

						local target = {}
						for _, loc in ipairs(all_locs) do
							local key = loc.filename .. ":" .. loc.lnum .. ":" .. loc.col
							local is_write = write_set[key] ~= nil
							if (kind == 1 and is_write) or (kind ~= 1 and not is_write) then
								target[#target + 1] = loc
							end
						end

						if #target == 0 then
							vim.notify("No " .. (kind == 1 and "write" or "read") .. " refs to '"
								.. varname .. "'", vim.log.levels.INFO)
							return
						end

						local items = {}
						for _, loc in ipairs(target) do
							items[#items + 1] = {
								filename = loc.filename,
								lnum = loc.lnum,
								col = loc.col,
							}
						end
						vim.fn.setqflist({}, " ", { items = items })
						require("telescope.builtin").quickfix()
					end
					map("<leader>rd", function() refs_by_kind(2) end, "Read references")
					map("<leader>rw", function() refs_by_kind(1) end, "Write references")

					map("<leader>lf", "<cmd>lua vim.lsp.buf.format()<CR>", "Format buffer")
					map("<leader>lf", "<cmd>lua vim.lsp.buf.format()<CR>", "Format selection", "v")
					map("<leader>rn", vim.lsp.buf.rename, "Rename")
					map("<leader>ss", "<cmd>lua vim.lsp.buf.document_symbol()<CR>", "Document symbols")
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
						"--log=verbose",
						"--pretty",
					},
				},

				ruff = {},
				pylsp = { cmd = { "pylsp" } },
				yamlls = {
					settings = {
						yaml = { schemaStore = { enable = true } },
						redhat = { telemetry = { enabled = false } },
					},
				},
				-- lean is not here; lean.nvim handles its own LSP (leanls) via lsp/leanls.lua

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
		width = 33,
		auto_width = {
			enabled = false,
			max_width = 40,
		},
		-- Whether width is relative to the total width of nvim
		-- When relative_width = true, this means take 33% of the total
		-- screen width for outline window (1/3 of the horizontal space).
		relative_width = true,
		config = function()
			map("n", "<leader>o", "<cmd>Outline<CR>", { desc = "Toggle Outline" })
			require("outline").setup({})
		end,
	},

	{ -- dark theme
		"everviolet/nvim",
		name = "evergarden",
		priority = 1000,
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

	{ -- light theme
		"rose-pine/neovim",
		priority = 1000,
		name = "rose-pine-dawn",
		styles = {
			transparency = false,
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

	{
		"stevearc/oil.nvim",
		opts = {},
		dependencies = { { "nvim-mini/mini.icons", opts = {} } },
		lazy = false,
	},

	{
		"Julian/lean.nvim",
		init = function()
			vim.g.lean_config = {
				mappings = true,
				infoview = {
					-- vertical infoview takes 1/3 of the horizontal screen width
					width = 1 / 3,
					-- horizontal infoview takes 1/3 of the vertical screen height
					height = 1 / 3,
				},
				on_imports_out_of_date = function(bufnr)
					require("lean.lsp").restart_file(bufnr)
				end,
				lsp = {
					on_attach = function(_, bufnr)
						map("n", "<leader>lf", function()
							vim.lsp.buf.format({ bufnr = bufnr })
						end, { buffer = bufnr, desc = "Format Lean" })
					end,
				},
			}
		end,
	},

	checker = { enabled = true, notify = false },
})
