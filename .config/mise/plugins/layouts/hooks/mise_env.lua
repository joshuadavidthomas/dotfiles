function PLUGIN:MiseEnv(ctx)
  if os.getenv("MISE_LAYOUTS_DISABLE") == "1" then
    return {env = {}, watch_files = {}, cacheable = false}
  end
  local config_dir = os.getenv("MISE_CONFIG_DIR") or ((os.getenv("XDG_CONFIG_HOME") or (os.getenv("HOME") .. "/.config")) .. "/mise")
  local root = ctx.options.root or (config_dir .. "/plugins/layouts")
  if root:sub(1, 1) ~= "/" then root = ctx.config_root .. "/" .. root end
  ctx.options.root = root
  local result = dofile(root .. "/lib/bridge.lua")(ctx)
  return {env = result.env, watch_files = result.watch_files, cacheable = false, redact = true}
end
