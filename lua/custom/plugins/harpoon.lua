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
    harpoon:setup()

    vim.keymap.set('n', '<leader>a', function()
      harpoon:list():add()
    end, { desc = 'Harpoon [A]dd file' })

    vim.keymap.set('n', '<leader>e', function()
      harpoon.ui:toggle_quick_menu(harpoon:list())
    end, { desc = 'Harpoon m[E]nu' })

    for i = 1, 4 do
      vim.keymap.set('n', '<leader>' .. i, function()
        harpoon:list():select(i)
      end, { desc = 'Harpoon to file ' .. i })
    end
  end,
}
