return {
  'catppuccin/nvim',
  name = 'catppuccin',
  config = function()
    require('catppuccin').setup {
      flavour = 'mocha',
      transparent_background = true,

      custom_highlights = function(colors)
        return {
          LineNr = {
            fg = colors.overlay1,
            bold = true,
          },
        }
      end,
    }
    vim.api.nvim_set_hl(0, 'Normal', { bg = 'none' })
    vim.api.nvim_set_hl(0, 'NormalFloat', { bg = 'none' })
    vim.cmd 'colorscheme catppuccin'
  end,
}
