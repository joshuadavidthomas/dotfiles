function PLUGIN:MisePath(ctx)
  ctx.plugin_root = RUNTIME and RUNTIME.pluginDirPath or nil
  if not ctx.plugin_root then
    local config_dir = os.getenv("MISE_CONFIG_DIR") or ((os.getenv("XDG_CONFIG_HOME") or (os.getenv("HOME") .. "/.config")) .. "/mise")
    ctx.plugin_root = config_dir .. "/plugins/layouts"
  end
  return dofile(ctx.plugin_root .. "/lib/layouts.lua")(ctx, "path").paths
end
