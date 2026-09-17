function PLUGIN:MisePath(ctx)
  ctx.layout_path_pass = true
  if os.getenv("MISE_LAYOUTS_DISABLE") == "1" then return {} end
  local config_dir = os.getenv("MISE_CONFIG_DIR") or ((os.getenv("XDG_CONFIG_HOME") or (os.getenv("HOME") .. "/.config")) .. "/mise")
  local root = ctx.options.root or (config_dir .. "/plugins/layouts")
  if root:sub(1, 1) ~= "/" then root = ctx.config_root .. "/" .. root end
  ctx.options.root = root
  return dofile(root .. "/lib/bridge.lua")(ctx).paths
end
