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
    if not handlers[message.type] then
      return
    end
    for i, handler in ipairs(handlers[message.type]) do
      handler(message)
    end
  end

  return dispatcher
end

return dispatcher
