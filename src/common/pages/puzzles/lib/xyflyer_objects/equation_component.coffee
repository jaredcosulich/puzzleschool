equationComponent = exports ? provide('./equation_component', {})

class equationComponent.EquationComponent
    
    constructor: ({@equationFragment, @equationAreas}) ->
        @equationAreas or= []
        
    asHtml: ->
        """
        <div class='equation_component #{@equationAreas.join(' ')}'>#{@equationFragment}</div>
        """