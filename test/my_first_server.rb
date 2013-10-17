require 'webrick'

root = File.expand_path '../views'
server = WEBrick::HTTPServer.new :Port => 8090, :DocumentRoot => root

trap('INT') { server.shutdown }
server.mount_proc '/' do |req, res|
  res.body = 'Hello, world!'
end

server.start