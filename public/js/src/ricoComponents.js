/**
  *  (c) 2005-2007 Richard Cowin (http://openrico.org)
  *  (c) 2005-2007 Matt Brown (http://dowdybrown.com)
  *
  *  Rico is licensed under the Apache License, Version 2.0 (the "License"); you may not use this
  *  file except in compliance with the License. You may obtain a copy of the License at
  *   http://www.apache.org/licenses/LICENSE-2.0
  **/
  

Rico.ContentTransitionBase = function() {}
Rico.ContentTransitionBase.prototype = {
	initialize: function(titles, contents, options) { 
    if (typeof titles == 'string')
      titles = $$(titles)
    if (typeof contents == 'string')
      contents = $$(contents)
	  
	  this.titles = titles;
	  this.contents = contents;
		this.options = Object.extend({
			duration:200, 
			steps:8,
			rate:Rico.Effect.easeIn
	  }, options || {});
	  this.hoverSet = new Rico.HoverSet(titles, options);
		contents.each(function(p){ if (p) Element.hide(p)})
	  this.selectionSet = new Rico.SelectionSet(titles, Object.extend(this.options, {onSelect: this.select.bind(this)}));
		if (this.initContent) this.initContent();
	},
	reset: function(){
	  this.selectionSet.reset();
	},
	select: function(title) {
	  if ( this.selected == this.contentOf(title)) return
		var panel = this.contentOf(title); 
		if (this.transition){
			if (this.selected){
			  var effect = this.transition(panel)
			  if (effect) Rico.animate(effect, this.options)
      }
			else
				Element.show(panel);
		}else{
			if (this.selected)
				Element.hide(this.selected)
			Element.show(panel);
		}
		this.selected = panel;
	},
	add: function(title, content){
		this.titles.push(title);
		this.contents.push(content);
		this.hoverSet.add(title);
		this.selectionSet.add(title);	
		this.selectionSet.select(title);
	},
	remove: function(title){},
	removeAll: function(){
		this.hoverSet.removeAll();
		this.selectionSet.removeAll();
	},
	openByIndex: function(index){this.selectionSet.selectIndex(index)},
	contentOf: function(title){ return this.contents[this.titles.indexOf(title)]}
}

Rico.ContentTransition = Class.create();
Rico.ContentTransition.prototype = Object.extend(new Rico.ContentTransitionBase(),{});

Rico.SlidingPanel = Class.create();
Rico.SlidingPanel.prototype = {
	initialize: function(panel) {
		this.panel = panel;
		this.options = arguments[1] || {};
		this.closed = true;
		this.showing = false
		this.openEffect = this.options.openEffect;
		this.closeEffect = this.options.closeEffect;
		this.animator = new Rico.Effect.Animator();
		Element.makeClipping(this.panel)
	},
	toggle: function () {
		if(!this.showing){
			this.open();
		} else { 
			this.close();
    }
	},
	open: function () {
	  if (this.closed){
	    this.showing = true;
		  Element.show(this.panel);
  		this.options.disabler.disableNative();
    }
		/*this.animator.stop();*/
		this.animator.play(this.openEffect,
		 									{ onFinish:function(){ Element.undoClipping($(this.panel))}.bind(this),
												rate:Rico.Effect.easeIn});
	},
 	close: function () {
		Element.makeClipping(this.panel)
		this.animator.stop();
		this.showing = false;
		this.animator.play(this.closeEffect,
	                     { onFinish:function(){  Element.hide(this.panel); 	
																							this.options.disabler.enableNative()}.bind(this),	
												rate:Rico.Effect.easeOut});
	}
}


//-------------------------------------------
// Example components
//-------------------------------------------

Rico.Accordion = Class.create();
Rico.Accordion.prototype = Object.extend(new Rico.ContentTransitionBase(), {
  initContent: function() { 
		this.selected.style.height = this.options.panelHeight + "px";
	},
  transition: function(p){ 
    if (!this.options.noAnimate)
		  return new Rico.AccordionEffect(this.selected, p, this.options.panelHeight);
    else{
      p.style.height = this.options.panelHeight + "px";
      if (this.selected) Element.hide(this.selected);
  		Element.show(p);
    }
	}
})


Rico.TabbedPanel = Class.create();
Rico.TabbedPanel.prototype = Object.extend(new Rico.ContentTransitionBase(), {
  initContent: function() { 
	  if (typeof this.options.panelWidth=='number') this.options.panelWidth+="px";
	  if (typeof this.options.panelHeight=='number') this.options.panelHeight+="px";
    if (!this.options.corners) this.options.corners='top';
    if (Rico.Corner && this.options.corners!='none') {
      if (!this.options.border) this.options.color='transparent';
      for (var i=0; i<this.titles.length; i++)
        if (this.titles[i]) {
          if (this.options.panelHdrWidth) this.titles[i].style.width=this.options.panelHdrWidth;
          Rico.Corner.round(this.titles[i], this.options);
        }
    }
		this.transition(this.selected);
	},
  transition: function(p){ 
    if (this.selected) Element.hide(this.selected);
		Element.show(p);
    if (this.options.panelHeight) p.style.height = this.options.panelHeight;
    if (this.options.panelWidth) p.style.width = this.options.panelWidth;
	}
})


Rico.SlidingPanel.top = function(panel, innerPanel){
	var options = Object.extend({
		disabler: Rico.Controls.defaultDisabler
  }, arguments[2] || {});
	var height = options.height || Element.getDimensions(innerPanel)[1] || innerPanel.offsetHeight;
	var top = options.top || Position.positionedOffset(panel)[1];
	options.openEffect = new Rico.Effect.SizeFromTop(panel, innerPanel, top, height, {baseHeight:height});
	options.closeEffect = new Rico.Effect.SizeFromTop(panel, innerPanel, top, 1, {baseHeight:height});
  panel.style.height = "0px";
	innerPanel.style.top = -height + "px";	
	return new Rico.SlidingPanel(panel, options);
}

Rico.SlidingPanel.bottom = function(panel){
	var options = Object.extend({
		disabler: Rico.Controls.blankDisabler
  }, arguments[1] || {});
	var height = options.height || Element.getDimensions(panel).height;
	var top = Position.positionedOffset(panel)[1];
	options.openEffect = new Rico.Effect.SizeFromBottom(panel, top - height, height);
	options.closeEffect = new Rico.Effect.SizeFromBottom(panel, top, 1);
	return new Rico.SlidingPanel(panel, options); 
}

Rico.includeLoaded('ricoComponents.js');
