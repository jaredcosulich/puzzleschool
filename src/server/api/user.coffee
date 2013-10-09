bcrypt = require('bcrypt')
crypto = require('crypto')
Line = require('line').Line
soma = require('soma')
wings = require('wings')

db = require('../lib/db')

{checkPassword, requireUser} = require('./lib/decorators')
{email} = require('./lib/email')

registrationTemplate = """
    {name}, 
    
    I just wanted to welcome you to the Puzzle School.
    
    We're working on a number of different projects, trying to make
    it fun and interesting to learn a variety of material.
    
    Please don't hesitate to reach out. We love hearing from people.

    Best,
        Jared
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
                
    '/api/email': ->
        return @sendError(new Error('Email was invalid')) unless @data.email and /.+@.+\..+/.test(@data.email)
        @data.email = @data.email.toLowerCase()

        l = new Line
            error: (err) => 
                console.log('Saving email failed:', err)
                @sendError()

            =>
                @cookies.set('email', @data.email, { signed: true })
                db.update 'users', 'emails', {count: {add: 1}, emails: {add: [@data.email]}}, l.wait()

            =>
                email.sendText 'The Puzzle School <support@puzzleschool.com>', 'Admin <info@puzzleschool.com>',
                    "New Puzzle School Email",
                    "#{@data.email}"
                    l.wait()

            => @send()

        

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


            => db.update 'users', 'data', {count: {add: 1}, ids: {add: [@user.id]}}, l.wait()
            
            =>
                email.sendText 'The Puzzle School <support@puzzleschool.com>', 'Admin <info@puzzleschool.com>',
                    "New Puzzle School User",
                    "#{@user.email}, #{@user.name}, #{@user.birthday}"
                    l.wait()
                    
            => @send()
