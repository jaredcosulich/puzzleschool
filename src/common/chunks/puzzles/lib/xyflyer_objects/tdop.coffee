tdop = exports ? provide('./tdop', {})

tdop.makeParse = ->
    symbolTable = {}
    [token, tokens, tokenNr] = [null, null, null]

    originalSymbol = 
        nud: -> error('Undefined.', this)
        led: (left) -> error('Missing operator.', this)

    symbol = (id, bp) ->
        s = symbolTable[id]
        bp or= 0
        if (s) 
            s.lbp = bp if (bp >= s.lbp)
        else 
            s = Object.create(originalSymbol)
            s.id = s.value = id
            s.lbp = bp
            symbolTable[id] = s
    
        return s


    symbol('(end)')

    juxMult = (left) ->
        value: '*'
        arity: 'binary'
        first: left
        second: expression(60, @)

    itself = -> @

    symbol('(name)', 58).nud = itself
    symbol('(name)').led = juxMult

    symbol('(literal)', 60).nud = itself
    symbol('(literal)').led = juxMult

    advance = (id) -> 
        if (id and token.id != id) 
            error("Expected '" + id + "'.", token)
    
        if (tokenNr >= tokens.length) 
            token = symbolTable["(end)"]
            return
    
        t = tokens[tokenNr]
        tokenNr += 1
        v = t.value
        a = t.type
        if (a == "name") 
            o = symbolTable["(name)"]
         else if (a == "operator") 
            o = symbolTable[v]
            if (!o) 
                error("Unknown operator.", t)
        
         else if (a == "number") 
            a = "literal"
            o = symbolTable["(literal)"]
         else 
            error("Unexpected token.", t)
    
        token = Object.create(o)
        token.value = v
        token.arity = a
        return token


    expression = (rbp, first) ->
        if (first)
            left=first.nud()
        else
            t = token
            advance()
            left = t.nud()
   	
        while (rbp < token.lbp) 
            t = token
            advance()
            left = t.led(left)
    
        return left


    infix = (id, bp, led) ->
        s = symbol(id, bp)
        s.led = led or (left) ->
            this.first = left
            this.second = expression(bp)
            this.arity = "binary"
            return this

        return s


    infix("+", 50)
    infix("-", 50)
    infix("*", 60)
    infix("/", 60)
    infix("^", 70)

    infix("=", 40)
    #infix("<", 40)
    #infix("<=", 40)
    #infix(">", 40)
    #infix(">=", 40)

    symbol('(').nud = ->
        e = expression(0)
        advance(')')
        return e


    symbol('(', 61).led = (left) ->
        e = expression(0)
        advance(')')
        if (fns[left.value])
            left.arity='function'
            left.arg=e
            return left
        else 
            return {
                value: '*'
                arity: 'binary'
                first: left
                second: e
            }

    symbol(')')

    symbol('-').nud = ->
        return {
            value: '-'
            arity: 'binary'
            first: 
                value: 0
                arity: 'literal'
            second: expression(65)
        }

    return (source) -> 
        tokens = source.tokens('=<>/+-*%^()xym')
        tokenNr = 0
        advance()
        s = expression(0)
        advance('(end)')
        return s
    
tdop.toSexp = (v) ->
    if (v.arity=='literal' || v.arity=='number' || v.arity=='name') 
        return v.value        
    else if (v.arity=='binary') 
        return '('+v.value+' '+tdop.toSexp(v.first)+' '+tdop.toSexp(v.second)+')'
    else if (v.arity=='function')
        return '('+v.value+' '+tdop.toSexp(v.arg)+')'

tdop.toJs = (exp, boundVars, freeVars, fns) ->
    expToJs = (v) ->
        return v.value if (v.arity=='literal' or v.arity=='number') 
            
        if (v.arity=='name') 
            return v.value if (boundVars.indexOf(v.value)!=-1) 
            
            if (freeVars[v.value] != undefined) 
                return freeVars[v.value]
            else error('Undefined variable or constant', v)
        
        else if (v.arity=='binary')
            if (v.value=='^') 
                return 'Math.pow('+expToJs(v.first)+','+expToJs(v.second)+')'
            else 
                return '('+expToJs(v.first)+' '+v.value+' '+expToJs(v.second)+')'
        
        else if (v.arity=='function')
            if (fns[v.value])
                return fns[v.value]+'('+' '+expToJs(v.arg)+')'
            else error('Undefined function: '+v.value, v)
    
    return expToJs(exp)
    
fns = 
    'sin':'Math.sin'
    'cos':'Math.cos'
    'tan':'Math.tan'
    'round':'Math.round'
    'sqrt':'Math.sqrt'
    'abs':'Math.abs'
    'ln':'Math.log'
    'atan': 'Math.atan'
    'acos': 'Math.acos'
    'asin': 'Math.asin'

constants = 
    'pi':'Math.PI'
    'e':'Math.E'

parse = tdop.makeParse()

tdop.compileToJsInequality = (equation, m) ->
    c = Object.create(constants)
    c.m = m
    parts = equation.split('=')
    if (parts.length==1) 
        eval(
            'function f(x, y){ return (y<' +
            tdop.toJs(parse(parts[0]), ['x', 'y'], c, fns) +
            ')}'
        )

    else eval(
        'function f(x, y){ return (' +
        tdop.toJs(parse(parts[0]), ['x', 'y'], c, fns) + 
        '<' +
        tdop.toJs(parse(parts[1]), ['x', 'y'], c, fns) +
        ')}'
    )
        
    return f

tdop.compileToJs = (equation, m) ->
    c = Object.create(constants)
    c.m = m
    parts = equation.split('=')
    if (parts.length==1) 
        eval(
            'function f(x){ return (' +
            tdop.toJs(parse(parts[0]), ['x', 'y'], c, fns) +
            ')}'
        )

    else eval(
        'function f(x){ return (' +
        tdop.toJs(parse(parts[1]), ['x', 'y'], c, fns) +
        ')}'
    )

    return f

