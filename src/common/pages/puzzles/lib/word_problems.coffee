wordProblems = exports ? provide('./lib/word_problems', {})

class wordProblems.ViewHelper    
    constructor: ({}) ->
        
    $: (selector) -> @el.find(selector)    
        
   