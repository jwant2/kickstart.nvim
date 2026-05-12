-- Next.js / JavaScript / TypeScript debugging with DAP
-- Uses Microsoft's js-debug (vscode-js-debug) adapter via Mason
--
-- Keybindings:
--   F5        = Start / Continue
--   F1        = Step Into
--   F2        = Step Over
--   F3        = Step Out
--   F7        = Toggle DAP UI
--   <leader>b = Toggle breakpoint
--   <leader>B = Conditional breakpoint
--   <leader>dl = Run last debug session
--   <leader>dr = Open REPL
--   <leader>dh = Hover value under cursor

return {
  'mfussenegger/nvim-dap',
  dependencies = {
    'rcarriga/nvim-dap-ui',
    'nvim-neotest/nvim-nio',
    'mason-org/mason.nvim',
    'jay-babu/mason-nvim-dap.nvim',
  },
  keys = {
    {
      '<F5>',
      function()
        require('dap').continue()
      end,
      desc = 'Debug: Start/Continue',
    },
    {
      '<F1>',
      function()
        require('dap').step_into()
      end,
      desc = 'Debug: Step Into',
    },
    {
      '<F2>',
      function()
        require('dap').step_over()
      end,
      desc = 'Debug: Step Over',
    },
    {
      '<F3>',
      function()
        require('dap').step_out()
      end,
      desc = 'Debug: Step Out',
    },
    {
      '<leader>b',
      function()
        require('dap').toggle_breakpoint()
      end,
      desc = 'Debug: Toggle Breakpoint',
    },
    {
      '<leader>B',
      function()
        require('dap').set_breakpoint(vim.fn.input 'Breakpoint condition: ')
      end,
      desc = 'Debug: Conditional Breakpoint',
    },
    {
      '<F7>',
      function()
        require('dapui').toggle()
      end,
      desc = 'Debug: Toggle UI',
    },
    {
      '<leader>dl',
      function()
        require('dap').run_last()
      end,
      desc = 'Debug: Run Last',
    },
    {
      '<leader>dr',
      function()
        require('dap').repl.open()
      end,
      desc = 'Debug: Open REPL',
    },
    {
      '<leader>dh',
      function()
        require('dap.ui.widgets').hover()
      end,
      desc = 'Debug: Hover',
    },
  },
  config = function()
    local dap = require 'dap'
    local dapui = require 'dapui'

    -- Install js-debug-adapter via Mason
    require('mason-nvim-dap').setup {
      automatic_installation = true,
      handlers = {},
      ensure_installed = {
        'js',
      },
    }

    -- DAP UI setup
    dapui.setup {
      icons = { expanded = '▾', collapsed = '▸', current_frame = '*' },
      controls = {
        icons = {
          pause = '⏸',
          play = '▶',
          step_into = '⏎',
          step_over = '⏭',
          step_out = '⏮',
          step_back = 'b',
          run_last = '▶▶',
          terminate = '⏹',
          disconnect = '⏏',
        },
      },
    }

    -- Auto open/close DAP UI
    dap.listeners.after.event_initialized['dapui_config'] = dapui.open
    dap.listeners.before.event_terminated['dapui_config'] = dapui.close
    dap.listeners.before.event_exited['dapui_config'] = dapui.close

    -- Breakpoint signs
    vim.fn.sign_define('DapBreakpoint', { text = '●', texthl = 'DiagnosticError', numhl = '' })
    vim.fn.sign_define('DapBreakpointCondition', { text = '◆', texthl = 'DiagnosticWarn', numhl = '' })
    vim.fn.sign_define('DapStopped', { text = '▶', texthl = 'DiagnosticOk', linehl = 'DapStoppedLine', numhl = '' })
    vim.api.nvim_set_hl(0, 'DapStoppedLine', { bg = '#304030' })

    -- js-debug-adapter path (installed by Mason)
    local js_debug_path = vim.fn.stdpath 'data' .. '/mason/packages/js-debug-adapter'

    -- Register the pwa-node adapter (for server-side Node.js / Next.js)
    dap.adapters['pwa-node'] = {
      type = 'server',
      host = 'localhost',
      port = '${port}',
      executable = {
        command = 'node',
        args = {
          js_debug_path .. '/js-debug/src/dapDebugServer.js',
          '${port}',
        },
      },
    }

    -- Register the pwa-chrome adapter (for client-side browser debugging)
    dap.adapters['pwa-chrome'] = {
      type = 'server',
      host = 'localhost',
      port = '${port}',
      executable = {
        command = 'node',
        args = {
          js_debug_path .. '/js-debug/src/dapDebugServer.js',
          '${port}',
        },
      },
    }

    -- Shared configurations for all JS/TS filetypes
    local js_ts_configs = {
      -- Attach to Next.js dev server (server-side)
      {
        type = 'pwa-node',
        request = 'attach',
        name = 'Attach to Next.js Server',
        processId = require('dap.utils').pick_process,
        cwd = '${workspaceFolder}',
        sourceMaps = true,
        skipFiles = { '<node_internals>/**', 'node_modules/**' },
      },
      -- Launch Next.js dev server with debugging
      {
        type = 'pwa-node',
        request = 'launch',
        name = 'Launch Next.js Dev (node --inspect)',
        runtimeExecutable = 'npm',
        runtimeArgs = { 'run', 'dev' },
        cwd = '${workspaceFolder}',
        sourceMaps = true,
        console = 'integratedTerminal',
        skipFiles = { '<node_internals>/**', 'node_modules/**' },
      },
      -- Debug client-side via Chrome
      {
        type = 'pwa-chrome',
        request = 'launch',
        name = 'Launch Chrome (client-side)',
        url = 'http://localhost:3000',
        webRoot = '${workspaceFolder}',
        sourceMaps = true,
        skipFiles = { '<node_internals>/**', 'node_modules/**' },
      },
      -- Attach to running Node process
      {
        type = 'pwa-node',
        request = 'attach',
        name = 'Attach to Node Process',
        port = 9229,
        cwd = '${workspaceFolder}',
        sourceMaps = true,
        skipFiles = { '<node_internals>/**', 'node_modules/**' },
      },
      -- Launch current file directly with Node
      {
        type = 'pwa-node',
        request = 'launch',
        name = 'Launch Current File',
        program = '${file}',
        cwd = '${workspaceFolder}',
        sourceMaps = true,
        skipFiles = { '<node_internals>/**', 'node_modules/**' },
      },
    }

    -- Apply to all relevant filetypes
    for _, ft in ipairs { 'javascript', 'typescript', 'javascriptreact', 'typescriptreact' } do
      dap.configurations[ft] = js_ts_configs
    end
  end,
}
