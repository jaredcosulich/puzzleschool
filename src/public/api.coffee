(($) ->
    PuzzleSchool = provide('PuzzleSchool', {})
    
    PuzzleSchool.post = ({url, data, success}) =>
        $.ajax
            url: "http://api.puzzleschool.com/#{url}"
            method: 'POST'
            data: data
            success: success
    
)(ender)