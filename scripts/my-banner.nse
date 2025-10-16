description = [[
  Simple NSE script that connects to a TCP port, reads up to 512 bytes and prints banner.
]]
author = "Laboratorio Docker"
license = "Same as Nmap--See https://nmap.org/book/man-legal.html"
categories = {"discovery", "safe"}

require "shortport"
require "stdnse"
require "nmap"

portrule = function(host, port)
  return port.protocol == "tcp" and port.state == "open"
end

action = function(host, port)
  local socket = nmap.new_socket()
  socket:set_timeout(3000)
  local status, err = socket:connect(host.ip, port.number)
  if not status then
    return "connect error: " .. tostring(err)
  end
  local data, err = socket:receive_lines(1)
  socket:close()
  if data then
    return "banner: " .. data
  else
    return "no banner or read error: " .. tostring(err)
  end
end
