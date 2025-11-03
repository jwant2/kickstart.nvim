return {
  'rose-pine/neovim',
  name = 'rose-pine',
  config = function()
    require('rose-pine').setup {
      variant = 'moon', -- "auto", "main", "moon", or "dawn"
      dark_variant = 'main',
      disable_background = true, -- 🔹 removes background
      disable_float_background = true,
      disable_italics = false,
    }
    vim.api.nvim_set_hl(0, 'Normal', { bg = 'none' })
    vim.api.nvim_set_hl(0, 'NormalFloat', { bg = 'none' })
    vim.cmd 'colorscheme rose-pine'
  end,
}
