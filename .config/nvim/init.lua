vim.g.mapleader = " "
vim.g.maplocalleader = " "

-- Install package manager
--    https://github.com/folke/lazy.nvim
--    `:help lazy.nvim.txt` for more info
local lazypath = vim.fn.stdpath("data") .. "/lazy/lazy.nvim"
if not vim.uv.fs_stat(lazypath) then
	vim.fn.system({
		"git",
		"clone",
		"--filter=blob:none",
		"https://github.com/folke/lazy.nvim.git",
		"--branch=stable", -- latest stable release
		lazypath,
	})
end
vim.opt.rtp:prepend(lazypath)

local csv_fts = {
	"csv",
	"tsv",
	"csv_semicolon",
	"csv_whitespace",
	"csv_pipe",
	"rfc_csv",
	"rfc_semicolon",
}

local on_attach = function(client, bufnr)
	local nmap = function(keys, func, desc)
		if desc then
			desc = "LSP: " .. desc
		end

		vim.keymap.set("n", keys, func, { buffer = bufnr, desc = desc })
	end
	local telescope = require("telescope.builtin")

	nmap("<leader>R", vim.cmd.LspRestart, "Restart")
	nmap("<leader><C-r>", vim.cmd.LspStart, "Start / force restart")

	nmap("<leader>r", vim.lsp.buf.rename, "Rename")
	vim.keymap.set({ "n", "v" }, "<leader>a", vim.lsp.buf.code_action, { desc = "Code Action", buffer = bufnr }) -- 'weilbith/nvim-code-action-menu',

	nmap("gd", telescope.lsp_definitions, "Definition")
	nmap("gr", telescope.lsp_references, "References")
	nmap("gi", telescope.lsp_implementations, "Implementation")
	nmap("gy", telescope.lsp_type_definitions, "Type")

	nmap("K", vim.lsp.buf.hover, "Hover Documentation")
	vim.keymap.set({ "n", "i" }, "<C-k>", vim.lsp.buf.signature_help, { desc = "Signature Help" })
end

require("lazy").setup({
	-- detect tabs/spaces
	"tpope/vim-sleuth",
	-- "NMAC427/guess-indent.nvim",

	-- icons
	"nvim-tree/nvim-web-devicons",

	{
		"goolord/alpha-nvim",
		dependencies = { "nvim-tree/nvim-web-devicons" },
		config = function()
			local dashboard = require("alpha.themes.dashboard")

			-- just some silly stuff
			math.randomseed()
			local shuffled = {}
			for _, v in ipairs({
				[[███    ██ ███████  ██████  ██    ██ ██ ███    ███]],
				[[████   ██ ██      ██    ██ ██    ██ ██ ████  ████]],
				[[██ ██  ██ █████   ██    ██ ██    ██ ██ ██ ████ ██]],
				[[██  ██ ██ ██      ██    ██  ██  ██  ██ ██  ██  ██]],
				[[██   ████ ███████  ██████    ████   ██ ██      ██]],
			}) do
				local pos = math.random(1, #shuffled + 1)
				table.insert(shuffled, pos, v)
			end

			local branch =
				vim.fn.system("git branch --show-current 2> /dev/null | rev | cut -d / -f 1 | rev | tr -d '\n'")
			local branch_has_session = false
			local git_sha = vim.fn.system("git rev-parse --short HEAD 2> /dev/null | tr -d '\n'")

			local cwd = vim.fn.getcwd()
			local cwd_tail = string.match(cwd, "[^/]*$")
			local session_name = cwd_tail .. "__" .. branch
			local all_sessions = require("possession.session").list()
			local cwd_sessions = {}
			local other_sessions = {}
			for _, session in pairs(all_sessions) do
				if session.cwd == cwd then
					if session.name == session_name then
						branch_has_session = true
					else
						table.insert(cwd_sessions, session.name)
					end
				else
					table.insert(other_sessions, session.name)
				end
			end

			dashboard.section.header.val = shuffled
			dashboard.section.buttons.val = {
				dashboard.button(
					"f",
					"  Find Files",
					":Telescope " .. (git_sha ~= "" and "git_files" or "find_files") .. "<cr>"
				),
				dashboard.button("/", " " .. " Find Text", ":Telescope live_grep <CR>"),
				dashboard.button("e", "󰙅 " .. " Open Explorer", ":FloatermNew yazi <CR>"),
				(function()
					if branch ~= "" then
						return dashboard.button(
							"<CR>",
							"󰘬  " .. (branch_has_session and "Load" or "New") .. " Branch Session",
							(branch_has_session and ":PossessionLoad " or ":PossessionSave ") .. session_name .. "<CR>"
						)
					end
				end)(),
				dashboard.button("q", " " .. " Quit", ":qa<CR>"),
				{ type = "padding", val = 1 },
				(function()
					local group = {
						type = "group",
						opts = { spacing = 1 },
						val = {
							{
								type = "text",
								val = "Sessions",
								opts = {
									position = "center",
								},
							},
						},
					}

					vim.list_extend(cwd_sessions, other_sessions)
					for i = 1, 10, 1 do
						if cwd_sessions[i] ~= nil then
							table.insert(
								group.val,
								dashboard.button(
									tostring(i),
									"󰆓  " .. cwd_sessions[i],
									"<cmd>PossessionLoad " .. cwd_sessions[i] .. "<cr>"
								)
							)
						end
					end
					return group
				end)(),
			}
			dashboard.opts.layout[1].val = 8

			require("alpha").setup(dashboard.opts)
		end,
	},

	{
		"folke/flash.nvim",
		event = "VeryLazy",
		keys = {
			{
				"s",
				mode = { "n", "v" },
				function()
					require("flash").jump({
						search = {
							mode = function(str)
								return "\\<" .. str
							end,
						},
					})
				end,
				desc = "Flash",
			},
		},
		config = function()
			require("flash").setup({
				labels = "arstgmneiozxcdvkqwfpbjluy",
				modes = {
					search = {
						enabled = false,
					},
					char = {
						enabled = false,
					},
				},
			})
		end,
	},

	{
		"kristijanhusak/vim-dadbod-ui",
		dependencies = {
			{ "tpope/vim-dadbod", lazy = true },
			{ "kristijanhusak/vim-dadbod-completion", ft = { "sql", "mysql", "plsql" }, lazy = true },
		},
		cmd = {
			"DBUI",
			"DBUIToggle",
			"DBUIAddConnection",
			"DBUIFindBuffer",
		},
		init = function()
			-- Your DBUI configuration
			vim.g.db_ui_use_nerd_fonts = 1
			vim.g.db_ui_auto_execute_table_helpers = 1
			vim.g.db_ui_winwidth = 25
			vim.g.db_ui_execute_on_save = 0
			vim.g.vim_dadbod_completion_lowercase_keywords = 1

			vim.api.nvim_set_hl(0, "NotificationInfo", { link = "DiagnosticFloatingInfo" })
			vim.api.nvim_set_hl(0, "NotificationWarning", { link = "DiagnosticFloatingWarn" })
			vim.api.nvim_set_hl(0, "NotificationError", { link = "DiagnosticFloatingError" })
		end,
	},

	{
		"jedrzejboczar/possession.nvim",
		dependencies = { "nvim-lua/plenary.nvim" },
		config = function()
			vim.o.sessionoptions = "buffers,curdir"
			local possession = require("possession")
			possession.setup({
				autosave = {
					current = true,
					on_load = true,
					on_quit = true,
				},
				plugins = {
					delete_hidden_buffers = false,
					nvim_tree = false,
					neo_tree = false,
					symbols_outline = false,
					tabby = false,
					dap = false,
					dapui = false,
					neotest = false,
					delete_buffers = false,
				},
				telescope = {
					previewer = {
						enabled = true,
						previewer = "pretty",
						wrap_lines = true,
						include_empty_plugin_data = false,
						cwd_colors = {
							cwd = "Comment",
						},
					},
					list = {
						default_action = "load",
						mappings = {
							delete = { n = "<c-x>", i = "<c-x>" },
							load = { n = "<cr>", i = "<cr>" },
							save = { n = "<c-s>", i = "<c-s>" },
							rename = { n = "<c-r>", i = "<c-r>" },
						},
					},
				},
			})

			require("telescope").load_extension("possession")
			vim.keymap.set(
				"n",
				"<leader>sf",
				require("telescope").extensions.possession.list,
				{ desc = "session find" }
			)

			vim.keymap.set("n", "<leader>S", function()
				local session_name = vim.fn.input("(name) ")
				if (session_name or "") ~= "" then
					possession.save(session_name)
				end
			end, { desc = "session save" })
		end,
	},

	{
		"tpope/vim-fugitive",
		cmd = { "Git", "Gdiffsplit" },
		init = function()
			vim.g.fugitive_dynamic_colors = 0
			vim.keymap.set("n", "<leader>gb", function()
				vim.cmd.Git("blame")
			end, { desc = "Git Blame" })
			vim.keymap.set("n", "<leader>gd", vim.cmd.Gdiffsplit, { desc = "Git Diff" })

			-- other git keymapping
			vim.keymap.set("n", "<leader>g<Left>", function()
				vim.cmd.diffget("LOCAL")
			end, { desc = "Git local changes" })
			vim.keymap.set("n", "<leader>g<Right>", function()
				vim.cmd.diffget("REMOTE")
			end, { desc = "Git remote changes" })
		end,
	},

	{
		"lewis6991/gitsigns.nvim",
		dependencies = { "ghostbuster91/nvim-next" },
		opts = {
			current_line_blame = true,
			current_line_blame_opts = {
				virt_text = true,
				virt_text_pos = "eol",
				delay = 1000,
				ignore_whitespace = true,
			},
			attach_to_untracked = true,
			signs = {
				add = { text = "+" },
				change = { text = "~" },
				delete = { text = "_" },
				topdelete = { text = "‾" },
				changedelete = { text = "~" },
				untracked = { text = "┆" },
			},
			on_attach = function(bufnr)
				local gitsigns = require("gitsigns")
				local next_integrations = require("nvim-next.integrations")
				local next_gs = next_integrations.gitsigns(gitsigns)

				-- don't override the built-in and fugitive keymaps
				vim.keymap.set({ "n", "v" }, "]g", function()
					if vim.wo.diff then
						return "]g"
					end
					vim.schedule(function()
						next_gs.next_hunk()
					end)
					return "<Ignore>"
				end, { expr = true, buffer = bufnr, desc = "Jump to next hunk" })
				vim.keymap.set({ "n", "v" }, "[g", function()
					if vim.wo.diff then
						return "[g"
					end
					vim.schedule(function()
						next_gs.prev_hunk()
					end)
					return "<Ignore>"
				end, { expr = true, buffer = bufnr, desc = "Jump to previous hunk" })
				vim.keymap.set({ "n" }, "<leader>ga", gitsigns.stage_hunk)
				vim.keymap.set({ "n" }, "<leader>g<BS>", gitsigns.reset_hunk)
			end,
		},
	},

	{
		"nvim-telescope/telescope.nvim",
		branch = "0.1.x",
		dependencies = {
			"nvim-lua/plenary.nvim",
			{
				"nvim-telescope/telescope-fzf-native.nvim",
				build = "make",
				cond = function()
					return vim.fn.executable("make") == 1
				end,
			},
			"nvim-telescope/telescope-ui-select.nvim",
			"xiyaowong/telescope-emoji.nvim",
		},
		config = function()
			local telescope = require("telescope")
			local builtins = require("telescope.builtin")
			local actions = require("telescope.actions")
			local split_layout_config = { fname_width = 1000 }

			telescope.setup({
				defaults = {
					cache_picker = {
						num_pickers = 20,
						ignore_empty_prompt = true,
					},
					path_display = { "truncate" },
					sorting_strategy = "ascending",
					layout_strategy = "vertical",
					layout_config = {
						vertical = {
							prompt_position = "top",
							mirror = true,
							preview_cutoff = 30,
						},
					},
					vimgrep_arguments = {
						"rg",
						"--color=never",
						"--no-heading",
						"--with-filename",
						"--line-number",
						"--column",
						"--smart-case",
						"--hidden",
						"--glob=!**/.git/**/*",
					},
					mappings = {
						i = {
							["<esc>"] = actions.close,
							["<C-u>"] = false,
							["<C-q>"] = actions.send_selected_to_qflist + actions.open_qflist,
							["<C-x>"] = actions.delete_buffer,
							["<C-f>"] = actions.to_fuzzy_refine,
						},
					},
				},
				pickers = {
					buffers = {
						ignore_current_buffer = true,
						sort_mru = true,
					},
					find_files = {
						find_command = { "rg", "--files", "-uu", "--glob=!**/.git/**/*" },
					},
					live_grep = split_layout_config,
					lsp_definitions = split_layout_config,
					lsp_document_symbols = split_layout_config,
					lsp_dynamic_workspace_symbols = split_layout_config,
					lsp_implementations = split_layout_config,
					lsp_incoming_calls = split_layout_config,
					lsp_outgoing_calls = split_layout_config,
					lsp_references = split_layout_config,
					lsp_type_definitions = split_layout_config,
					lsp_workspace_symbols = split_layout_config,
				},
				extensions = {
					emoji = {
						action = function(emoji)
							-- argument emoji is a table.
							-- {name="", value="", cagegory="", description=""}

							vim.fn.setreg("e", emoji.value)

							-- insert emoji when picked
							vim.api.nvim_put({ emoji.value }, "c", false, true)
						end,
					},
					["ui-select"] = {
						require("telescope.themes").get_cursor(),
					},
					aerial = {
						format_symbol = function(symbol_path, filetype)
							if filetype == "json" or filetype == "yaml" then
								return table.concat(symbol_path, ".")
							else
								return symbol_path[#symbol_path]
							end
						end,
					},
				},
			})

			pcall(telescope.load_extension, "fzf")
			pcall(telescope.load_extension, "emoji")
			pcall(telescope.load_extension, "ui-select")

			local project_files = function()
				local is_inside_work_tree = {}

				local opts = { show_untracked = true }

				local cwd = vim.fn.getcwd()
				if is_inside_work_tree[cwd] == nil then
					vim.fn.system("git rev-parse --is-inside-work-tree")
					is_inside_work_tree[cwd] = vim.v.shell_error == 0
				end

				if is_inside_work_tree[cwd] then
					builtins.git_files(opts)
				else
					builtins.find_files(opts)
				end
			end

			local grep_prompt = function(additional_args)
				builtins.grep_string({
					search = vim.fn.input("(grep) "),
					additional_args = function()
						return { additional_args }
					end,
				})
			end

			vim.keymap.set("n", "<leader>/", builtins.live_grep, { desc = "Live grep" })
			vim.keymap.set("n", "<leader>?", builtins.grep_string, { desc = "Grep cword" })
			vim.keymap.set("n", "<leader><leader>", builtins.pickers, { desc = "Recent pickers" })
			vim.keymap.set("n", "<leader>.", grep_prompt, { desc = "Grep in files" })
			vim.keymap.set("n", "<leader>>", function()
				grep_prompt("-uu")
			end, { desc = "Grep in all files" })
			vim.keymap.set("n", "<leader>f", project_files, { desc = "Find files" })
			vim.keymap.set("n", "<leader>F", builtins.find_files, { desc = "Find all Files" })
			vim.keymap.set("n", "<leader>b", builtins.buffers, { desc = "Find buffers" })
			vim.keymap.set("n", "<leader>B", builtins.oldfiles, { desc = "Find buffers" })
			vim.keymap.set("n", "<leader><cr>", function()
				vim.cmd.Telescope("emoji")
			end, { desc = "Pick Emoji" })
			vim.keymap.set("n", "<leader>d", function()
				builtins.diagnostics({ bufnr = 0 })
			end, { desc = "Diagnostics" })
			vim.keymap.set("n", "<leader>D", builtins.diagnostics, { desc = "Diagnostics" })
			vim.keymap.set("n", "<leader>h", builtins.help_tags, { desc = "Help topics" })
			vim.keymap.set("n", "<leader>H", builtins.highlights, { desc = "highlights" })
		end,
	},

	{ "folke/which-key.nvim", opts = {} },

	-- {
	-- 	"pmizio/typescript-tools.nvim",
	-- 	dependencies = { "nvim-lua/plenary.nvim", "neovim/nvim-lspconfig" },
	-- 	opts = {
	-- 		settings = {
	-- 			expose_as_code_action = { "remove_unused_imports", "add_missing_imports" },
	-- 			complete_function_calls = true,
	-- 		},
	-- 		on_attach = function(client)
	-- 			vim.keymap.set(
	-- 				"n",
	-- 				"gD",
	-- 				vim.cmd.TSToolsGoToSourceDefinition,
	-- 				{ desc = "TypeScript: Source Definition" }
	-- 			)
	-- 			client.server_capabilities.semanticTokensProvider = nil
	-- 		end,
	-- 	},
	-- },

	{
		"mpas/marp-nvim",
		opts = {},
		cmd = { "MarpStart", "MarpToggle" },
	},

	{
		"vigoux/ltex-ls.nvim",
		ft = { "latex", "tex", "bib", "markdown", "gitcommit", "text" },
		config = function(self, opts)
			local capabilities = vim.lsp.protocol.make_client_capabilities()
			capabilities = require("cmp_nvim_lsp").default_capabilities(capabilities)

			require("ltex-ls").setup({
				on_attach = on_attach,
				capabilities = capabilities,
				use_spellfile = false,
				filetypes = { "latex", "tex", "bib", "markdown", "gitcommit", "text" },
				settings = {
					ltex = {
						enabled = { "latex", "tex", "bib", "markdown" },
						language = "en-US",
						checkFrequency = "save",
						sentenceCacheSize = 2000,
						dictionary = (function()
							-- For dictionary, search for files in the runtime to have
							-- and include them as externals the format for them is
							-- dict/{LANG}.txt
							--
							-- Also add dict/default.txt to all of them
							local files = {}
							for _, file in ipairs(vim.api.nvim_get_runtime_file("dict/*", true)) do
								local lang = vim.fn.fnamemodify(file, ":t:r")
								local fullpath = vim.fs.normalize(file, ":p")
								files[lang] = { ":" .. fullpath }
							end

							if files.default then
								for lang, _ in pairs(files) do
									if lang ~= "default" then
										vim.list_extend(files[lang], files.default)
									end
								end
								files.default = nil
							end
							return files
						end)(),
					},
				},
			})
		end,
	},

	{
		"neovim/nvim-lspconfig",
		dependencies = {

			{ "williamboman/mason.nvim", config = true },
			"williamboman/mason-lspconfig.nvim",

			"lukas-reineke/lsp-format.nvim",

			{
				"creativenull/efmls-configs-nvim",
				version = "v1.x.x", -- version is optional, but recommended
			},
		},

		config = function()
			local stylua = require("efmls-configs.formatters.stylua")
			local terraform_fmt = require("efmls-configs.formatters.terraform_fmt")
			-- not working right now
			-- local prettier = require("efmls-configs.formatters.prettier_d")
			local prettier = require("efmls-configs.formatters.prettier")

			vim.lsp.handlers["textDocument/hover"] = vim.lsp.with(vim.lsp.handlers.hover, {
				border = "rounded",
			})
			vim.lsp.handlers["textDocument/signatureHelp"] = vim.lsp.with(vim.lsp.handlers.signature_help, {
				border = "rounded",
			})

			require("lsp-format").setup({})

			local servers = {
				bashls = {},
				cssls = {},
				html = {},
				marksman = {},
				ltex = {},
				prismals = {},
				rust_analyzer = {},
				svelte = {},
				tsp_server = {},
				terraformls = {},
				tailwindcss = {
					filetypes = { "svelte" },
				},
				jsonls = {
					settings = {
						json = {
							schemas = {
								{
									fileMatch = { "package.json" },
									url = "https://json.schemastore.org/package.json",
								},
								{
									fileMatch = { ".prettierrc", ".prettierrc.json", "prettier.config.json" },
									url = "https://json.schemastore.org/prettierrc.json",
								},
								{
									fileMatch = { ".swcrc", ".swcrc.json", "swc.config.json" },
									url = "https://swc.rs/schema.json",
								},
								{
									fileMatch = { "tsconfig.json", "tsconfig.*.json", "*.tsconfig.json" },
									url = "http://json.schemastore.org/tsconfig",
								},
							},
						},
					},
				},
				ts_ls = {
					settings = {
						completions = {
							completeFunctionCalls = true,
						},
					},
					init_options = {
						hostInfo = "neovim",
						preferences = {
							includeCompletionsWithSnippetText = true,
							includeCompletionsForImportStatements = true,
						},
					},
				},
				vtsls = {
					autostart = false,
					settings = {
						complete_function_calls = true,
						vtsls = {
							enableMoveToFileCodeAction = true,
							autoUseWorkspaceTsdk = true,
							experimental = {
								completion = {
									enableServerSideFuzzyMatch = true,
								},
							},
						},
						typescript = {
							updateImportsOnFileMove = { enabled = "always" },
							suggest = { completeFunctionCalls = true },
							tsserver = {
								maxTsServerMemory = 8192,
							},
						},
					},
					on_attach = function(client, bufnr)
						-- not working; open in picker
						vim.keymap.set("n", "gD", function()
							local params = vim.lsp.util.make_position_params()
							vim.lsp.buf_request(0, "workspace/executeCommand", {
								command = "typescript.goToSourceDefinition",
								arguments = { params.textDocument.uri, params.position },
							}, function() end)
						end, { desc = "TypeScript: Source Definition" })

						on_attach(client, bufnr)
					end,
				},
				lua_ls = {
					settings = {
						Lua = {
							telemetry = { enable = false },
							workspace = {
								checkThirdParty = false,
								library = vim.api.nvim_get_runtime_file("", true),
							},
							diagnostics = {
								globals = { "vim" },
							},
						},
					},
				},
				efm = {
					on_attach = require("lsp-format").on_attach,
					init_options = { documentFormatting = true },
					settings = {
						languages = {
							javascript = { prettier },
							json = { prettier },
							jsonc = { prettier },
							typescript = { prettier },
							svelte = { prettier },
							sql = { prettier },
							markdown = { prettier },
							typespec = { prettier },
							lua = { stylua },
							terraform = { terraform_fmt },
						},
					},
				},
				eslint = {
					on_attach = function(client, bufnr)
						vim.api.nvim_create_autocmd("BufWritePre", {
							buffer = bufnr,
							command = "EslintFixAll",
						})
						on_attach(client, bufnr)
					end,
					settings = {
						workingDirectories = { mode = "auto" },
						codeActionOnSave = { enable = true },
					},
				},
			}

			local capabilities = vim.lsp.protocol.make_client_capabilities()
			capabilities = require("cmp_nvim_lsp").default_capabilities(capabilities)

			local mason_lspconfig = require("mason-lspconfig")

			mason_lspconfig.setup({
				automatic_installation = true,
				ensure_installed = vim.tbl_keys(servers),
			})

			mason_lspconfig.setup_handlers({
				function(server_name)
					require("lspconfig")[server_name].setup(vim.tbl_extend("keep", servers[server_name], {
						capabilities = capabilities,
						on_init = function(client)
							-- treesitter does our highlighting, thanks
							client.server_capabilities.semanticTokensProvider = nil
						end,
						on_attach = on_attach,
					}))
				end,
			})
		end,
	},

	{
		"folke/lazydev.nvim",
		dependencies = {
			{ "gonstoll/wezterm-types", lazy = true },
			{ "Bilal2453/luvit-meta", lazy = true }, -- optional `vim.uv` typings
		},
		ft = "lua", -- only load on lua files
		opts = {
			library = {
				-- See the configuration section for more details
				-- Load luvit types when the `vim.uv` word is found
				{ path = "luvit-meta/library", words = { "vim%.uv" } },
				{ path = "wezterm-types", mods = { "wezterm" } },
			},
		},
	},

	{
		"hrsh7th/nvim-cmp",
		event = "InsertEnter",
		dependencies = {
			-- Snippet Engine & its associated nvim-cmp source
			{
				"L3MON4D3/LuaSnip",
				-- follow latest release.
				version = "v2.*", -- Replace <CurrentMajor> by the latest released major (first number of latest release)
				-- install jsregexp (optional!).
				build = "make install_jsregexp",
			},
			"saadparwaiz1/cmp_luasnip",

			"rafamadriz/friendly-snippets",

			"hrsh7th/cmp-nvim-lsp",
			"hrsh7th/cmp-buffer",
			"hrsh7th/cmp-path",
		},
		config = function()
			local cmp = require("cmp")
			local luasnip = require("luasnip")

			require("luasnip.loaders.from_vscode").lazy_load()
			luasnip.config.setup({})

			---@diagnostic disable-next-line: missing-fields
			cmp.setup({
				---@diagnostic disable-next-line: missing-fields
				completion = {
					keyword_length = 1,
				},
				preselect = cmp.PreselectMode.None,
				snippet = {
					expand = function(args)
						luasnip.lsp_expand(args.body)
					end,
				},
				mapping = cmp.mapping.preset.insert({
					["<C-u>"] = cmp.mapping.scroll_docs(-4),
					["<C-d>"] = cmp.mapping.scroll_docs(4),
					["<CR>"] = cmp.mapping.confirm({
						behavior = cmp.ConfirmBehavior.Replace,
						select = false,
					}),
					["<Tab>"] = cmp.mapping(function(fallback)
						if cmp.visible() then
							cmp.select_next_item()
						elseif luasnip.expand_or_locally_jumpable() then
							luasnip.expand_or_jump()
						else
							fallback()
						end
					end, { "i", "s" }),
					["<S-Tab>"] = cmp.mapping(function(fallback)
						if cmp.visible() then
							cmp.select_prev_item()
						elseif luasnip.locally_jumpable(-1) then
							luasnip.jump(-1)
						else
							fallback()
						end
					end, { "i", "s" }),
				}),
				sources = {
					{ name = "nvim_lsp" },
					{ name = "luasnip" },
					{ name = "path" },
					{
						name = "buffer",
						option = {
							get_bufnrs = function()
								return vim.api.nvim_list_bufs()
							end,
						},
					},
					{ name = "vim-dadbod-completion" },
					{ name = "lazydev" },
				},
			})

			vim.keymap.set("i", "<C-x>", cmp.complete, {})
		end,
	},

	{
		"vargasd/fansi.nvim",
		priority = 1000,
		config = function()
			require("fansi").setup({
				transparent_mode = true,
			})

			vim.cmd.colorscheme("fansi")
		end,
	},

	{
		"folke/noice.nvim",
		event = "VeryLazy",
		opts = {
			popupmenu = {
				enabled = false,
			},
			lsp = {
				hover = {
					enabled = false,
				},
				signature = {
					enabled = false,
				},
			},
		},
		keys = {
			{
				"<leader>m",
				function()
					vim.cmd.Telescope("noice")
				end,
				desc = "Search Messages",
			},
		},
	},

	{
		"hedyhli/outline.nvim",
		cmd = { "Outline", "OutlineOpen" },
		keys = {
			{ "<leader>O", vim.cmd.Outline, desc = "Toggle outline" },
		},
		opts = {
			outline_window = {
				position = "left",
				auto_close = true,
			},
		},
	},

	{
		"stevearc/aerial.nvim",
		opts = {},
		keys = {
			{
				"<leader>o",
				function()
					vim.cmd.Telescope("aerial")
				end,
				desc = "Outline finder",
			},
		},
		dependencies = {
			"nvim-treesitter/nvim-treesitter",
			"nvim-tree/nvim-web-devicons",
			"nvim-telescope/telescope.nvim",
		},
		init = function()
			require("telescope").load_extension("aerial")
		end,
	},

	-- { "echasnovski/mini.statusline", version = "*", opts = {} },
	{
		"nvim-lualine/lualine.nvim",
		config = function()
			local base_config = {
				lualine_b = {
					{
						"diff",
						diff_color = {
							added = "Added",
							modified = "Changed",
							removed = "Removed",
						},
					},
					{
						"diagnostics",
						diagnostics_color = {
							error = "DiagnosticError",
							warn = "DiagnosticWarn",
							info = "DiagnosticInfo",
							hint = "DiagnosticHint",
						},
					},
				},
				lualine_x = { "encoding", "fileformat", "filetype", "location" },
				lualine_y = { "branch" },
			}
			local winbar = vim.tbl_extend("keep", base_config, {
				lualine_a = {
					{
						"filename",
						file_status = true,
						path = 1,
					},
				},
				lualine_z = { "mode" },
			})
			local sections = vim.tbl_extend("keep", base_config, {
				lualine_a = { "mode" },
			})

			require("lualine").setup({
				options = {
					component_separators = "|",
					section_separators = "",

					theme = {
						normal = {
							a = { bg = 7, fg = 0 },
							b = { bg = "NONE", fg = 7 },
							c = { bg = "NONE", fg = 7 },
						},
						insert = {
							a = { bg = "Blue", fg = 0 },
						},
						visual = {
							a = { bg = "Yellow", fg = 0 },
						},
						replace = {
							a = { bg = "Red", fg = 0 },
						},
						command = {
							a = { bg = "Green", fg = 0 },
						},
						inactive = {
							a = { bg = 8, fg = 0 },
						},
					},
				},
				-- sections = sections,
				-- inactive_sections = sections,
				sections = {},
				inactive_sections = {},
				winbar = winbar,
				inactive_winbar = winbar,
			})
		end,
	},

	{
		"lukas-reineke/indent-blankline.nvim",
		main = "ibl",
		opts = {
			indent = { char = "·" },
			scope = { enabled = false },
			whitespace = { remove_blankline_trail = true },
		},
	},

	-- 'gc' to comment
	{
		"numToStr/Comment.nvim",
		config = function()
			local ft = require("Comment.ft")
			ft.typespec = { "//%s", "/* %s */" }

			require("Comment").setup()
		end,
	},

	{
		"nvim-treesitter/nvim-treesitter",
		dependencies = {
			"nvim-treesitter/nvim-treesitter-textobjects",
			"ghostbuster91/nvim-next",
		},
		build = ":TSUpdate",
		config = function()
			require("nvim-next.integrations").treesitter_textobjects()
			require("nvim-treesitter.configs").setup({
				modules = {},
				sync_install = false,
				ignore_install = {},
				ensure_installed = {
					-- general
					"comment",
					"regex",

					-- tools
					"devicetree", -- zmk
					"dockerfile",
					"graphql",
					"git_config",
					"git_rebase",
					"gitattributes",
					"gitcommit",
					"gitignore",
					"jq",
					"markdown",
					"nix",
					"prisma",
					"terraform",
					"vim",
					"vimdoc",

					-- config
					"json",
					"jsonc",
					"toml",
					"yaml",

					"bash",
					"css",
					"glimmer", -- handlebars
					"html",
					"lua",
					"javascript",
					"jsdoc",
					"rust",
					"sql",
					"svelte",
					"tsx",
					"typespec",
					"typescript",
				},
				auto_install = false,
				highlight = {
					enable = true,
					additional_vim_regex_highlighting = { "sql", "markdown" },
					-- disable = csv_fts,
					disable = function(lang, buf)
						local max_filesize = 500 * 1024 -- 500 KB
						local ok, stats = pcall(vim.uv.fs_stat, vim.api.nvim_buf_get_name(buf))
						if ok and stats and stats.size > max_filesize then
							return true
						end
					end,
				},
				indent = { enable = true },
				playground = { enable = true },
				textobjects = {
					select = {
						enable = true,
						lookahead = true,
						keymaps = {
							["aa"] = "@parameter.outer",
							["ia"] = "@parameter.inner",
							["af"] = "@function.outer",
							["if"] = "@function.inner",
							["ac"] = "@comment.outer",
							["ic"] = "@comment.inner",
						},
					},
				},
				nvim_next = {
					enable = true,
					textobjects = {
						move = {
							set_jumps = true,
							goto_next_start = {
								["]f"] = "@function.outer",
								["]a"] = "@parameter.outer",
								["]]"] = "@block.inner",
								["]c"] = "@comment.inner",
								["]v"] = "@assignment.lhs",
							},
							goto_previous_start = {
								["[f"] = "@function.outer",
								["[a"] = "@parameter.outer",
								["[["] = "@block.inner",
								["[c"] = "@comment.inner",
								["[v"] = "@assignment.lhs",
							},
						},
					},
				},
			})
		end,
	},

	{
		"kevinhwang91/nvim-ufo",
		dependencies = { "kevinhwang91/promise-async" },
		config = function()
			local ufo = require("ufo")
			ufo.setup({
				provider_selector = function(bufnr, filetype, buftype)
					return { "treesitter", "indent" }
				end,
			})

			vim.o.foldenable = true
			vim.o.foldlevel = 99
			vim.o.foldlevelstart = 99
			vim.keymap.set("n", "zR", ufo.openAllFolds)
			vim.keymap.set("n", "zM", ufo.closeAllFolds)
			vim.keymap.set("n", "zr", ufo.openFoldsExceptKinds)
			vim.keymap.set("n", "zm", ufo.closeFoldsWith)
		end,
	},

	{
		"ghostbuster91/nvim-next",
		config = function()
			local builtins = require("nvim-next.builtins")
			local move = require("nvim-next.move")
			local next_integrations = require("nvim-next.integrations")
			local diagnostics = next_integrations.diagnostic()
			next_integrations.quickfix().setup()

			require("nvim-next").setup({
				items = {
					builtins.f,
					builtins.t,
				},
			})

			vim.keymap.set({ "n", "x", "o" }, ",", move.repeat_last_move)
			vim.keymap.set({ "n", "x", "o" }, ";", move.repeat_last_move_opposite)
			vim.keymap.set(
				"n",
				"[d",
				diagnostics.goto_prev({ severity = { min = vim.diagnostic.severity.WARN } }),
				{ desc = "Previous diagnostic" }
			)
			vim.keymap.set(
				"n",
				"]d",
				diagnostics.goto_next({ severity = { min = vim.diagnostic.severity.WARN } }),
				{ desc = "Next diagnostic" }
			)
		end,
	},

	--#region non-treesitter highlighting
	{
		"cameron-wags/rainbow_csv.nvim",
		ft = csv_fts,
		priority = 100,
		cmd = {
			"RainbowDelim",
			"RainbowDelimSimple",
			"RainbowDelimQuoted",
			"RainbowMultiDelim",
		},
		config = function()
			require("rainbow_csv").setup()

			-- vim.api.nvim_create_autocmd("BufEnter", {
			-- 	pattern = "*.csv",
			-- 	callback = function()
			-- 		vim.keymap.set("n", "<leader>r", vim.cmd.RainbowAlign, {})
			-- 		vim.keymap.set("n", "<leader>R", vim.cmd.RainbowShrink, {})
			-- 	end,
			-- })
		end,
	},

	{
		"kylechui/nvim-surround",
		version = "*", -- Use for stability; omit to use `main` branch for the latest features
		config = function()
			require("nvim-surround").setup({
				-- Configuration here, or leave empty to use defaults
			})
		end,
	},

	{
		"windwp/nvim-autopairs",
		event = "InsertEnter",
		-- Optional dependency
		dependencies = { "hrsh7th/nvim-cmp" },
		config = function()
			require("nvim-autopairs").setup({
				break_undo = false,
			})
			local cmp_autopairs = require("nvim-autopairs.completion.cmp")
			local cmp = require("cmp")
			cmp.event:on("confirm_done", cmp_autopairs.on_confirm_done())
		end,
	},

	{
		"norcalli/nvim-colorizer.lua",
		ft = "css",
		cmd = { "ColorizerToggle" },
		opts = {
			"css",
		},
	},
	--#endregion

	{
		"mg979/vim-visual-multi",
		config = function()
			vim.keymap.set("n", "<M-J>", "<Plug>(VM-Add-Cursor-Down)", {})
			vim.keymap.set("n", "<M-K>", "<Plug>(VM-Add-Cursor-Up)", {})
		end,
	},

	{
		"mbbill/undotree",
		cmd = {
			"UndotreeShow",
		},
		init = function()
			vim.g.undotree_DiffAutoOpen = 0
			vim.keymap.set("n", "<leader>u", function()
				vim.cmd.UndotreeShow()
				vim.cmd.UndotreeFocus()
			end, { desc = "Undo tree" })
		end,
	},

	{
		"voldikss/vim-floaterm",
		cmd = {
			"FloatermToggle",
			"FloatermNew",
		},
		init = function()
			vim.g.floaterm_opener = "edit"
			vim.g.floaterm_height = 0.9
			vim.g.floaterm_width = 0.9

			vim.keymap.set("n", "<leader>t", function()
				vim.cmd.FloatermToggle("main")
			end, { desc = "Terminal" })

			vim.keymap.set(
				"n",
				"<leader>T",
				":FloatermNew! --disposable cd %:p:h<CR>",
				{ silent = true, desc = "Terminal at current dir" }
			)

			for i = 0, 9 do
				vim.keymap.set("n", "<leader>" .. i, function()
					vim.cmd.FloatermToggle("terminal " .. i)
				end, { desc = "Terminal " .. i })
			end

			vim.keymap.set("n", "<leader>G", function()
				vim.cmd.FloatermNew("lazygit")
			end, { desc = "lazygit" })

			vim.api.nvim_create_autocmd("TermOpen", {
				callback = function(args)
					vim.keymap.set({ "n", "t" }, "<C-q>", vim.cmd.FloatermToggle, { buffer = args.buf })
					vim.keymap.set("t", "<C-z>", "<C-\\><C-n>", { buffer = args.buf })
				end,
			})
		end,
	},

	---@type LazySpec
	{
		"mikavilpas/yazi.nvim",
		dependencies = {
			"nvim-lua/plenary.nvim",
		},
		event = "VeryLazy",
		keys = {
			{
				"<leader>e",
				function()
					require("yazi").yazi()
				end,
				{ desc = "Open the file manager at buffer" },
			},
			{
				"<leader>E",
				function()
					require("yazi").yazi(nil, vim.fn.getcwd())
				end,
				{ desc = "Open the file manager at cwd" },
			},
		},
		opts = {
			open_for_directories = true,
		},
	},

	{
		"renerocksai/telekasten.nvim",
		dependencies = { "nvim-telescope/telescope.nvim" },
		cmd = "Telekasten",
		init = function()
			vim.keymap.set("n", "<leader>Z", "<cmd>Telekasten panel<CR>")

			vim.keymap.set("n", "<leader>zf", "<cmd>Telekasten find_notes<CR>")
			vim.keymap.set("n", "<leader>z/", "<cmd>Telekasten search_notes<CR>")
			vim.keymap.set("n", "<leader>zc", "<cmd>Telekasten goto_today<CR>")
			vim.keymap.set("n", "<leader>zz", "<cmd>Telekasten follow_link<CR>")
			vim.keymap.set("n", "<leader>zn", "<cmd>Telekasten new_note<CR>")
		end,
		config = function()
			local home = vim.fn.stdpath("data") .. "/../zettelkasten/"
			require("telekasten").setup({
				home = home,
				template_handling = "new_note",
				template_new_note = home .. "/templates/new_note.md",
				template_new_daily = home .. "/templates/new_note.md",
				auto_set_filetype = false,
			})
		end,
	},
}, { rocks = { enabled = false } })

-- Diagnostics
local signs = { Error = "●", Warn = "●", Hint = "●", Info = "●" }
for type, icon in pairs(signs) do
	local hl = "DiagnosticSign" .. type
	vim.fn.sign_define(hl, { text = icon, texthl = hl, numhl = hl })
end

vim.keymap.set("n", "H", vim.diagnostic.open_float, { desc = "Open Diagnostics Float" })

vim.diagnostic.config({
	virtual_text = {
		severity = {
			min = vim.diagnostic.severity.WARN,
		},
	},
	float = {
		source = true,
		header = "",
		prefix = "",
		border = "rounded",
	},
	update_in_insert = false,
	severity_sort = true,
})

-- fat finger commands
vim.api.nvim_create_user_command("E", "edit", {})
vim.api.nvim_create_user_command("W", "write", {})
vim.api.nvim_create_user_command("Q", "quit", {})
vim.api.nvim_create_user_command("Wq", "wq", {})
vim.api.nvim_create_user_command("WQ", "wq", {})

-- no space ops since it's the leader
vim.keymap.set({ "n", "v" }, "<Space>", "<Nop>", { silent = true })

-- display linewise movement
vim.keymap.set("n", "k", "v:count == 0 ? 'gk' : 'k'", { expr = true, silent = true })
vim.keymap.set("n", "j", "v:count == 0 ? 'gj' : 'j'", { expr = true, silent = true })
vim.keymap.set("n", "<Up>", "v:count == 0 ? 'gk' : 'k'", { expr = true, silent = true })
vim.keymap.set("n", "<Down>", "v:count == 0 ? 'gj' : 'j'", { expr = true, silent = true })

vim.keymap.set("n", "<esc>", "<cmd>nohlsearch<CR>")

-- reduce pinky stress
vim.keymap.set("n", "<leader>q", vim.cmd.bdelete, { desc = "Quit buffer" })
vim.keymap.set("n", "<leader>Q", function()
	vim.cmd.bdelete({ bang = true })
end, { desc = "Quit all" })
vim.keymap.set("n", "<leader><c-q>", vim.cmd.qall, { desc = "Quit all" })
vim.keymap.set("n", "q", "<Nop>", { silent = true }) -- q gets way too annoying if accidentally pressed
vim.keymap.set("n", "Q", "q", {})
vim.keymap.set("n", "<leader>w", vim.cmd.write, { desc = "Write" })
vim.keymap.set("n", "<leader>W", vim.cmd.wall, { desc = "Write" })

-- clipboard
vim.keymap.set("n", "<leader>YA", ':let @+=expand("%:p")<CR>', { silent = true, desc = "Yank Absolute path" })
vim.keymap.set("n", "<leader>YF", ':let @+=expand("%:t")<CR>', { silent = true, desc = "Yank File name" })
vim.keymap.set("n", "<leader>YR", ':let @+=expand("%")<CR>', { silent = true, desc = "Yank Relative path" })
vim.keymap.set({ "n", "v" }, "<leader>y", '"*y', { desc = "Yank to system clipboard" })
vim.keymap.set({ "n", "v" }, "<leader>p", '"*p', { desc = "Paste from system clipboard" })
vim.keymap.set({ "n", "v" }, "<leader>P", '"*P', { desc = "Paste from system clipboard" })

local highlight_group = vim.api.nvim_create_augroup("YankHighlight", { clear = true })
vim.api.nvim_create_autocmd("TextYankPost", {
	callback = function()
		vim.highlight.on_yank()
	end,
	group = highlight_group,
	pattern = "*",
})

-- quickfix
local toggle_qf = function()
	local qf_exists = false
	for _, win in pairs(vim.fn.getwininfo()) do
		if win["quickfix"] == 1 then
			qf_exists = true
		end
	end
	if qf_exists == true then
		vim.cmd("cclose")
		return
	end
	if not vim.tbl_isempty(vim.fn.getqflist()) then
		vim.cmd("copen")
	end
end

vim.keymap.set("n", "<C-w>t", "<C-w>T", { desc = "Send to tab" })
vim.keymap.set("n", "[t", vim.cmd.tabprevious, { desc = "Previous tab" })
vim.keymap.set("n", "]t", vim.cmd.tabnext, { desc = "Next tab" })

vim.keymap.set("n", "gi", function()
	local issue = vim.fn.expand("<cword>")
	os.execute("open https://linear.app/tildei/issue/" .. issue)
end, { desc = "Open issue under cursor" })

vim.keymap.set("n", "<C-q>", toggle_qf, { desc = "Close quickfix" })

-- helix-inspired
vim.keymap.set("n", "U", "<C-r>")
vim.keymap.set({ "n", "v", "o" }, "gh", "^")
vim.keymap.set({ "n", "v", "o" }, "gl", "$")
-- center bottom
vim.keymap.set("n", "G", "Gzz", { noremap = true })

-- insert/command mode emacs bindings
vim.keymap.set({ "i", "c" }, "<C-a>", "<Home>")
vim.keymap.set({ "i", "c" }, "<C-b>", "<Left>")
vim.keymap.set({ "i", "c" }, "<C-d>", "<Del>")
vim.keymap.set({ "i", "c" }, "<C-e>", "<End>")
vim.keymap.set({ "i", "c" }, "<C-f>", "<Right>")
vim.keymap.set({ "i", "c" }, "<C-n>", "<Down>")
vim.keymap.set({ "i", "c" }, "<C-p>", "<Up>")
vim.keymap.set({ "i", "c" }, "<M-b>", "<S-Left>")
vim.keymap.set({ "i", "c" }, "<M-f>", "<S-Right>")

-- Use lowercase for global marks and uppercase for local marks.
local lower = function(i)
	return string.char(97 + i)
end
local upper = function(i)
	return string.char(65 + i)
end

for i = 0, 25 do
	vim.keymap.set("n", "m" .. lower(i), "m" .. upper(i))
	vim.keymap.set("n", "'" .. lower(i), "'" .. upper(i))
	vim.keymap.set("n", "`" .. lower(i), "`" .. upper(i))
	-- vim.keymap.set("n", "m" .. upper(i), "m" .. lower(i))
	-- vim.keymap.set("n", "'" .. upper(i), "'" .. lower(i))
	-- vim.keymap.set("n", "`" .. upper(i), "`" .. lower(i))
end

vim.o.undodir = vim.fn.stdpath("state") .. "/undo//"
vim.o.undofile = true

vim.o.termguicolors = false
vim.o.mouse = "nvi"
vim.o.mousemodel = "extend"

vim.o.swapfile = false
vim.o.updatetime = 10
vim.o.timeoutlen = 300

vim.o.completeopt = "menuone,noselect"

vim.o.shiftwidth = 2
vim.o.tabstop = 2
vim.o.autoindent = true
vim.o.smartindent = true

vim.wo.signcolumn = "yes"
vim.o.relativenumber = true
vim.o.number = true

vim.opt.listchars = {
	tab = "· ",
	trail = "-",
}
vim.o.list = true
vim.opt.iskeyword:append("-")
vim.opt.iskeyword:append("#")

vim.o.ignorecase = true
vim.o.smartcase = true

vim.o.ruler = false

vim.opt.fillchars.stl = " "
vim.opt.fillchars.stlnc = " "

-- --#region kitty/wezterm
vim.o.laststatus = 0
-- --#endregion kitty
--#region alacritty/ghostty/tmux
-- set title dynamimcally by buffer
-- local overridetitle = ""
-- -- vim.o.laststatus = 3
-- vim.opt.title = true
-- vim.opt.titlelen = 0
-- vim.api.nvim_create_autocmd("BufEnter", {
-- 	callback = function(args)
-- 		local buftype = vim.api.nvim_get_option_value("buftype", { buf = args.buf })
-- 		if overridetitle == "" and buftype == "" then
-- 			vim.o.titlestring = vim.fn.expand("%:p:h:t")
-- 				.. "/"
-- 				.. vim.fn.expand("%:t")
-- 				.. " ("
-- 				.. vim.fn.expand("%:~:.:h:h")
-- 				.. ")"
-- 			-- else
-- 			-- 	vim.o.titlestring = buftype
-- 		end
-- 	end,
-- })

vim.api.nvim_create_user_command("SetTitle", function(opts)
	overridetitle = opts.fargs[1]
	vim.o.titlestring = overridetitle
end, { nargs = 1 })
--#endregion

vim.filetype.add({
	extension = {
		jsonl = "json",
		mustache = "handlebars",
		keymap = "dts",
		overlay = "dts",
	},
	pattern = {
		[".env.*"] = "sh",
	},
})
