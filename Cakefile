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

        'cd build'
        'npm install'
        'cd -'
    ]

task 'build:local', 'Build all local code', ->
    execCmds [
        'coffee --compile --bare --output build/server src/server/*.coffee'
        'coffee --compile --bare --output build/server/lib src/server/lib/*.coffee'
        'coffee --compile --bare --output build/server/lib/db src/server/lib/db/*.coffee'
        'coffee --compile --bare --output build/server/api src/server/api/*.coffee'

        'ln -sf ../src/server/favicon.ico build/server'
        'ln -sf ../src/package.json build'
    ]
        