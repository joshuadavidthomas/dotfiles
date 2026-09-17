return function(ctx)
  if os.getenv("MISE_LAYOUTS_DISABLE") == "1" then
    return {env = {}, paths = {}, watch_files = {}, messages = {}}
  end
  local cmd = require("cmd")
  local json = require("json")
  local function quote(s)
    return "'" .. s:gsub("'", "'\\''") .. "'"
  end
  local output = cmd.exec("uv run --quiet --no-project --no-env-file --script "
    .. quote(ctx.options.root .. "/lib/layouts.py") .. " --cwd " .. quote(cmd.exec("pwd"):gsub("%s+$", "")),
    { env = { MISE_LAYOUTS_INTERNAL = "1" } })
  local result = json.decode(output)
  for _, message in ipairs(result.messages or {}) do
    print("layouts: " .. message)
  end
  return result
end
