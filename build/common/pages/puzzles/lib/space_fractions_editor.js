// Generated by CoffeeScript 1.3.3
var spaceFractionsEditor;

spaceFractionsEditor = typeof exports !== "undefined" && exports !== null ? exports : provide('./lib/space_fractions_editor', {});

spaceFractionsEditor.EditorHelper = (function() {

  function EditorHelper(_arg) {
    this.el = _arg.el, this.viewHelper = _arg.viewHelper;
    this.initElementSelector();
    this.initSquares();
  }

  EditorHelper.prototype.$ = function(selector) {
    return $(selector, this.el);
  };

  EditorHelper.prototype.initElementSelector = function() {
    this.elementSelector = $(document.createElement('DIV'));
    this.elementSelector.addClass('element_selector');
    this.initObjectSelector();
    this.initFractionSelector();
    return this.el.append(this.elementSelector);
  };

  EditorHelper.prototype.initObjectSelector = function() {
    var objectSelector, objectType, _fn,
      _this = this;
    objectSelector = $(document.createElement('DIV'));
    objectSelector.addClass('selector');
    objectSelector.addClass('object_selector');
    _fn = function(objectType) {
      var object, objectContainer, objectImage;
      object = _this.viewHelper.objects[objectType];
      objectContainer = $(document.createElement('DIV'));
      objectContainer.addClass('object');
      objectContainer.data('object_type', objectType);
      objectContainer.bind('click', function() {
        return _this.addObject(objectType);
      });
      objectImage = $(document.createElement('IMG'));
      objectImage.attr('src', object.image);
      objectContainer.append(objectImage);
      return objectSelector.append(objectContainer);
    };
    for (objectType in this.viewHelper.objects) {
      _fn(objectType);
    }
    return this.elementSelector.append(objectSelector);
  };

  EditorHelper.prototype.initFractionSelector = function() {
    var setFraction,
      _this = this;
    this.fractionSelector = $(document.createElement('DIV'));
    this.fractionSelector.html("<h2>Select A Fraction</h2>\n<p>What fraction of laser should this object use?</p>\n<p>\n    <input name='numerator' class='numerator' type='text' value='1'/>\n    <span class='solidus'>/</span>\n    <input name='denominator' class='denominator' type='text' value='1'/>\n</p>\n<p class='fraction'>Fraction: 1/1 or " + (Math.round(1000 * (1 / 1)) / 1000) + "</p>\n<button class='set_fraction'>Set</button>\n<br/>\n<p><a class='select_new_object'>< Select a different object</a></p>");
    this.fractionSelector.find('.numerator, .denominator').bind('keyup', function() {
      return _this.displayFractionValue();
    });
    setFraction = this.fractionSelector.find('.set_fraction');
    setFraction.bind('click', function() {
      _this[setFraction.data('callback')](_this.fractionSelector.find('.numerator').val(), _this.fractionSelector.find('.denominator').val());
      return _this.closeElementSelector();
    });
    this.fractionSelector.find('.select_new_object').bind('click', function() {
      return _this.showSelector('object');
    });
    this.fractionSelector.addClass('selector');
    this.fractionSelector.addClass('fraction_selector');
    this.fractionSelector.hide();
    return this.elementSelector.append(this.fractionSelector);
  };

  EditorHelper.prototype.setFractionValue = function(numeratorVal, denominatorVal) {
    if (numeratorVal == null) {
      numeratorVal = 1;
    }
    if (denominatorVal == null) {
      denominatorVal = 1;
    }
    this.fractionSelector.find('.numerator').val(numeratorVal);
    this.fractionSelector.find('.denominator').val(denominatorVal);
    return this.displayFractionValue();
  };

  EditorHelper.prototype.displayFractionValue = function() {
    var denominatorVal, numeratorVal;
    numeratorVal = this.fractionSelector.find('.numerator').val();
    denominatorVal = this.fractionSelector.find('.denominator').val();
    return this.fractionSelector.find('.fraction').html("Fraction: " + numeratorVal + "/" + denominatorVal + " or " + (Math.round(1000 * (numeratorVal / denominatorVal)) / 1000));
  };

  EditorHelper.prototype.initSquares = function() {
    var _this = this;
    return this.$('.board .square').bind('click', function(e) {
      var square;
      _this.$('.board .selected').removeClass('selected');
      square = $(e.currentTarget);
      square.addClass('selected');
      return _this.showElementSelector(square);
    });
  };

  EditorHelper.prototype.showElementSelector = function(square) {
    var offset;
    square = $(square);
    offset = square.offset();
    this.elementSelector.css({
      opacity: 0,
      top: offset.top + offset.height + 6,
      left: offset.left + (offset.width / 2) - (this.elementSelector.offset().width / 2)
    });
    this.showObjectSelector();
    return this.elementSelector.animate({
      opacity: 1,
      duration: 250
    });
  };

  EditorHelper.prototype.closeElementSelector = function() {
    var _this = this;
    this.$('.board .selected').removeClass('selected');
    return this.elementSelector.animate({
      opacity: 0,
      duration: 250,
      complete: function() {
        return _this.elementSelector.css({
          top: -1000,
          left: -1000
        });
      }
    });
  };

  EditorHelper.prototype.addObject = function(objectType) {
    var object, selectedSquare;
    selectedSquare = this.$('.board .selected');
    this.viewHelper.addObjectToBoard(objectType, selectedSquare);
    object = this.viewHelper.objects[objectType];
    return this.showObjectSelector();
  };

  EditorHelper.prototype.showObjectSelector = function() {
    var object, selectedSquare;
    selectedSquare = this.$('.board .selected');
    if (!selectedSquare.hasClass('occupied')) {
      this.showSelector('object');
      return;
    }
    object = this.viewHelper.objects[selectedSquare.data('object_type')];
    if ((object.distribute && !object.accept) || (object.accept && !object.distribute)) {
      this.setFractionValue(selectedSquare.data('numerator') || 1, selectedSquare.data('denominator') || 1);
      this.fractionSelector.find('.set_fraction').data('callback', 'setObjectFraction');
      return this.showSelector('fraction');
    } else {
      return this.closeElementSelector();
    }
  };

  EditorHelper.prototype.setObjectFraction = function(numerator, denominator) {
    var selectedSquare;
    selectedSquare = this.$('.board .selected');
    selectedSquare.data('numerator', numerator);
    selectedSquare.data('denominator', denominator);
    selectedSquare.attr('title', "Fraction: " + numerator + "/" + denominator);
    return this.viewHelper.fireLaser(selectedSquare);
  };

  EditorHelper.prototype.showSelector = function(selectorPage) {
    var selector, selectors,
      _this = this;
    selectors = this.elementSelector.find('.selector');
    selector = this.elementSelector.find("." + selectorPage + "_selector");
    if (parseInt(this.elementSelector.css('opacity'))) {
      selectors.animate({
        opacity: 0,
        duration: 250,
        complete: function() {
          selectors.hide();
          selector.css({
            opacity: 0,
            display: 'block'
          });
          return selector.animate({
            opacity: 1,
            duration: 250
          });
        }
      });
    } else {
      selectors.hide();
    }
    return selector.css({
      opacity: 1,
      display: 'block'
    });
  };

  return EditorHelper;

})();
