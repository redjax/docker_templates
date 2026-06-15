-- Map 'z' to fold (close) the current fold
vim.keymap.set('n', 'z', 'zc', { noremap = true, desc = "Fold section under cursor" })

-- Map 'zz' to unfold (open) the current fold
vim.keymap.set('n', 'zz', 'zo', { noremap = true, desc = "Unfold section under cursor" })

-- Fold (foldable) code on left arrow press
-- vim.keymap.set('n', '<Left>', function()
--   -- If the line is open and foldable, close it; otherwise, move left as usual
--   if vim.fn.foldlevel('.') > 0 and vim.fn.foldclosed('.') == -1 then
--   vim.cmd('normal! zc')
--   else
--   vim.cmd('normal! h')
--   end
-- end, { noremap = true, desc = "Fold with left arrow or move left" })

-- Unfold folded code on right arrow press
-- vim.keymap.set('n', '<Right>', function()
--   -- If the line is folded, open it; otherwise, move right as usual
--   if vim.fn.foldclosed('.') ~= -1 then
--     vim.cmd('normal! zo')
--   else
--     vim.cmd('normal! l')
--   end
-- end, { noremap = true, desc = "Unfold with right arrow or move right" })
