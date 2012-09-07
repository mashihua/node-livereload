# Implement [LiveReload Protocol](http://help.livereload.com/kb/ecosystem/livereload-protocol)
# for nodejs user

WSServer = require('ws').Server
http = require 'http'
path = require 'path'
url = require 'url'
fs = require 'fs'
# Livereload.js  folder
livereloadPath = "#{__dirname}/../lib/livereload/"

# This server handler client connect and send reload command to client
Server = (options) ->
  #Web socket pool 
  @conns = []
  #Web server
  @web = null
  @options = options
  @start()
  return

# Send reload command to all client
Server::reloadBrowser = (paths = []) ->
  console.log "Reloading browser: #{paths.join(' ')}"
  for path in paths
    data = 
      command : 'reload'
      path : path
      liveCSS : true
      liveImg : true
    for conn in @conns
      conn.send JSON.stringify data

# Shutdown the server
Server::stop = ->
  @web.close ()-> console.log 'Shutdown the server.' if @web

# Start the web server and web socket server
Server::start = ->
    
  console.log "LiveReload #{@options.apiVersion} is waiting for a browser to connect."  
  conns = @conns
  
  # Create web server
  web = http.createServer (request, response) ->
    query = url.parse request.url, true
    # For compatible purpose:
    # Node.js 0.8 start move path.exists to fs.exists.
    # See [change log](https://github.com/joyent/node/wiki/API-changes-between-v0.6-and-v0.8).
    existsFuc = if fs.existsSync then fs.existsSync else path.existsSync
    file = "#{livereloadPath}#{query.pathname}"
    exists = existsFuc file
    if exists and query.pathname isnt '/'
      response.writeHead 200
        'Transfer-Encoding' :'chunked',
        'Content-Type': 'application/x-javascript'
      read = fs.createReadStream file
      read.pipe response
    else
      body = 'Not Found'
      response.writeHead 404
        'Content-Length': body.length,
        'Content-Type': 'text/plain'
      response.end body
      
  # Start the web server    
  web.listen @options.port,@options.host

  @web = web
  
  # Start the web socket server
  wss = new WSServer 
    server : web
    path: '/livereload'
     
  wss.on 'connection' , (ws) ->
    
    console.log 'Browser connected.'
    conns.push ws
    
    ws.on 'message' , (msg, flag) ->
      msg = JSON.parse msg
      # Handshake command
      if msg.command is 'hello'
        protocols = msg.protocols
        protocols.push 'http://livereload.com/protocols/2.x-remote-control' 
        protocols.push 'http://livereload.com/protocols/official-7'  
        handshake = 
          'command' : 'hello'
          'protocols' : protocols
          'serverName' : 'livereload-node'
        ws.send JSON.stringify handshake
      # Client information with listen url
      if msg.command is 'info' and msg['url']
        console.log "Browser URL: " + msg.url
    
    ws.on 'close' , () ->
      # Remove the client from connection pool
      conns.splice conns.indexOf ws, 1;
      console.log 'Browser disconnected.'

module.exports = Server