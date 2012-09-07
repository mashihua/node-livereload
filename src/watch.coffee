# Watch file or directory, Example:
# 	watch = require('watch').watch
# 	watch __filename
# 	watch __dirname, (event) -> event.on 'change', (file) -> console.log file
# 	event = watch __dirname, {exts: ['coffee']}
# 	event.on 'delete', (file) ->
# 	  console.log "Delete #{file}"
# 	event.on 'change', (file) ->
# 	  {spawn} = require 'child_process'
# 	  coffee = spawn 'coffee', ['-c', '-o', 'lib', file]
# 	  (item.on 'data',(data) -> console.log data) for item in [coffee.stdout,coffee.stderr]

fs        = require 'fs'
util      = require 'util'
path      = require 'path'
events    = require 'events'
map       = {}

# Default file extentions
exports.extentions = [
  'html', 'htm', 'css', 'js', 'png', 'gif', 'jpg',
  'php', 'php5', 'py', 'rb', 'erb'
]
# ## API
# Watch directory or file, the `callback` argument is a function with `EventEmitter` instance.
# ---
# The `options` have following property
# * `exts` , File extentions, Defalut is `exports.extentions`
# * `ignore` , Ignore function which exclusions this file or directory
# * `callback` , Callback function gets one arguments `(file)`
# ---
# The `EventEmitter` have following event
# * `error` , If `fs` api emits an 'error' event - it will forwarded here
# * `create`, If file or directory was created
# * `change`, If file or directory was changed
# * `delete`, If file or directory was delete

exports.watch = (dir_name, options, callback) ->
  # Who is not given callback
  if not callback
    callback ?= options ? ()->
    options =  {}
  # File extention
  options.exts ?=  exports.extentions 
  # Ignore method
  if not options.ignore
    options.ignore = (file) ->
      return /^\./.test file
      
  em =  new events.EventEmitter();
  monitor = (err, file, event) ->
    if err
      em.emit 'error', err
    else 
      em.emit event, file
  # For compatible purpose:
  # Node.js 0.8 start move path.exists to fs.exists.
  # See[change log](https://github.com/joyent/node/wiki/API-changes-between-v0.6-and-v0.8).
  existsFuc = if fs.existsSync then fs.existsSync else path.existsSync
  if not existsFuc #{dir_name}
    console.log "#{dir_name} is not exists"
    return
  watch dir_name, options, monitor
  console.log "Start watch #{dir_name}"
  callback em
  em
  
# Match file extention with given extentions
match = (file, extentions) ->
  extentions.some (ele, index, array) ->
    file[file.length - ele.length..] is ele
    
# Watch files in a directory and recursive the sub directory 
watchFiles = (dir, files, options, callback) ->
  for filename in files when not options.ignore filename
    do (filename) ->
      # The file or directory
      file = "#{dir}/#{filename}"
      fs.stat file, (err, stats)->
        if err
          callback err if err.code isnt 'ENOENT'
        else
          # Recursive this directory
          if stats.isDirectory()
            watchDir file, options, callback
            return
          # Match the file extentions
          else if stats.isFile() && match file, options.exts
            # Watch this file
            fs.watchFile file, (curr, prev) ->
              # Delete file event
              if curr.nlink is 0
                callback null, file, 'delete'
                fs.unwatchFile file
                return
              # Does not changed
              return if curr.nlink isnt 0 and curr.mtime.getTime() is prev.mtime.getTime()
              # Change file event
              callback null, file, 'change'

# Watch the directory
watchDir = (dir, options, callback) ->
  
  walk = ->
    # Reads the contents of a directory.
    fs.readdir dir, (err, files) ->
      return callback err if err
      #Insert to a map
      if not map[dir]
        map[dir] = files
      else
        newFiles = files.filter ( file )->
          if file not in map[dir] and match file, options.exts
            # New file event
            callback null, file, 'create'
            file
        map[dir] = files
        files = newFiles ? []
      # Watch this directory
      watchFiles dir, files, options, callback
  
  # Watch this directory
  fs.watchFile dir, (curr, prev) ->
    # Delete directory event
    if curr.nlink is 0
      callback null, dir, 'delete'
      fs.unwatchFile dir
    # Rewatch this directory
    walk() if curr.size >  prev.size
  
  walk()

watch = (dir_name, options, callback) ->
  # Directory status
  fs.stat dir_name, (err, stats) ->
    if err 
      util.error "Error for reading #{dir_name}"
      callback err
    else
      # Watch the directory
      if stats.isDirectory()
        watchDir dir_name, options, callback
      # Watch the file if file given
      else if stats.isFile()
        watchFiles (path.dirname dir_name), [dir_name], options, callback
