bcrypt = require('bcrypt')
crypto = require('crypto')
Line = require('line').Line

db = require('../../lib/db')

exports.checkPassword = (fn) ->->
    args = Array.prototype.slice.call(arguments)
    @data.email = @user.email if @user and not @data.email

    return @sendError() unless @data.email and /.+@.+\..+/.test(@data.email)
    return @sendError() unless @data.password and /\S{3,}/.test(@data.password)

    l = new Line
        error: (err) => 
            console.log('checkPassword failed:', err)
            @sendError()
            
        => db.get 'login', @data.email.toLowerCase(), l.wait()

        (@login) => 
            return line.fail('Login failed, email not on record.') if not @login
            bcrypt.compare @data.password, @login.password, l.wait()
        
        (result) => return l.fail('Login failed, invalid password') if not result

        => fn.apply(this, args)


exports.requireUser = (fn) ->->
    args = Array.prototype.slice.call(arguments)
    userCookie = @cookies.get('user', { signed: true })
    
    return @go('/') unless userCookie

    l = new Line
        error: (err) => 
            console.log('checkUser failed:', err)
            @sendError()
            
        => db.get 'users', userCookie.id, l.wait()
    
        (@user) =>
            if !@user or @user.session != userCookie.session
                @cookies.set('user', null)
                @go('/')
            
            else
                @cookies.set('user', @user, { signed: true })
                fn.apply(this, args)
