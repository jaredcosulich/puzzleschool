fs = require('fs')
{spawn, exec} = require('child_process')

execCmds = (cmds) ->
    exec cmds.join(' && '), (err, stdout, stderr) ->
        output = (stdout + stderr).trim()
        console.log(output + '\n') if (output)
        throw err if err

task 'build', 'Build project', ->
    execCmds [
        'npm install'
        'cake build:site'
    ]

task 'build:site', 'Build all local code', ->
    execCmds [
        'coffee --compile --bare --output client/views/js src/client/views/js/*.coffee'
        'coffee --compile --bare --output server src/server/*.coffee'
        'coffee --compile --bare --output server/lib src/server/lib/*.coffee'
        'coffee --compile --bare --output server/lib/db src/server/lib/db/*.coffee'
        'coffee --compile --bare --output server/api src/server/api/*.coffee'
        
        'cake build:site_html'
    ]
        
task 'build:site_html', ->
    source = 'src'

    execCmds [
        "cp -r #{source}/client/views/html client/views/",
        "cp -r #{source}/client/css/images client/css/",
    ]
    
    stylesheets = ("/css/#{sheet}.css" for sheet in ['all'])
    scripts = ("/views/js/#{script}.js" for script in ['base', 'page'])

    wings = require("./node_modules/wings/lib/wings.js")
    site = wings.renderTemplate(fs.readFileSync("#{source}/client/views/html/site.html", 'utf-8'), {
            favicon: "/css/images/favicon.png",
            stylesheets: stylesheets,
            scripts: scripts
    })

    fs.writeFileSync("client/views/html/site.html", site)

    