liveServer = require './server'
watch = require './watch'
program = require 'commander'

# LiveReload Server instance,  [Api Documentation](http://mashihua.github.com/node-livereload/docs/server.html)
server = null

# Exports the watch api,  [Api Documentation](http://mashihua.github.com/node-livereload/docs/watch.html)
exports.wacth = watch


# Create LiveReload Server
exports.createServer = (options) ->
  return server if server 
  opts = 
    apiVersion : '1.6'
    host : '0.0.0.0'
    port : '35729'
  for key,value of options
    opts[key] = value
  server = new liveServer opts
  options.path = process.cwd() if not options.path
  
  watch.watch options.path, options, (event) ->
    event.on 'error', (error) ->
      console.log error
    event.on 'change', (file) ->
      sever.reloadBrowser [file] if server
  server  

# Stop the LiveReload Server  
exports.stop = ->
  server.stop() if server

# process command-line arguments
exports.cli = (argv)->
  
  list = (val) ->
    val.split ','
   
  program
    .version('0.1.0')
    .option('-p, --path [path]', 'Watch path. Default is current directory', String)
    .option('-e, --exts [items]', 'File extentions list split by comma', list)
    .parse argv
  if not program.exts
    program.exts = watch.extentions
  else    
    program.exts = program.exts.concat watch.extentions

  exports.createServer program