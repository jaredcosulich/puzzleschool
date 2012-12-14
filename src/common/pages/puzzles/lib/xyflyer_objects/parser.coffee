parser = exports ? provide('./parser', {})
tdop = require('./tdop')

parser.parse = (data) ->
    try
        parts = data.replace(/\s/g, '').split(/[{}]/)
        formula = tdop.compileToJs(parts[0])       
        area = parser.calculateArea(parts[1])   
    catch err
    return [formula, area]

parser.calculateArea = (areaString) ->
    return (-> true) if not areaString or not areaString.length
    parts = areaString.replace(/[^=0-9.<>xy-]/g, '').split(/x/)
    return (x) ->
        return false if not eval(parts[0] + 'x') 
        return false if not eval('x' + parts[1]) 
        return true
