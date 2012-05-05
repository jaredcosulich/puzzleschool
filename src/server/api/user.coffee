bcrypt = require('bcrypt')
crypto = require('crypto')
line = require('line')
soma = require('soma')
wings = require('wings')

db = require('../lib/db')

{checkPassword, requireUser} = require('./lib/decorators')

registrationTemplate = """
    {name}, 
    
    We just wanted to welcome you to Min.gl
    
    Hope you enjoy it and meet some cool people.
    
    Really that's all we wanted to say. 
    
    If you have any questions, let us know.
    
    Best,
        The Min.gl Team
"""
soma.routes
    '/api/login': checkPassword ->
        line => db.get 'users', @login.user, line.wait()
        line (@user) =>
            userCookie = @jar.get('user')
            # if userCookie possibly merge user data
            
        line => crypto.randomBytes 16, line.wait()
        line (session) => db.update 'users', @user.id, {session: session.toString('hex')}, line.wait()
        line.run (@user) =>
            @jar.set('user', JSON.stringify(@user), { signed: true, httpOnly: false })
            @send()
