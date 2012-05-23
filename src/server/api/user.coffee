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
            userCookie = @cookies.get('user')
            # if userCookie possibly merge user data
            
        line => crypto.randomBytes 16, line.wait()
        line (session) => db.update 'users', @user.id, {session: session.toString('hex')}, line.wait()
        line.run (@user) =>
            @cookies.set('user', @user, { signed: true })
            @send()

    '/api/register': ->
        return @sendError(new Error('Name was invalid')) unless @data.name and /\S{3,}/.test(@data.name)
        return @sendError(new Error('Email was invalid')) unless @data.email and /.+@.+\..+/.test(@data.email)
        return @sendError(new Error('Password was invalid')) unless @data.password and /\S{3,}/.test(@data.password)
        return @sendError(new Error('Birthday was invalid')) unless @data.year and @data.month and @data.day and isFinite(@data.year) and isFinite(@data.month) and isFinite(@data.day)

        @data.birthday = "#{@data.year}-#{@data.month}-#{@data.day}"
        @data.year = parseInt(@data.year)
        @data.month = parseInt(@data.month)
        @data.day = parseInt(@data.day)
        @data.email = @data.email.toLowerCase()

        line =>
            db.get 'login', @data.email, line.wait (login) =>
                return line.fail('duplicate login') if login?

        line => bcrypt.genSalt line.wait()
        line (salt) => bcrypt.hash @data.password, salt, line.wait()

        line (hash) =>
            @data.password = hash
            crypto.randomBytes 16, line.wait()

        line (session) =>
            user = {id: @data.email, session: session.toString('hex')}
            user[key] = @data[key] for key in ['name', 'email', 'birthday', 'month', 'day', 'year']
            db.put 'users', user, line.wait()

        line (@user) =>
            @cookies.set('user', @user, { signed: true })
            db.put 'login', { id: @data.email, password: @data.password, user: @user.id }, line.wait()

        # line => 
        #     @email.send 'The Puzzle School <support@puzzleschool.com>', @data.email,
        #         "#{@user.name}, Welcome",
        #         wings.renderTemplate(registrationTemplate, @user),
        #         line.wait()

        line.error (err) => @sendError(err, 'Registration failed')

        line.run => @send()
