if(typeof Rico=='undefined')
  throw("GridMenu requires the Rico JavaScript framework");


/**
 * Standard menu for LiveGrid
 */
Rico.GridMenu = Class.create();

Rico.GridMenu.prototype = {

initialize: function(options) {
  this.options = {
    width           : '18em',
    dataMenuHandler : null          // put custom items on the menu
  };
  Object.extend(this.options, options || {});
  Object.extend(this, new Rico.Menu(this.options));
  this.sortmenu = new Rico.Menu({ width: '15em' });
  this.filtermenu = new Rico.Menu({ width: '22em' });
  this.exportmenu = new Rico.Menu({ width: '24em' });
  this.hideshowmenu = new Rico.Menu({ width: '22em' });
  this.createDiv();
  this.sortmenu.createDiv();
  this.filtermenu.createDiv();
  this.exportmenu.createDiv();
  this.hideshowmenu.createDiv();
},

// Build context menu for grid
buildGridMenu: function(r,c) {
  this.clearMenu();
  var totrows=this.liveGrid.buffer.totalRows;
  var onBlankRow=r >= totrows;
  var column=this.liveGrid.columns[c];
  if (this.options.dataMenuHandler) {
     var showMenu=this.options.dataMenuHandler(this.liveGrid,r,c,onBlankRow);
     if (!showMenu) return false;
  }

  // menu items for sorting
  if (column.sortable && totrows>0) {
    this.sortmenu.clearMenu();
    this.addSubMenuItem(RicoTranslate.getPhrase("Sort by")+": "+column.displayName, this.sortmenu, false);
    this.sortmenu.addMenuItem("Ascending", column.sortAsc.bind(column), true);
    this.sortmenu.addMenuItem("Descending", column.sortDesc.bind(column), true);
  }

  // menu items for filtering
  this.filtermenu.clearMenu();
  if (column.canFilter() && (!onBlankRow || column.filterType == Rico.TableColumn.USERFILTER)) {
    this.addSubMenuItem(RicoTranslate.getPhrase("Filter by")+": "+column.displayName, this.filtermenu, false);    
    column.userFilter=column.getValue(r);
    if (column.filterType == Rico.TableColumn.USERFILTER) {
      this.filtermenu.addMenuItem("Remove filter", column.setUnfiltered.bind(column,false), true);
      this.filtermenu.addMenuItem("Refresh", this.liveGrid.filterHandler.bind(this.liveGrid), true);
      if (column.filterOp=='LIKE')
        this.filtermenu.addMenuItem("Change keyword...", column.setFilterKW.bind(column), true);
      if (column.filterOp=='NE' && !onBlankRow)
        this.filtermenu.addMenuItem("Exclude this value also", column.addFilterNE.bind(column), true);
    } else if (!onBlankRow) {
      this.filtermenu.addMenuItem("Include only this value", column.setFilterEQ.bind(column), true);
      this.filtermenu.addMenuItem("Greater than or equal to this value", column.setFilterGE.bind(column), column.userFilter!='');
      this.filtermenu.addMenuItem("Less than or equal to this value", column.setFilterLE.bind(column), column.userFilter!='');
      if (column.isText)
        this.filtermenu.addMenuItem("Contains keyword...", column.setFilterKW.bind(column), true);
      this.filtermenu.addMenuItem("Exclude this value", column.setFilterNE.bind(column), true);
    }
    if (this.liveGrid.filterCount() > 0)
      this.filtermenu.addMenuItem("Remove all filters", this.liveGrid.clearFilters.bind(this.liveGrid), true);
  } else if (this.liveGrid.filterCount() > 0) {
    this.addSubMenuItem(RicoTranslate.getPhrase("Filter by")+": "+column.displayName, this.filtermenu, false);    
    this.filtermenu.addMenuItem("Remove all filters", this.liveGrid.clearFilters.bind(this.liveGrid), true);
  }

  // menu items for Print/Export
  if (this.liveGrid.options.maxPrint > 0 && totrows>0) {
    this.exportmenu.clearMenu();
    this.addSubMenuItem('Print\t/Export',this.exportmenu);
    this.exportmenu.addMenuItem("Visible rows\t to web page", this.liveGrid.printVisible.bind(this.liveGrid,'plain'), true);
    this.exportmenu.addMenuItem("All rows\t to web page", this.liveGrid.printAll.bind(this.liveGrid,'plain'), this.liveGrid.buffer.totalRows <= this.liveGrid.options.maxPrint);
    if (Prototype.Browser.IE) {
      this.exportmenu.addMenuBreak();
      this.exportmenu.addMenuItem("Visible rows\t to spreadsheet", this.liveGrid.printVisible.bind(this.liveGrid,'owc'), true);
      this.exportmenu.addMenuItem("All rows\t to spreadsheet", this.liveGrid.printAll.bind(this.liveGrid,'owc'), this.liveGrid.buffer.totalRows <= this.liveGrid.options.maxPrint);
    }
  }

  // menu items for hide/unhide
  var hiddenCols=this.liveGrid.listInvisible();
  for (var showableCnt=0,x=0; x<hiddenCols.length; x++)
    if (hiddenCols[x].canHideShow()) showableCnt++;
  if (showableCnt > 0 || column.canHideShow()) {
    this.hideshowmenu.clearMenu();
    this.addSubMenuItem('Hide\t/Show',this.hideshowmenu);
    var visibleCnt=this.liveGrid.columns.length-hiddenCols.length;
    var enabled=(visibleCnt>1 && column.visible && column.canHideShow());
    this.hideshowmenu.addMenuItem(RicoTranslate.getPhrase('Hide')+': '+column.displayName, column.hideColumn.bind(column), enabled);
    for (var cnt=0,x=0; x<hiddenCols.length; x++) {
      if (hiddenCols[x].canHideShow()) {
        if (cnt++==0) this.hideshowmenu.addMenuBreak();
        this.hideshowmenu.addMenuItem(RicoTranslate.getPhrase('Show')+': '+hiddenCols[x].displayName, hiddenCols[x].showColumn.bind(hiddenCols[x]));
      }
    }
    if (hiddenCols.length > 1)
      this.hideshowmenu.addMenuItem(RicoTranslate.getPhrase('Show All'), this.liveGrid.showAll.bind(this.liveGrid));
  }
  return true;
}

}

Rico.includeLoaded('ricoLiveGridMenu.js');
