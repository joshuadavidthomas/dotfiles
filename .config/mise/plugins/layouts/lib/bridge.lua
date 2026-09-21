return function(ctx)
  if os.getenv("MISE_LAYOUTS_DISABLE") == "1" then
    return {env = {}, paths = {}, watch_files = {}, messages = {}}
  end
  local cmd = require("cmd")
  local json = require("json")
  local function quote(s)
    return "'" .. s:gsub("'", "'\\''") .. "'"
  end
  -- Keep environment JSON separate while visible setup diagnostics stream to stderr.
  local result_path = cmd.exec("mktemp"):gsub("%s+$", "")
  -- uv may discover Python through a mise shim; prevent nested layout execution.
  -- Scope this guard to the helper subprocess, leaving interactive layouts enabled.
  local code = os.execute("MISE_LAYOUTS_DISABLE=1 uv run --quiet --no-project --no-env-file --script "
    .. quote(ctx.options.root .. "/lib/layouts.py") .. " --cwd "
    .. quote(cmd.exec("pwd"):gsub("%s+$", ""))
    .. (ctx.layout_path_pass and " --path-pass" or "") .. " > " .. quote(result_path))
  local handle = io.open(result_path, "r")
  local output = handle and handle:read("*a") or ""
  if handle then handle:close() end
  os.remove(result_path)
  if code ~= 0 then error("layout helper failed (exit " .. tostring(code) .. ")") end
  local result = json.decode(output)
  return result
end
