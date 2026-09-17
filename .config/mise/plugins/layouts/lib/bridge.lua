return function(ctx)
  if os.getenv("MISE_LAYOUTS_DISABLE") == "1" then
    return {env = {}, paths = {}, watch_files = {}, messages = {}}
  end
  local cmd = require("cmd")
  local json = require("json")
  local function quote(s)
    return "'" .. s:gsub("'", "'\\''") .. "'"
  end
  -- Keep the environment JSON separate while setup diagnostics stream to stderr.
  local result_path = cmd.exec("mktemp"):gsub("%s+$", "")
  local code = os.execute("uv run --quiet --no-project --no-env-file --script "
    .. quote(ctx.options.root .. "/lib/layouts.py") .. " --cwd "
    .. quote(cmd.exec("pwd"):gsub("%s+$", "")) .. " > " .. quote(result_path))
  local handle = io.open(result_path, "r")
  local output = handle and handle:read("*a") or ""
  if handle then handle:close() end
  os.remove(result_path)
  if code ~= 0 then error("layout helper failed (exit " .. tostring(code) .. ")") end
  local result = json.decode(output)
  for _, message in ipairs(result.messages or {}) do
    print("layouts: " .. message)
  end
  return result
end
