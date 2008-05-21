/**
  *  (c) 2005-2007 Richard Cowin (http://openrico.org)
  *  (c) 2005-2007 Matt Brown (http://dowdybrown.com)
  *
  *  Rico is licensed under the Apache License, Version 2.0 (the "License"); you may not use this
  *  file except in compliance with the License. You may obtain a copy of the License at
  *   http://www.apache.org/licenses/LICENSE-2.0
  **/


if(typeof Rico=='undefined') throw("SimpleGrid requires the Rico JavaScript framework");
if(typeof RicoUtil=='undefined') throw("SimpleGrid requires the RicoUtil Library");
if(typeof RicoTranslate=='undefined') throw("SimpleGrid requires the RicoTranslate Library");

/**
 * Create & manage an unbuffered grid.
 * Supports: frozen columns & headings, resizable columns
 */
Rico.SimpleGrid = Class.create();

Rico.SimpleGrid.prototype = {

  initialize: function( tableId, options ) {
    Object.extend(this, new Rico.GridCommon);
    this.baseInit();
    Rico.setDebugArea(tableId+"_debugmsgs");    // if used, this should be a textarea
    Object.extend(this.options, options || {});
    this.tableId = tableId;
    this.createDivs();
    this.hdrTabs=new Array(2);
    this.simpleGridInit();
  },

  simpleGridInit: function() {
    for (var i=0; i<2; i++) {
      this.tabs[i]=$(this.tableId+'_tab'+i);
      if (!this.tabs[i]) return;
      this.hdrTabs[i]=$(this.tableId+'_tab'+i+'h');
      if (!this.hdrTabs[i]) return;
      if (i==0) this.tabs[i].style.position='absolute';
      if (i==0) this.tabs[i].style.left='0px';
      this.hdrTabs[i].style.position='absolute';
      this.hdrTabs[i].style.top='0px';
      this.hdrTabs[i].style.zIndex=1;
      this.thead[i]=this.hdrTabs[i];
      this.tbody[i]=this.tabs[i];
      this.headerColCnt = this.getColumnInfo(this.hdrTabs[i].rows);
      if (i==0) this.options.frozenColumns=this.headerColCnt;
    }
    if (this.headerColCnt==0) {
      alert('ERROR: no columns found in "'+this.tableId+'"');
      return;
    }
    this.hdrHt=Math.max(RicoUtil.nan2zero(this.hdrTabs[0].offsetHeight),this.hdrTabs[1].offsetHeight);
    for (var i=0; i<2; i++)
      if (i==0) this.tabs[i].style.top=this.hdrHt+'px';
    this.createColumnArray();
    this.pageSize=this.columns[0].dataColDiv.childNodes.length;
    this.sizeDivs();
    if (typeof(this.options.FilterLocation)=='number')
      this.createFilters(this.options.FilterLocation);
    this.attachMenuEvents();
    this.scrollEventFunc=this.handleScroll.bindAsEventListener(this);
    this.pluginScroll();
    if (this.options.windowResize)
      Event.observe(window,"resize", this.sizeDivs.bindAsEventListener(this), false);
  },

  // return id string for a filter element
  filterId: function(colnum) {
    return 'RicoFilter_'+this.tableId+'_'+colnum;
  },
  
  // create filter elements on heading row r
  createFilters: function(r) {
    if (r < 0) {
      r=this.addHeadingRow();
      this.sizeDivs();
    }
    for( var c=0; c < this.headerColCnt; c++ ) {
      var col=this.columns[c];
      var fmt=col.format;
      if (typeof fmt.filterUI!='string') continue;
      var cell=this.hdrCells[r][c].cell;
      var field,name=this.filterId(c);
      var divs=cell.getElementsByTagName('div');
      switch (fmt.filterUI.charAt(0)) {
        case 't':
          field=RicoUtil.createFormField(divs[1],'input','text',name,name);
          var size=fmt.filterUI.match(/\d+/);
          field.maxLength=fmt.Length || 50;
          field.size=size ? parseInt(size) : 10;
          Event.observe(field,'keyup',col.filterKeypress.bindAsEventListener(col),false);
          break;
        case 's':
          field=RicoUtil.createFormField(divs[1],'select',null,name);
          RicoUtil.addSelectOption(field,this.options.FilterAllToken,RicoTranslate.getPhraseById("filterAll"));
          this.getFilterValues(col);
          var keys=col.filterHash.keys();
          keys.sort();
          for (var i=0; i<keys.length; i++)
            RicoUtil.addSelectOption(field,keys[i],keys[i] || RicoTranslate.getPhraseById("filterBlank"));
          Event.observe(field,'change',col.filterChange.bindAsEventListener(col),false);
          break;
      }
    }
    this.initFilterImage(r);
  },
  
  getFilterValues: function(col) {
    var h=$H();
    var n=col.numRows();
    for (var i=0; i<n; i++) {
      var v=RicoUtil.getInnerText(col.cell(i));
      var hval=h.get(v);
      if (hval)
        hval.push(i);
      else
        h.set(v,[i]);
    }
    col.filterHash=h;
  },
  
  // hide filtered rows
  applyFilters: function() {
    // rows to display will be the intersection of all filterRows arrays
    var fcols=[];
    for (var c=0; c<this.columns.length; c++) {
      if (this.columns[c].filterRows)
        fcols.push(this.columns[c].filterRows);
    }
    if (fcols.length==0) {
      // no filters are set
      this.showAllRows();
      return;
    }
    for (var r=0; r<this.pageSize; r++) {
      var showflag=true;
      for (var j=0; j<fcols.length; j++)
        if (fcols[j].indexOf(r)==-1) {
          showflag=false;
          break;
        }
      if (showflag)
        this.showRow(r);
      else
        this.hideRow(r);
    }
    this.sizeDivs();
  },

  handleScroll: function(e) {
    var newTop=(this.hdrHt-this.scrollDiv.scrollTop)+'px';
    this.tabs[0].style.top=newTop;
    this.setHorizontalScroll();
  },

  /**
   * Register a menu that will only be used in the scrolling part of the grid.
   * If submenus are used, they must be registered after the main menu.
   */
  registerScrollMenu: function(menu) {
    if (!this.menu) this.menu=menu;
    menu.grid=this;
    menu.showmenu=menu.showSimpleMenu;
    menu.showSubMenu=menu.showSimpleSubMenu;
    menu.createDiv(this.outerDiv);
  },

  handleMenuClick: function(e) {
    if (!this.menu) return;
    this.cancelMenu();
    this.menuCell=RicoUtil.getParentByTagName(Event.element(e),'div');
    this.highlightEnabled=false;
    if (this.hideScroll) this.scrollDiv.style.overflow="hidden";
    if (this.menu.buildGridMenu) this.menu.buildGridMenu(this.menuCell);
    this.menu.showmenu(e,this.closeMenu.bind(this));
  },

  closeMenu: function() {
    if (this.hideScroll) this.scrollDiv.style.overflow="";
    this.highlightEnabled=true;
  },

  sizeDivs: function() {
    if (this.outerDiv.offsetParent.style.display=='none') return;
    this.baseSizeDivs();
    var maxHt=Math.max(this.options.maxHt || this.availHt(), 50);
    var totHt=Math.min(this.hdrHt+this.dataHt, maxHt);
    Rico.writeDebugMsg('sizeDivs '+this.tableId+': hdrHt='+this.hdrHt+' dataHt='+this.dataHt);
    this.dataHt=totHt-this.hdrHt;
    if (this.scrWi>0) this.dataHt+=this.options.scrollBarWidth;
    this.scrollDiv.style.height=this.dataHt+'px';
    var divAdjust=2;
    this.innerDiv.style.width=(this.scrWi-this.options.scrollBarWidth+divAdjust)+'px';
    this.innerDiv.style.height=this.hdrHt+'px';
    totHt+=divAdjust;
    this.resizeDiv.style.height=this.frozenTabs.style.height=totHt+'px';
    this.outerDiv.style.height=(totHt+this.options.scrollBarWidth)+'px';
    this.handleScroll();
  },
  
  /**
   * Hide a row in the grid.
   * sizeDivs() should be called after this function has completed.
   */
  hideRow: function(rownum) {
    if (this.columns[0].cell(rownum).style.display=='none') return;
    for (var i=0; i<this.columns.length; i++)
      this.columns[i].cell(rownum).style.display='none';
  },

  /**
   * Unhide a row in the grid.
   * sizeDivs() should be called after this function has completed.
   */
  showRow: function(rownum) {
    if (this.columns[0].cell(rownum).style.display=='') return;
    for (var i=0; i<this.columns.length; i++)
      this.columns[i].cell(rownum).style.display='';
  },

  /**
   * Search for rows that contain SearchString in column ColIdx.
   * If ShowMatch is false, then matching rows are hidden, if true then mismatching rows are hidden.
   */
  searchRows: function(ColIdx,SearchString,ShowMatch) {
    if (!SearchString) return;
    var re=new RegExp(SearchString);
    var rowcnt=this.columns[ColIdx].numRows();
    for(var r=0; r<rowcnt; r++) {
      var txt=this.cell(r,ColIdx).innerHTML;
      var matched=(txt.match(re) != null);
      if (matched != ShowMatch) this.hideRow(r);
    }
    this.sizeDivs();
    this.handleScroll();
  },

  /**
   * Unhide all rows in the grid
   */
  showAllRows: function() {
    for (var i=0; i<this.pageSize; i++)
      this.showRow(i);
    this.sizeDivs();
  },
  
  openPopup: function(elem,popupobj) {
    while (elem && !Element.hasClassName(elem,'ricoLG_cell'))
      elem=elem.parentNode;
    if (!elem) return false;
    var td=RicoUtil.getParentByTagName(elem,'td');
  
    var newLeft=Math.floor(td.offsetLeft-this.scrollDiv.scrollLeft+td.offsetWidth/2);
    if (this.direction == 'rtl') {
      if (newLeft > this.width) newLeft-=this.width;
    } else {
      if (newLeft+this.width+this.options.margin > this.scrollDiv.clientWidth) newLeft-=this.width;
    }
    popupobj.divPopup.style.visibility="hidden";
    popupobj.divPopup.style.display="block";
    var contentHt=popupobj.divPopup.offsetHeight;
    var newTop=Math.floor(elem.offsetTop-this.scrollDiv.scrollTop+elem.offsetHeight/2);
    if (newTop+contentHt+popupobj.options.margin > this.scrollDiv.clientHeight)
      newTop=Math.max(newTop-contentHt,0);
    popupobj.openPopup(this.frzWi+newLeft,this.hdrHt+newTop);
    popupobj.divPopup.style.visibility ="visible";
    return elem;
  }

};

if (Rico.Menu) {
Object.extend(Rico.Menu.prototype, {

showSimpleMenu: function(e,hideFunc) {
  Event.stop(e);
  this.hideFunc=hideFunc;
  if (this.div.childNodes.length==0) {
    this.cancelmenu();
    return false;
  }
  var elem=Event.element(e);
  this.grid.openPopup(elem,this);
  return elem;
},

showSimpleSubMenu: function(a,submenu) {
  if (this.openSubMenu) this.hideSubMenu();
  this.openSubMenu=submenu;
  this.openMenuAnchor=a;
  if (a.className=='ricoSubMenu') a.className='ricoSubMenuOpen';
  var top=parseInt(this.div.style.top);
  var left=parseInt(this.div.style.left);
  submenu.openPopup(left+a.offsetWidth,top+a.offsetTop);
  submenu.div.style.visibility ="visible";
}

});
}

Object.extend(Rico.TableColumn.prototype, {

initialize: function(grid,colIdx,hdrInfo,tabIdx) {
  this.baseInit(grid,colIdx,hdrInfo,tabIdx);
},

setUnfiltered: function() {
  this.filterRows=null;
},

filterChange: function(e) {
  var selbox=Event.element(e);
  if (selbox.value==this.liveGrid.options.FilterAllToken)
    this.setUnfiltered();
  else
    this.filterRows=this.filterHash.get(selbox.value);
  this.liveGrid.applyFilters();
},

filterKeypress: function(e) {
  var txtbox=Event.element(e);
  if (typeof this.lastKeyFilter != 'string') this.lastKeyFilter='';
  if (this.lastKeyFilter==txtbox.value) return;
  var v=txtbox.value;
  Rico.writeDebugMsg("filterKeypress: "+this.index+' '+v);
  this.lastKeyFilter=v;
  if (v) {
    v=v.replace('\\','\\\\');
    v=v.replace('(','\\(').replace(')','\\)');
    v=v.replace('.','\\.');
    if (this.format.filterUI.indexOf('^') > 0) v='^'+v;
    var re=new RegExp(v,'i');
    this.filterRows=[];
    var n=this.numRows();
    for (var i=0; i<n; i++) {
      var celltxt=RicoUtil.getInnerText(this.cell(i));
      if (celltxt.match(re)) this.filterRows.push(i);
    }
  } else {
    this.setUnfiltered();
  }
  this.liveGrid.applyFilters();
}

});

Rico.includeLoaded('ricoSimpleGrid.js');
