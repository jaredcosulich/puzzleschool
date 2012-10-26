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
        'mkdir -p build/client/css/puzzles'
        'lessc src/client/css/all.less build/client/css/all.css'
        'lessc src/client/css/puzzles/language_scramble.less build/client/css/puzzles/language_scramble.css'
        'lessc src/client/css/puzzles/space_fractions.less build/client/css/puzzles/space_fractions.css'

        'coffee --compile --bare --output build/server/lib src/server/lib/*.coffee'
        'coffee --compile --bare --output build/server/lib/db src/server/lib/db/*.coffee'
        'coffee --compile --bare --output build/server/api src/server/api/*.coffee'
        'coffee --compile --bare --output build/server/api src/server/api/puzzles/*.coffee'
        'coffee --compile --bare --output build/server/api/lib src/server/api/lib/*.coffee'

        'coffee --compile --bare --output build/client/pages src/client/pages/*.coffee'

        'coffee --compile --bare --output build/common/pages src/common/pages/*.coffee'
        'coffee --compile --bare --output build/common/pages/puzzles src/common/pages/puzzles/*.coffee'
        'coffee --compile --bare --output build/common/pages/puzzles/lib src/common/pages/puzzles/lib/*.coffee'
        'cp -r src/common/templates build/common'
    ]

task 'build:language_scramble', 'Build the language scramble app', ->
    execCmds [
        'cake build:site'
        'coffee --compile --bare --output apps/language_scramble/web src/apps/language_scramble/js/*.coffee'
        'cp build/common/pages/puzzles/lib/language_scramble.js apps/language_scramble/web/language_scramble.js'
        'cp ender.js apps/language_scramble/web/ender.js'
        'cp -r apps/language_scramble/* ~/workspace/puzzleschoolapps/languagescramble/'
    ]

    
task 'build:ender', 'Build the ender modules', ->
    execCmds [
        'ender build sel soma wings morpheus timeout'
    ]

