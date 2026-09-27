local irc = {}
irc.__index = irc




local function toWsUrl(server, port)
	
	if type(server) == "string" and (server:sub(1, 5) == "ws://" or server:sub(1, 6) == "wss://") then
		return server
	end
	return ("ws://%s:%d"):format(tostring(server), tonumber(port) or 80)
end

local function normalizeIrcLine(s)
	
	s = tostring(s or "")
	if s:sub(-2) ~= "\r\n" then
		s = s .. "\r\n"
	end
	return s
end

function irc.new(server, port, nickname)
	local self = setmetatable({}, irc)
	self.server = server
	self.port = port
	self.nickname = nickname
	self.connection = nil

	self._inbuf = ""
	self._queue = {}
	self._closed = false

	return self
end

function irc:connect()
	local url = toWsUrl(self.server, self.port)
	self.connection = WebSocket.connect(url)

	self._closed = false
	self._inbuf = ""
	self._queue = {}

	
	self.connection.OnMessage:Connect(function(payload)
		if self._closed then
			return
		end

		self._inbuf ..= tostring(payload)

		while true do
			local i, j = self._inbuf:find("\r\n", 1, true)
			if not i then
				break
			end
			local line = self._inbuf:sub(1, i - 1)
			table.insert(self._queue, line)
			self._inbuf = self._inbuf:sub(j + 1)
		end
	end)

	self.connection.OnClose:Connect(function()
		self._closed = true
	end)

	
	self.connection:Send(normalizeIrcLine("NICK " .. self.nickname))
	self.connection:Send(normalizeIrcLine("USER " .. self.nickname .. " 0 * :" .. self.nickname))
end

function irc:sendMessage(channel, message)
	if self.connection and not self._closed then
		self.connection:Send(normalizeIrcLine("PRIVMSG " .. channel .. " :" .. message))
	end
end

function irc:receiveMessage()
	
	if #self._queue > 0 then
		return table.remove(self._queue, 1)
	end
	return nil
end

function irc:disconnect()
	if self.connection then
		if not self._closed then
			
			pcall(function()
				self.connection:Send(normalizeIrcLine("QUIT"))
			end)
		end
		pcall(function()
			self.connection:Close()
		end)
		self.connection = nil
		self._closed = true
	end
end

return irc
