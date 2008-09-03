/**
  *  (c) 2005-2008 Richard Cowin (http://openrico.org)
  *  (c) 2005-2008 Matt Brown (http://dowdybrown.com)
  *
  *  Rico is licensed under the Apache License, Version 2.0 (the "License"); you may not use this
  *  file except in compliance with the License. You may obtain a copy of the License at
  *   http://www.apache.org/licenses/LICENSE-2.0
  **/

// -----------------------------------------------------
//
// Custom formatting for LiveGrid columns
//
// columnSpecs Usage: { type:'control', control:new Rico.TableColumn.CONTROLNAME() }
//
// -----------------------------------------------------


// Display unique key column as: <checkbox> <key value>
// and keep track of which keys the user selects
// Key values should not contain <, >, or &
Rico.TableColumn.checkboxKey = Class.create();

Rico.TableColumn.checkboxKey.prototype = {

  initialize: function(showKey) {
    this._checkboxes=[];
    this._spans=[];
    this._KeyHash=$H();
    this._showKey=showKey;
  },

  _create: function(gridCell,windowRow) {
    this._checkboxes[windowRow]=RicoUtil.createFormField(gridCell,'input','checkbox',this.liveGrid.tableId+'_chkbox_'+this.index+'_'+windowRow);
    this._spans[windowRow]=RicoUtil.createFormField(gridCell,'span',null,this.liveGrid.tableId+'_desc_'+this.index+'_'+windowRow);
    this._clear(gridCell,windowRow);
    Event.observe(this._checkboxes[windowRow], "click", this._onclick.bindAsEventListener(this), false);
  },

  _onclick: function(e) {
    var elem=Event.element(e);
    var windowRow=parseInt(elem.id.split(/_/).pop());
    var v=this.getValue(windowRow);
    if (elem.checked)
      this._addChecked(v);
    else
      this._remChecked(v);
  },

  _clear: function(gridCell,windowRow) {
    var box=this._checkboxes[windowRow];
    box.checked=false;
    box.style.display='none';
    this._spans[windowRow].innerHTML='';
  },

  _display: function(v,gridCell,windowRow) {
    var box=this._checkboxes[windowRow];
    box.style.display='';
    box.checked=this._KeyHash.get(v);
    if (this._showKey) this._spans[windowRow].innerHTML=v;
  },

  _SelectedKeys: function() {
    return this._KeyHash.keys();
  },

  _addChecked: function(k){
    this._KeyHash.set(k,1);
  },

  _remChecked: function(k){
    this._KeyHash.unset(k);
  }
}

// display checkboxes for two-valued column (e.g. yes/no)
Rico.TableColumn.checkbox = Class.create();

Rico.TableColumn.checkbox.prototype = {

  initialize: function(checkedValue, uncheckedValue, defaultValue, readOnly) {
    this._checkedValue=checkedValue;
    this._uncheckedValue=uncheckedValue;
    this._defaultValue=defaultValue || false;
    this._readOnly=readOnly || false;
    this._checkboxes=[];
  },

  _create: function(gridCell,windowRow) {
    this._checkboxes[windowRow]=RicoUtil.createFormField(gridCell,'input','checkbox',this.liveGrid.tableId+'_chkbox_'+this.index+'_'+windowRow);
    this._clear(gridCell,windowRow);
    if (this._readOnly)
      this._checkboxes[windowRow].disabled=true;
    else
      Event.observe(this._checkboxes[windowRow], "click", this._onclick.bindAsEventListener(this), false);
  },

  _onclick: function(e) {
    var elem=Event.element(e);
    var windowRow=parseInt(elem.id.split(/_/).pop());
    var newval=elem.checked ? this._checkedValue : this._uncheckedValue;
    this.setValue(windowRow,newval);
  },

  _clear: function(gridCell,windowRow) {
    var box=this._checkboxes[windowRow];
    box.checked=this._defaultValue;
    box.style.display='none';
  },

  _display: function(v,gridCell,windowRow) {
    var box=this._checkboxes[windowRow];
    box.style.display='';
    box.checked=(v==this._checkedValue);
  }

}

// display value in a text box
Rico.TableColumn.textbox = Class.create();

Rico.TableColumn.textbox.prototype = {

  initialize: function(boxSize, boxMaxLen, readOnly) {
    this._boxSize=boxSize;
    this._boxMaxLen=boxMaxLen;
    this._readOnly=readOnly || false;
    this._textboxes=[];
  },

  _create: function(gridCell,windowRow) {
    var box=RicoUtil.createFormField(gridCell,'input','text',this.liveGrid.tableId+'_txtbox_'+this.index+'_'+windowRow);
    box.size=this._boxSize;
    box.maxLength=this._boxMaxLen;
    this._textboxes[windowRow]=box
    this._clear(gridCell,windowRow);
    if (this._readOnly)
      box.disabled=true;
    else
      Event.observe(box, "change", this._onchange.bindAsEventListener(this), false);
  },

  _onchange: function(e) {
    var elem=Event.element(e);
    var windowRow=parseInt(elem.id.split(/_/).pop());
    this.setValue(windowRow,elem.value);
  },

  _clear: function(gridCell,windowRow) {
    var box=this._textboxes[windowRow];
    box.value='';
    box.style.display='none';
  },

  _display: function(v,gridCell,windowRow) {
    var box=this._textboxes[windowRow];
    box.style.display='';
    box.value=v;
  }

}

// highlight a grid cell when a particular value is present in the specified column
Rico.TableColumn.HighlightCell = Class.create();

Rico.TableColumn.HighlightCell.prototype = {
  initialize: function(chkcol,chkval,highlightColor,highlightBackground) {
    this._chkcol=chkcol;
    this._chkval=chkval;
    this._highlightColor=highlightColor;
    this._highlightBackground=highlightBackground;
  },

  _clear: function(gridCell,windowRow) {
    gridCell.style.color='';
    gridCell.style.backgroundColor='';
    gridCell.innerHTML='&nbsp;';
  },

  _display: function(v,gridCell,windowRow) {
    var gridval=this.liveGrid.buffer.getWindowValue(windowRow,this._chkcol);
    var match=(gridval==this._chkval);
    gridCell.style.color=match ? this._highlightColor : '';
    gridCell.style.backgroundColor=match ? this._highlightBackground : '';
    gridCell.innerHTML=this._format(v);
  }
}

// database value contains a css color name/value
Rico.TableColumn.bgColor = Class.create();

Rico.TableColumn.bgColor.prototype = {

  initialize: function() {
  },

  _clear: function(gridCell,windowRow) {
    gridCell.style.backgroundColor='';
  },

  _display: function(v,gridCell,windowRow) {
    gridCell.style.backgroundColor=v;
  }

}

// database value contains a url to another page
Rico.TableColumn.link = Class.create();

Rico.TableColumn.link.prototype = {

  initialize: function(href,target) {
    this._href=href;
    this._target=target;
    this._anchors=[];
  },

  _create: function(gridCell,windowRow) {
    this._anchors[windowRow]=RicoUtil.createFormField(gridCell,'a',null,this.liveGrid.tableId+'_a_'+this.index+'_'+windowRow);
    if (this._target) this._anchors[windowRow].target=this._target;
    this._clear(gridCell,windowRow);
  },

  _clear: function(gridCell,windowRow) {
    this._anchors[windowRow].href='';
    this._anchors[windowRow].innerHTML='';
  },

  _display: function(v,gridCell,windowRow) {
    this._anchors[windowRow].innerHTML=v;
    var getWindowValue=this.liveGrid.buffer.getWindowValue.bind(this.liveGrid.buffer);
    this._anchors[windowRow].href=this._href.replace(/\{\d+\}/g,
      function ($1) {
        var colIdx=parseInt($1.substr(1));
        return getWindowValue(windowRow,colIdx);
      }
    );
  }

}

// database value contains a url to an image
Rico.TableColumn.image = Class.create();

Rico.TableColumn.image.prototype = {

  initialize: function() {
    this._img=[];
  },

  _create: function(gridCell,windowRow) {
    this._img[windowRow]=RicoUtil.createFormField(gridCell,'img',null,this.liveGrid.tableId+'_img_'+this.index+'_'+windowRow);
    this._clear(gridCell,windowRow);
  },

  _clear: function(gridCell,windowRow) {
    var img=this._img[windowRow];
    img.style.display='none';
    img.src='';
  },

  _display: function(v,gridCell,windowRow) {
    var img=this._img[windowRow];
    this._img[windowRow].src=v;
    img.style.display='';
  }

}

// map a database value to a display value
Rico.TableColumn.lookup = Class.create();

Rico.TableColumn.lookup.prototype = {

  initialize: function(map, defaultCode, defaultDesc) {
    this._map=map;
    this._defaultCode=defaultCode || '';
    this._defaultDesc=defaultDesc || '&nbsp;';
    this._sortfunc=this._sortvalue.bind(this);
    this._codes=[];
    this._descriptions=[];
  },

  _create: function(gridCell,windowRow) {
    this._descriptions[windowRow]=RicoUtil.createFormField(gridCell,'span',null,this.liveGrid.tableId+'_desc_'+this.index+'_'+windowRow);
    this._codes[windowRow]=RicoUtil.createFormField(gridCell,'input','hidden',this.liveGrid.tableId+'_code_'+this.index+'_'+windowRow);
    this._clear(gridCell,windowRow);
  },

  _clear: function(gridCell,windowRow) {
    this._codes[windowRow].value=this._defaultCode;
    this._descriptions[windowRow].innerHTML=this._defaultDesc;
  },

  _sortvalue: function(v) {
    return this._getdesc(v).replace(/&amp;/g, '&').replace(/&lt;/g,'<').replace(/&gt;/g,'>').replace(/&nbsp;/g,' ');
  },

  _getdesc: function(v) {
    var desc=this._map[v];
    return (typeof desc=='string') ? desc : this._defaultDesc;
  },

  _export: function(v) {
    return this._getdesc(v);
  },

  _display: function(v,gridCell,windowRow) {
    this._codes[windowRow].value=v;
    this._descriptions[windowRow].innerHTML=this._getdesc(v);
  }

}


Rico.includeLoaded('ricoLiveGridControls.js');
