xyflyerEditor = exports ? provide('./lib/xyflyer_editor', {})

class xyflyerEditor.EditorHelper
    constructor: ({@el, @viewHelper, encodeMethod}) ->
        
    $: (selector) -> $(selector, @el)
 