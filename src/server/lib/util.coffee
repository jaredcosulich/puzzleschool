
exports.combineChunks = (chunks) ->
    size = 0
    for chunk in chunks
        size += chunk.length

    # Create the buffer for the file data
    result = new Buffer(size)

    size = 0
    for chunk in chunks
        chunk.copy(result, size, 0)
        size += chunk.length

    return result


Array.prototype.unique = ->
    o = {}
    l = @length
    r = []
    o[@[i]] = @[i] for i in [0...l]
    r.push(o[i]) for i of o 
    return r

Array.prototype.shuffle = ->
    top = @length
    return @ if not top

    while(top--) 
        current = Math.floor(Math.random() * (top + 1))
        tmp = @[current]
        @[current] = @[top]
        @[top] = tmp
