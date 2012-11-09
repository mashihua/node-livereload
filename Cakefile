fs            = require 'fs'
path          = require 'path'
{print}       = require 'util'
{spawn, exec} = require 'child_process'

shell = (cmd, args, cb)->
  process.env.PATH = "./node_modules/.bin:#{process.env.PATH}"
  proc = spawn cmd, args, 
          cwd : process.cwd()
          env : process.env
  proc.stderr.on 'data', (buffer) -> console.log buffer.toString()
  proc.stdout.on 'data', (data) -> print data.toString()
  proc.stderr.on 'data', (data) -> print data.toString()
  proc.on 'exit', (code) -> cb?() if code is 0
  
build = (watch, cb) ->
  if typeof watch is 'function'
    callback = watch
    watch = false
  options = ['-c', '-o', 'lib', 'src']
  options.unshift '-w' if watch
  shell 'coffee', options
  
task 'build', 'Compile the Coffee source', ->
  build()

task 'watch', 'Recompile CoffeeScript source files when modified', ->
  build true

task 'docs', 'Generate annotated source code with Docco', ->
  files = fs.readdirSync 'src'
  files = ("src/#{file}" for file in files when file.match /\.coffee$/ )
  shell 'docco', files 
        
task 'test', 'Run test suite', ->
  files = fs.readdirSync 'test'
  files = ("test/#{file}" for file in files when file.match /\.coffee$/ )
  shell 'mocha', files

task 'livereload.js', 'Update livereload.js', ->
  process.chdir 'vandor/livereload-js' 
  shell 'git', ['pull', 'origin', 'master']
  read = fs.createReadStream 'dist/livereload.js', {encoding:'utf8'}
  write = fs.createWriteStream './../../lib/livereload/livereload.js', {encoding:'utf8'}
  read.pipe write
  