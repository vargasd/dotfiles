---require('snacks')
---@module "Snacks"
---@type LazySpec[]
return {
	{
		"folke/snacks.nvim",
		priority = 1000,
		lazy = false,
		---@type snacks.Config
		opts = {
			bigfile = { enabled = true },
			picker = {
				enabled = true,
				keys = {
					["<Esc>"] = { "close", mode = { "n", "i" } },
				},
				win = {
					input = {
						["<Esc>"] = { "close", mode = { "n", "i" } },
						["<C-w>"] = { "<c-s-w>", mode = { "i" }, expr = true, desc = "delete word" },
						["<CR>"] = { "confirm", mode = { "n", "i" } },
						["<Down>"] = { "list_down", mode = { "i", "n" } },
						["<S-Tab>"] = { "select_and_prev", mode = { "i", "n" } },
						["<Tab>"] = { "select_and_next", mode = { "i", "n" } },
						["<Up>"] = { "list_up", mode = { "i", "n" } },
						["<a-f>"] = { "toggle_follow", mode = { "i", "n" } },
						["<a-h>"] = { "toggle_hidden", mode = { "i", "n" } },
						["<a-i>"] = { "toggle_ignored", mode = { "i", "n" } },
						["<a-m>"] = { "toggle_maximize", mode = { "i", "n" } },
						["<a-p>"] = { "toggle_preview", mode = { "i", "n" } },
						["<a-w>"] = { "cycle_win", mode = { "i", "n" } },
						["<a-a>"] = { "select_all", mode = { "n", "i" } },
						["<c-b>"] = { "preview_scroll_up", mode = { "i", "n" } },
						["<c-f>"] = { "preview_scroll_down", mode = { "i", "n" } },
						["<c-n>"] = { "list_down", mode = { "i", "n" } },
						["<c-p>"] = { "list_up", mode = { "i", "n" } },
						["<c-q>"] = { "qflist", mode = { "i", "n" } },
						["<a-s>"] = { "flash", mode = { "n", "i" } },
					},
				},
				layout = {
					layout = {
						backdrop = false,
						width = 0.7,
						min_width = 80,
						height = 0.9,
						min_height = 30,
						box = "vertical",
						border = "rounded",
						title = "{title} {live} {flags}",
						title_pos = "center",
						{ win = "input", height = 1, border = "bottom" },
						{ win = "list", border = "none" },
						{ win = "preview", title = "{preview}", height = 0.6, border = "top" },
					},
				},
			},

			git = { enabled = true },
			statuscolumn = { enabled = true },
		},
		keys = {
			-- Top Pickers & Explorer
			{
				"<leader>'",
				function()
					Snacks.picker.smart({ multi = { "git_files", "buffers" } })
				end,
				desc = "Smart Find Files",
			},
			{
				"<leader>b",
				function()
					Snacks.picker.buffers()
				end,
				desc = "Buffers",
			},
			{
				"<leader>/",
				function()
					Snacks.picker.grep()
				end,
				desc = "Grep",
			},
			{
				"<leader>f",
				function()
					Snacks.picker.git_files()
				end,
				desc = "Find Files",
			},
			{
				"<leader>B",
				function()
					Snacks.picker.recent()
				end,
				desc = "Recent",
			},
			{
				'<leader>s"',
				function()
					Snacks.picker.registers()
				end,
				desc = "Registers",
			},
			{
				"<leader>s/",
				function()
					Snacks.picker.search_history()
				end,
				desc = "Search History",
			},
			{
				"<leader>d",
				function()
					Snacks.picker.diagnostics()
				end,
				desc = "Diagnostics",
			},
			{
				"<leader>h",
				function()
					Snacks.picker.help()
				end,
				desc = "Help Pages",
			},
			{
				"<leader>H",
				function()
					Snacks.picker.highlights()
				end,
				desc = "Highlights",
			},
			-- {
			-- 	"<leader>sR",
			-- 	function()
			-- 		Snacks.picker.resume()
			-- 	end,
			-- 	desc = "Resume",
			-- },
			-- {
			-- 	"<leader>su",
			-- 	function()
			-- 		Snacks.picker.undo()
			-- 	end,
			-- 	desc = "Undo History",
			-- },
			-- {
			-- 	"<leader>uC",
			-- 	function()
			-- 		Snacks.picker.colorschemes()
			-- 	end,
			-- 	desc = "Colorschemes",
			-- },
			-- LSP
			{
				"gd",
				function()
					Snacks.picker.lsp_definitions()
				end,
				desc = "Goto Definition",
			},
			{
				"gD",
				function()
					Snacks.picker.lsp_declarations()
				end,
				desc = "Goto Declaration",
			},
			{
				"gr",
				function()
					Snacks.picker.lsp_references()
				end,
				nowait = true,
				desc = "References",
			},
			{
				"gI",
				function()
					Snacks.picker.lsp_implementations()
				end,
				desc = "Goto Implementation",
			},
			{
				"gy",
				function()
					Snacks.picker.lsp_type_definitions()
				end,
				desc = "Goto T[y]pe Definition",
			},
			{
				"<leader>ss",
				function()
					Snacks.picker.lsp_symbols()
				end,
				desc = "LSP Symbols",
			},
			{
				"<leader>sS",
				function()
					Snacks.picker.lsp_workspace_symbols()
				end,
				desc = "LSP Workspace Symbols",
			},
			-- Other
			{
				"<leader>z",
				function()
					Snacks.zen()
				end,
				desc = "Toggle Zen Mode",
			},
			{
				"<leader>Z",
				function()
					Snacks.zen.zoom()
				end,
				desc = "Toggle Zoom",
			},
			{
				"<leader>.",
				function()
					Snacks.scratch()
				end,
				desc = "Toggle Scratch Buffer",
			},
			{
				"<leader>S",
				function()
					Snacks.scratch.select()
				end,
				desc = "Select Scratch Buffer",
			},
			{
				"<leader>n",
				function()
					Snacks.notifier.show_history()
				end,
				desc = "Notification History",
			},
			{
				"<leader>bd",
				function()
					Snacks.bufdelete()
				end,
				desc = "Delete Buffer",
			},
			{
				"<leader>cR",
				function()
					Snacks.rename.rename_file()
				end,
				desc = "Rename File",
			},
			{
				"<leader>gB",

				function()
					Snacks.gitbrowse()
				end,
				desc = "Git Browse",
				mode = { "n", "v" },
			},
			{
				"<leader>gg",
				function()
					Snacks.lazygit()
				end,
				desc = "Lazygit",
			},
			{
				"<leader>un",
				function()
					Snacks.notifier.hide()
				end,
				desc = "Dismiss All Notifications",
			},
			{
				"<c-/>",
				function()
					Snacks.terminal()
				end,
				desc = "Toggle Terminal",
			},
			{
				"]]",
				function()
					Snacks.words.jump(vim.v.count1)
				end,
				desc = "Next Reference",
				mode = { "n", "t" },
			},
			{
				"[[",
				function()
					Snacks.words.jump(-vim.v.count1)
				end,
				desc = "Prev Reference",
				mode = { "n", "t" },
			},
		},
	},
}
