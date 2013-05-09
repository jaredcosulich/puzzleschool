operator = exports ? provide('./operator', {})
Component = require('./component').Component

class operator.Operator extends Component
    constructor: ({@value, container, drag}) ->
        super(container: container, drag: drag)
        @init()
        
        @draggable = @el
        @initDrag()
        
    init: ->    
        @el.addClass('operator')
        label = @value
        label = '&times;' if @value == '*'
        @el.html """
            <h3><span class='value'>#{@value}</span></h3>
        """

