fs = require('fs')
{spawn, exec} = require('child_process')

execCmds = (cmds) ->
    exec cmds.join(' && '), (err, stdout, stderr) ->
        output = (stdout + stderr).trim()
        console.log(output + '\n') if (output)
        throw err if err

task 'build', 'Build project', ->
    execCmds [
        'cake build:local'
        'npm install'
    ]

task 'build:local', 'Build all local code', ->
    execCmds [
        'coffee --compile --bare --output public src/public/*.coffee'
        'coffee --compile --bare --output server src/server/*.coffee'
        'coffee --compile --bare --output server/lib src/server/lib/*.coffee'
        'coffee --compile --bare --output server/lib/db src/server/lib/db/*.coffee'
        'coffee --compile --bare --output server/api src/server/api/*.coffee'
    ]
        