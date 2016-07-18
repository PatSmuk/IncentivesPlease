local dispatcher = {}

local MAX_MESSAGES_IN_LOG = 75

function dispatcher.createDispatcher()
  local dispatcher = {
    handlers = {},
    lastMessages = {}
  }

  function dispatcher:on(messageType, handler)
    if self.handlers[messageType] == nil then
      self.handlers[messageType] = {}
    end

    table.insert(self.handlers[messageType], handler)
  end

  function dispatcher:dispatch(message)
    assert(type(message.type) == "string")

    if message.loggable then
      local s = message.type.." { "
      for k, v in pairs(message) do
        if k ~= "type" and k ~= "loggable" then
          s = s..k..": "..tostring(v)..", "
        end
      end

      table.insert(self.lastMessages, s:sub(1, #s - 2).." }")
      if #self.lastMessages > MAX_MESSAGES_IN_LOG then
        table.remove(self.lastMessages, 1)
      end
    end

    if not self.handlers[message.type] then
      return
    end
    for i, handler in ipairs(self.handlers[message.type]) do
      handler(dispatcher, message)
    end
  end

  return dispatcher
end

return dispatcher
