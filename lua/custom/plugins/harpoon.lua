-- Harpoon 2: pin a handful of working files, jump to them instantly.
--
-- Keymaps use a leader scheme instead of Harpoon's suggested <C-h/t/n/s>
-- defaults, which would collide with existing bindings in this config:
--   <C-h> -> window-left (init.lua) and disabled in oil
--   <C-t> -> LSP jump-back-from-definition (init.lua LspAttach)
--   <C-n> -> completion next
-- Leader keys below are all verified unused (checked vs global maps,
-- dotnet <leader>c*/<leader>t*, and the git <leader>h* group).
return {
  'ThePrimeagen/harpoon',
  branch = 'harpoon2',
  dependencies = { 'nvim-lua/plenary.nvim' }, -- already present (telescope dep)
  config = function()
    local harpoon = require 'harpoon'
    harpoon:setup {
      settings = {
        -- Default is false, which makes q/<Esc> silently drop any reordering
        -- done in the menu; only :w would keep it.
        save_on_toggle = true,
        sync_on_ui_close = true,
      },
    }

    -- Move lines in the menu so the list can be read top to bottom in
    -- execution order (endpoint -> handler -> repository). Buffer-local,
    -- so the global <C-j>/<C-k> are untouched.
    harpoon:extend {
      UI_CREATE = function(cx)
        local opts = { buffer = cx.bufnr, silent = true }
        vim.keymap.set('n', '<C-j>', '<cmd>m .+1<CR>', vim.tbl_extend('force', opts, { desc = 'Harpoon: move item down' }))
        vim.keymap.set('n', '<C-k>', '<cmd>m .-2<CR>', vim.tbl_extend('force', opts, { desc = 'Harpoon: move item up' }))
      end,
    }

    vim.keymap.set('n', '<leader>a', function()
      harpoon:list():add()
    end, { desc = 'Harpoon [A]dd file' })

    vim.keymap.set('n', '<leader>e', function()
      harpoon.ui:toggle_quick_menu(harpoon:list())
    end, { desc = 'Harpoon m[E]nu' })

    for i = 1, 6 do
      vim.keymap.set('n', '<leader>' .. i, function()
        harpoon:list():select(i)
      end, { desc = 'Harpoon to file ' .. i })
    end
  end,
}
