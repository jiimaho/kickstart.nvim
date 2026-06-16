local lsp_config = {
  settings = {
    ['csharp|inlay_hints'] = {
      csharp_enable_inlay_hints_for_implicit_object_creation = true,
      csharp_enable_inlay_hints_for_implicit_variable_types = true,
      csharp_enable_inlay_hints_for_lambda_parameter_types = true,
      csharp_enable_inlay_hints_for_types = true,
      dotnet_enable_inlay_hints_for_indexer_parameters = true,
      dotnet_enable_inlay_hints_for_literal_parameters = true,
      dotnet_enable_inlay_hints_for_object_creation_parameters = true,
      dotnet_enable_inlay_hints_for_other_parameters = true,
      dotnet_enable_inlay_hints_for_parameters = true,
      dotnet_suppress_inlay_hints_for_parameters_that_differ_only_by_suffix = true,
      dotnet_suppress_inlay_hints_for_parameters_that_match_argument_name = true,
      dotnet_suppress_inlay_hints_for_parameters_that_match_method_intent = true,
    },
    ['csharp|code_lens'] = {
      dotnet_enable_references_code_lens = true,
      dotnet_enable_tests_code_lens = true,
    },
    ['csharp|background_analysis'] = {
      dotnet_analyzer_diagnostics_scope = 'openFiles',
      dotnet_compiler_diagnostics_scope = 'fullSolution',
    },
    ['csharp|completion'] = {
      dotnet_provide_regex_completions = false,
      dotnet_show_completion_items_from_unimported_namespaces = true,
      dotnet_show_name_completion_suggestions = false,
    },
    ['csharp|navigation'] = {
      dotnet_navigate_to_decompiled_sources = true,
    },
    ['csharp|symbol_search'] = {
      dotnet_search_reference_assemblies = true,
    },
    ['csharp|quick_info'] = {
      dotnet_show_remarks_in_quick_info = true,
    },
    ['csharp|highlighting'] = {
      dotnet_highlight_related_json_components = true,
      dotnet_highlight_related_regex_components = true,
    },
  },
}

return {
  {
    'Cliffback/netcoredbg-macOS-arm64.nvim',
    ft = { 'cs', 'csproj' },
    dependencies = { 'mfussenegger/nvim-dap' },
    config = function()
      require('netcoredbg-macOS-arm64').setup(require('dap'))
    end,
  },
  {
    'GustavEikaas/easy-dotnet.nvim',
    dependencies = { 'nvim-lua/plenary.nvim', 'mfussenegger/nvim-dap' },
    ft = { 'cs', 'csproj', 'sln', 'slnx', 'props', 'csx', 'targets' },
    opts = {
      debugger = {
        bin_path = vim.fn.stdpath('data') .. '/lazy/netcoredbg-macOS-arm64.nvim/netcoredbg',
        console = 'integratedTerminal',
      },
      lsp = {
        enabled = true,
        config = lsp_config,
        -- Disable built-in codelens wiring; handled once in init.lua LspAttach
        -- to avoid duplicate refresh cycles when multiple clients attach.
        auto_refresh_codelens = false,
      },
      auto_bootstrap_namespace = {
        type = 'file_scoped',
        enabled = true,
      },
      picker = 'telescope',
      test_runner = {
        viewmode = 'vsplit',
        vsplit_width = 70,
        vsplit_pos = 'topleft',
        noBuild = false,
        mappings = {
          run_test_from_buffer = { lhs = '<leader>tR', desc = 'run test from buffer' },
          debug_test_from_buffer = { lhs = '<leader>tD', desc = 'debug test from buffer' },
          filter_failed_tests = { lhs = '<leader>tf', desc = 'filter failed tests' },
          debug_test = { lhs = '<leader>td', desc = 'debug test' },
          go_to_file = { lhs = '<leader>tg', desc = 'goto to file' },
          run_all = { lhs = '<leader>tA', desc = 'run all tests' },
          run = { lhs = '<leader>tr', desc = 'run test' },
          peek_stacktrace = { lhs = '<leader>tp', desc = 'peek stacktrace of failed test' },
          expand = { lhs = 'o', desc = 'expand' },
          expand_node = { lhs = 'E', desc = 'expand node' },
          expand_all = { lhs = '-', desc = 'expand all' },
          collapse_all = { lhs = 'W', desc = 'collapse all' },
          close = { lhs = 'q', desc = 'close testrunner' },
        },
      },
    },
    keys = {
      { '<leader>cn', '', desc = '+.NET' },
      { '<leader>cnp', '', desc = '+Package' },
      { '<leader>ce', '<cmd>Dotnet diagnostic<cr>', desc = 'Diagnostic errors', ft = { 'cs' } },
      { '<leader>cD', '<cmd>Dotnet diagnostic warnings<cr>', desc = 'Diagnostics (warnings)', ft = { 'cs' } },
      { '<leader>cnpo', '<cmd>Dotnet outdated<cr>', desc = 'Show outdated' },
      { '<leader>cnpa', '<cmd>Dotnet add package<cr>', desc = 'Add package' },
      { '<leader>cnpr', '<cmd>Dotnet remove package <cr>', desc = 'Remove package' },
      { '<leader>cnn', '<cmd>Dotnet new<cr>', desc = 'Add new item' },
      { '<leader>cnr', '', desc = '+Reference' },
      { '<leader>cnSa', '<cmd>Dotnet solution add<cr>', desc = 'Add project to sln' },
      { '<leader>cnSr', '<cmd>Dotnet solution remove<cr>', desc = 'Remove project from sln' },
      { '<leader>cnSs', '<cmd>Dotnet solution select<cr>', desc = 'select solution' },
      { '<leader>cnR', '', desc = '+Run' },
      { '<leader>cnS', '', desc = '+Solution' },
      { '<leader>cnB', '<cmd>Dotnet build quickfix<cr>', desc = 'build solution' },
      { '<leader>cnRr', '<cmd>Dotnet run<cr>', desc = 'run' },
      { '<leader>cnRd', '<cmd>Dotnet debug profile<cr>', desc = 'debug (pick launch profile)' },
      { '<leader>cnx', '<cmd>Dotnet clean<cr>', desc = 'clean solution' },
      { '<leader>to', '<cmd>Dotnet testrunner<cr>', desc = 'Open test runner' },
      { '<leader>tR', '', desc = 'run test from buffer', ft = { 'cs', 'easy-dotnet' } },
      { '<leader>tD', '', desc = 'debug test from buffer', ft = { 'cs', 'easy-dotnet' } },
    },
  },
}
