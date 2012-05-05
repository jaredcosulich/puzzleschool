fs = require('fs')
{spawn, exec} = require('child_process')

execCmds = (cmds) ->
    exec cmds.join(' && '), (err, stdout, stderr) ->
        output = (stdout + stderr).trim()
        console.log(output + '\n') if (output)
        throw err if err

task 'build', 'Compile to JS', ->
    execCmds [
        'rm -rf node_modules'
        'npm install'
        'cake build:site'
        'cake build:ender'
    ]

task 'build:site', 'Build the site files', ->
    execCmds [
        'rm -rf build'
        
        'mkdir -p build/client/css'
        'lessc src/client/css/all.less build/client/css/all.css'

        'coffee --compile --bare --output build/server/lib src/server/lib/*.coffee'
        'coffee --compile --bare --output build/server/lib/db src/server/lib/db/*.coffee'
        'coffee --compile --bare --output build/server/api src/server/api/*.coffee'
        'coffee --compile --bare --output build/server/api/lib src/server/api/lib/*.coffee'

        'coffee --compile --bare --output build/client/pages src/client/pages/*.coffee'
        'cp -r src/client/templates build/client'
    ]
    
task 'build:ender', 'Build the ender modules', ->
    execCmds [
        'ender build sel ../soma wings'
    ]

