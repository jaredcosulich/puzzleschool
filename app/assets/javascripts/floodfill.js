var ImageProcessing;

ImageProcessing = {

  /* Convert HTML color (e.g. "#rrggbb" or "#rrggbbaa") to object with properties r, g, b, a.
   * If no alpha value is given, 255 (0xff) will be assumed.
   */
  toRGB: function (color) {
    var r, g, b, a, html;
    html = color;

    // Parse out the RGBA values from the HTML Code
    if (html.substring(0, 1) === "#")
    {
      html = html.substring(1);
    }

    if (html.length === 3 || html.length === 4)
    {
      r = html.substring(0, 1);
      r = r + r;

      g = html.substring(1, 2);
      g = g + g;

      b = html.substring(2, 3);
      b = b + b;

      if (html.length === 4) {
        a = html.substring(3, 4);
        a = a + a;
      }
      else {
        a = "ff";
      }
    }
    else if (html.length === 6 || html.length === 8)
    {
      r = html.substring(0, 2);
      g = html.substring(2, 4);
      b = html.substring(4, 6);
      a = html.length === 6 ? "ff" : html.substring(6, 8);
    }

    // Convert from Hex (Hexidecimal) to Decimal
    r = parseInt(r, 16);
    g = parseInt(g, 16);
    b = parseInt(b, 16);
    a = parseInt(a, 16);
    return ;
  },

  /* Get the color at the given x,y location from the pixels array, assuming the array has a width and height as given.
   * This interprets the 1-D array as a 2-D array.
   *
   * If useColor is defined, its values will be set. This saves on object creation.
   */
  getColor: function (pixels, x, y, width, height, useColor) {
    var redIndex = y * width * 4 + x * 4;
    if (useColor === undefined) {
      useColor = { r: pixels[redIndex], g: pixels[redIndex + 1], b: pixels[redIndex + 2], a: pixels[redIndex + 3] };
    }
    else {
      useColor.r = pixels[redIndex];
      useColor.g = pixels[redIndex + 1]
      useColor.b = pixels[redIndex + 2];
      useColor.a = pixels[redIndex + 3];
    }
    return useColor;
  },

  setColor: function (pixels, x, y, width, height, color) {
    var redIndex = y * width * 4 + x * 4;
    pixels[redIndex] = color.r;
    pixels[redIndex + 1] = color.g,
    pixels[redIndex + 2] = color.b;
    pixels[redIndex + 3] = color.a;
  },

/*
 * fill: Flood a canvas with the given fill color.
 *
 * Returns a rectangle { x, y, width, height } that defines the maximum extent of the pixels that were changed.
 *
 *    canvas .................... Canvas to modify.
 *    fillColor ................. RGBA Color to fill with.
 *                                This may be a string ("#rrggbbaa") or an object of the form { r: red, g: green, b: blue, a: alpha }.
 *    x, y ...................... Coordinates of seed point to start flooding.
 *    bounds .................... Restrict flooding to this rectangular region of canvas.
 *                                This object has these attributes: { x, y, width, height }.
 *                                If undefined or null, use the whole of the canvas.
 *    stopFunction .............. Function that decides if a pixel is a boundary that should cause
 *                                flooding to stop. If omitted, any pixel that differs from seedColor
 *                                will cause flooding to stop. seedColor is the color under the seed point (x,y).
 *                                Parameters: stopFunction(fillColor, seedColor, pixelColor).
 *                                Returns true if flooding shoud stop.
 *                                The colors are objects of the form { r: red, g: green, b: blue, a: alpha }
 */
 fill: function (canvas, fillColor, x, y, bounds, stopFunction) {
    // Supply default values if necessary.
    var ctx, minChangedX, minChangedY, maxChangedX, maxChangedY, wasTested, shouldTest, imageData, pixels, currentX, currentY, currentColor, currentIndex, seedColor, tryX, tryY, tryIndex, boundsWidth, boundsHeight, pixelStart, fillRed, fillGreen, fillBlue, fillAlpha;
    fillColor = {r: fillColor[0], g: fillColor[1], b: fillColor[2], a: 1}
    x = Math.round(x);
    y = Math.round(y);
    if (bounds === null || bounds === undefined) {
      bounds = { x: 0, y: 0, width: canvas.width, height: canvas.height };
    }
    else {
      bounds = { x: Math.round(bounds.x), y: Math.round(bounds.y), width: Math.round(bounds.y), height: Math.round(bounds.height) };
    }
    if (stopFunction === null || stopFunction === undefined) {
      stopFunction = function(fillColor, seedColor, pixelColor) {
        return pixelColor.r != seedColor.r || pixelColor.g != seedColor.g || pixelColor.b != seedColor.b || pixelColor.a != seedColor.a;
      }
    }
    minChangedX = maxChangedX = x - bounds.x;
    minChangedY = maxChangedY = y - bounds.y;
    boundsWidth = bounds.width;
    boundsHeight = bounds.height;

    // Initialize wasTested to false. As we check each pixel to decide if it should be painted with the new color,
    // we will mark it with a true value at wasTested[row = y][column = x];
    wasTested = new Array(boundsHeight * boundsWidth);
    /*
    $R(0, bounds.height - 1).each(function (row) {
      var subArray = new Array(bounds.width);
      wasTested[row] = subArray;
    });
    */

    // Start with a single point that we know we should test: (x, y).
    // Convert (x,y) to image data coordinates by subtracting the bounds' origin.
    currentX = x - bounds.x;
    currentY = y - bounds.y;
    currentIndex = currentY * boundsWidth + currentX;
    shouldTest = [ currentIndex ];

    ctx = canvas.getContext("2d");
    //imageData = ctx.getImageData(bounds.x, bounds.y, bounds.width, bounds.height);
    imageData = ImageProcessing.getImageData(ctx, bounds.x, bounds.y, bounds.width, bounds.height);
    pixels = imageData.data;
    seedColor = ImageProcessing.getColor(pixels, currentX, currentY, boundsWidth, boundsHeight);
    currentColor = { r: 0, g: 0, b: 0, a: 1 };
    fillRed = fillColor.r;
    fillGreen = fillColor.g;
    fillBlue = fillColor.b;
    fillAlpha = fillColor.a;
    while (shouldTest.length > 0) {
      currentIndex = shouldTest.pop();
      currentX = currentIndex % boundsWidth;
      currentY = (currentIndex - currentX) / boundsWidth;
      if (! wasTested[currentIndex]) {
        wasTested[currentIndex] = true;
        //currentColor = ImageProcessing.getColor(pixels, currentX, currentY, boundsWidth, boundsHeight, currentColor);
        // Inline getColor for performance.
        pixelStart = currentIndex * 4;
        currentColor.r = pixels[pixelStart];
        currentColor.g = pixels[pixelStart + 1]
        currentColor.b = pixels[pixelStart + 2];
        currentColor.a = pixels[pixelStart + 3];

        if (! stopFunction(fillColor, seedColor, currentColor)) {
          // Color the pixel with the fill color.
          //ImageProcessing.setColor(pixels, currentX, currentY, boundsWidth, boundsHeight, fillColor);
          // Inline setColor for performance
          pixels[pixelStart] = fillRed;
          pixels[pixelStart + 1] = fillGreen;
          pixels[pixelStart + 2] = fillBlue;
          pixels[pixelStart + 3] = fillAlpha * 255;

          if (minChangedX < currentX) { minChangedX = currentX; }
          else if (maxChangedX > currentX) { maxChangedX = currentX; }
          if (minChangedY < currentY) { minChangedY = currentY; }
          else if (maxChangedY > currentY) { maxChangedY = currentY; }

          // Add the adjacent four pixels to the list to be tested, unless they have already been tested.
          tryX = currentX - 1;
          tryY = currentY;
          tryIndex = tryY * boundsWidth + tryX;
          if (tryX >= 0 && ! wasTested[tryIndex]) {
            shouldTest.push(tryIndex);
          }
          tryX = currentX;
          tryY = currentY + 1;
          tryIndex = tryY * boundsWidth + tryX;
          if (tryY < boundsHeight && ! wasTested[tryIndex]) {
            shouldTest.push(tryIndex);
          }
          tryX = currentX + 1;
          tryY = currentY;
          tryIndex = tryY * boundsWidth + tryX;
          if (tryX < boundsWidth && ! wasTested[tryIndex]) {
            shouldTest.push(tryIndex);
          }
          tryX = currentX;
          tryY = currentY - 1;
          tryIndex = tryY * boundsWidth + tryX;
          if (tryY >= 0 && ! wasTested[tryIndex]) {
            shouldTest.push(tryIndex);
          }
        }
      }
    }
    //ctx.putImageData(imageData, bounds.x, bounds.y);
    ImageProcessing.putImageData(ctx, imageData, bounds.x, bounds.y);

    return { x: minChangedX + bounds.x, y: minChangedY + bounds.y, width: maxChangedX - minChangedX + 1, height: maxChangedY - minChangedY + 1 };
  },

  getImageData: function (ctx, x, y, w, h) {
    return ctx.getImageData(x, y, w, h);
  },

  putImageData: function (ctx, data, x, y) {
    ctx.putImageData(data, x, y);
  }

};
