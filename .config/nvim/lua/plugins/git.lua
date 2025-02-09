---@type LazySpec
return {
	{
		"tpope/vim-fugitive",
		cmd = { "Git", "Gdiffsplit" },
		keys = {
			{
				"<leader>gb",
				function()
					vim.cmd.Git("blame")
				end,
				desc = "Git Blame",
			},
			{ "<leader>gd", vim.cmd.Gdiffsplit, desc = "Git Diff" },
			{
				"<leader>g<Left>",
				function()
					vim.cmd.diffget("LOCAL")
				end,
				desc = "Git local changes",
			},
			{
				"<leader>g<Right>",
				function()
					vim.cmd.diffget("REMOTE")
				end,
				desc = "Git remote changes",
			},
		},
		init = function()
			vim.g.fugitive_dynamic_colors = 0
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
			attach_to_untracked = true,
			signs = {
				add = { text = "+" },
				change = { text = "~" },
				delete = { text = "_" },
				topdelete = { text = "‾" },
				changedelete = { text = "~" },
				untracked = { text = "┆" },
			},
		},
		keys = {
			-- don't override the built-in and fugitive keymaps
			{
				"]g",
				function()
					if vim.wo.diff then
						return "]g"
					end
					vim.schedule(function()
						require("nvim-next.integrations").gitsigns(require("gitsigns")).next_hunk()
					end)
					return "<Ignore>"
				end,
				{ expr = true, desc = "Jump to next hunk" },
				{ "n", "v" },
			},
			{
				"[g",
				function()
					if vim.wo.diff then
						return "[g"
					end
					vim.schedule(function()
						require("nvim-next.integrations").gitsigns(require("gitsigns")).prev_hunk()
					end)
					return "<Ignore>"
				end,
				{ expr = true, desc = "Jump to previous hunk" },
				{ "n", "v" },
			},
			{
				"<leader>ga",
				function()
					require("gitsigns").stage_hunk()
				end,
			},
			{
				"<leader>g<BS>",
				function()
					require("gitsigns").reset_hunk()
				end,
			},
		},

		{
			"kdheepak/lazygit.nvim",
			dependencies = {
				"nvim-lua/plenary.nvim",
			},
			keys = {
				{ "<leader>G", vim.cmd.LazyGit, desc = "LazyGit" },
				{ "<leader>gh", vim.cmd.LazyGitFilterCurrentFile, desc = "Show file commits" },
			},
		},
	},
}
