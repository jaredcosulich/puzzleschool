ohmsLawWorksheet = exports ? provide('./ohms_law_worksheet', {})
circuitousObject = require('./object')

class ohmsLawWorksheet.OhmsLawWorksheet extends circuitousObject.Object
    nodes: [
        {x: 0, y: 0}
    ]
    
    centerOffset: 
        x: -16
        y: 64
    
    constructor: ({@recordChange}) ->

    initTag: ->
        
    initCurrent: ->
        @worksheet = $(document.createElement('DIV'))
        @worksheet.css
            backgroundColor: 'white'
            border: '2px solid grey'
            textAlign: 'center'
            padding: '24px 0'
            width: 507
            height: 490
            
        @worksheet.html '''
            <h2>Ohm\'s Law</h2>
            <p>
                Try to figure out Ohm\'s Law and fill in the missing values:
            </p>
            <div>
                Volts (V) = power &nbsp; &nbsp; &nbsp; &nbsp; &nbsp; 
                Ohms (Ω) = resistance &nbsp; &nbsp; &nbsp; &nbsp; &nbsp; &nbsp;
                Amps (A) = current
            </div>
            <table style='width: 80%; font-size: 18px; margin: 12px auto 0 auto'>
                <tbody>
                    <th>Volts (V)</th>
                    <th>Ohms (Ω)</th>
                    <th>Amps (A)</th>
                    <tr class='odd'><td>6 V</td><td>5 Ω</td><td>1.2 A</td></tr>
                    <tr><td>6 V</td><td>10 Ω</td><td>0.6 A</td></tr>
                    <tr class='odd'><td>6 V</td><td>20 Ω</td><td>0.3 A</td></tr>
                    <tr><td>12 V</td><td>5 Ω</td><td>2.4 A</td></tr>
                    <tr class='odd'><td>12 V</td><td>10 Ω</td><td>1.2 A</td></tr>
                    <tr><td>12 V</td><td>20 Ω</td><td>0.6 A</td></tr>
                    <tr class='odd'><td>10 V</td><td>20 Ω</td><td><input class='missing_amps'/> A</td></tr>
                    <tr><td><input class='missing_volts'/> V</td><td>5 Ω</td><td>0.8 A</td></tr>
                    <tr class='odd'><td>12 V</td><td><input class='missing_ohms'/> Ω</td><td>4 A</td></tr>
                </tbody>
            </table>
        '''
        @el.append(@worksheet)
        $.timeout 100, =>
            @worksheet.find('input').css(width: 42, fontSize: 18) 
            @worksheet.find('td').css(padding: '6px 0') 
            @worksheet.find('.odd').css(backgroundColor: '#ccc')
            
            @worksheet.find('input').bind 'click', (e) -> e.currentTarget.focus() 
                
            @worksheet.find('input').bind 'keyup', (e) =>  
                @checkAnswers
                    'missing_amps': 0.5
                    'missing_volts': 4
                    'missing_ohms': 3                
        
    checkAnswers: (answers) ->
        allCorrect = true
        for inputElement in @worksheet.find('input')
            input = $(inputElement)
            correct = parseFloat(input.val()) == answers[input[0].className]
            allCorrect = false unless correct
            if not input.val().length
                input.css(backgroundColor: null) 
            else
                input.css(backgroundColor: (if correct then 'green' else 'red'))
          
        @setCurrent('infinite', true) if allCorrect        
                
    setCurrent: (current, force) -> 
        if force
            @current = current
            @recordChange()
        
