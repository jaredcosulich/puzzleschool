beforeEach(function() {
  this.addMatchers({
    toBePlaying: function(expectedSong) {
      var player = this.actual;
      return player.currentlyPlayingSong === expectedSong && 
             player.isPlaying;
    }
  });
});

trigger = function(element, eventName, eventAttributes) {
    var event = document.createEvent('HTMLEvents');
    event['initEvent'](eventName, true, true, window, 1)
    for (attributeName in eventAttributes) {
        event[attributeName] = eventAttributes[attributeName];
    }
    element.dispatchEvent(event)
}

triggerTouch = function(element, touchEventName, x, y) {
    trigger(
        element,
        'touch' + touchEventName,
        {targetTouches: [{pageX: x, pageY: y}]}
    );
}
