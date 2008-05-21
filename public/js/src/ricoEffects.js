 /**
   *  (c) 2005-2007 Richard Cowin (http://openrico.org)
   *
   *  Rico is licensed under the Apache License, Version 2.0 (the "License"); you may not use this
   *  file except in compliance with the License. You may obtain a copy of the License at
   *   http://www.apache.org/licenses/LICENSE-2.0
   **/

Rico.animate = function(effect){
  new Rico.Effect.Animator().play(effect, arguments[1]);
}

Rico.Effect = {}
Rico.Effect.easeIn = function(step){
  return Math.sqrt(step)
}
Rico.Effect.easeOut = function(step){
  return step*step
}
Rico.Stepping = {}
Rico.Stepping.easeIn = Rico.Effect.easeIn;
Rico.Stepping.easeOut = Rico.Effect.easeOut;

Rico.Effect.Animator = Class.create();
Rico.Effect.Animator.prototype = {
  initialize : function(effect) {
    this.animateMethod = this.animate.bind(this);
    this.options = arguments[1] || {};
    this.stepsLeft = 0;
    if (!effect) return;
    this.reset(effect, arguments[1]);
  },
  reset: function(effect){
    this.effect = effect;
    if (arguments[1]) this.setOptions(arguments[1]);
    this.stepsLeft = this.options.steps;
    this.duration = this.options.duration;
  },
  setOptions: function(options){
    this.options = Object.extend({
      steps: 10,
      duration: 200,
      rate: function(steps){ return steps;}
    }, options|| {});
  },
  play: function(effect) {
    this.setOptions(arguments[1])
    if (effect)
      if (effect.step)
        this.reset(effect, arguments[1]);
      else{
        $H(effect).keys().each((function(e){
          var effectClass = {fadeOut:Rico.Effect.FadeOut}[e];
          this.reset(new effectClass(effect[e]));
        }).bind(this))
      }
    this.animate();
  },
  stop: function() {
    if (this.timer) clearTimeout(this.timer);
    this.stepsLeft = 0;
    if (this.effect && this.effect.finish) this.effect.finish();
    if (this.options.onFinish) this.options.onFinish();
  },
  pause: function() {
    this.interupt = true;
  },
  resume: function() {
    this.interupt = false;
    if (this.stepsLeft >0)
      this.animate();
  },
  animate: function() {
    if (this.interupt)
      return;
    if (this.stepsLeft <=0) {
      this.stop();
      return;
    }
    if (this.timer) clearTimeout(this.timer);
    this.effect.step(this.options.rate(this.stepsLeft));
    this.startNextStep();
  },
  startNextStep: function() {
    var stepDuration = Math.round(this.duration/this.stepsLeft) ;
    this.duration -= stepDuration;
    this.stepsLeft--;
    this.timer = setTimeout(this.animateMethod, stepDuration);
  },
  isPlaying: function(){
    return this.stepsLeft != 0 && !this.interupt;
  }
}

Rico.Effect.Group = Class.create();
Rico.Effect.Group.prototype = {
  initialize: function(effects){
    this.effects = effects;
  },
  step: function(stepsToGo){
    this.effects.each(function(e){e.step(stepsToGo)});
  },
  finish: function(){
    this.effects.each(function(e){if (e.finish) e.finish()});
  }
}

Rico.Effect.SizeAndPosition = Class.create();
Rico.Effect.SizeAndPosition.prototype = {
  initialize: function(element, x, y, w, h) {
    Object.extend(this, new Rico.Effect.SizeAndPositionFade(element, x, y, w, h));
  }
}

Rico.Effect.SizeAndPositionFade = Class.create();
Rico.Effect.SizeAndPositionFade.prototype = {
  initialize: function(element, x, y, w, h, value) {
    this.element = $(element);
    this.x = typeof(x)=='number' ? x : this.element.offsetLeft;
    this.y = typeof(y)=='number' ? y : this.element.offsetTop;
    if (!Prototype.Browser.IE || (document.compatMode && document.compatMode.indexOf("CSS")!=-1)) {
      this.pw = RicoUtil.nan2zero(Element.getStyle(this.element,'padding-left'))+RicoUtil.nan2zero(Element.getStyle(this.element,'padding-right'));
      this.pw += RicoUtil.nan2zero(Element.getStyle(this.element,'border-left-width'))+RicoUtil.nan2zero(Element.getStyle(this.element,'border-right-width'));
      this.ph = RicoUtil.nan2zero(Element.getStyle(this.element,'padding-top'))+RicoUtil.nan2zero(Element.getStyle(this.element,'padding-bottom'));
      this.ph += RicoUtil.nan2zero(Element.getStyle(this.element,'border-top-width'))+RicoUtil.nan2zero(Element.getStyle(this.element,'border-bottom-width'));
    } else {
      this.pw=0;
      this.ph=0;
    }
    this.w = typeof(w)=='number' ? w : this.element.offsetWidth;
    this.h = typeof(h)=='number' ? h : this.element.offsetHeight;
    this.opacity = Element.getStyle(this.element, 'opacity') || 1.0;
    this.target = arguments.length > 5 ? Math.min(value, 1.0) : this.opacity;
  },
  step: function(stepsToGo) {
    var left = this.element.offsetLeft + ((this.x - this.element.offsetLeft)/stepsToGo);
    var top = this.element.offsetTop + ((this.y - this.element.offsetTop)/stepsToGo);
    var width = this.element.offsetWidth + ((this.w - this.element.offsetWidth)/stepsToGo) - this.pw;
    var height = this.element.offsetHeight + ((this.h - this.element.offsetHeight)/stepsToGo) - this.ph;
    var style = this.element.style;
    var curOpacity = Element.getStyle(this.element, 'opacity');
    var newOpacity = curOpacity + (this.target - curOpacity) / stepsToGo;
    Rico.Effect.setOpacity(this.element, Math.min(Math.max(0,newOpacity),1.0));
    style.left = left + "px";
    style.top = top + "px";
    style.width = width + "px";
    style.height = height + "px";
  }
}

Rico.AccordionEffect = Class.create();
Rico.AccordionEffect.prototype = {
  initialize: function(toClose, toOpen, height) {
    this.toClose   = toClose;
    this.toOpen    = toOpen;
    toOpen.style.height = "0px";
    Element.show(toOpen);
    Element.makeClipping(toOpen);
    Element.makeClipping(toClose);
    Rico.Controls.disableNativeControls(toClose);
    this.endHeight = height;
  },
  step: function(framesLeft) {
    var cHeight = Math.max(1,this.toClose.offsetHeight - parseInt((parseInt(this.toClose.offsetHeight))/framesLeft));
    var closeHeight = cHeight + "px";
    var openHeight = (this.endHeight - cHeight) + "px"
    this.toClose.style.height = closeHeight;
    this.toOpen.style.height = openHeight;
  },
  finish: function(){
    Element.hide(this.toClose)
    this.toOpen.style.height = this.endHeight + "px";
    this.toClose.style.height = "0px";
    Element.undoClipping(this.toOpen);
    Element.undoClipping(this.toClose);
    Rico.Controls.enableNativeControls(this.toOpen);
  }
};

Rico.Effect.SizeFromBottom = Class.create()
Rico.Effect.SizeFromBottom.prototype = {
  initialize: function(element, y, h) {
    this.element = $(element);
    this.y = typeof(y)=='number' ? y : this.element.offsetTop;
    this.h = typeof(h)=='number' ? h : this.element.offsetHeight;
    this.options  = arguments[3] || {};
  },
  step: function(framesToGo) {
    var top = this.element.offsetTop + ((this.y - this.element.offsetTop)/framesToGo) + "px"
    var height = this.element.offsetHeight + ((this.h - this.element.offsetHeight)/framesToGo) + "px"
    var style = this.element.style;
    style.height = height;
    style.top = top;
  }
}

Rico.Effect.Position = Class.create();
Rico.Effect.Position.prototype = {
  initialize: function(element, x, y) {
    this.element = $(element);
    this.x = typeof(x)=='number' ? x : this.element.offsetLeft;
    this.destTop = typeof(y)=='number' ? y : this.element.offsetTop;
  },
  step: function(stepsToGo) {
    var left = this.element.offsetLeft + ((this.x - this.element.offsetLeft)/stepsToGo) + "px"
    var top = this.element.offsetTop + ((this.destTop - this.element.offsetTop)/stepsToGo) + "px"
    var style = this.element.style;
    style.left = left;
    style.top = top;
  }
}

Rico.Effect.FadeTo = Class.create()
Rico.Effect.FadeTo.prototype = {
  initialize: function(element, value){
    this.element = element;
    this.opacity = Element.getStyle(this.element, 'opacity') || 1.0;
    this.target = Math.min(value, 1.0);
  },
  step: function(framesLeft) {
    var curOpacity = Element.getStyle(this.element, 'opacity');
    var newOpacity = curOpacity + (this.target - curOpacity)/framesLeft
    Rico.Effect.setOpacity(this.element, Math.min(Math.max(0,newOpacity),1.0));
  }
}

Rico.Effect.FadeOut = Class.create()
Rico.Effect.FadeOut.prototype = {
  initialize: function(element){
    this.effect = new Rico.Effect.FadeTo(element, 0.0)
  },
  step: function(framesLeft) {
    this.effect.step(framesLeft);
  }
}

Rico.Effect.FadeIn = Class.create()
Rico.Effect.FadeIn.prototype = {
  initialize: function(element){
    var options = arguments[1] || {}
    var startValue = options.startValue || 0
    Rico.Effect.setOpacity(element, startValue);
    this.effect = new Rico.Effect.FadeTo(element, 1.0)
  },
  step: function(framesLeft) {
    this.effect.step(framesLeft);
  }
}

Rico.Effect.setOpacity= function(element, value) {
  if (element.setOpacity) {
     element.setOpacity(value);  // use prototype function
  } else {
     element.style.filter = "alpha(opacity="+Math.round(value*100)+")";
     element.style.opacity = value;
  }
}

Rico.Effect.SizeFromTop = Class.create()
Rico.Effect.SizeFromTop.prototype = {
  initialize: function(element, scrollElement, y, h) {
     this.element = $(element);
     this.h = typeof(h)=='number' ? h : this.element.offsetHeight;
  //   element.style.top = y;
     this.scrollElement = scrollElement;
     this.options  = arguments[4] || {};
     this.baseHeight = this.options.baseHeight ||  Math.max(this.h, this.element.offsetHeight)
  },
  step: function(framesToGo) {
    var rawHeight = this.element.offsetHeight + ((this.h - this.element.offsetHeight)/framesToGo);
    var height = rawHeight + "px"
    var scroll = (rawHeight - this.baseHeight) + "px";
    this.scrollElement.style.top = scroll;
    this.element.style.height = height;
  }
}


Rico.Effect.Height = Class.create()
Rico.Effect.Height.prototype = {
  initialize: function(element, endHeight) {
    this.element = element
    this.endHeight = endHeight
  },
  step: function(stepsLeft) {
    if (this.element.constructor != Array){
      var height = this.element.offsetHeight + ((this.endHeight - this.element.offsetHeight)/stepsLeft) + "px"
      this.element.style.height = height;
    } else {
      var height = this.element[0].offsetHeight + ((this.endHeight - this.element[0].offsetHeight)/stepsLeft) + "px"
      this.element.each(function(e){e.style.height = height})
    }
  }
}

Rico.Effect.SizeWidth = Class.create();
Rico.Effect.SizeWidth.prototype = {
    initialize: function(element, endWidth) {
      this.element = element
      this.endWidth = endWidth
    },
    step: function(stepsLeft) {
       delta = Math.abs(this.endWidth - parseInt(this.element.offsetWidth))/(stepsLeft);
       this.element.style.width = (this.element.offsetWidth - delta) + "px";
    }
}

//these are to support non Safari browsers and keep controls from bleeding through on absolute positioned element.
Rico.Controls = {
  editors: [],
  scrollSelectors: [],

  disableNativeControls: function(element) {
    Rico.Controls.defaultDisabler.disableNative(element);
  },
  enableNativeControls: function(element){
    Rico.Controls.defaultDisabler.enableNative(element);
  },
  prepareForSizing: function(element){
    Element.makeClipping(element)
    Rico.Controls.disableNativeControls(element)
  },
  resetSizing: function(element){
    Element.undoClipping(element)
    Rico.Controls.enableNativeControls(element)
  },
  registerScrollSelectors: function(selectorSet) {
    selectorSet.each(function(s){Rico.Controls.scrollSelectors.push(Rico.selector(s))});
  }
}

Rico.Controls.Disabler = Class.create();
Rico.Controls.Disabler.prototype = {
  initialize: function(){
    this.options = Object.extend({
      excludeSet: [],
      hidables: Rico.Controls.editors
    }, arguments[0] || {});
  },
  disableNative: function(element) {
    if (!(/Konqueror|Safari|KHTML/.test(navigator.userAgent))){
      if (!navigator.appVersion.match(/\bMSIE\b/))
        this.blockControls(element).each(function(e){Element.makeClipping(e)});
      else
        this.hidableControls(element).each(function(e){e.disable()});
    }
  },
  enableNative: function(element){
    if (!(/Konqueror|Safari|KHTML/.test(navigator.userAgent))){
      if (!navigator.appVersion.match(/\bMSIE\b/))
        this.blockControls(element).each(function(e){Element.undoClipping(e)});
      else
        this.hidableControls(element).each(function(e){e.enable()});
    }
  },
  blockControls: function(element){
    try{
    var includes = [];
    if (this.options.includeSet)
      includes = this.options.includeSet;
    else{
      var selectors = this.options.includeSelectors || Rico.Controls.scrollSelectors;
      includes = selectors.map(function(s){return s.findAll(element)}).flatten();
    }
    return includes.select(function(e){return (Element.getStyle(e, 'display') != 'none') && !this.options.excludeSet.include(e)}.bind(this));
  }catch(e) { return []}
  },
  hidableControls: function(element){
    if (element)
      return this.options.hidables.select(function(e){return Element.childOf(e, element)});
    else
      return this.options.hidables;
  }
}

Rico.Controls.defaultDisabler = new Rico.Controls.Disabler();
Rico.Controls.blankDisabler = new Rico.Controls.Disabler({includeSet:[],hidables:[]});

Rico.Controls.HidableInput = Class.create();
Rico.Controls.HidableInput.prototype = {
  initialize: function(field, view){
    this.field = field;
    this.view = view;
    this.enable();
    Rico.Controls.editors.push(this);
  },
  enable: function(){
    Element.hide(this.view);
    Element.show(this.field);
  },
  disable: function(){
    this.view.value = $F(this.field);
    if (this.field.offsetWidth > 1) {
      this.view.style.width =  parseInt(this.field.offsetWidth)  + "px";
      Element.hide(this.field);
      Element.show(this.view);
    }
  }
}



Element.forceRefresh = function(item) {
  try {
    var n = document.createTextNode(' ')
    item.appendChild(n); item.removeChild(n);
  } catch(e) { }
};

Rico.includeLoaded('ricoEffects.js');
