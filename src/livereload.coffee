liveServer = require './server'
watch = require './watch'
program = require 'commander'
path = require 'path'

# LiveReload Server instance,  [Api Documentation](server.html)
exports.liveServer = server =  null

# Exports the watch api,  [Api Documentation](watch.html)
exports.wacthServer = watch


# Create LiveReload Server
exports.createServer = (options = {}) ->
  return server if server 
  opts = 
    apiVersion : '1.6'
    host : '0.0.0.0'
    port : '35729'
  for key,value of opts
      opts[key] = options[value] if options[key]
  
  server = new liveServer opts

# Watch directory or file, the `callback` argument is a function with `EventEmitter` instance.
# See [Watch Api Documentation](watch.html)
exports.watch = (options = {}, callback = ->) ->
  watch.watch options.path, options, (event) ->
    event.on 'error', (error) ->
      callback error
    event.on 'change', (file) ->
      callback file

# Stop the LiveReload Server  
exports.stop = ->
  server.stop() if server

# Process command-line arguments
exports.cli = (argv)->  
  list = (val) ->
    val.split ','   
  program
    .version('0.1.0')
    .option('-p, --path [path]', 'Watch path. Default is current directory', String)
    .option('-e, --exts [items]', 'File extentions list split by comma', list)
    .option('-i, --ignore [items], Ignore expression list split by comma ', list)
    .parse argv
  
  if not program.exts
    program.exts = watch.extentions
  else    
    program.exts = program.exts.concat watch.extentions
    
  if not options.path
    options.path = process.cwd()
  else
    options.path = path.resolve process.cwd(), options.path
      
  if progarm.ignore
    ignores = progarm.ignore
    progarm.ignore = (file)->
      for key, val in ignores
        if new RegExp(val).test file
          return true
      false
           
  exports.createServer()
  exports.watch program, (file) ->
    server.reloadBrowser [file] if server