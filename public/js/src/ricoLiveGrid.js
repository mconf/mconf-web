/**
  *  (c) 2005-2008 Richard Cowin (http://openrico.org)
  *  (c) 2005-2008 Matt Brown (http://dowdybrown.com)
  *
  *  Rico is licensed under the Apache License, Version 2.0 (the "License"); you may not use this
  *  file except in compliance with the License. You may obtain a copy of the License at
  *   http://www.apache.org/licenses/LICENSE-2.0
  **/

if(typeof Rico=='undefined') throw("LiveGrid requires the Rico JavaScript framework");
if(typeof RicoUtil=='undefined') throw("LiveGrid requires the RicoUtil Library");
if(typeof RicoTranslate=='undefined') throw("LiveGrid requires the RicoTranslate Library");
if(typeof Rico.TableColumn=='undefined') throw("LiveGrid requires ricoGridCommon.js");


Rico.Buffer = {};

/**
 * Loads buffer with data that already exists in the document as an HTML table (no AJAX).
 * Also serves as a base class for AJAX-enabled buffers.
 */
Rico.Buffer.Base = Class.create();

Rico.Buffer.Base.prototype = {

  initialize: function(dataTable, options) {
    this.clear();
    this.updateInProgress = false;
    this.lastOffset = 0;
    this.rcvdRowCount = false;  // true if an eof element was included in the last xml response
    this.foundRowCount = false; // true if an xml response is ever received with eof true
    this.totalRows = 0;
    this.rowcntContent = "";
    this.rcvdOffset = -1;
    this.options = {
      fixedHdrRows     : 0,
      canFilter        : true,  // does buffer object support filtering?
      isEncoded        : true,  // is the data received via ajax html encoded?
      acceptAttr       : []     // attributes that can be copied from original/ajax data (e.g. className, style, id)
    }
    Object.extend(this.options, options || {});
    if (dataTable) {
      this.loadRowsFromTable(dataTable,this.options.fixedHdrRows);
    } else {
      this.clear();
    }
  },

  registerGrid: function(liveGrid) {
    this.liveGrid = liveGrid;
  },

  setTotalRows: function( newTotalRows ) {
    if (this.totalRows == newTotalRows) return;
    this.totalRows = newTotalRows;
    if (this.liveGrid) {
      Rico.writeDebugMsg("setTotalRows, newTotalRows="+newTotalRows);
      if (this.liveGrid.sizeTo=='data') this.liveGrid.resizeWindow();
      this.liveGrid.updateHeightDiv();
    }
  },

  loadRowsFromTable: function(tableElement,firstRow) {
    var newRows = new Array();
    var trs = tableElement.getElementsByTagName("tr");
    for ( var i=firstRow || 0; i < trs.length; i++ ) {
      var row = new Array();
      var cells = trs[i].getElementsByTagName("td");
      for ( var j=0; j < cells.length ; j++ )
        row[j]=cells[j].innerHTML;
      newRows.push( row );
    }
    this.loadRows(newRows);
  },

  loadRowsFromArray: function(array2D) {
    for ( var i=0; i < array2D.length; i++ )
      for ( var j=0; j < array2D[i].length ; j++ )
        array2D[i][j]=array2D[i][j].toString();
    this.loadRows(array2D);
  },

  loadRows: function(jstable) {
    this.baseRows = jstable;
    this.startPos = 0;
    this.size = this.baseRows.length;
  },

  dom2jstable: function(rowsElement) {
    Rico.writeDebugMsg('dom2jstable: encoded='+this.options.isEncoded);
    var newRows = new Array();
    var trs = rowsElement.getElementsByTagName("tr");
    for ( var i=0; i < trs.length; i++ ) {
      var row = new Array();
      var cells = trs[i].getElementsByTagName("td");
      for ( var j=0; j < cells.length ; j++ )
        row[j]=RicoUtil.getContentAsString(cells[j],this.options.isEncoded);
      newRows.push( row );
    }
    return newRows;
  },

  dom2jstableAttr: function(rowsElement,firstRow) {
    var acceptAttr=this.options.acceptAttr;
    Rico.writeDebugMsg("dom2jstableAttr start, # attr="+acceptAttr.length);
    var newRows = new Array();
    var trs = rowsElement.getElementsByTagName("tr");
    for ( var i=firstRow || 0; i < trs.length; i++ ) {
      var row = new Array();
      var cells = trs[i].getElementsByTagName("td");
      for ( var j=0; j < cells.length ; j++ ) {
        row[j]={};
        for (var k=0; k<acceptAttr.length; k++)
          row[j]['_'+acceptAttr[k]]=cells[j].getAttribute(acceptAttr[k]);
        if (Prototype.Browser.IE) row[j]._class=cells[j].getAttribute('className');
      }
      newRows.push( row );
    }
    Rico.writeDebugMsg("dom2jstableAttr end");
    return newRows;
  },

  _blankRow: function() {
    var newRow=[];
    for (var i=0; i<this.liveGrid.columns.length; i++) {
      newRow[i]='';
    }
    return newRow;
  },

  insertRow: function(beforeRowIndex) {
    this.rows.splice(beforeRowIndex,0,this._blankRow());
  },

  appendRows: function(cnt) {
    for (var i=0; i<cnt; i++)
      this.rows.push(this._blankRow());
    this.size=this.rows.length;
  },
  
  sortFunc: function(coltype) {
    switch (coltype) {
      case 'number': return this._sortNumeric.bind(this);
      case 'control':return this._sortControl.bind(this);
      default:       return this._sortAlpha.bind(this);
    }
  },

  sortBuffer: function(colnum) {
    if (!this.baseRows) {
      this.delayedSortCol=colnum;
      return;
    }
    this.liveGrid.showMsg(RicoTranslate.getPhraseById("sorting"));
    this.sortColumn=colnum;
    var col=this.liveGrid.columns[colnum];
    this.getValFunc=col._sortfunc;
    this.baseRows.sort(this.sortFunc(col.format.type));
    if (col.getSortDirection()=='DESC') this.baseRows.reverse();
  },
  
  _sortAlpha: function(a,b) {
    var aa = this.sortColumn<a.length ? RicoUtil.getInnerText(a[this.sortColumn]) : '';
    var bb = this.sortColumn<b.length ? RicoUtil.getInnerText(b[this.sortColumn]) : '';
    if (aa==bb) return 0;
    if (aa<bb) return -1;
    return 1;
  },

  _sortNumeric: function(a,b) {
    var aa = this.sortColumn<a.length ? this.nan2zero(RicoUtil.getInnerText(a[this.sortColumn])) : 0;
    var bb = this.sortColumn<b.length ? this.nan2zero(RicoUtil.getInnerText(b[this.sortColumn])) : 0;
    return aa-bb;
  },

  nan2zero: function(n) {
    if (typeof(n)=='string') n=parseFloat(n);
    return isNaN(n) || typeof(n)=='undefined' ? 0 : n;
  },
  
  _sortControl: function(a,b) {
    var aa = this.sortColumn<a.length ? RicoUtil.getInnerText(a[this.sortColumn]) : '';
    var bb = this.sortColumn<b.length ? RicoUtil.getInnerText(b[this.sortColumn]) : '';
    if (this.getValFunc) {
      aa=this.getValFunc(aa);
      bb=this.getValFunc(bb);
    }
    if (aa==bb) return 0;
    if (aa<bb) return -1;
    return 1;
  },

  clear: function() {
    this.rows = new Array();
    this.startPos = -1;
    this.size = 0;
    this.windowPos = 0;
  },

  isInRange: function(position) {
    var lastRow=Math.min(this.totalRows, position + this.liveGrid.pageSize)
    return (position >= this.startPos) && (lastRow <= this.endPos()); // && (this.size != 0);
  },

  endPos: function() {
    return this.startPos + this.rows.length;
  },

  fetch: function(offset) {
    Rico.writeDebugMsg('fetch: offset='+offset);
    this.applyFilters();
    this.setTotalRows(this.size);
    this.rcvdRowCount = true;
    this.foundRowCount = true;
    if (offset < 0) offset=0;
    this.liveGrid.refreshContents(offset);
    return;
  },

  exportAllRows: function(populate,finish) {
    populate(this.getRows(0,this.totalRows));
    finish();
  },

  setWindow: function(start, count) {
    this.windowStart = start - this.startPos;
    this.windowEnd = Math.min(this.windowStart + count,this.size);
    this.windowPos = start;
  },

  isVisible: function(bufRow) {
    return bufRow < this.rows.length && bufRow >= this.windowStart && bufRow < this.windowEnd;
  },

  getWindowCell: function(windowRow,col) {
    var bufrow=this.windowStart+windowRow;
    return this.isVisible(bufrow) && col < this.rows[bufrow].length ? this.rows[bufrow][col] : null;
  },

  getWindowAttr: function(windowRow,col) {
    var bufrow=this.windowStart+windowRow;
    return this.attr && this.isVisible(bufrow) && col < this.attr[bufrow].length ? this.attr[bufrow][col] : null;
  },

  getWindowValue: function(windowRow,col) {
    return this.getWindowCell(windowRow,col);
  },

  setWindowValue: function(windowRow,col,newval) {
    var bufRow=this.windowStart+windowRow;
    if (bufRow >= this.windowEnd) return false;
    return this.setValue(bufRow,col,newval);
  },

  getCell: function(bufRow,col) {
    return bufRow < this.size ? this.rows[bufRow][col] : null;
  },

  getValue: function(bufRow,col) {
    return this.getCell(bufRow,col);
  },

  setValue: function(bufRow,col,newval,newstyle) {
    if (bufRow>=this.size) return false;
    if (!this.rows[bufRow][col]) this.rows[bufRow][col]={};
    this.rows[bufRow][col]=newval;
    if (typeof newstyle=='string') this.rows[bufRow][col]._style=newstyle;
    this.rows[bufRow][col].modified=true;
    return true;
  },

  getRows: function(start, count) {
    var begPos = start - this.startPos;
    var endPos = Math.min(begPos + count,this.size);
    var results = new Array();
    for ( var i=begPos; i < endPos; i++ )
      results.push(this.rows[i]);
    return results
  },

  applyFilters: function() {
    var newRows=[],re=[];
    var cols=this.liveGrid.columns;
    for (var n=0,filtercnt=0; n<cols.length; n++) {
      var c=cols[n];
      if (c.filterType == Rico.TableColumn.UNFILTERED) continue;
      filtercnt++;
      if (c.filterOp=='LIKE') re[n]=new RegExp(c.filterValues[0],'i');
    }
    Rico.writeDebugMsg('applyFilters: # of filters='+filtercnt);
    if (filtercnt==0) {
      this.rows = this.baseRows;
    } else {
      for (var r=0; r<this.baseRows.length; r++) {
        var showRow=true;
        for (n=0; n<cols.length && showRow; n++) {
          var c=cols[n];
          if (c.filterType == Rico.TableColumn.UNFILTERED) continue;
          switch (c.filterOp) {
            case 'LIKE':
              showRow=re[n].test(this.baseRows[r][n]);
              break;
            case 'EQ':
              showRow=this.baseRows[r][n]==c.filterValues[0];
              break;
            case 'NE':
              for (var i=0; i<c.filterValues.length && showRow; i++)
                showRow=this.baseRows[r][n]!=c.filterValues[i];
              break;
            case 'LE':
              if (c.format.type=='number')
                showRow=this.nan2zero(this.baseRows[r][n])<=this.nan2zero(c.filterValues[0]);
              else
                showRow=this.baseRows[r][n]<=c.filterValues[0];
              break;
            case 'GE':
              if (c.format.type=='number')
                showRow=this.nan2zero(this.baseRows[r][n])>=this.nan2zero(c.filterValues[0]);
              else
                showRow=this.baseRows[r][n]>=c.filterValues[0];
              break;
            case 'NULL':
              showRow=this.baseRows[r][n]=='';
              break;
            case 'NOTNULL':
              showRow=this.baseRows[r][n]!='';
              break;
          }
        }
        if (showRow) newRows.push(this.baseRows[r]);
      }
      this.rows = newRows;
    }
    this.rowcntContent = this.size = this.rows.length;
  }

};


// Rico.LiveGrid -----------------------------------------------------

Rico.LiveGrid = Class.create();

Rico.LiveGrid.prototype = {

  initialize: function( tableId, buffer, options ) {
    Object.extend(this, new Rico.GridCommon);
    Object.extend(this, new Rico.LiveGridMethods);
    this.baseInit();
    this.tableId = tableId;
    this.buffer = buffer;
    Rico.setDebugArea(tableId+"_debugmsgs");    // if used, this should be a textarea

    Object.extend(this.options, {
      visibleRows      : -1,    // -1 or 'window'=size grid to client window; -2 or 'data'=size grid to min(window,data); -3 or 'body'=size so body does not have a scrollbar; -4 or 'parent'=size to parent element (e.g. if grid is inside a div)
      frozenColumns    : 0,
      offset           : 0,     // first row to be displayed
      prefetchBuffer   : true,  // load table on page load?
      minPageRows      : 2,
      maxPageRows      : 50,
      canSortDefault   : true,  // can be overridden in the column specs
      canFilterDefault : buffer.options.canFilter, // can be overridden in the column specs
      canHideDefault   : true,  // can be overridden in the column specs

      // highlight & selection parameters
      highlightElem    : 'none',// what gets highlighted/selected (cursorRow, cursorCell, menuRow, menuCell, selection, or none)
      highlightSection : 3,     // which section gets highlighted (frozen=1, scrolling=2, all=3, none=0)
      highlightMethod  : 'class', // outline, class, both (outline is less CPU intensive on the client)
      highlightClass   : 'ricoLG_selection',

      // export/print parameters
      maxPrint         : 1000,  // max # of rows that can be printed/exported, 0=disable print/export feature

      // heading parameters
      headingSort      : 'link', // link: make headings a link that will sort column, hover: make headings a hoverset, none: events on headings are disabled
      hdrIconsFirst    : true,   // true: put sort & filter icons before header text, false: after
      sortAscendImg    : 'sort_asc.gif',
      sortDescendImg   : 'sort_desc.gif',
      filterImg        : 'filtercol.gif'
    });
    // other options:
    //   sortCol: initial sort column

    this.options.sortHandler = this.sortHandler.bind(this);
    this.options.filterHandler = this.filterHandler.bind(this);
    this.options.onRefreshComplete = this.bookmarkHandler.bind(this);
    this.options.rowOverHandler = this.rowMouseOver.bindAsEventListener(this);
    this.options.mouseDownHandler = this.selectMouseDown.bindAsEventListener(this);
    this.options.mouseOverHandler = this.selectMouseOver.bindAsEventListener(this);
    this.options.mouseUpHandler  = this.selectMouseUp.bindAsEventListener(this);
    Object.extend(this.options, options || {});

    switch (typeof this.options.visibleRows) {
      case 'string':
        this.sizeTo=this.options.visibleRows;
        switch (this.options.visibleRows) {
          case 'data':   this.options.visibleRows=-2; break;
          case 'body':   this.options.visibleRows=-3; break;
          case 'parent': this.options.visibleRows=-4; break;
          default:       this.options.visibleRows=-1; break;
        }
        break;
      case 'number':
        switch (this.options.visibleRows) {
          case -1: this.sizeTo='window'; break;
          case -2: this.sizeTo='data'; break;
          case -3: this.sizeTo='body'; break;
          case -4: this.sizeTo='parent'; break;
          default: this.sizeTo='fixed'; break;
        }
        break;
      default:
        this.sizeTo='window';
        this.options.visibleRows=-1;
    }
    this.highlightEnabled=this.options.highlightSection>0;
    this.pageSize=0;
    this.createTables();
    if (this.headerColCnt==0) {
      alert('ERROR: no columns found in "'+this.tableId+'"');
      return;
    }
    this.createColumnArray();
    if (this.options.headingSort=='hover')
      this.createHoverSet();

    this.bookmark=$(this.tableId+"_bookmark");
    this.sizeDivs();
    var filterUIrow=this.buffer.options.canFilter ? this.options.FilterLocation : false;
    if (typeof(filterUIrow)=='number' && filterUIrow<0)
      filterUIrow=this.addHeadingRow();
    this.createDataCells(this.options.visibleRows);
    if (this.pageSize == 0) return;
    this.buffer.registerGrid(this);
    if (this.buffer.setBufferSize) this.buffer.setBufferSize(this.pageSize);
    this.scrollTimeout = null;
    this.lastScrollPos = 0;
    this.attachMenuEvents();

    // preload the images...
    new Image().src = Rico.imgDir+this.options.filterImg;
    new Image().src = Rico.imgDir+this.options.sortAscendImg;
    new Image().src = Rico.imgDir+this.options.sortDescendImg;
    Rico.writeDebugMsg("images preloaded");

    this.setSortUI( this.options.sortCol, this.options.sortDir );
    this.setImages();
    if (this.listInvisible().length==this.columns.length)
      this.columns[0].showColumn();
    this.sizeDivs();
    this.scrollDiv.style.display="";
    if (this.buffer.totalRows>0)
      this.updateHeightDiv();
    if (this.options.prefetchBuffer) {
      if (this.bookmark) this.bookmark.innerHTML = RicoTranslate.getPhraseById('bookmarkLoading');
      if (this.options.canFilterDefault && this.options.getQueryParms)
        this.checkForFilterParms();
      this.buffer.fetch(this.options.offset);
    }
    if (typeof(filterUIrow)=='number')
      this.createFilters(filterUIrow);
    this.scrollEventFunc=this.handleScroll.bindAsEventListener(this);
    this.wheelEventFunc=this.handleWheel.bindAsEventListener(this);
    this.wheelEvent=(Prototype.Browser.IE || Prototype.Browser.Opera || Prototype.Browser.WebKit) ? 'mousewheel' : 'DOMMouseScroll';
    if (this.options.offset && this.options.offset < this.buffer.totalRows)
      setTimeout(this.scrollToRow.bind(this,this.options.offset),50);  // Safari requires a delay
    this.pluginScroll();
    this.setHorizontalScroll();
    if (this.options.windowResize)
      setTimeout(this.pluginWindowResize.bind(this),100);
  }
};

Rico.LiveGridMethods = function() {};

Rico.LiveGridMethods.prototype = {

  createHoverSet: function() {
    var hdrs=[];
    for( var c=0; c < this.headerColCnt; c++ )
      if (this.columns[c].sortable)
        hdrs.push(this.columns[c].hdrCellDiv);
    this.hoverSet = new Rico.HoverSet(hdrs);
  },

  checkForFilterParms: function() {
    var s=window.location.search;
    if (s.charAt(0)=='?') s=s.substring(1);
    var pairs = s.split('&');
    for (var i=0; i<pairs.length; i++)
      if (pairs[i].match(/^f\[\d+\]/)) {
        this.buffer.options.requestParameters.push(pairs[i]);
      }
  },

/**
 * Create one table for frozen columns and one for scrolling columns.
 * Also create div's to contain them.
 */
  createTables: function() {
    var insertloc;
    var result = -1;
    var table = $(this.tableId) || $(this.tableId+'_outerDiv');
    if (!table) return result;
    if (table.tagName.toLowerCase()=='table') {
      var theads=table.getElementsByTagName("thead");
      if (theads.length == 1) {
        Rico.writeDebugMsg("createTables: using thead section, id="+this.tableId);
        if (this.options.PanelNamesOnTabHdr && this.options.panels) {
          var r=theads[0].insertRow(0);
          this.insertPanelNames(r, 0, this.options.frozenColumns, 'ricoFrozen');
          this.insertPanelNames(r, this.options.frozenColumns, this.options.columnSpecs.length);
        }
        var hdrSrc=theads[0].rows;
      } else {
        Rico.writeDebugMsg("createTables: using tbody section, id="+this.tableId);
        var hdrSrc=new Array(table.rows[0]);
      }
      insertloc=table;
    } else if (this.options.columnSpecs.length > 0) {
      if (!table.id.match(/_outerDiv$/)) insertloc=table;
      Rico.writeDebugMsg("createTables: inserting at "+table.tagName+", id="+this.tableId);
    } else {
      alert("ERROR!\n\nUnable to initialize '"+this.tableId+"'\n\nLiveGrid terminated");
      return result;
    }

    this.createDivs();
    this.scrollTabs = this.createDiv("scrollTabs",this.innerDiv);
    this.shadowDiv  = this.createDiv("shadow",this.scrollDiv);
    this.shadowDiv.style.direction='ltr';  // avoid FF bug
    this.scrollDiv.style.display="none";
    this.scrollDiv.scrollTop=0;
    if (this.options.highlightMethod!='class') {
      this.highlightDiv=[];
      switch (this.options.highlightElem) {
        case 'menuRow':
        case 'cursorRow':
          this.highlightDiv[0] = this.createDiv("highlight",this.outerDiv);
          this.highlightDiv[0].style.display="none";
          break;
        case 'menuCell':
        case 'cursorCell':
          for (var i=0; i<2; i++) {
            this.highlightDiv[i] = this.createDiv("highlight",i==0 ? this.frozenTabs : this.scrollTabs);
            this.highlightDiv[i].style.display="none";
            this.highlightDiv[i].id+=i;
          }
          break;
        case 'selection':
          // create one div for each side of the rectangle
          var parentDiv=this.options.highlightSection==1 ? this.frozenTabs : this.scrollTabs;
          for (var i=0; i<4; i++) {
            this.highlightDiv[i] = this.createDiv("highlight",parentDiv);
            this.highlightDiv[i].style.display="none";
            this.highlightDiv[i].style.overflow="hidden";
            this.highlightDiv[i].id+=i;
            this.highlightDiv[i].style[i % 2==0 ? 'height' : 'width']="0px";
          }
          break;
      }
    }

    // create new tables
    for (var i=0; i<2; i++) {
      this.tabs[i] = document.createElement("table");
      this.tabs[i].className = 'ricoLG_table';
      this.tabs[i].border=0;
      this.tabs[i].cellPadding=0;
      this.tabs[i].cellSpacing=0;
      this.tabs[i].id = this.tableId+"_tab"+i;
      this.thead[i]=this.tabs[i].createTHead();
      this.thead[i].className='ricoLG_top';
      if (this.tabs[i].tBodies.length==0)
        this.tbody[i]=this.tabs[i].appendChild(document.createElement("tbody"));
      else
        this.tbody[i]=this.tabs[i].tBodies[0];
      this.tbody[i].className='ricoLG_bottom';
      this.tbody[i].insertRow(-1);
    }
    this.frozenTabs.appendChild(this.tabs[0]);
    this.scrollTabs.appendChild(this.tabs[1]);
    if (insertloc) insertloc.parentNode.insertBefore(this.outerDiv,insertloc);
    if (hdrSrc) {
      this.headerColCnt = this.getColumnInfo(hdrSrc);
      this.loadHdrSrc(hdrSrc);
    } else {
      this.createHdr(0,0,this.options.frozenColumns);
      this.createHdr(1,this.options.frozenColumns,this.options.columnSpecs.length);
      if (this.options.PanelNamesOnTabHdr && this.options.panels) {
        this.insertPanelNames(this.thead[0].insertRow(0), 0, this.options.frozenColumns);
        this.insertPanelNames(this.thead[1].insertRow(0), this.options.frozenColumns, this.options.columnSpecs.length);
      }
      for (var i=0; i<2; i++)
        this.headerColCnt = this.getColumnInfo(this.thead[i].rows);
    }
    for( var c=0; c < this.headerColCnt; c++ )
      this.tbody[c<this.options.frozenColumns ? 0 : 1].rows[0].insertCell(-1);
    if (insertloc) table.parentNode.removeChild(table);
    Rico.writeDebugMsg('createTables end');
  },

  createDataCells: function(visibleRows) {
    if (visibleRows < 0) {
      for (var i=0; i<this.options.minPageRows; i++)
        this.appendBlankRow();
      this.sizeDivs();
      this.autoAppendRows(this.remainingHt());
    } else {
      for( var r=0; r < visibleRows; r++ )
        this.appendBlankRow();
    }
    var s=this.options.highlightSection;
    if (s & 1) this.attachHighlightEvents(this.tbody[0]);
    if (s & 2) this.attachHighlightEvents(this.tbody[1]);
  },

  // return id string for a filter element
  filterId: function(colnum) {
    return 'RicoFilter_'+this.tableId+'_'+colnum;
  },

  // create filter elements on heading row r
  createFilters: function(r) {
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
          if (col.filterType==Rico.TableColumn.USERFILTER && col.filterOp=='LIKE') {
            var v=col.filterValues[0];
            if (v.charAt(0)=='*') v=v.substr(1);
            if (v.slice(-1)=='*') v=v.slice(0,-1);
            field.value=v;
            col.lastKeyFilter=v;
          }
          Event.observe(field,'keyup',col.filterKeypress.bindAsEventListener(col),false);
          break;
        case 's':
          field=RicoUtil.createFormField(divs[1],'select',null,name);
          RicoUtil.addSelectOption(field,this.options.FilterAllToken,RicoTranslate.getPhraseById("filterAll"));
          var options={};
          Object.extend(options, this.buffer.ajaxOptions);
          var colnum=fmt.filterUI.length>1 ? fmt.filterUI.substr(1) : c;
          options.parameters = 'id='+this.tableId+'&distinct='+colnum;
          options.onComplete = this.filterValuesUpdate.bind(this,c);
          new Ajax.Request(this.buffer.dataSource, options);
          break;
      }
    }
    this.initFilterImage(r);
  },

  // update select list filter with values in AJAX response
  filterValuesUpdate: function(colnum,request) {
    var response = request.responseXML.getElementsByTagName("ajax-response");
    Rico.writeDebugMsg("filterValuesUpdate: "+request.status);
    if (response == null || response.length != 1) return;
    response=response[0];
    var error = response.getElementsByTagName('error');
    if (error.length > 0) {
      Rico.writeDebugMsg("Data provider returned an error:\n"+RicoUtil.getContentAsString(error[0],this.buffer.isEncoded));
      alert(RicoTranslate.getPhraseById("requestError",RicoUtil.getContentAsString(error[0],this.buffer.isEncoded)));
      return null;
    }
    response=response.getElementsByTagName('response')[0];
    var rowsElement = response.getElementsByTagName('rows')[0];
    //var colnum = rowsElement.getAttribute("distinct");
    var col=this.columns[parseInt(colnum)];
    var rows = this.buffer.dom2jstable(rowsElement);
    var v, field=$(this.filterId(colnum));
    if (col.filterType==Rico.TableColumn.USERFILTER && col.filterOp=='EQ') v=col.filterValues[0];
    Rico.writeDebugMsg('filterValuesUpdate: col='+colnum+' rows='+rows.length);
    for (var i=0; i<rows.length; i++) {
      if (rows[i].length>0) {
        var c0=rows[i][0];
        var opt=RicoUtil.addSelectOption(field,c0,c0 || RicoTranslate.getPhraseById("filterBlank"));
        if (col.filterType==Rico.TableColumn.USERFILTER && c0==v) opt.selected=true;
      }
    }
    Event.observe(field,'change',col.filterChange.bindAsEventListener(col),false);
  },

  unplugHighlightEvents: function() {
    var s=this.options.highlightSection;
    if (s & 1) this.detachHighlightEvents(this.tbody[0]);
    if (s & 2) this.detachHighlightEvents(this.tbody[1]);
  },

  // place panel names on first row of grid header (used by LiveGridForms)
  insertPanelNames: function(r,start,limit,cellClass) {
    Rico.writeDebugMsg('insertPanelNames: start='+start+' limit='+limit);
    r.className='ricoLG_hdg';
    var lastIdx=-1, span, newCell=null, spanIdx=0;
    for( var c=start; c < limit; c++ ) {
      if (lastIdx == this.options.columnSpecs[c].panelIdx) {
        span++;
      } else {
        if (newCell) newCell.colSpan=span;
        newCell = r.insertCell(-1);
        if (cellClass) newCell.className=cellClass
        span=1;
        lastIdx=this.options.columnSpecs[c].panelIdx;
        newCell.innerHTML=this.options.panels[lastIdx];
      }
    }
    if (newCell) newCell.colSpan=span;
  },

  // create grid header for table i (if none was provided)
  createHdr: function(i,start,limit) {
    Rico.writeDebugMsg('createHdr: i='+i+' start='+start+' limit='+limit);
    var mainRow = this.thead[i].insertRow(-1);
    mainRow.id=this.tableId+'_tab'+i+'h_main';
    mainRow.className='ricoLG_hdg';
    for( var c=start; c < limit; c++ ) {
      var newCell = mainRow.insertCell(-1);
      newCell.innerHTML=this.options.columnSpecs[c].Hdg;
    }
  },

  // move header cells in original table to grid
  loadHdrSrc: function(hdrSrc) {
    Rico.writeDebugMsg('loadHdrSrc start');
    for (var i=0; i<2; i++) {
      for (var r=0; r<hdrSrc.length; r++) {
        var newrow = this.thead[i].insertRow(-1);
        newrow.className='ricoLG_hdg '+this.tableId+'_hdg'+r;
      }
    }
    if (hdrSrc.length==1) {
      var cells=hdrSrc[0].cells;
      for (var c=0; cells.length > 0; c++)
        this.thead[c<this.options.frozenColumns ? 0 : 1].rows[0].appendChild(cells[0]);
    } else {
      for (var r=0; r<hdrSrc.length; r++) {
        var cells=hdrSrc[r].cells;
        for (var c=0,h=0; cells.length > 0; c++) {
          if (cells[0].className=='ricoFrozen') {
            if (r==this.headerRowIdx) this.options.frozenColumns=c+1;
          } else {
            h=1;
          }
          this.thead[h].rows[r].appendChild(cells[0]);
        }
      }
    }
    Rico.writeDebugMsg('loadHdrSrc end');
  },

  sizeDivs: function() {
    Rico.writeDebugMsg('sizeDivs: '+this.tableId);
    //this.cancelMenu();
    this.unhighlight();
    this.baseSizeDivs();
    var firstVisible=this.firstVisible();
    if (this.pageSize == 0 || firstVisible < 0) return;
    var totRowHt=this.columns[firstVisible].dataColDiv.offsetHeight;
    this.rowHeight = Math.round(totRowHt/this.pageSize);
    var scrHt=this.dataHt;
    if (this.scrWi>0 || Prototype.Browser.IE || Prototype.Browser.WebKit)
      scrHt+=this.options.scrollBarWidth;
    this.scrollDiv.style.height=scrHt+'px';
    this.innerDiv.style.width=(this.scrWi-this.options.scrollBarWidth+1)+'px';
    this.resizeDiv.style.height=this.frozenTabs.style.height=this.innerDiv.style.height=(this.hdrHt+this.dataHt+1)+'px';
    Rico.writeDebugMsg('sizeDivs scrHt='+scrHt+' innerHt='+this.innerDiv.style.height+' rowHt='+this.rowHeight+' pageSize='+this.pageSize);
    pad=(this.scrWi-this.scrTabWi < this.options.scrollBarWidth) ? 2 : 0;
    this.shadowDiv.style.width=(this.scrTabWi+pad)+'px';
    this.outerDiv.style.height=(this.hdrHt+scrHt)+'px';
    this.setHorizontalScroll();
  },

  setHorizontalScroll: function() {
    var scrleft=this.scrollDiv.scrollLeft;
    this.scrollTabs.style.left=(-scrleft)+'px';
  },

  remainingHt: function() {
    var winHt=RicoUtil.windowHeight();
    var margin=Prototype.Browser.IE ? 15 : 10;
    // if there is a horizontal scrollbar take it into account
    if (!Prototype.Browser.IE && window.frameElement && window.frameElement.scrolling=='yes' && this.sizeTo!='parent') margin+=this.options.scrollBarWidth;
    switch (this.sizeTo) {
      case 'window':
      case 'data':
        var divPos=Position.page(this.outerDiv);
        var tabHt=Math.max(this.tabs[0].offsetHeight,this.tabs[1].offsetHeight);
        Rico.writeDebugMsg("remainingHt, winHt="+winHt+' tabHt='+tabHt+' gridY='+divPos[1]);
        return winHt-divPos[1]-tabHt-this.options.scrollBarWidth-margin;  // allow for scrollbar and some margin
      case 'parent':
        return this.outerDiv.parentNode.offsetHeight - this.outerDiv.offsetHeight - this.options.scrollBarWidth - margin;
      case 'body':
        //Rico.writeDebugMsg("remainingHt, document.height="+document.height);
        //Rico.writeDebugMsg("remainingHt, body.offsetHeight="+document.body.offsetHeight);
        //Rico.writeDebugMsg("remainingHt, body.scrollHeight="+document.body.scrollHeight);
        //Rico.writeDebugMsg("remainingHt, documentElement.scrollHeight="+document.documentElement.scrollHeight);
        var bodyHt=Prototype.Browser.IE ? document.body.scrollHeight : document.body.offsetHeight;
        var remHt=winHt-bodyHt-margin;
        if (!Prototype.Browser.WebKit) remHt-=this.options.scrollBarWidth;
        Rico.writeDebugMsg("remainingHt, winHt="+winHt+' pageHt='+bodyHt+' remHt='+remHt);
        return remHt;
    }
  },

  adjustPageSize: function() {
    var remHt=this.remainingHt();
    Rico.writeDebugMsg('adjustPageSize remHt='+remHt+' lastRow='+this.lastRowPos);
    if (remHt > this.rowHeight)
      this.autoAppendRows(remHt);
    else if (remHt < 0 || this.sizeTo=='data')
      this.autoRemoveRows(-remHt);
  },

  pluginWindowResize: function() {
    this.resizeWindowHandler=this.resizeWindow.bindAsEventListener(this);
    Event.observe(window, "resize", this.resizeWindowHandler, false);
  },

  unplugWindowResize: function() {
    if (!this.resizeWindowHandler) return;
    Event.stopObserving(window,"resize", this.resizeWindowHandler, false);
    this.resizeWindowHandler=null;
  },

  resizeWindow: function() {
    Rico.writeDebugMsg('resizeWindow '+this.tableId+' lastRow='+this.lastRowPos);
    if (!this.sizeTo) {
      this.sizeDivs();
      return;
    }
    var oldSize=this.pageSize;
    this.adjustPageSize();
    if (this.pageSize > oldSize) {
      this.isPartialBlank=true;
      var adjStart=this.adjustRow(this.lastRowPos);
      this.buffer.fetch(adjStart);
    } else if (this.pageSize < oldSize) {
      if (this.options.onRefreshComplete) this.options.onRefreshComplete(this.contentStartPos,this.contentStartPos+this.pageSize-1);  // update bookmark
    }
    if (oldSize != this.pageSize)
      setTimeout(this.finishResize.bind(this),50);
    else
      this.sizeDivs();
    Rico.writeDebugMsg('resizeWindow complete. old size='+oldSize+' new size='+this.pageSize);
  },

  finishResize: function() {
    this.sizeDivs();
    this.updateHeightDiv();
  },

  topOfLastPage: function() {
    return Math.max(this.buffer.totalRows-this.pageSize,0);
  },

  updateHeightDiv: function() {
    var notdisp=this.topOfLastPage();
    var ht = this.scrollDiv.clientHeight + this.rowHeight * notdisp;
    Rico.writeDebugMsg("updateHeightDiv, ht="+ht+' scrollDiv.clientHeight='+this.scrollDiv.clientHeight+' rowsNotDisplayed='+notdisp);
    this.shadowDiv.style.height=ht+'px';
  },

  autoRemoveRows: function(overage) {
    if (!this.rowHeight) return;
    var removeCnt=Math.ceil(overage / this.rowHeight);
    if (this.sizeTo=='data')
      removeCnt=Math.max(removeCnt,this.pageSize-this.buffer.totalRows);
    Rico.writeDebugMsg("autoRemoveRows overage="+overage+" removeCnt="+removeCnt);
    for (var i=0; i<removeCnt; i++)
      this.removeRow();
  },

  removeRow: function() {
    if (this.pageSize <= this.options.minPageRows) return;
    this.pageSize--;
    for( var c=0; c < this.headerColCnt; c++ ) {
      var cell=this.columns[c].cell(this.pageSize);
      this.columns[c].dataColDiv.removeChild(cell);
    }
  },

  autoAppendRows: function(overage) {
    if (!this.rowHeight) return;
    var addCnt=Math.floor(overage / this.rowHeight);
    Rico.writeDebugMsg("autoAppendRows overage="+overage+" cnt="+addCnt+" rowHt="+this.rowHeight);
    for (var i=0; i<addCnt; i++) {
      if (this.sizeTo=='data' && this.pageSize>=this.buffer.totalRows) break;
      this.appendBlankRow();
    }
  },

  // on older systems, this can be fairly slow
  appendBlankRow: function() {
    if (this.pageSize >= this.options.maxPageRows) return;
    Rico.writeDebugMsg("appendBlankRow #"+this.pageSize);
    var cls=this.defaultRowClass(this.pageSize);
    for( var c=0; c < this.headerColCnt; c++ ) {
      var newdiv = document.createElement("div");
      newdiv.className = 'ricoLG_cell '+cls;
      newdiv.id=this.tableId+'_'+this.pageSize+'_'+c;
      this.columns[c].dataColDiv.appendChild(newdiv);
      newdiv.innerHTML='&nbsp;';
      if (this.columns[c]._create)
        this.columns[c]._create(newdiv,this.pageSize);
    }
    this.pageSize++;
  },

  defaultRowClass: function(rownum) {
    return (rownum % 2==0) ? 'ricoLG_evenRow' : 'ricoLG_oddRow';
  },

  handleMenuClick: function(e) {
    if (!this.menu) return;
    this.cancelMenu();
    this.unhighlight(); // in case highlighting was invoked externally
    var cell=Event.element(e);
    if (cell.className=='ricoLG_highlightDiv') {
      var idx=this.highlightIdx;
    } else {
      cell=RicoUtil.getParentByTagName(cell,'div','ricoLG_cell');
      if (!cell) return;
      var idx=this.winCellIndex(cell);
      if ((this.options.highlightSection & (idx.tabIdx+1))==0) return;
    }
    this.highlight(idx);
    this.highlightEnabled=false;
    if (this.hideScroll) this.scrollDiv.style.overflow="hidden";
    this.menuIdx=idx;
    if (!this.menu.div) this.menu.createDiv();
    this.menu.liveGrid=this;
    if (this.menu.buildGridMenu) {
      var showMenu=this.menu.buildGridMenu(idx.row, idx.column, idx.tabIdx);
      if (!showMenu) return;
    }
    if (this.options.highlightElem=='selection' && !this.isSelected(idx.cell))
      this.selectCell(idx.cell);
    this.menu.showmenu(e,this.closeMenu.bind(this));
  },

  closeMenu: function() {
    if (!this.menuIdx) return;
    if (this.hideScroll) this.scrollDiv.style.overflow="";
    this.unhighlight();
    this.highlightEnabled=true;
    this.menuIdx=null;
  },

/**
 * @return index of cell within the window
 */
  winCellIndex: function(cell) {
    var a=cell.id.split(/_/);
    var l=a.length;
    var r=parseInt(a[l-2]);
    var c=parseInt(a[l-1]);
    return {row:r, column:c, tabIdx:this.columns[c].tabIdx, cell:cell};
  },

/**
 * @return index of cell within the buffer
 */
  bufCellIndex: function(cell) {
    var idx=this.winCellIndex(cell);
    idx.row+=this.buffer.windowPos;
    if (idx.row >= this.buffer.size) idx.onBlankRow=true;
    return idx;
  },

  attachHighlightEvents: function(tBody) {
    switch (this.options.highlightElem) {
      case 'selection':
        Event.observe(tBody,"mousedown", this.options.mouseDownHandler, false);
        tBody.ondrag = function () { return false; };
        tBody.onselectstart = function () { return false; };
        break;
      case 'cursorRow':
      case 'cursorCell':
        Event.observe(tBody,"mouseover", this.options.rowOverHandler, false);
        break;
    }
  },

  detachHighlightEvents: function(tBody) {
    switch (this.options.highlightElem) {
      case 'selection':
        Event.stopObserving(tBody,"mousedown", this.options.mouseDownHandler, false);
        tBody.ondrag = null;
        tBody.onselectstart = null;
        break;
      case 'cursorRow':
      case 'cursorCell':
        Event.stopObserving(tBody,"mouseover", this.options.rowOverHandler, false);
        break;
    }
  },

  getVisibleSelection: function() {
    var cellList=[];
    if (this.SelectIdxStart && this.SelectIdxEnd) {
      var r1=Math.max(Math.min(this.SelectIdxEnd.row,this.SelectIdxStart.row),this.buffer.windowPos);
      var r2=Math.min(Math.max(this.SelectIdxEnd.row,this.SelectIdxStart.row),this.buffer.windowEnd-1);
      var c1=Math.min(this.SelectIdxEnd.column,this.SelectIdxStart.column);
      var c2=Math.max(this.SelectIdxEnd.column,this.SelectIdxStart.column);
      for (var r=r1; r<=r2; r++)
        for (var c=c1; c<=c2; c++)
          cellList.push({row:r-this.buffer.windowPos,column:c});
    }
    if (this.SelectCtrl) {
      for (var i=0; i<this.SelectCtrl.length; i++) {
        if (this.SelectCtrl[i].row>=this.buffer.windowPos && this.SelectCtrl[i].row<this.buffer.windowEnd)
          cellList.push({row:this.SelectCtrl[i].row-this.buffer.windowPos,column:this.SelectCtrl[i].column});
      }
    }
    return cellList;
  },

  updateSelectOutline: function() {
    if (!this.SelectIdxStart || !this.SelectIdxEnd) return;
    var r1=Math.max(Math.min(this.SelectIdxEnd.row,this.SelectIdxStart.row), this.buffer.windowStart);
    var r2=Math.min(Math.max(this.SelectIdxEnd.row,this.SelectIdxStart.row), this.buffer.windowEnd-1);
    if (r1 > r2) {
      this.HideSelection();
      return;
    }
    var c1=Math.min(this.SelectIdxEnd.column,this.SelectIdxStart.column);
    var c2=Math.max(this.SelectIdxEnd.column,this.SelectIdxStart.column);
    var top1=this.columns[c1].cell(r1-this.buffer.windowStart).offsetTop;
    var cell2=this.columns[c1].cell(r2-this.buffer.windowStart);
    var bottom2=cell2.offsetTop+cell2.offsetHeight;
    var left1=this.columns[c1].dataCell.offsetLeft;
    var left2=this.columns[c2].dataCell.offsetLeft;
    var right2=left2+this.columns[c2].dataCell.offsetWidth;
    //window.status='updateSelectOutline: '+r1+' '+r2+' top='+top1+' bot='+bottom2;
    this.highlightDiv[0].style.top=this.highlightDiv[3].style.top=this.highlightDiv[1].style.top=(this.hdrHt+top1-1) + 'px';
    this.highlightDiv[2].style.top=(this.hdrHt+bottom2-1)+'px';
    this.highlightDiv[3].style.left=(left1-2)+'px';
    this.highlightDiv[0].style.left=this.highlightDiv[2].style.left=(left1-1)+'px';
    this.highlightDiv[1].style.left=(right2-1)+'px';
    this.highlightDiv[0].style.width=this.highlightDiv[2].style.width=(right2-left1-1) + 'px';
    this.highlightDiv[1].style.height=this.highlightDiv[3].style.height=(bottom2-top1) + 'px';
    //this.highlightDiv[0].style.right=this.highlightDiv[2].style.right=this.highlightDiv[1].style.right=()+'px';
    //this.highlightDiv[2].style.bottom=this.highlightDiv[3].style.bottom=this.highlightDiv[1].style.bottom=(this.hdrHt+bottom2) + 'px';
    for (var i=0; i<4; i++)
      this.highlightDiv[i].style.display='';
  },

  HideSelection: function(cellList) {
    if (this.options.highlightMethod!='class') {
      for (var i=0; i<this.highlightDiv.length; i++)
        this.highlightDiv[i].style.display='none';
    }
    if (this.options.highlightMethod!='outline') {
      var cellList=this.getVisibleSelection();
      for (var i=0; i<cellList.length; i++)
        this.unhighlightCell(this.columns[cellList[i].column].cell(cellList[i].row));
    }
  },

  ShowSelection: function() {
    if (this.options.highlightMethod!='class')
      this.updateSelectOutline();
    if (this.options.highlightMethod!='outline') {
      var cellList=this.getVisibleSelection();
      for (var i=0; i<cellList.length; i++)
        this.highlightCell(this.columns[cellList[i].column].cell(cellList[i].row));
    }
  },

  ClearSelection: function() {
    this.HideSelection();
    this.SelectIdxStart=null;
    this.SelectIdxEnd=null;
    this.SelectCtrl=[];
  },

  selectCell: function(cell) {
    this.ClearSelection();
    this.SelectIdxStart=this.SelectIdxEnd=this.bufCellIndex(cell);
    this.ShowSelection();
  },

  AdjustSelection: function(cell) {
    var newIdx=this.bufCellIndex(cell);
    if (this.SelectIdxStart.tabIdx != newIdx.tabIdx) return;
    this.HideSelection();
    this.SelectIdxEnd=newIdx;
    this.ShowSelection();
  },

  RefreshSelection: function() {
    var cellList=this.getVisibleSelection();
    for (var i=0; i<cellList.length; i++)
      this.columns[cellList[i].column].displayValue(cellList[i].row);
  },

  FillSelection: function(newVal,newStyle) {
    if (this.SelectIdxStart && this.SelectIdxEnd) {
      var r1=Math.min(this.SelectIdxEnd.row,this.SelectIdxStart.row);
      var r2=Math.max(this.SelectIdxEnd.row,this.SelectIdxStart.row);
      var c1=Math.min(this.SelectIdxEnd.column,this.SelectIdxStart.column);
      var c2=Math.max(this.SelectIdxEnd.column,this.SelectIdxStart.column);
      for (var r=r1; r<=r2; r++)
        for (var c=c1; c<=c2; c++)
          this.buffer.setValue(r,c,newVal,newStyle);
    }
    if (this.SelectCtrl) {
      for (var i=0; i<this.SelectCtrl.length; i++)
        this.buffer.setValue(this.SelectCtrl[i].row,this.SelectCtrl[i].column,newVal,newStyle);
    }
    this.RefreshSelection();
  },

  selectMouseDown: function(e) {
    if (this.highlightEnabled==false) return true;
    this.cancelMenu();
    var cell=Event.element(e);
    Event.stop(e);
    if (!Event.isLeftClick(e)) return;
    cell=RicoUtil.getParentByTagName(cell,'div','ricoLG_cell');
    if (!cell) return;
    var newIdx=this.bufCellIndex(cell);
    if (newIdx.onBlankRow) return;
    if (e.ctrlKey) {
      if (!this.SelectIdxStart || this.options.highlightMethod!='class') return;
      if (!this.isSelected(cell)) {
        this.highlightCell(cell);
        this.SelectCtrl.push(this.bufCellIndex(cell));
      } else {
        for (var i=0; i<this.SelectCtrl.length; i++) {
          if (this.SelectCtrl[i].row==newIdx.row && this.SelectCtrl[i].column==newIdx.column) {
            this.unhighlightCell(cell);
            this.SelectCtrl.splice(i,1);
            break;
          }
        }
      }
    } else if (e.shiftKey) {
      if (!this.SelectIdxStart) return;
      this.AdjustSelection(cell);
    } else {
      this.selectCell(cell);
      this.pluginSelect();
    }
  },

  pluginSelect: function() {
    if (this.selectPluggedIn) return;
    var tBody=this.tbody[this.SelectIdxStart.tabIdx];
    Event.observe(tBody,"mouseover", this.options.mouseOverHandler, false);
    Event.observe(this.outerDiv,"mouseup",  this.options.mouseUpHandler,  false);
    this.selectPluggedIn=true;
  },

  unplugSelect: function() {
    if (!this.selectPluggedIn) return;
    var tBody=this.tbody[this.SelectIdxStart.tabIdx];
    Event.stopObserving(tBody,"mouseover", this.options.mouseOverHandler , false);
    Event.stopObserving(this.outerDiv,"mouseup", this.options.mouseUpHandler , false);
    this.selectPluggedIn=false;
  },

  selectMouseUp: function(e) {
    this.unplugSelect();
    var cell=Event.element(e);
    cell=RicoUtil.getParentByTagName(cell,'div','ricoLG_cell');
    if (!cell) return;
    if (this.SelectIdxStart && this.SelectIdxEnd)
      this.AdjustSelection(cell);
    else
      this.ClearSelection();
  },

  selectMouseOver: function(e) {
    var cell=Event.element(e);
    cell=RicoUtil.getParentByTagName(cell,'div','ricoLG_cell');
    if (!cell) return;
    this.AdjustSelection(cell);
    Event.stop(e);
  },

  isSelected: function(cell) {
    if (this.options.highlightMethod!='outline') return Element.hasClassName(cell,this.options.highlightClass);
    if (!this.SelectIdxStart || !this.SelectIdxEnd) return false;
    var r1=Math.max(Math.min(this.SelectIdxEnd.row,this.SelectIdxStart.row), this.buffer.windowStart);
    var r2=Math.min(Math.max(this.SelectIdxEnd.row,this.SelectIdxStart.row), this.buffer.windowEnd-1);
    if (r1 > r2) return false;
    var c1=Math.min(this.SelectIdxEnd.column,this.SelectIdxStart.column);
    var c2=Math.max(this.SelectIdxEnd.column,this.SelectIdxStart.column);
    var curIdx=this.bufCellIndex(cell);
    return (r1<=curIdx.row && curIdx.row<=r2 && c1<=curIdx.column && curIdx.column<=c2);
  },

  highlightCell: function(cell) {
    Element.addClassName(cell,this.options.highlightClass);
  },

  unhighlightCell: function(cell) {
    if (cell==null) return;
    Element.removeClassName(cell,this.options.highlightClass);
  },

  selectRow: function(r) {
    for (var c=0; c<this.columns.length; c++)
      this.highlightCell(this.columns[c].cell(r));
  },

  unselectRow: function(r) {
    for (var c=0; c<this.columns.length; c++)
      this.unhighlightCell(this.columns[c].cell(r));
  },

  rowMouseOver: function(e) {
    if (!this.highlightEnabled) return;
    var cell=Event.element(e);
    cell=RicoUtil.getParentByTagName(cell,'div','ricoLG_cell');
    if (!cell) return;
    var newIdx=this.winCellIndex(cell);
    if ((this.options.highlightSection & (newIdx.tabIdx+1))==0) return;
    this.highlight(newIdx);
  },

  highlight: function(newIdx) {
    if (this.options.highlightMethod!='outline') this.cursorSetClass(newIdx);
    if (this.options.highlightMethod!='class') this.cursorOutline(newIdx);
    this.highlightIdx=newIdx;
  },

  cursorSetClass: function(newIdx) {
    switch (this.options.highlightElem) {
      case 'menuCell':
      case 'cursorCell':
        if (this.highlightIdx) this.unhighlightCell(this.highlightIdx.cell);
        this.highlightCell(newIdx.cell);
        break;
      case 'menuRow':
      case 'cursorRow':
        if (this.highlightIdx) this.unselectRow(this.highlightIdx.row);
        var s1=this.options.highlightSection & 1;
        var s2=this.options.highlightSection & 2;
        var c0=s1 ? 0 : this.options.frozenColumns;
        var c1=s2 ? this.columns.length : this.options.frozenColumns;
        for (var c=c0; c<c1; c++)
          this.highlightCell(this.columns[c].cell(newIdx.row));
        break;
      default: return;
    }
  },

  cursorOutline: function(newIdx) {
    switch (this.options.highlightElem) {
      case 'menuCell':
      case 'cursorCell':
        var div=this.highlightDiv[newIdx.tabIdx];
        div.style.left=(this.columns[newIdx.column].dataCell.offsetLeft-1)+'px';
        div.style.width=this.columns[newIdx.column].colWidth;
        this.highlightDiv[1-newIdx.tabIdx].style.display='none';
        break;
      case 'menuRow':
      case 'cursorRow':
        var div=this.highlightDiv[0];
        var s1=this.options.highlightSection & 1;
        var s2=this.options.highlightSection & 2;
        div.style.left=s1 ? '0px' : this.frozenTabs.style.width;
        div.style.width=((s1 ? this.frozenTabs.offsetWidth : 0) + (s2 ? this.innerDiv.offsetWidth : 0) - 4)+'px';
        break;
      default: return;
    }
    div.style.top=(this.hdrHt+newIdx.row*this.rowHeight-1)+'px';
    div.style.height=(this.rowHeight-1)+'px';
    div.style.display='';
  },

  unhighlight: function() {
    switch (this.options.highlightElem) {
      case 'menuCell':
        this.highlightIdx=this.menuIdx;
      case 'cursorCell':
        if (this.highlightIdx) this.unhighlightCell(this.highlightIdx.cell);
        if (!this.highlightDiv) return;
        for (var i=0; i<2; i++)
          this.highlightDiv[i].style.display='none';
        break;
      case 'menuRow':
        this.highlightIdx=this.menuIdx;
      case 'cursorRow':
        if (this.highlightIdx) this.unselectRow(this.highlightIdx.row);
        if (this.highlightDiv) this.highlightDiv[0].style.display='none';
        break;
    }
  },

  resetContents: function(resetHt) {
    Rico.writeDebugMsg("resetContents("+resetHt+")");
    this.buffer.clear();
    this.clearRows();
    if (typeof resetHt=='undefined' || resetHt==true) {
      this.buffer.setTotalRows(0);
    } else {
      this.scrollToRow(0);
    }
    this.clearBookmark();
  },

  setImages: function() {
    for (n=0; n<this.columns.length; n++)
      this.columns[n].setImage();
  },

  // returns column index, or -1 if there are no sorted columns
  findSortedColumn: function() {
    for (var n=0; n<this.columns.length; n++)
      if (this.columns[n].isSorted()) return n;
    return -1;
  },

  findColumnName: function(name) {
    for (var n=0; n<this.columns.length; n++)
      if (this.columns[n].fieldName == name) return n;
    return -1;
  },

/**
 * Set initial sort
 */
  setSortUI: function( columnNameOrNum, sortDirection ) {
    Rico.writeDebugMsg("setSortUI: "+columnNameOrNum+' '+sortDirection);
    var colnum=this.findSortedColumn();
    if (colnum >= 0) {
      sortDirection=this.columns[colnum].getSortDirection();
    } else {
      if (typeof sortDirection!='string') {
        sortDirection=Rico.TableColumn.SORT_ASC;
      } else {
        sortDirection=sortDirection.toUpperCase();
        if (sortDirection != Rico.TableColumn.SORT_DESC) sortDirection=Rico.TableColumn.SORT_ASC;
      }
      switch (typeof columnNameOrNum) {
        case 'string':
          colnum=this.findColumnName(columnNameOrNum);
          break;
        case 'number':
          colnum=columnNameOrNum;
          break;
      }
    }
    if (typeof(colnum)!='number' || colnum < 0) return;
    this.clearSort();
    this.columns[colnum].setSorted(sortDirection);
    this.buffer.sortBuffer(colnum);
  },

/**
 * clear sort flag on all columns
 */
  clearSort: function() {
    for (var x=0;x<this.columns.length;x++)
      this.columns[x].setUnsorted();
  },

/**
 * clear filters on all columns
 */
  clearFilters: function() {
    for (var x=0;x<this.columns.length;x++)
      this.columns[x].setUnfiltered(true);
    if (this.options.filterHandler)
      this.options.filterHandler();
  },

/**
 * returns number of columns with a user filter set
 */
  filterCount: function() {
    for (var x=0,cnt=0;x<this.columns.length;x++)
      if (this.columns[x].isFiltered()) cnt++;
    return cnt;
  },

  sortHandler: function() {
    this.cancelMenu();
    this.setImages();
    var n=this.findSortedColumn();
    if (n < 0) return;
    Rico.writeDebugMsg("sortHandler: sorting column "+n);
    this.buffer.sortBuffer(n);
    this.clearRows();
    this.scrollDiv.scrollTop = 0;
    this.buffer.fetch(0);
  },

  filterHandler: function() {
    Rico.writeDebugMsg("filterHandler");
    this.unplugScroll();
    this.cancelMenu();
    this.ClearSelection();
    this.setImages();
    this.clearBookmark();
    this.clearRows();
    this.buffer.fetch(-1);
    setTimeout(this.pluginScroll.bind(this), 1); // resetting ht div can cause a scroll event, triggering an extra fetch
  },

  clearBookmark: function() {
    if (this.bookmark) this.bookmark.innerHTML="&nbsp;";
  },

  bookmarkHandler: function(firstrow,lastrow) {
    if (isNaN(firstrow) || !this.bookmark) return;
    var totrows=this.buffer.totalRows;
    if (totrows < lastrow) lastrow=totrows;
    if (totrows<=0) {
      var newhtml = RicoTranslate.getPhraseById('bookmarkNoMatch');
    } else if (lastrow<0) {
      var newhtml = RicoTranslate.getPhraseById('bookmarkNoRec');
    } else if (this.buffer.foundRowCount) {
      var newhtml = RicoTranslate.getPhraseById('bookmarkExact',firstrow,lastrow,totrows);
    } else {
      var newhtml = RicoTranslate.getPhraseById('bookmarkAbout',firstrow,lastrow,totrows);
    }
    this.bookmark.innerHTML = newhtml;
  },

  clearRows: function() {
    if (this.isBlank==true) return;
    for (var c=0; c < this.columns.length; c++)
      this.columns[c].clearColumn();
    this.ClearSelection();
    this.isBlank = true;
  },

  refreshContents: function(startPos) {
    Rico.writeDebugMsg("refreshContents: startPos="+startPos+" lastRow="+this.lastRowPos+" PartBlank="+this.isPartialBlank+" pageSize="+this.pageSize);
    this.hideMsg();
    this.cancelMenu();
    this.unhighlight(); // in case highlighting was manually invoked
    this.highlightEnabled=this.options.highlightSection!='none';
    if (startPos == this.lastRowPos && !this.isPartialBlank && !this.isBlank) return;
    this.isBlank = false;
    var viewPrecedesBuffer = this.buffer.startPos > startPos
    var contentStartPos = viewPrecedesBuffer ? this.buffer.startPos: startPos;
    this.contentStartPos = contentStartPos+1;
    var contentEndPos = Math.min(this.buffer.startPos + this.buffer.size, startPos + this.pageSize);
    var onRefreshComplete = this.options.onRefreshComplete;

    if ((startPos + this.pageSize < this.buffer.startPos)
        || (this.buffer.startPos + this.buffer.size < startPos)
        || (this.buffer.size == 0)) {
      this.clearRows();
      if (onRefreshComplete) onRefreshComplete(this.contentStartPos,contentEndPos);  // update bookmark
      return;
    }

    Rico.writeDebugMsg('refreshContents: contentStartPos='+contentStartPos+' contentEndPos='+contentEndPos+' viewPrecedesBuffer='+viewPrecedesBuffer);
    if (this.options.highlightElem=='selection') this.HideSelection();
    var rowSize = contentEndPos - contentStartPos;
    this.buffer.setWindow(contentStartPos, rowSize );
    var blankSize = this.pageSize - rowSize;
    var blankOffset = viewPrecedesBuffer ? 0: rowSize;
    var contentOffset = viewPrecedesBuffer ? blankSize: 0;

    for (var r=0; r < rowSize; r++) { //initialize what we have
      for (var c=0; c < this.columns.length; c++)
        this.columns[c].displayValue(r + contentOffset);
    }
    for (var i=0; i < blankSize; i++)     // blank out the rest
      this.blankRow(i + blankOffset);
    if (this.options.highlightElem=='selection') this.ShowSelection();
    this.isPartialBlank = blankSize > 0;
    this.lastRowPos = startPos;
    Rico.writeDebugMsg("refreshContents complete, startPos="+startPos);
    if (onRefreshComplete) onRefreshComplete(this.contentStartPos,contentEndPos);  // update bookmark
  },

  scrollToRow: function(rowOffset) {
     var p=this.rowToPixel(rowOffset);
     Rico.writeDebugMsg("scrollToRow, rowOffset="+rowOffset+" pixel="+p);
     this.scrollDiv.scrollTop = p; // this causes a scroll event
     if ( this.options.onscroll )
        this.options.onscroll( this, rowOffset );
  },

  scrollUp: function() {
     this.moveRelative(-1);
  },

  scrollDown: function() {
     this.moveRelative(1);
  },

  pageUp: function() {
     this.moveRelative(-this.pageSize);
  },

  pageDown: function() {
     this.moveRelative(this.pageSize);
  },

  adjustRow: function(rowOffset) {
     var notdisp=this.topOfLastPage();
     if (notdisp == 0 || !rowOffset) return 0;
     return Math.min(notdisp,rowOffset);
  },

  rowToPixel: function(rowOffset) {
     return this.adjustRow(rowOffset) * this.rowHeight;
  },

/**
 * @returns row to display at top of scroll div
 */
  pixeltorow: function(p) {
     var notdisp=this.topOfLastPage();
     if (notdisp == 0) return 0;
     var prow=parseInt(p/this.rowHeight);
     return Math.min(notdisp,prow);
  },

  moveRelative: function(relOffset) {
     newoffset=Math.max(this.scrollDiv.scrollTop+relOffset*this.rowHeight,0);
     newoffset=Math.min(newoffset,this.scrollDiv.scrollHeight);
     //Rico.writeDebugMsg("moveRelative, newoffset="+newoffset);
     this.scrollDiv.scrollTop=newoffset;
  },

  pluginScroll: function() {
     if (this.scrollPluggedIn) return;
     Rico.writeDebugMsg("pluginScroll: wheelEvent="+this.wheelEvent);
     Event.observe(this.scrollDiv,"scroll",this.scrollEventFunc, false);
     for (var t=0; t<2; t++)
       Event.observe(this.tabs[t],this.wheelEvent,this.wheelEventFunc, false);
     this.scrollPluggedIn=true;
  },

  unplugScroll: function() {
     if (!this.scrollPluggedIn) return;
     Rico.writeDebugMsg("unplugScroll");
     Event.stopObserving(this.scrollDiv,"scroll", this.scrollEventFunc , false);
     for (var t=0; t<2; t++)
       Event.stopObserving(this.tabs[t],this.wheelEvent,this.wheelEventFunc, false);
     this.scrollPluggedIn=false;
  },

  handleWheel: function(e) {
    var delta = 0;
    if (e.wheelDelta) {
      if (Prototype.Browser.Opera)
        delta = e.wheelDelta/120;
      else if (Prototype.Browser.WebKit)
        delta = -e.wheelDelta/12;
      else
        delta = -e.wheelDelta/120;
    } else if (e.detail) {
      delta = e.detail/3; /* Mozilla/Gecko */
    }
    if (delta) this.moveRelative(delta);
    Event.stop(e);
    return false;
  },

  handleScroll: function(e) {
     if ( this.scrollTimeout )
       clearTimeout( this.scrollTimeout );
     this.setHorizontalScroll();
     var scrtop=this.scrollDiv.scrollTop;
     var vscrollDiff = this.lastScrollPos-scrtop;
     if (vscrollDiff == 0.00) return;
     var newrow=this.pixeltorow(scrtop);
     if (newrow == this.lastRowPos && !this.isPartialBlank && !this.isBlank) return;
     var stamp1 = new Date();
     //Rico.writeDebugMsg("handleScroll, newrow="+newrow+" scrtop="+scrtop);
     this.buffer.fetch(newrow);
     if (this.options.onscroll) this.options.onscroll(this, newrow);
     this.scrollTimeout = setTimeout(this.scrollIdle.bind(this), 1200 );
     this.lastScrollPos = this.scrollDiv.scrollTop;
     var stamp2 = new Date();
     //Rico.writeDebugMsg("handleScroll, time="+(stamp2.getTime()-stamp1.getTime()));
  },

  scrollIdle: function() {
     if ( this.options.onscrollidle )
        this.options.onscrollidle();
  },

  printAll: function(exportType) {
    this.showMsg(RicoTranslate.getPhraseById('exportInProgress'));
    setTimeout(this._printAll.bind(this,exportType),10);  // allow message to paint
  },

/**
 * Support function for printAll()
 */
  _printAll: function(exportType) {
    this.exportStart();
    this.buffer.exportAllRows(this.exportBuffer.bind(this),this.exportFinish.bind(this,exportType));
  },

/**
 * Send all rows to print/export window
 */
  exportBuffer: function(rows,startPos) {
    Rico.writeDebugMsg("exportBuffer: "+rows.length+" rows");
    var tdtag=[];
    var totalcnt=startPos || 0;
    for (var c=0; c<this.columns.length; c++)
      if (this.columns[c].visible) tdtag[c]="<td style='"+this.exportStyle(this.columns[c].cell(0))+"'>";  // assumes row 0 style applies to all rows
    for(var r=0; r < rows.length; r++) {
      this.exportText+="<tr>";
      for (var c=0; c<this.columns.length; c++) {
        if (!this.columns[c].visible) continue;
        var v=this.columns[c]._export(rows[r][c]);
        if (v.match(/<span\s+class=(['"]?)ricolookup\1>(.*)<\/span>/i))
          v=RegExp.leftContext;
        if (v=='') v='&nbsp;';
        this.exportText+=tdtag[c]+v+"</td>";
      }
      this.exportText+="</tr>";
      totalcnt++;
      if (totalcnt % 10 == 0) window.status=RicoTranslate.getPhraseById('exportStatus',totalcnt);
    }
  }

};


Object.extend(Rico.TableColumn.prototype, {

initialize: function(liveGrid,colIdx,hdrInfo,tabIdx) {
  this.baseInit(liveGrid,colIdx,hdrInfo,tabIdx);
  if (typeof this.format.type!='string') this.format.type='raw';
  if (typeof this.isNullable!='boolean') this.isNullable = /number|date/.test(this.format.type);
  this.isText = /raw|text/.test(this.format.type);
  Rico.writeDebugMsg(" sortable="+this.sortable+" filterable="+this.filterable+" hideable="+this.hideable+" isNullable="+this.isNullable+' isText='+this.isText);
  this.fixHeaders(this.liveGrid.tableId, this.options.hdrIconsFirst);
  if (this.format.control) {
    // copy all properties/methods that start with '_'
    if (typeof this.format.control=='string')
      this.format.control=eval(this.format.control);
    for (var property in this.format.control)
      if (property.charAt(0)=='_') {
        Rico.writeDebugMsg("Copying control property "+property);
        this[property] = this.format.control[property];
      }
  }
  if (this['format_'+this.format.type])
    this._format=this['format_'+this.format.type].bind(this);
},

sortAsc: function() {
  this.setColumnSort(Rico.TableColumn.SORT_ASC);
},

sortDesc: function() {
  this.setColumnSort(Rico.TableColumn.SORT_DESC);
},

setColumnSort: function(direction) {
  this.liveGrid.clearSort();
  this.setSorted(direction);
  if (this.liveGrid.options.saveColumnInfo.sort)
    this.liveGrid.setCookie();
  if (this.options.sortHandler)
    this.options.sortHandler();
},

isSortable: function() {
  return this.sortable;
},

isSorted: function() {
  return this.currentSort != Rico.TableColumn.UNSORTED;
},

getSortDirection: function() {
  return this.currentSort;
},

toggleSort: function() {
  if (this.liveGrid.buffer && this.liveGrid.buffer.totalRows==0) return;
  if (this.currentSort == Rico.TableColumn.SORT_ASC)
    this.sortDesc();
  else
    this.sortAsc();
},

setUnsorted: function() {
  this.setSorted(Rico.TableColumn.UNSORTED);
},

/**
 * direction must be one of Rico.TableColumn.UNSORTED, .SORT_ASC, or .SORT_DESC
 */
setSorted: function(direction) {
  this.currentSort = direction;
},

canFilter: function() {
  return this.filterable;
},

getFilterText: function() {
  var vals=[];
  for (var i=0; i<this.filterValues.length; i++) {
    var v=this.filterValues[i];
    if (typeof(v)=='string' && v.match(/<span\s+class=(['"]?)ricolookup\1>(.*)<\/span>/i)) v=RegExp.leftContext;
    vals.push(v=='' ? RicoTranslate.getPhraseById('filterBlank') : v);
  }
  switch (this.filterOp) {
    case 'EQ':   return '= '+(vals[0]);
    case 'NE':   return RicoTranslate.getPhraseById('filterNot',vals.join(', '));
    case 'LE':   return '<= '+vals[0];
    case 'GE':   return '>= '+vals[0];
    case 'LIKE': return RicoTranslate.getPhraseById('filterLike',vals[0]);
    case 'NULL': return RicoTranslate.getPhraseById('filterEmpty');
    case 'NOTNULL': return RicoTranslate.getPhraseById('filterNotEmpty');
  }
  return '?';
},

getFilterQueryParm: function() {
  if (this.filterType == Rico.TableColumn.UNFILTERED) return '';
  var retval='&f['+this.index+'][op]='+this.filterOp;
  retval+='&f['+this.index+'][len]='+this.filterValues.length
  for (var i=0; i<this.filterValues.length; i++)
    retval+='&f['+this.index+']['+i+']='+escape(this.filterValues[i]);
  return retval;
},

setUnfiltered: function(skipHandler) {
  this.filterType = Rico.TableColumn.UNFILTERED;
  if (this.liveGrid.options.saveColumnInfo.filter)
    this.liveGrid.setCookie();
  if (this.removeFilterFunc)
    this.removeFilterFunc();
  if (this.options.filterHandler && !skipHandler)
    this.options.filterHandler();
},

setFilterEQ: function() {
  this.setUserFilter('EQ');
},
setFilterNE: function() {
  this.setUserFilter('NE');
},
addFilterNE: function() {
  this.filterValues.push(this.userFilter);
  if (this.liveGrid.options.saveColumnInfo.filter)
    this.liveGrid.setCookie();
  if (this.options.filterHandler)
    this.options.filterHandler();
},
setFilterGE: function() { this.setUserFilter('GE'); },
setFilterLE: function() { this.setUserFilter('LE'); },
setFilterKW: function() {
  var keyword=prompt(RicoTranslate.getPhraseById("keywordPrompt"),'');
  if (keyword!='' && keyword!=null) {
    this.setFilter('LIKE',keyword,Rico.TableColumn.USERFILTER);
  } else {
    this.liveGrid.cancelMenu();
  }
},

setUserFilter: function(relop) {
  this.setFilter(relop,this.userFilter,Rico.TableColumn.USERFILTER);
},

setSystemFilter: function(relop,filter) {
  this.setFilter(relop,filter,Rico.TableColumn.SYSTEMFILTER);
},

setFilter: function(relop,filter,type,removeFilterFunc) {
  this.filterValues = [filter];
  this.filterType = type;
  this.filterOp = relop;
  if (type == Rico.TableColumn.USERFILTER && this.liveGrid.options.saveColumnInfo.filter)
    this.liveGrid.setCookie();
  this.removeFilterFunc=removeFilterFunc;
  if (this.options.filterHandler)
    this.options.filterHandler();
},

isFiltered: function() {
  return this.filterType == Rico.TableColumn.USERFILTER;
},

filterChange: function(e) {
  var selbox=Event.element(e);
  if (selbox.value==this.liveGrid.options.FilterAllToken)
    this.setUnfiltered();
  else
    this.setFilter('EQ',selbox.value,Rico.TableColumn.USERFILTER,function() {selbox.selectedIndex=0;});
},

filterKeypress: function(e) {
  var txtbox=Event.element(e);
  if (typeof this.lastKeyFilter != 'string') this.lastKeyFilter='';
  if (this.lastKeyFilter==txtbox.value) return;
  var v=txtbox.value;
  Rico.writeDebugMsg("filterKeypress: "+this.index+' '+v);
  this.lastKeyFilter=v;
  if (v=='' || v=='*')
    this.setUnfiltered();
  else {
    this.setFilter('LIKE', v, Rico.TableColumn.USERFILTER, function() {txtbox.value='';});
  }
},

format_text: function(v) {
  if (typeof v!='string')
    return '&nbsp;';
  else
    return v.stripTags();
},

format_showTags: function(v) {
  if (typeof v!='string')
    return '&nbsp;';
  else
    return v.replace(/&/g, '&amp;').replace(/</g,'&lt;').replace(/>/g,'&gt;');
},

format_number: function(v) {
  if (typeof v=='undefined' || v=='' || v==null)
    return '&nbsp;';
  else
    return v.formatNumber(this.format);
},

format_datetime: function(v) {
  if (typeof v=='undefined' || v=='' || v==null)
    return '&nbsp;';
  else {
    var d=new Date();
    if (!d.setISO8601(v)) return v;
    return (this.format.prefix || '')+d.formatDate(this.format.dateFmt || 'translateDateTime')+(this.format.suffix || '');
  }
},

// converts GMT/UTC to local time
format_UTCasLocalTime: function(v) {
  if (typeof v=='undefined' || v=='' || v==null)
    return '&nbsp;';
  else {
    var d=new Date();
    if (!d.setISO8601(v,-d.getTimezoneOffset())) return v;
    return (this.format.prefix || '')+d.formatDate(this.format.dateFmt || 'translateDateTime')+(this.format.suffix || '');
  }
},

format_date: function(v) {
  if (typeof v=='undefined' || v==null || v=='')
    return '&nbsp;';
  else {
    var d=new Date();
    if (!d.setISO8601(v)) return v;
    return (this.format.prefix || '')+d.formatDate(this.format.dateFmt || 'translateDate')+(this.format.suffix || '');
  }
},

fixHeaders: function(prefix, iconsfirst) {
  if (this.sortable) {
    switch (this.options.headingSort) {
      case 'link':
        var a=RicoUtil.wrapChildren(this.hdrCellDiv,'ricoSort',undefined,'a')
        a.href = "#";
        a.onclick = this.toggleSort.bindAsEventListener(this);
        break;
      case 'hover':
        this.hdrCellDiv.onclick = this.toggleSort.bindAsEventListener(this);
        break;
    }
  }
  this.imgFilter = document.createElement('img');
  this.imgFilter.style.display='none';
  this.imgFilter.src=Rico.imgDir+this.options.filterImg;
  this.imgFilter.className='ricoLG_HdrIcon';
  this.imgSort = document.createElement('img');
  this.imgSort.style.display='none';
  this.imgSort.src=Rico.imgDir+this.options.sortAscendImg;
  this.imgSort.className='ricoLG_HdrIcon';
  if (iconsfirst) {
    this.hdrCellDiv.insertBefore(this.imgSort,this.hdrCellDiv.firstChild);
    this.hdrCellDiv.insertBefore(this.imgFilter,this.hdrCellDiv.firstChild);
  } else {
    this.hdrCellDiv.appendChild(this.imgFilter);
    this.hdrCellDiv.appendChild(this.imgSort);
  }
},

getValue: function(windowRow) {
  return this.liveGrid.buffer.getWindowValue(windowRow,this.index);
},

getBufferCell: function(windowRow) {
  return this.liveGrid.buffer.getWindowCell(windowRow,this.index);
},

getBufferAttr: function(windowRow) {
  return this.liveGrid.buffer.getWindowAttr(windowRow,this.index);
},

setValue: function(windowRow,newval) {
  this.liveGrid.buffer.setWindowValue(windowRow,this.index,newval);
},

_format: function(v) {
  return v;
},

_display: function(v,gridCell) {
  gridCell.innerHTML=this._format(v);
},

_export: function(v) {
  return this._format(v);
},

displayValue: function(windowRow) {
  var bufCell=this.getBufferCell(windowRow);
  if (bufCell==null) {
    this.clearCell(windowRow);
    return;
  }
  var gridCell=this.cell(windowRow);
  this._display(bufCell,gridCell,windowRow);
  var acceptAttr=this.liveGrid.buffer.options.acceptAttr;
  if (acceptAttr.length==0) return;
  var bufAttr=this.getBufferAttr(windowRow);
  if (bufAttr==null) return;
  for (var k=0; k<acceptAttr.length; k++) {
    var bufAttr=bufAttr['_'+acceptAttr[k]] || '';
    switch (acceptAttr[k]) {
      case 'style': gridCell.style.cssText=bufAttr; break;
      case 'class': gridCell.className=bufAttr; break;
      default:      gridCell['_'+acceptAttr[k]]=bufAttr; break;
    }
  }
}

});

Rico.includeLoaded('ricoLiveGrid.js');
