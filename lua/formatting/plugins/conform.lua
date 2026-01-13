-- use :help Conform to see available formatters
return { -- Autoformat
  'stevearc/conform.nvim',
  event = { 'BufWritePre' },
  cmd = { 'ConformInfo' },
  keys = {
    {
      '<leader>f',
      function()
        local ft = vim.bo.filetype
        if ft == 'javascript' or ft == 'typescript' or ft == 'typescriptreact' or ft == 'javascriptreact' then
          require('conform').format { async = true, formatters = { 'prettier', 'eslint_d' } }
        else
          require('conform').format { async = false, lsp_format = 'fallback' }
        end
      end,
      mode = '',
      desc = '[F]ormat buffer',
    },
  },
  opts = {
    notify_on_error = false,
    format_on_save = function(bufnr)
      return {
        timeout_ms = 500,
        lsp_format = 'fallback',
      }
    end,
    formatters_by_ft = {
      lua = { 'stylua' },
      javascript = { 'prettier' },
      typescript = { 'prettier' },
      typescriptreact = { 'prettier' },
      javascriptreact = { 'prettier' },
      css = { 'prettier' },
      scss = { 'prettier' },
      json = { 'prettier' },
    },
    formatters = { prettier = { require_cwd = true } },
  },
}
