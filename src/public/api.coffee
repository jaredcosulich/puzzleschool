(($) ->
    PuzzleSchool = provide('PuzzleSchool', {})
    
    PuzzleSchool.post = ({url, data, success}) =>
        $.ajax
            url: "http://puzzleschoollocal.com:5000/#{url}"
            method: 'POST'
            data: data
            success: success
    
)(ender)