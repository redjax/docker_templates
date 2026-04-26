-- Backup, swap, undo
vim.opt.swapfile = false
vim.opt.backup = false

-- Time in ms after typing stops before executing CursorHold events
vim.opt.updatetime = 250

local undodir
if vim.g.platform == "windows" then
	local userprofile = os.getenv("USERPROFILE")
	if userprofile then
		undodir = userprofile .. "/.vim/undodir"
	else
		vim.notify("USERPROFILE not set! Undo directory not configured.", vim.log.levels.ERROR)
	end
else
	local home = os.getenv("HOME")
	if home then
		undodir = home .. "/.vim/undodir"
	else
		vim.notify("HOME not set! Undo directory not configured.", vim.log.levels.ERROR)
	end
end

if undodir then
	vim.fn.mkdir(undodir, "p")
	vim.opt.undodir = undodir
	vim.opt.undofile = true
end

-- Re-open documents at last known position
vim.api.nvim_create_autocmd("BufRead", {
	callback = function(opts)
		vim.api.nvim_create_autocmd("BufWinEnter", {
			once = true,
			buffer = opts.buf,
			callback = function()
				local ft = vim.bo[opts.buf].filetype
				local last_known_line = vim.api.nvim_buf_get_mark(opts.buf, '"')[1]
				if
					not (ft:match("commit") and ft:match("rebase"))
					and last_known_line > 1
					and last_known_line <= vim.api.nvim_buf_line_count(opts.buf)
				then
					vim.api.nvim_feedkeys([[g`"]], "nx", false)
				end
			end,
		})
	end,
})
