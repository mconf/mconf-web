/**
  *
  *  Copyright 2005 Sabre Airline Solutions
  *
  *  Licensed under the Apache License, Version 2.0 (the "License"); you may not use this
  *  file except in compliance with the License. You may obtain a copy of the License at
  *
  *         http://www.apache.org/licenses/LICENSE-2.0
  *
  *  Unless required by applicable law or agreed to in writing, software distributed under the
  *  License is distributed on an "AS IS" BASIS, WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND,
  *  either express or implied. See the License for the specific language governing permissions
  *  and limitations under the License.
  **/

//-------------------- ricoColor.js
Rico.Color = Class.create();

Rico.Color.prototype = {

   initialize: function(red, green, blue) {
      this.rgb = { r: red, g : green, b : blue };
   },

   setRed: function(r) {
      this.rgb.r = r;
   },

   setGreen: function(g) {
      this.rgb.g = g;
   },

   setBlue: function(b) {
      this.rgb.b = b;
   },

   setHue: function(h) {

      // get an HSB model, and set the new hue...
      var hsb = this.asHSB();
      hsb.h = h;

      // convert back to RGB...
      this.rgb = Rico.Color.HSBtoRGB(hsb.h, hsb.s, hsb.b);
   },

   setSaturation: function(s) {
      // get an HSB model, and set the new hue...
      var hsb = this.asHSB();
      hsb.s = s;

      // convert back to RGB and set values...
      this.rgb = Rico.Color.HSBtoRGB(hsb.h, hsb.s, hsb.b);
   },

   setBrightness: function(b) {
      // get an HSB model, and set the new hue...
      var hsb = this.asHSB();
      hsb.b = b;

      // convert back to RGB and set values...
      this.rgb = Rico.Color.HSBtoRGB( hsb.h, hsb.s, hsb.b );
   },

   darken: function(percent) {
      var hsb  = this.asHSB();
      this.rgb = Rico.Color.HSBtoRGB(hsb.h, hsb.s, Math.max(hsb.b - percent,0));
   },

   brighten: function(percent) {
      var hsb  = this.asHSB();
      this.rgb = Rico.Color.HSBtoRGB(hsb.h, hsb.s, Math.min(hsb.b + percent,1));
   },

   blend: function(other) {
      this.rgb.r = Math.floor((this.rgb.r + other.rgb.r)/2);
      this.rgb.g = Math.floor((this.rgb.g + other.rgb.g)/2);
      this.rgb.b = Math.floor((this.rgb.b + other.rgb.b)/2);
   },

   isBright: function() {
      var hsb = this.asHSB();
      return this.asHSB().b > 0.5;
   },

   isDark: function() {
      return ! this.isBright();
   },

   asRGB: function() {
      return "rgb(" + this.rgb.r + "," + this.rgb.g + "," + this.rgb.b + ")";
   },

   asHex: function() {
      return "#" + this.rgb.r.toColorPart() + this.rgb.g.toColorPart() + this.rgb.b.toColorPart();
   },

   asHSB: function() {
      return Rico.Color.RGBtoHSB(this.rgb.r, this.rgb.g, this.rgb.b);
   },

   toString: function() {
      return this.asHex();
   }

};

Rico.Color.createFromHex = function(hexCode) {
  if(hexCode.length==4) {
    var shortHexCode = hexCode;
    var hexCode = '#';
    for(var i=1;i<4;i++)
      hexCode += (shortHexCode.charAt(i) + shortHexCode.charAt(i));
  }
  if ( hexCode.indexOf('#') == 0 )
    hexCode = hexCode.substring(1);
  if (!hexCode.match(/^[0-9A-Fa-f]{6}$/)) return null;
  var red   = hexCode.substring(0,2);
  var green = hexCode.substring(2,4);
  var blue  = hexCode.substring(4,6);
  return new Rico.Color( parseInt(red,16), parseInt(green,16), parseInt(blue,16) );
}

/**
 * Factory method for creating a color from the background of
 * an HTML element.
 */
Rico.Color.createColorFromBackground = function(elem) {

   var actualColor = Element.getStyle(elem, "background-color");

   // if color is tranparent, check parent
   // Safari returns "rgba(0, 0, 0, 0)", which means transparent
   if ( actualColor.match(/^(transparent|rgba\(0,\s*0,\s*0,\s*0\))$/i) && elem.parentNode )
      return Rico.Color.createColorFromBackground(elem.parentNode);

   if ( actualColor == null )
      return new Rico.Color(255,255,255);

   if ( actualColor.indexOf("rgb(") == 0 ) {
      var colors = actualColor.substring(4, actualColor.length - 1 );
      var colorArray = colors.split(",");
      return new Rico.Color( parseInt( colorArray[0] ),
                            parseInt( colorArray[1] ),
                            parseInt( colorArray[2] )  );

   }
   else if ( actualColor.indexOf("#") == 0 ) {
      return Rico.Color.createFromHex(actualColor);
   }
   else
      return new Rico.Color(255,255,255);
}

Rico.Color.HSBtoRGB = function(hue, saturation, brightness) {

   var red   = 0;
	var green = 0;
	var blue  = 0;

   if (saturation == 0) {
      red = parseInt(brightness * 255.0 + 0.5);
	   green = red;
	   blue = red;
	}
	else {
      var h = (hue - Math.floor(hue)) * 6.0;
      var f = h - Math.floor(h);
      var p = brightness * (1.0 - saturation);
      var q = brightness * (1.0 - saturation * f);
      var t = brightness * (1.0 - (saturation * (1.0 - f)));

      switch (parseInt(h)) {
         case 0:
            red   = (brightness * 255.0 + 0.5);
            green = (t * 255.0 + 0.5);
            blue  = (p * 255.0 + 0.5);
            break;
         case 1:
            red   = (q * 255.0 + 0.5);
            green = (brightness * 255.0 + 0.5);
            blue  = (p * 255.0 + 0.5);
            break;
         case 2:
            red   = (p * 255.0 + 0.5);
            green = (brightness * 255.0 + 0.5);
            blue  = (t * 255.0 + 0.5);
            break;
         case 3:
            red   = (p * 255.0 + 0.5);
            green = (q * 255.0 + 0.5);
            blue  = (brightness * 255.0 + 0.5);
            break;
         case 4:
            red   = (t * 255.0 + 0.5);
            green = (p * 255.0 + 0.5);
            blue  = (brightness * 255.0 + 0.5);
            break;
          case 5:
            red   = (brightness * 255.0 + 0.5);
            green = (p * 255.0 + 0.5);
            blue  = (q * 255.0 + 0.5);
            break;
	    }
	}

   return { r : parseInt(red), g : parseInt(green) , b : parseInt(blue) };
}

/**
 * Returns a 3-element object: h=hue, s=saturation, b=brightness.
 * Unlike some HSB documentation which states hue should be a value 0-360, this routine returns hue values from 0 to 1.0
 */
Rico.Color.RGBtoHSB = function(r, g, b) {

   var hue;
   var saturation;
   var brightness;

   var cmax = (r > g) ? r : g;
   if (b > cmax)
      cmax = b;

   var cmin = (r < g) ? r : g;
   if (b < cmin)
      cmin = b;

   brightness = cmax / 255.0;
   if (cmax != 0)
      saturation = (cmax - cmin)/cmax;
   else
      saturation = 0;

   if (saturation == 0)
      hue = 0;
   else {
      var redc   = (cmax - r)/(cmax - cmin);
    	var greenc = (cmax - g)/(cmax - cmin);
    	var bluec  = (cmax - b)/(cmax - cmin);

    	if (r == cmax)
    	   hue = bluec - greenc;
    	else if (g == cmax)
    	   hue = 2.0 + redc - bluec;
      else
    	   hue = 4.0 + greenc - redc;

    	hue = hue / 6.0;
    	if (hue < 0)
    	   hue = hue + 1.0;
   }

   return { h : hue, s : saturation, b : brightness };
}

Rico.Color.createGradientV = function(e,startColor,endColor) {
  var c1=typeof(startColor)=='string' ? Rico.Color.createFromHex(startColor) : startColor;
  var c2=typeof(endColor)=='string' ? Rico.Color.createFromHex(endColor) : endColor;
  if (Prototype.Browser.IE) {
    e.style.filter = "progid:DXImageTransform.Microsoft.Gradient(GradientType=0,StartColorStr=\"" + c1.asHex() + "\",EndColorStr=\"" + c2.asHex() + "\")";
  } else {
    colorArray = Rico.Color.createColorPath(c1,c2,Math.min(e.offsetHeight,50));
    var remh=e.offsetHeight,l=colorArray.length;
    var div=Rico.Color.createGradientContainer();
    var tmpDOM = document.createDocumentFragment();
    for(p=0;p<colorArray.length;p++) {
      h = Math.round(remh/l) || 1;
      g = document.createElement("div");
      g.setAttribute("style","height:" + h + "px;width:100%;background-color:" + colorArray[p].asRGB() + ";");
      tmpDOM.appendChild(g);
      l--;
      remh-=h;
    }
    div.appendChild(tmpDOM);
    e.appendChild(div);
    tmpDOM = null;
  }
}

Rico.Color.createGradientH = function(e,startColor,endColor) {
  var c1=typeof(startColor)=='string' ? Rico.Color.createFromHex(startColor) : startColor;
  var c2=typeof(endColor)=='string' ? Rico.Color.createFromHex(endColor) : endColor;
  if (Prototype.Browser.IE) {
    e.style.filter = "progid:DXImageTransform.Microsoft.Gradient(GradientType=1,StartColorStr=\"" + c1.asHex() + "\",EndColorStr=\"" + c2.asHex() + "\")";
  } else {
    colorArray = Rico.Color.createColorPath(c1,c2,Math.min(e.offsetWidth,50));
    var x=0,remw=e.offsetWidth,l=colorArray.length;
    var div=Rico.Color.createGradientContainer();
    var tmpDOM = document.createDocumentFragment();
    for(p=0;p<colorArray.length;p++) {
      var w=Math.round(remw/l) || 1;
      var g = document.createElement("div");
      g.setAttribute("style","position:absolute;top:0px;left:" + x + "px;height:100%;width:" + w + "px;background-color:" + colorArray[p].asRGB() + ";");
      tmpDOM.appendChild(g);
      x+=w;
      l--;
      remw-=w;
    }
    div.appendChild(tmpDOM);
    e.appendChild(div);
    tmpDOM = null;
  }
}

Rico.Color.createGradientContainer = function() {
  var div=document.createElement('div');
  div.style.height='100%';
  div.style.width='100%';
  div.style.position='absolute';
  div.style.top='0px';
  div.style.left='0px';
  div.style.zIndex=-1;
  return div;
}

Rico.Color.createColorPath = function(color1,color2,slices) {
  var colorPath = [];
  var colorPercent = 1.0;
  var delta=1.0/slices;
  do {
    colorPath[colorPath.length]=Rico.Color.setColorHue(color1,colorPercent,color2);
    colorPercent-=delta;
  } while(colorPercent>0);
  return colorPath;
}

Rico.Color.setColorHue = function(originColor,opacityPercent,maskRGB) {
  return new Rico.Color(
    Math.round(originColor.rgb.r*opacityPercent + maskRGB.rgb.r*(1.0-opacityPercent)),
    Math.round(originColor.rgb.g*opacityPercent + maskRGB.rgb.g*(1.0-opacityPercent)),
    Math.round(originColor.rgb.b*opacityPercent + maskRGB.rgb.b*(1.0-opacityPercent))
  );
}

//-------------------- ricoCorner.js
Rico.Corner = {

   round: function(e, options) {
      var e = $(e);
      this._setOptions(options);
      var color = this.options.color == "fromElement" ? this._background(e) : this.options.color;
      var bgColor = this.options.bgColor == "fromParent" ? this._background(e.parentNode) : this.options.bgColor;
      if (Prototype.Browser.Gecko && this.options.useMoz && !this.options.border && Element.getStyle(e,'background-image')=='none')
        this._roundCornersGecko(e, color);
      else if (typeof(Element.getStyle(e,'-webkit-border-radius'))=='string' && !this.options.border)
        this._roundCornersWebKit(e, color);
      else
        this._roundCornersImpl(e, color, bgColor);
   },

   _roundCornersImpl: function(e, color, bgColor) {
      this.options.numSlices = this.options.compact ? 2 : 4;
      this.borderColor = this._borderColor(color,bgColor);
      if(this.options.border)
         this._renderBorder(e,bgColor);
      if(this._isTopRounded())
         this._roundTopCorners(e,color,bgColor);
      if(this._isBottomRounded())
         this._roundBottomCorners(e,color,bgColor);
   },

   _roundCornersGecko: function(e, color) {
      var radius=this.options.compact ? '4px' : '8px';
      if (this._hasString(this.options.corners, "all"))
        Element.setStyle(e, {MozBorderRadius:radius}, true)
      else {
        if (this._hasString(this.options.corners, "top", "tl")) Element.setStyle(e, {MozBorderRadiusTopleft:radius}, true)
        if (this._hasString(this.options.corners, "top", "tr")) Element.setStyle(e, {MozBorderRadiusTopright:radius}, true)
        if (this._hasString(this.options.corners, "bottom", "bl")) Element.setStyle(e, {MozBorderRadiusBottomleft:radius}, true)
        if (this._hasString(this.options.corners, "bottom", "br")) Element.setStyle(e, {MozBorderRadiusBottomright:radius}, true)
      }
   },

   _roundCornersWebKit: function(e, color) {
      var radius=this.options.compact ? '4px' : '8px';
      if (this._hasString(this.options.corners, "all"))
        Element.setStyle(e, {WebkitBorderRadius:radius}, true)
      else {
        if (this._hasString(this.options.corners, "top", "tl")) Element.setStyle(e, {WebkitBorderTopLeftRadius:radius}, true)
        if (this._hasString(this.options.corners, "top", "tr")) Element.setStyle(e, {WebkitBorderTopRightRadius:radius}, true)
        if (this._hasString(this.options.corners, "bottom", "bl")) Element.setStyle(e, {WebkitBorderBottomLeftRadius:radius}, true)
        if (this._hasString(this.options.corners, "bottom", "br")) Element.setStyle(e, {WebkitBorderBottomRightRadius:radius}, true)
      }
   },

   _renderBorder: function(el,bgColor) {
      var borderValue = "1px solid " + this._borderColor(bgColor);
      var borderL = "border-left: "  + borderValue;
      var borderR = "border-right: " + borderValue;
      var style   = "style='height:100%;" + borderL + ";" + borderR +  "'";
      el.innerHTML = "<div " + style + ">" + el.innerHTML + "</div>"
   },

   _roundTopCorners: function(el, color, bgColor) {
      var corner = this._createCorner(bgColor);
      for(var i=0 ; i < this.options.numSlices ; i++ )
         corner.appendChild(this._createCornerSlice(color,bgColor,i,"top"));
      el.style.paddingTop = '0px';
      el.insertBefore(corner,el.firstChild);
   },

   _roundBottomCorners: function(el, color, bgColor) {
      var corner = this._createCorner(bgColor);
      for(var i=(this.options.numSlices-1) ; i >= 0 ; i-- )
         corner.appendChild(this._createCornerSlice(color,bgColor,i,"bottom"));
      el.style.paddingBottom = 0;
      el.appendChild(corner);
   },

   _createCorner: function(bgColor) {
      var corner = document.createElement("div");
      corner.style.backgroundColor = (this._isTransparent() ? "transparent" : bgColor);
      return corner;
   },

   _createCornerSlice: function(color,bgColor, n, position) {
      var slice = document.createElement("span");

      var inStyle = slice.style;
      inStyle.backgroundColor = color;
      inStyle.display  = "block";
      inStyle.height   = "1px";
      inStyle.overflow = "hidden";
      inStyle.fontSize = "1px";

      if ( this.options.border && n == 0 ) {
         inStyle.borderTopStyle    = "solid";
         inStyle.borderTopWidth    = "1px";
         inStyle.borderLeftWidth   = "0px";
         inStyle.borderRightWidth  = "0px";
         inStyle.borderBottomWidth = "0px";
         inStyle.height            = "0px"; // assumes css compliant box model
         inStyle.borderColor       = this.borderColor;
      }
      else if(this.borderColor) {
         inStyle.borderColor = this.borderColor;
         inStyle.borderStyle = "solid";
         inStyle.borderWidth = "0px 1px";
      }

      if ( !this.options.compact && (n == (this.options.numSlices-1)) )
         inStyle.height = "2px";

      this._setMargin(slice, n, position);
      this._setBorder(slice, n, position);
      return slice;
   },

   _setOptions: function(options) {
      this.options = {
         corners : "all",
         color   : "fromElement",
         bgColor : "fromParent",
         blend   : true,
         border  : false,
         compact : false,
         useMoz  : true  // use native Gecko corners
      }
      Object.extend(this.options, options || {});
      if (this._isTransparent()) this.options.blend = false;
   },

   _whichSideTop: function() {
      if ( this._hasString(this.options.corners, "all", "top") )
         return "";

      if ( this.options.corners.indexOf("tl") >= 0 && this.options.corners.indexOf("tr") >= 0 )
         return "";

      if (this.options.corners.indexOf("tl") >= 0)
         return "left";
      else if (this.options.corners.indexOf("tr") >= 0)
          return "right";
      return "";
   },

   _whichSideBottom: function() {
      if ( this._hasString(this.options.corners, "all", "bottom") )
         return "";

      if ( this.options.corners.indexOf("bl")>=0 && this.options.corners.indexOf("br")>=0 )
         return "";

      if(this.options.corners.indexOf("bl") >=0)
         return "left";
      else if(this.options.corners.indexOf("br")>=0)
         return "right";
      return "";
   },

   _borderColor : function(color,bgColor) {
      if (color == "transparent") return bgColor;
      if (this.options.border) return this.options.border;
      if (!this.options.blend) return '';
      var cc1 = Rico.Color.createFromHex(bgColor);
      var cc2 = Rico.Color.createFromHex(color);
      if (cc1==null || cc2==null) {
         this.options.blend=false;
         return '';
      }
      cc1.blend(cc2);
      return cc1;
   },


   _setMargin: function(el, n, corners) {
      var marginSize = this._marginSize(n);
      var whichSide = corners == "top" ? this._whichSideTop() : this._whichSideBottom();

      if ( whichSide == "left" ) {
         el.style.marginLeft = marginSize + "px"; el.style.marginRight = "0px";
      }
      else if ( whichSide == "right" ) {
         el.style.marginRight = marginSize + "px"; el.style.marginLeft  = "0px";
      }
      else {
         el.style.marginLeft = marginSize + "px"; el.style.marginRight = marginSize + "px";
      }
   },

   _setBorder: function(el,n,corners) {
      var borderSize = this._borderSize(n);
      var whichSide = corners == "top" ? this._whichSideTop() : this._whichSideBottom();
      if ( whichSide == "left" ) {
         el.style.borderLeftWidth = borderSize + "px"; el.style.borderRightWidth = "0px";
      }
      else if ( whichSide == "right" ) {
         el.style.borderRightWidth = borderSize + "px"; el.style.borderLeftWidth  = "0px";
      }
      else {
         el.style.borderLeftWidth = borderSize + "px"; el.style.borderRightWidth = borderSize + "px";
      }
      if (this.options.border) {
        el.style.borderLeftWidth = borderSize + "px"; el.style.borderRightWidth = borderSize + "px";
      }
   },

   _marginSize: function(n) {
      if ( this._isTransparent() )
         return 0;

      var marginSizes          = [ 5, 3, 2, 1 ];
      var blendedMarginSizes   = [ 3, 2, 1, 0 ];
      var compactMarginSizes   = [ 2, 1 ];
      var smBlendedMarginSizes = [ 1, 0 ];

      if ( this.options.compact && this.options.blend )
         return smBlendedMarginSizes[n];
      else if ( this.options.compact )
         return compactMarginSizes[n];
      else if ( this.options.blend )
         return blendedMarginSizes[n];
      else
         return marginSizes[n];
   },

   _borderSize: function(n) {
      var transparentBorderSizes = [ 5, 3, 2, 1 ];
      var blendedBorderSizes     = [ 2, 1, 1, 1 ];
      var compactBorderSizes     = [ 1, 0 ];
      var actualBorderSizes      = [ 0, 2, 0, 0 ];

      if ( this.options.compact && (this.options.blend || this._isTransparent()) )
         return 1;
      else if ( this.options.compact )
         return compactBorderSizes[n];
      else if ( this.options.blend )
         return blendedBorderSizes[n];
      else if ( this.options.border )
         return actualBorderSizes[n];
      else if ( this._isTransparent() )
         return transparentBorderSizes[n];
      return 0;
   },

   _background: function(elem) {
     try {
       var actualColor = Element.getStyle(elem, "background-color");

       // if color is tranparent, check parent
       // Safari returns "rgba(0, 0, 0, 0)", which means transparent
       if ( actualColor.match(/^(transparent|rgba\(0,\s*0,\s*0,\s*0\))$/i) && elem.parentNode )
          return this._background(elem.parentNode);

       return actualColor == null ? "#ffffff" : actualColor;
     } catch(err) {
       return "#ffffff";
     }
   },

   _hasString: function(str) {
     for(var i=1 ; i<arguments.length ; i++)
       if (str.indexOf(arguments[i]) >= 0) return true;
     return false;
   },

   _isTransparent: function() { return this.options.color == "transparent"; },
   _isTopRounded: function() { return this._hasString(this.options.corners, "all", "top", "tl", "tr"); },
   _isBottomRounded: function() { return this._hasString(this.options.corners, "all", "bottom", "bl", "br"); },
   _hasSingleTextChild: function(el) { return el.childNodes.length == 1 && el.childNodes[0].nodeType == 3; }
}

Rico.includeLoaded('ricoStyles.js');
