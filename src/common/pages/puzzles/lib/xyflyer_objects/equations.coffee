equations = exports ? provide('./equations', {})
EquationComponent = require('./equation_component').EquationComponent

class equations.Equations
    constructor: ({@el, submit}) ->
        @possibleFragments = @$('.possible_fragments')
        @$('.launch').bind 'click', => submit()

    $: (selector) -> $(selector, @el)

    addEquationComponent: (equationFragment, equationAreas) ->
        equationComponent = new EquationComponent
            equationFragment: equationFragment
            equationAreas: equationAreas

        @possibleFragments.append(equationComponent.asHtml())
        