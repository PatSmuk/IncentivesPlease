local dispatcher = {}

function dispatcher.createDispatcher()
  local dispatcher = {}
  local handlers = {}

  function dispatcher:on(messageType, handler)
    if handlers[messageType] == nil then
      handlers[messageType] = {}
    end

    table.insert(handlers[messageType], handler)
  end

  function dispatcher:dispatch(message)
    assert(type(message.type) == "string")

    if message.loggable then
      local s = message.type.." { "
      for k, v in pairs(message) do
        if k ~= "type" then
          s = s..k..": "..tostring(v)..", "
        end
      end
      print(s:sub(1, #s - 2).." }")
    end

    if not handlers[message.type] then
      return
    end
    for i, handler in ipairs(handlers[message.type]) do
      handler(dispatcher, message)
    end
  end

  return dispatcher
end

return dispatcher
