WebSocket = require 'ws'
Server = require './../src/server'
http = require 'http'

describe 'Server', ->
  
  options = 
    version : '1.6'
    host : '0.0.0.0'
    port : '35729'
  app = new Server options
  ws = new WebSocket "ws://127.0.0.1:#{options.port}/livereload"
    
  describe 'Communicate between clint and server', ->

    it 'Handshake message should send to clinet',(done) ->
      ws.on 'open', ->
        handshake = 
          command : 'hello'
          protocols : [ 'http://livereload.com/protocols/connection-check-1']
          serverName : 'LiveReload 2'
        ws.send JSON.stringify handshake

      ws.once 'message', (data, flags) ->
        command = JSON.parse data
        command.should.have.property 'command', 'hello'
        command.should.have.property('protocols').with.lengthOf 3
        command.should.have.property 'serverName', 'livereload-node'
        done()
    
    it 'Client should recive livereload.js', (done)->
      opts = 
        host: 'localhost',
        port: '35729',
        path: '/livereload.js'
        method: 'GET'
      req = http.request opts, (res) ->
        res.statusCode.should.equal 200
        done()
      req.end()
   
    it 'Client should recive 404 status code', (done)->
      opts = 
        host: 'localhost',
        port: '35729',
        path: '/'
        method: 'GET'
      req = http.request opts, (res) ->
        res.statusCode.should.equal 404
        done()
      req.end()
        
    it 'Should send reload request to client', (done)->
      reload = 
        command : 'reload'
        path: 'path/to/file.ext'
        liveCSS: true
      
      ws.once 'message', (data, flags) ->
        command = JSON.parse data
        command.should.have.property 'command', reload.command
        command.liveCSS.should.be.true
        command.should.have.property 'path', reload.path
        done()
      app.reloadBrowser [reload.path]
     