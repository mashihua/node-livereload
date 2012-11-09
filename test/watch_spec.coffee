{watch} = require './../src/watch'
fs = require 'fs'

describe 'Watch', ->
  
  created = false
  changed = false
  deleted = false
  fs.mkdirSync 'tmp'
    
  process.on 'exit', ->
    fs.rmdirSync 'tmp'
  ignores = ['.txt']
  event = watch 'tmp', ignore = (file)->
      for key, val in ignores
        if new RegExp(val).test file
          return true
      false
      
  event.on 'error', (error) ->
    console.log error
  event.on 'delete', (file) ->
    deleted = true
  event.on 'change', (file) ->
    changed = true
  event.on 'create', (file) ->
    created = true
      
  describe 'File watch event', ->
    # For fs.watch interval is set to 5007, 
    # we set interval is 6000 to be sure recive event
    interval = 6000
    it 'Should recive create event', (done)->
      fd = fs.openSync 'tmp/index.html', 'w'
      setTimeout ->
        done() if created
        created = false
      ,interval
    
    it 'Should not recive create event', (done)->
      fd = fs.openSync 'tmp/index.txt', 'w'
      setTimeout ->
        done() if not created
        fs.unlinkSync 'tmp/index.txt'
      ,interval
        
    it 'Should recive change event', (done)->
      fs.writeFileSync 'tmp/index.html', '<html><head></head><body></body>'
      setTimeout ->
        done() if changed
      ,interval

    it 'Should recive delete event', (done)->
      fs.unlinkSync 'tmp/index.html'
      setTimeout ->
        done() if deleted 
      ,interval