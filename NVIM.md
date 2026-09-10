# Using as a Neovim colorscheme

This repo doubles as a Neovim plugin. `colors/gogh.lua` is the entry point
`:colorscheme gogh` looks for; it delegates to `lua/base16-colorscheme.lua`
for the actual highlight groups. Both are build output — rerun `./build.sh`
after changing anything upstream, don't hand-edit either file directly:

- `colors/gogh.lua` is generated per scheme from
  `templates/colors/lua.mustache` + `schemes/gogh.yaml` — edit the yaml to
  change colors.
- `lua/base16-colorscheme.lua` is copied verbatim from
  `templates/lua/base16-colorscheme.lua` — it's a shared engine (any base16
  palette in, highlight groups out), not per-scheme, so there's no mustache
  substitution — edit the template to change highlight-group logic.

## lazy.nvim

```lua
{
  "hugoocoto/gogh-theme",
  lazy = false,    -- load on startup, not on a trigger
  priority = 1000, -- before other plugins that might read highlight groups
  config = function()
    vim.cmd.colorscheme("gogh")
  end,
}
```

## vim.pack (Neovim's built-in package manager, 0.12+)

Add to `init.lua`:

```lua
vim.pack.add({
  { src = "https://github.com/hugoocoto/gogh-theme" },
})

vim.cmd.colorscheme("gogh")
```

`vim.pack.add` clones the plugin into `stdpath('data')/site/pack/core/opt`
and puts it on `runtimepath` immediately, so the `colorscheme` call can
follow right after in the same file. To update later:

```lua
vim.pack.update()
```

## Notes

- No `setup()` call is required — `colors/gogh.lua` configures everything
  itself when `:colorscheme gogh` runs.
- Only one scheme ships today (`gogh`); if more are added under `schemes/`
  and rebuilt, they become available as additional `colors/<slug>.lua`
  files using the same install steps.
