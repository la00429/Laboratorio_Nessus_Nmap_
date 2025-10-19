description = [[
Simple NSE script that connects to a TCP port, reads up to 512 bytes and prints banner.
]]

author = "Lab"
license = "Same as Nmap"
categories = {"discovery", "safe"}

local shortport = require "shortport"
local stdnse = require "stdnse"
local nmap = require "nmap"

portrule = shortport.port_or_service({21,22,23,25,80,110,143,443}, {"ftp","ssh","telnet","smtp","http","pop3","imap","https"})

action = function(host, port)
  local socket = nmap.new_socket()
  socket:set_timeout(3000)
  local status, err = socket:connect(host.ip, port.number)
  if not status then
    return nil
  end
  local status, data = socket:receive_lines(1)
  socket:close()
  if status then
    return "Banner: " .. data
  else
    return nil
  end
end
