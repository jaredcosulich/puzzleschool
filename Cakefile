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
        'lessc src/client/css/puzzles/neurobehav.less build/client/css/puzzles/neurobehav.css'
        'lessc src/client/css/puzzles/xyflyer.less build/client/css/puzzles/xyflyer.css'

        'coffee --compile --bare --output build/server/lib src/server/lib/*.coffee'
        'coffee --compile --bare --output build/server/lib/db src/server/lib/db/*.coffee'
        'coffee --compile --bare --output build/server/api src/server/api/*.coffee'
        'coffee --compile --bare --output build/server/api src/server/api/puzzles/*.coffee'
        'coffee --compile --bare --output build/server/api/lib src/server/api/lib/*.coffee'

        'coffee --compile --bare --output build/client/pages src/client/pages/*.coffee'

        'coffee --compile --bare --output build/common/pages src/common/pages/*.coffee'
        'coffee --compile --bare --output build/common/pages/puzzles src/common/pages/puzzles/*.coffee'
        'coffee --compile --bare --output build/common/pages/puzzles/lib src/common/pages/puzzles/lib/*.coffee'
        'coffee --compile --bare --output build/common/pages/puzzles/lib/neurobehav_objects src/common/pages/puzzles/lib/neurobehav_objects/*.coffee'
        'coffee --compile --bare --output build/common/pages/puzzles/lib/xyflyer_objects src/common/pages/puzzles/lib/xyflyer_objects/*.coffee'
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

task 'build:xyflyer', 'Build the xyflyer app', ->
    execCmds [
        'cake build:site'
        'coffee --compile --bare --output apps/xyflyer/web src/apps/xyflyer/js/*.coffee'
        'cp build/common/pages/puzzles/lib/xyflyer.js apps/xyflyer/web/xyflyer.js'
        'cp build/common/pages/puzzles/lib/xyflyer_objects/* apps/xyflyer/web/objects/'
        'cp ender.js apps/xyflyer/web/ender.js'
        'cp assets/third_party/equation_explorer/tokens.js apps/xyflyer/web/token.js'
        'cp assets/third_party/raphael-min.js apps/xyflyer/web/raphael-min.js'
        'cp assets/images/puzzles/xyflyer/* apps/xyflyer/css/images/'
        'cp -r apps/xyflyer/* ~/workspace/puzzleschoolapps/xyflyer/'
    ]

    
task 'build:ender', 'Build the ender modules', ->
    execCmds [
        'ender build sel soma wings morpheus timeout'
    ]

