client = exports ? provide('../common_objects/client', {})

client.Client = 
    x: (e, container) => (e.clientX or e.targetTouches?[0]?.pageX or e.touches?[0]?.pageX) - container.offset().left
    y: (e, container) => (e.clientY or e.targetTouches?[0]?.pageY or e.touches?[0]?.pageY) - container.offset().top
        
