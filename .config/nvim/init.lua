vim.g.mapleader = " "
vim.g.maplocalleader = " "

-- Install package manager
--    https://github.com/folke/lazy.nvim
--    `:help lazy.nvim.txt` for more info
local lazypath = vim.fn.stdpath("data") .. "/lazy/lazy.nvim"
if not vim.loop.fs_stat(lazypath) then
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

require("lazy").setup({
	"tpope/vim-sleuth",
	"nvim-tree/nvim-web-devicons",

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

			vim.api.nvim_set_hl(0, "NotificationInfo", { link = "DiagnosticFloatingInfo" })
			vim.api.nvim_set_hl(0, "NotificationWarning", { link = "DiagnosticFloatingWarn" })
			vim.api.nvim_set_hl(0, "NotificationError", { link = "DiagnosticFloatingError" })
		end,
	},

	{
		"olimorris/persisted.nvim",
		opts = {
			use_git_branch = true,
			autoload = true,
			allowed_dirs = { "~/work", "~/playground" },
			ignored_dirs = { "dadbod" },
		},
	},

	{
		"tpope/vim-fugitive",
		config = function()
			vim.keymap.set("n", "<leader>gb", function()
				vim.cmd.Git("blame")
			end, { desc = "Git Blame" })
			vim.keymap.set("n", "<leader>gd", vim.cmd.Gdiffsplit, { desc = "Git Diff" })

			-- other git keymapping
			vim.keymap.set("n", "<leader>gh", function()
				vim.cmd.diffget("LOCAL")
			end, { desc = "Git local changes" })
			vim.keymap.set("n", "<leader>gl", function()
				vim.cmd.diffget("REMOTE")
			end, { desc = "Git remote changes" })
		end,
	},

	{
		"lewis6991/gitsigns.nvim",
		opts = {
			current_line_blame = true,
			current_line_blame_opts = {
				virt_text = true,
				virt_text_pos = "eol",
				delay = 1000,
				ignore_whitespace = true,
			},
			signs = {
				add = { text = "+" },
				change = { text = "~" },
				delete = { text = "_" },
				topdelete = { text = "‾" },
				changedelete = { text = "~" },
			},
			on_attach = function(bufnr)
				-- don't override the built-in and fugitive keymaps
				local gs = package.loaded.gitsigns
				vim.keymap.set({ "n", "v" }, "]c", function()
					if vim.wo.diff then
						return "]c"
					end
					vim.schedule(function()
						gs.next_hunk()
					end)
					return "<Ignore>"
				end, { expr = true, buffer = bufnr, desc = "Jump to next hunk" })
				vim.keymap.set({ "n", "v" }, "[c", function()
					if vim.wo.diff then
						return "[c"
					end
					vim.schedule(function()
						gs.prev_hunk()
					end)
					return "<Ignore>"
				end, { expr = true, buffer = bufnr, desc = "Jump to previous hunk" })
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
		},
		config = function()
			local telescope = require("telescope")
			local builtins = require("telescope.builtin")
			local actions = require("telescope.actions")

			telescope.setup({
				defaults = {
					sorting_strategy = "ascending",
					layout_strategy = "vertical",
					layout_config = {
						vertical = {
							prompt_position = "top",
							mirror = true,
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
						find_command = { "rg", "--files", "-uu", "--glob", "!**/.git/*" },
					},
				},
			})

			pcall(telescope.load_extension, "fzf")

			telescope.load_extension("ui-select")
			local grep_prompt = function(additional_args)
				builtins.grep_string({
					search = vim.fn.input("grep> "),
					additional_args = function()
						return { additional_args }
					end,
				})
			end
			vim.keymap.set("n", "<leader>/", builtins.live_grep, { desc = "Live grep" })
			vim.keymap.set("n", "<leader>?", builtins.grep_string, { desc = "Grep cword" })
			vim.keymap.set("n", "<leader> ", builtins.resume, { desc = "Resume last picker" })
			vim.keymap.set("n", "<leader>.", grep_prompt, { desc = "Grep in files" })
			vim.keymap.set("n", "<leader>>", function()
				grep_prompt("-uu")
			end, { desc = "Grep in all files" })
			vim.keymap.set("n", "<leader>f", function()
				builtins.git_files({ show_untracked = true })
			end, { desc = "Find files" })
			vim.keymap.set("n", "<leader>F", builtins.find_files, { desc = "Find all Files" })
			vim.keymap.set("n", "<leader>b", builtins.buffers, { desc = "Find buffers" })
			vim.keymap.set("n", "<leader>s", builtins.lsp_document_symbols, { desc = "Find buffer symbols" })
			vim.keymap.set(
				"n",
				"<leader>S",
				builtins.lsp_dynamic_workspace_symbols,
				{ desc = "Find workspace symbols" }
			)
			vim.keymap.set("n", "<leader>d", builtins.diagnostics, { desc = "Diagnostics" })
		end,
	},

	{ "folke/which-key.nvim", opts = {} },

	-- {
	-- 	"pmizio/typescript-tools.nvim",
	-- 	dependencies = { "nvim-lua/plenary.nvim", "neovim/nvim-lspconfig" },
	-- 	config = function()
	-- 		require("typescript-tools").setup({
	-- 			settings = {
	-- 				expose_as_code_action = { "remove_unused", "add_missing_imports" },
	-- 				tsserver_file_preferences = {
	-- 					includeCompletionsWithSnippetText = true,
	-- 					includeCompletionsForImportStatements = true,
	-- 				},
	-- 				complete_function_calls = true,
	-- 			},
	-- 		})
	--
	-- 		vim.keymap.set("n", "gD", vim.cmd.TSToolsGoToSourceDefinition, { desc = "TypeScript: Source Definition" })
	-- 	end,
	-- },

	{
		"neovim/nvim-lspconfig",
		dependencies = {

			{ "williamboman/mason.nvim", config = true },
			"williamboman/mason-lspconfig.nvim",

			{
				"j-hui/fidget.nvim",
				tag = "legacy",
				opts = {
					window = {
						blend = 0,
					},
				},
			},

			{
				"weilbith/nvim-code-action-menu",
				config = function()
					vim.g.code_action_menu_window_border = "rounded"
					vim.g.code_action_menu_show_diff = false
				end,
			},

			"folke/neodev.nvim",
		},

		config = function()
			local on_attach = function(client, bufnr)
				local nmap = function(keys, func, desc)
					if desc then
						desc = "LSP: " .. desc
					end

					vim.keymap.set("n", keys, func, { buffer = bufnr, desc = desc })
				end
				local telescope = require("telescope.builtin")

				nmap("<leader>r", vim.lsp.buf.rename, "Rename")
				vim.keymap.set(
					{ "n", "v" },
					"<leader>a",
					vim.cmd.CodeActionMenu,
					{ desc = "Code Action", buffer = bufnr }
				) -- 'weilbith/nvim-code-action-menu',

				nmap("<leader>R", vim.cmd.LspRestart, "Restart")

				nmap("gd", vim.lsp.buf.definition, "Definition")
				nmap("gr", telescope.lsp_references, "References")
				nmap("gi", vim.lsp.buf.implementation, "Implementation")
				nmap("gy", vim.lsp.buf.type_definition, "Type")

				nmap("K", vim.lsp.buf.hover, "Hover Documentation")
				vim.keymap.set({ "n", "i" }, "<C-k>", vim.lsp.buf.signature_help, { desc = "Signature Help" })

				vim.api.nvim_buf_create_user_command(bufnr, "LspFormat", function(_)
					vim.lsp.buf.format()
				end, { desc = "Format current buffer with LSP" })

				vim.api.nvim_create_autocmd("CursorHold", {
					buffer = bufnr,
					callback = function()
						local opts = {
							focus_id = "diagnostics",
							focus = false,
							close_events = { "BufLeave", "CursorMoved", "InsertEnter", "FocusLost" },
							source = "always",
							prefix = " ",
							scope = "cursor",
						}
						vim.diagnostic.open_float(nil, opts)
					end,
				})
			end

			local prettier = {
				formatCommand = 'prettierd "${INPUT}"',
				formatStdin = true,
			}
			local stylua = {
				formatCommand = "stylua -s --stdin-filepath ${INPUT} -",
				formatStdin = true,
			}
			local terraform_fmt = { formatCommand = "terraform fmt -", formatStdin = true }

			local servers = {
				bashls = {},
				cssls = {},
				html = {},
				marksman = {},
				nil_ls = {},
				prismals = {},
				rust_analyzer = {},
				svelte = {},
				terraformls = {},
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
									fileMatch = { "tsconfig.json", "tsconfig.*.json", "*.tsconfig.json" },
									url = "http://json.schemastore.org/tsconfig",
								},
							},
						},
					},
				},
				tsserver = {
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
				lua_ls = {
					settings = {
						Lua = {
							workspace = { checkThirdParty = false },
							telemetry = { enable = false },
						},
					},
				},
				tailwindcss = {
					filetypes = { "svelte" },
				},
				efm = {
					on_attach = function(client, bufnr)
						on_attach(client, bufnr)

						local filter = function(lsp_client)
							return lsp_client.name == "efm"
						end

						vim.api.nvim_create_autocmd("BufWritePre", {
							buffer = bufnr,
							callback = function()
								vim.lsp.buf.format({ bufnr = bufnr, filter = filter })
							end,
							desc = "[lsp] format on save",
						})
					end,
					init_options = { documentFormatting = true },
					settings = {
						languages = {
							javascript = { prettier },
							json = { prettier },
							jsonc = { prettier },
							typescript = { prettier },
							svelte = { prettier },
							sql = { prettier },
							prisma = { prettier },
							lua = { stylua },
							terraform = { terraform_fmt },
						},
					},
				},
				eslint = {
					on_attach = function(client, bufnr)
						on_attach(client, bufnr)
						vim.api.nvim_create_autocmd("BufWritePre", {
							buffer = bufnr,
							command = "EslintFixAll",
						})
					end,
					settings = {
						probe = {
							"javascript",
							"javascriptreact",
							"typescript",
							"typescriptreact",
							"vue",
							"svelte",
						},
						workingDirectory = {
							mode = "auto",
						},
						codeActionOnSave = {
							enable = true,
						},
						packageManager = "pnpm",
					},
				},
			}

			require("neodev").setup()

			local capabilities = vim.lsp.protocol.make_client_capabilities()
			capabilities = require("cmp_nvim_lsp").default_capabilities(capabilities)

			local mason_lspconfig = require("mason-lspconfig")

			mason_lspconfig.setup({
				ensure_installed = vim.tbl_keys(servers),
			})

			mason_lspconfig.setup_handlers({
				function(server_name)
					require("lspconfig")[server_name].setup({
						capabilities = capabilities,
						on_init = function(client)
							-- treesitter does our highlighting, thanks
							client.server_capabilities.semanticTokensProvider = nil
						end,
						on_attach = (servers[server_name] or {}).on_attach or on_attach,
						settings = (servers[server_name] or {}).settings,
						init_options = (servers[server_name] or {}).init_options,
						filetypes = (servers[server_name] or {}).filetypes,
					})
				end,
			})
		end,
	},

	{
		"hrsh7th/nvim-cmp",

		dependencies = {
			-- Snippet Engine & its associated nvim-cmp source
			"L3MON4D3/LuaSnip",
			"rafamadriz/friendly-snippets",
			"saadparwaiz1/cmp_luasnip",

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
				},
			})

			vim.keymap.set("i", "<C-x>", cmp.complete, {})
		end,
	},

	{
		"ellisonleao/gruvbox.nvim",
		priority = 1000,
		config = function()
			require("gruvbox").setup({
				contrast = "soft",
				transparent_mode = true,
			})
			local colors = require("gruvbox.palette").get_base_colors({}, "dark", "soft")

			vim.cmd.colorscheme("gruvbox")

			function FixGruvbox()
				vim.api.nvim_set_hl(0, "NormalFloat", { fg = colors.fg1, bg = colors.bg1 })
				vim.api.nvim_set_hl(0, "DiffviewDiffAddAsDelete", { bg = "#431313" })
				vim.api.nvim_set_hl(0, "DiffDelete", { bg = "none", fg = colors.bg2 })
				vim.api.nvim_set_hl(0, "DiffAdd", { bg = "#142a03" })
				vim.api.nvim_set_hl(0, "DiffChange", { bg = "#3B3307" })
				vim.api.nvim_set_hl(0, "DiffText", { bg = "#4D520D" })
			end
			FixGruvbox()

			vim.api.nvim_create_autocmd("ColorScheme", { pattern = { "gruvbox" }, callback = FixGruvbox })
		end,
	},

	-- {
	-- 	"sainnhe/gruvbox-material",
	-- 	priority = 1000,
	-- 	config = function()
	-- 		vim.g.gruvbox_material_foreground = "original"
	-- 		vim.g.gruvbox_material_transparent_background = 1
	-- 		vim.cmd.colorscheme("gruvbox-material")
	-- 	end,
	-- },

	{
		"nvim-lualine/lualine.nvim",
		opts = {
			options = {
				component_separators = "|",
				section_separators = "",
			},
		},
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
	{ "numToStr/Comment.nvim", opts = {} },

	{
		"nvim-treesitter/nvim-treesitter",
		dependencies = {
			"nvim-treesitter/nvim-treesitter-textobjects",
		},
		build = ":TSUpdate",
		config = function()
			require("nvim-treesitter.configs").setup({
				modules = {},
				sync_install = false,
				ignore_install = {},
				ensure_installed = {
					-- general
					"comment",
					"regex",

					-- tools
					"dockerfile",
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
					"typescript",
				},
				auto_install = false,
				highlight = {
					enable = true,
					additional_vim_regex_highlighting = false,
					disable = { "sql" }, -- postgres (especially RLS and plpgsql) are better highlighted through non-treesitter. Extend sql/highlights.scm?
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
							["ac"] = "@class.outer",
							["ic"] = "@class.inner",
						},
					},
					move = {
						enable = true,
						set_jumps = true,
						goto_next_start = {
							["]f"] = "@function.outer",
						},
						goto_next_end = {
							["]F"] = "@function.outer",
						},
						goto_previous_start = {
							["[f"] = "@function.outer",
						},
						goto_previous_end = {
							["[F"] = "@function.outer",
						},
					},
				},
			})

			vim.opt.foldmethod = "expr"
			vim.opt.foldexpr = "nvim_treesitter#foldexpr()"
			vim.opt.foldlevel = 99
		end,
	},

	-- non-treesitter highlighting
	{ "mechatroner/rainbow_csv", ft = "csv" },
	{
		"norcalli/nvim-colorizer.lua",
		ft = "css",
		opts = {
			"css",
		},
	},

	{
		"mg979/vim-visual-multi",
		config = function()
			vim.keymap.set("n", "<M-J>", "<Plug>(VM-Add-Cursor-Down)", {})
			vim.keymap.set("n", "<M-K>", "<Plug>(VM-Add-Cursor-Up)", {})
		end,
	},

	{
		"mbbill/undotree",
		config = function()
			vim.keymap.set("n", "<leader>u", function()
				vim.cmd.UndotreeShow()
				vim.cmd.UndotreeFocus()
			end, { desc = "Undo tree" })
		end,
	},

	{
		"voldikss/vim-floaterm",
		config = function()
			vim.g.floaterm_opener = "edit"
			vim.g.floaterm_height = 0.9
			vim.g.floaterm_width = 0.9

			vim.keymap.set("n", "<leader>e", function()
				vim.cmd.FloatermNew("ranger")
			end, { desc = "Explorer" })
			vim.keymap.set("n", "<leader>t", function()
				vim.cmd.FloatermToggle("main")
			end, { desc = "Terminal" })
			vim.keymap.set("t", "<C-q>", function()
				vim.cmd.FloatermToggle()
			end, {})
			vim.keymap.set("t", "<C-z>", "<C-\\><C-n>", {})
			vim.keymap.set("n", "<leader>T", function()
				local cwd = vim.fn.getcwd()
				vim.cmd.FloatermNew("--disposable --cwd=<buffer>")
				vim.cmd.cd(cwd)
			end, { desc = "Terminal at current dir" })

			vim.api.nvim_set_hl(0, "FloatermBorder", { link = "Normal" })
		end,
	},
}, {})

-- Diagnostics
local signs = { Error = "●", Warn = "●", Hint = "●", Info = "●" }
for type, icon in pairs(signs) do
	local hl = "DiagnosticSign" .. type
	vim.fn.sign_define(hl, { text = icon, texthl = hl, numhl = hl })
end

vim.keymap.set("n", "[d", vim.diagnostic.goto_prev, { desc = "Previous diagnostic" })
vim.keymap.set("n", "]d", vim.diagnostic.goto_next, { desc = "Next diagnostic" })

local open_float_and_focus = function()
	vim.diagnostic.open_float({ source = "always", prefix = " " })
	vim.diagnostic.open_float({ source = "always", prefix = " " })
end
vim.keymap.set("n", "H", open_float_and_focus, { desc = "Focus diagnostics float" })

vim.diagnostic.config({
	virtual_text = false,
	signs = true,
	underline = true,
	update_in_insert = false,
	severity_sort = true,
})

-- fat finger commands
vim.api.nvim_create_user_command("E", "edit", {})
vim.api.nvim_create_user_command("W", "write", {})
vim.api.nvim_create_user_command("Q", "quit", {})
vim.api.nvim_create_user_command("Wq", "wq", {})
vim.api.nvim_create_user_command("WQ", "wq", {})

-- stuff from kickstart
vim.keymap.set({ "n", "v" }, "<Space>", "<Nop>", { silent = true })
vim.keymap.set("n", "k", "v:count == 0 ? 'gk' : 'k'", { expr = true, silent = true })
vim.keymap.set("n", "j", "v:count == 0 ? 'gj' : 'j'", { expr = true, silent = true })

-- remove search highlights on / or ?
vim.keymap.set("n", "/", ":noh<CR>/")
vim.keymap.set("n", "?", ":noh<CR>?")

-- reduce pinky stress
vim.keymap.set("n", "<leader>q", vim.cmd.bdelete, { desc = "Quit buffer" })
vim.keymap.set("n", "<leader>Q", vim.cmd.quitall, { desc = "Quit all" })
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
vim.keymap.set("n", "[q", vim.cmd.cprevious, { desc = "Previous quickfix" })
vim.keymap.set("n", "]q", vim.cmd.cnext, { desc = "Next quickfix" })
vim.keymap.set("n", "<C-q>", toggle_qf, { desc = "Close quickfix" })
vim.keymap.set("n", "<leader><C-q>", function()
	vim.cmd.cdo(vim.fn.getreg(":"))
end, { desc = "Execute last command quickfix entries" })

-- helix-inspired
vim.keymap.set("n", "U", "<C-r>")
vim.keymap.set({ "n", "v", "o" }, "ge", "G", { desc = "End of file" })
vim.keymap.set({ "n", "v", "o" }, "gh", "^")
vim.keymap.set({ "n", "v", "o" }, "gl", "$")

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

vim.o.undodir = vim.fn.stdpath("state") .. "/undo//"
vim.o.undofile = true

vim.o.termguicolors = true
vim.o.mouse = ""

vim.o.swapfile = false
vim.o.updatetime = 0
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

vim.o.ignorecase = true
vim.o.smartcase = true

-- set title dynamimcally by buffer
vim.opt.title = true
vim.opt.titlelen = 0
vim.api.nvim_create_autocmd("BufEnter", {
	command = 'let &titlestring = " " .. expand("%:p:h:t") .. "/" .. expand("%:t") .. " (" .. expand("%:~:.:h:h") .. ")"',
})

vim.api.nvim_create_autocmd("BufRead", {
	pattern = { "*.mustache" },
	command = "set filetype=handlebars",
})

-- Transparent backgrounds
-- not needed for gruvbox but if we switch to a non-transparent-supporting theme uncomment
-- vim.api.nvim_set_hl(0, "LineNr", { bg = "NONE" })
-- vim.api.nvim_set_hl(0, "Normal", { bg = "NONE" })
-- vim.api.nvim_set_hl(0, "NonText", { bg = "NONE" })
-- vim.api.nvim_set_hl(0, "SignColumn", { bg = "NONE" })
