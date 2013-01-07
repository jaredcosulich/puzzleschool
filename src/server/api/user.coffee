bcrypt = require('bcrypt')
crypto = require('crypto')
Line = require('line').Line
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
        l = new Line
            error: (err) => 
                console.log('Login failed:', err)
                @sendError()
        
            => db.get 'users', @login.user, l.wait()
            
        #    (@user) =>
        #       userCookie = @cookies.get('user')
        #       if userCookie possibly merge user data
            
        #    => crypto.randomBytes 16, l.wait()
        #    (session) => db.update 'users', @user.id, {session: session.toString('hex')}, l.wait()
            
            (@user) =>
                @cookies.set('user', @user, { signed: true })
                @send()

    '/api/register': ->
        return @sendError(new Error('Name was invalid')) unless @data.name and /\S{3,}/.test(@data.name)
        return @sendError(new Error('Email was invalid')) unless @data.email and /.+@.+\..+/.test(@data.email)
        return @sendError(new Error('Password was invalid')) unless @data.password and /\S{3,}/.test(@data.password)
        return @sendError(new Error('Birthday was invalid')) unless @data.year and isFinite(@data.year)

        @data.birthday = "#{@data.year}-#{@data.month}-#{@data.day}"
        @data.year = parseInt(@data.year)
        @data.month = parseInt(@data.month or -1)
        @data.day = parseInt(@data.day or -1)
        @data.email = @data.email.toLowerCase()

        l = new Line
            error: (err) => 
                console.log('Registration failed:', err)
                @sendError()
        
            => 
                db.get 'login', @data.email, l.wait (login) =>
                return l.fail('duplicate login') if login?

            => bcrypt.genSalt l.wait()
            
            (salt) => bcrypt.hash @data.password, salt, l.wait()

            (hash) =>
                @data.password = hash
                crypto.randomBytes 16, l.wait()

            (session) =>
                user = {id: @data.email, session: session.toString('hex')}
                user[key] = @data[key] for key in ['name', 'email', 'birthday', 'month', 'day', 'year']
                db.put 'users', user, l.wait()

            (@user) =>
                @cookies.set('user', @user, { signed: true })
                db.put 'login', { id: @data.email, password: @data.password, user: @user.id }, l.wait()

        # line => 
        #     @email.send 'The Puzzle School <support@puzzleschool.com>', @data.email,
        #         "#{@user.name}, Welcome",
        #         wings.renderTemplate(registrationTemplate, @user),
        #         l.wait()

            => @send()
