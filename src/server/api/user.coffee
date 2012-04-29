bcrypt = require('bcrypt')
crypto = require('crypto')
line = require('line')

db = require('../lib/db')
router = require('../lib/router')

router.add
    '/api/user': ->
        line => db.get 'users', @data.email, line.wait()
        line.error (err) => @sendError(err, 'Can\'t find user')
        line.run (@user) => @send(@user)
    
    '/api/register': ->
        line => 
            db.get 'users', @data.email, line.wait (user) =>
                if user.email
                    return line.fail('duplicate user')

        line => 
            @data.id = @data.email
            db.put 'users', @data, line.wait() 
                       
        line (@user) => @cookies.set('user', JSON.stringify(@user), { signed: true, httpOnly: false })
        line.error (err) => @sendError(err, 'Registration failed')
        line.run => @send()
     
     '/api/update': ->
        line => db.update 'users', @data.email, @data, line.wait()
        line.error (err) => @sendError(err, 'Updated failed')
        line.run => @send()