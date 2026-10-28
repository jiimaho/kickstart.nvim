# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## What this is

A personal Neovim configuration, forked from [kickstart.nvim](https://github.com/nvim-lua/kickstart.nvim)
(`origin` = `jiimaho/kickstart.nvim`). It is tuned for .NET/C# work on macOS as a
replacement for Rider/Cursor: persistent file tree, fuzzy finding, Roslyn code
intelligence, per-test runs, and a debugger.

The repo lives at `~/.config/nvim`, so edits here are the live config. There is no
build step and no test suite — changes take effect on the next Neovim start.

`README.md` and `.github/workflows/stylua.yml` are inherited from upstream kickstart
and do not describe this fork. The CI workflow is gated on
`github.repository == 'nvim-lua/kickstart.nvim'` and never runs here.

## Commands

```sh
# Verify the config parses and every plugin loads (exits non-zero / prints errors on failure)
nvim --headless -c 'qa'

# Inspect runtime state without opening the UI
nvim --headless -c 'lua print(vim.inspect(require("nvim-tree.config").g.view))' -c 'qa!'

# Format (stylua is NOT currently installed: brew install stylua)
stylua .
stylua --check .
```

Inside Neovim: `:Lazy` (plugin status/sync), `:Mason` (LSP/tool installs),
`:checkhealth`, `:checkhealth kickstart`.

Headless loading is the main verification tool — prefer it over asking the user to
restart, and read resolved runtime values rather than trusting what the file says.

## Layout

| Path | Role |
|---|---|
| `init.lua` | ~1400 lines; options, keymaps, and nearly every plugin spec |
| `lua/custom/plugins/*.lua` | Auto-imported by lazy via `{ import = 'custom.plugins' }` |
| `lua/kickstart/plugins/*.lua` | Upstream optional modules; all `require`d lines are commented out except `debug` |
| `lazy-lock.json` | Pinned commits for 34 plugins |
| `.stylua.toml` | `column_width = 160`, single quotes, `call_parentheses = "None"` |

Adding a plugin: new file in `lua/custom/plugins/` returning a lazy spec, or a spec
inline in `init.lua`. Do not uncomment `lua/kickstart/plugins/*` wholesale — several
map keys that collide with bindings this config already uses.

## Architecture notes

These are the non-obvious couplings; each one spans multiple files.

**C# does not go through the `servers` table.** `init.lua`'s `servers` list only holds
`vtsls`, `eslint`, `jsonnet_ls`, `lua_ls`. Roslyn is started and configured by
`easy-dotnet.nvim` (`lua/custom/plugins/dotnet.lua`), which also owns the test runner
and downloads `netcoredbg`. Roslyn settings go in that file's `lsp_config`, not
`init.lua`. `sourcekit` is a third path again — registered directly via
`vim.lsp.config`/`vim.lsp.enable` near `init.lua:788`.

**Roslyn diagnostics are deliberately scoped to open files.** `dotnet_analyzer_diagnostics_scope`
and `dotnet_compiler_diagnostics_scope` are both `openFiles`. `fullSolution` makes
Neovim's `bufadd()` cost quadratic in solution size — it was measured pinning nvim at
100% CPU with Roslyn RSS past 5GB, and was reverted (`ae24829`). Use `<leader>cnB`
(build to quickfix) for solution-wide errors instead.

**Codelens is wired once in `init.lua`'s `LspAttach`**, with easy-dotnet's
`auto_refresh_codelens` disabled, to avoid duplicate refresh cycles when several
clients attach to the same buffer.

**LSP keymaps live in the `LspAttach` autocmd**, not at top level. `:source $MYVIMRC`
will not re-run them for buffers that already attached — a real restart is required
to test changes there.

**Manual highlight overrides need a `ColorScheme` autocmd.** Loading or reloading a
colorscheme clears `nvim_set_hl` calls. The `jiimaho/rider-dark.nvim` block holds two
such groups (`csharp-lsp-hl` for Roslyn's `recordStruct`/`recordClass` semantic
tokens, `nvim-tree-hl` for the tree's cursorline), each defined as a function,
registered on `ColorScheme`, then called once immediately.

**nvim-tree's `api.tree.change_root()` is a silent no-op before the tree has been
opened once** — it returns early when `core.get_explorer()` is `nil`. Any code that
re-roots the tree must call `api.tree.open()` first.

**nvim-treesitter is on the `main` branch**, which no longer auto-attaches. Highlighting
and indentation are enabled per buffer by a `FileType` autocmd after `ts.install()`.

**Formatting is conform.nvim, not the LSP.** TS/JS/CSS/JSON/Markdown go through
`prettierd` so the project's own `.prettierrc` is honoured; falling back to the LSP
formatter silently ignores it.

## Conventions

Commits follow Conventional Commits with a scope naming the affected area
(`feat(nvim-tree):`, `fix(telescope):`, `perf(dotnet):`, `revert(roslyn):`). Bodies
explain *why*, including measurements when a change is performance-driven, and carry
a `Co-Authored-By` trailer.

Comments in the config explain reasoning that the code cannot — why a value was
chosen, what broke without it, which alternative was rejected. Match that density;
do not add comments that restate the line below them.

Keymaps are checked against the existing set before being added; `lua/custom/plugins/harpoon.lua`
documents that check in its header. `<leader>c*` and `<leader>t*` belong to .NET,
`<leader>h*` to git hunks, `<space>n*` to nvim-tree.
