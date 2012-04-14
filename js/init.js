(function($) {
  return $('document').ready(function() {
    debugger;
    $('body').view({
      name: 'Main',
      complete: function() {
        return $.route.init(true);
      }
    });
    return $('body').bind('dragenter dragover drop', function(event) {
      event.stopPropagation();
      event.preventDefault();
    });
  });
})(ender);