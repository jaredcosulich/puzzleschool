bcrypt = require('bcrypt')
crypto = require('crypto')
line = require('line')

db = require('../../lib/db')

exports.checkPassword = (fn) ->->
    args = Array.prototype.slice.call(arguments)
    if @user and not @data.email
        @data.email = @user.email

    return @sendError() unless @data.email and /.+@.+\..+/.test(@data.email)
    return @sendError() unless @data.password and /\S{3,}/.test(@data.password)
    
    line => db.get 'login', @data.email, line.wait()
    line (@login) =>
        if not @login.id
            return line.fail()

        bcrypt.compare @data.password, @login.password, line.wait()
        
    line (result) =>
        if not result
            return line.fail()

    line.error => @sendError()
    line.run => fn.apply(this, args)


exports.requireUser = (fn) ->->
    args = Array.prototype.slice.call(arguments)
    userCookie = @cookies.get('user', { signed: true })
    
    return @go('/') unless userCookie

    line => db.get 'users', userCookie.id, line.wait()
    
    line (@user) =>
        if @user.session != userCookie.session
            @cookies.set('user', null)
            @go('/')
            
        else
            @cookies.set('user', @user, { signed: true })
            fn.apply(this, args)
    
    line.error (err) => throw err

    line.run()