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
        'cake build:ender'
        'cake build:site'
    ]

task 'build:site', 'Build all local code', ->
    execCmds [
        'coffee --compile --bare --output client src/client/*.coffee'
        'coffee --compile --bare --output client/views/js src/client/views/js/*.coffee'
        'coffee --compile --bare --output server src/server/*.coffee'
        'coffee --compile --bare --output server/lib src/server/lib/*.coffee'
        'coffee --compile --bare --output server/lib/db src/server/lib/db/*.coffee'
        'coffee --compile --bare --output server/api src/server/api/*.coffee'
        
        'lessc src/client/css/site.less client/css/site.css'
        
        'cake build:site_html'
    ]
        
task 'build:site_html', ->
    source = 'src'

    execCmds [
        "cp -r #{source}/client/lib client/",
        "cp -r #{source}/client/views/html client/views/",
        "cp -r #{source}/client/css/images client/css/",
    ]
    
    stylesheets = ("/css/#{sheet}.css" for sheet in ['site'])
    stylesheets.push('http://fonts.googleapis.com/css?family=PT+Sans:400,700')
    
    views = ("views/js/#{name.replace('.coffee', '.js')}" for name in fs.readdirSync("#{source}/client/views/js") when name not in ['base.coffee', 'page.coffee'])
    views = ['views/js/base.js', 'views/js/page.js'].concat(views)

    scripts = [
        'lib/ender.js'
        views...
        'init.js'
    ]

    wings = require("./node_modules/wings/lib/wings.js")
    site = wings.renderTemplate(fs.readFileSync("#{source}/client/views/html/site.html", 'utf-8'), {
            favicon: "/css/images/favicon.png",
            stylesheets: stylesheets,
            scripts: scripts
    })

    fs.writeFileSync("client/index.html", site)

task 'build:ender', ->
    execCmds [
        'cd src/client/lib'

        'rm -rf node_modules',
        
        'npm install --dev',
        'npm install https://github.com/amccollum/bonzo/tarball/master',

        ['ender', 'build',
         'es5-basic', 'domready', 'sel', 'bonzo', 'bean',
         'morpheus', 'reqwest', 'hashchange', 'route',
         'timeout', 'upload', 'wings', 'jar', 'ender-json'].join(' '),

        'cd -'
    ]
    
    