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
     var showDefaultMenu=this.options.dataMenuHandler(this.liveGrid,r,c,onBlankRow);
     if (!showDefaultMenu) return (this.itemCount > 0);
  }

  // menu items for sorting
  if (column.sortable && totrows>0) {
    this.sortmenu.clearMenu();
    this.addSubMenuItem(RicoTranslate.getPhraseById("gridmenuSortBy",column.displayName), this.sortmenu, false);
    this.sortmenu.addMenuItemId("gridmenuSortAsc", column.sortAsc.bind(column), true);
    this.sortmenu.addMenuItemId("gridmenuSortDesc", column.sortDesc.bind(column), true);
  }

  // menu items for filtering
  this.filtermenu.clearMenu();
  if (column.canFilter() && !column.format.filterUI && (!onBlankRow || column.filterType == Rico.TableColumn.USERFILTER)) {
    this.addSubMenuItem(RicoTranslate.getPhraseById("gridmenuFilterBy",column.displayName), this.filtermenu, false);
    column.userFilter=column.getValue(r);
    if (column.filterType == Rico.TableColumn.USERFILTER) {
      this.filtermenu.addMenuItemId("gridmenuRemoveFilter", column.setUnfiltered.bind(column,false), true);
      this.filtermenu.addMenuItemId("gridmenuRefresh", this.liveGrid.filterHandler.bind(this.liveGrid), true);
      if (column.filterOp=='LIKE')
        this.filtermenu.addMenuItemId("gridmenuChgKeyword", column.setFilterKW.bind(column), true);
      if (column.filterOp=='NE' && !onBlankRow)
        this.filtermenu.addMenuItemId("gridmenuExcludeAlso", column.addFilterNE.bind(column), true);
    } else if (!onBlankRow) {
      this.filtermenu.addMenuItemId("gridmenuInclude", column.setFilterEQ.bind(column), true);
      this.filtermenu.addMenuItemId("gridmenuGreaterThan", column.setFilterGE.bind(column), column.userFilter!='');
      this.filtermenu.addMenuItemId("gridmenuLessThan", column.setFilterLE.bind(column), column.userFilter!='');
      if (column.isText)
        this.filtermenu.addMenuItemId("gridmenuContains", column.setFilterKW.bind(column), true);
      this.filtermenu.addMenuItemId("gridmenuExclude", column.setFilterNE.bind(column), true);
    }
    if (this.liveGrid.filterCount() > 0)
      this.filtermenu.addMenuItemId("gridmenuRemoveAll", this.liveGrid.clearFilters.bind(this.liveGrid), true);
  } else if (this.liveGrid.filterCount() > 0) {
    this.addSubMenuItem(RicoTranslate.getPhraseById("gridmenuFilterBy",column.displayName), this.filtermenu, false);
    this.filtermenu.addMenuItemId("gridmenuRemoveAll", this.liveGrid.clearFilters.bind(this.liveGrid), true);
  }

  // menu items for Print/Export
  if (this.liveGrid.options.maxPrint > 0 && totrows>0) {
    this.exportmenu.clearMenu();
    this.addSubMenuItem(RicoTranslate.getPhraseById('gridmenuExport'),this.exportmenu,false);
    this.exportmenu.addMenuItemId("gridmenuExportVis2Web", this.liveGrid.printVisible.bind(this.liveGrid,'plain'));
    this.exportmenu.addMenuItemId("gridmenuExportAll2Web", this.liveGrid.printAll.bind(this.liveGrid,'plain'), this.liveGrid.buffer.totalRows <= this.liveGrid.options.maxPrint);
    if (Prototype.Browser.IE) {
      this.exportmenu.addMenuBreak();
      this.exportmenu.addMenuItemId("gridmenuExportVis2SS", this.liveGrid.printVisible.bind(this.liveGrid,'owc'));
      this.exportmenu.addMenuItemId("gridmenuExportAll2SS", this.liveGrid.printAll.bind(this.liveGrid,'owc'), this.liveGrid.buffer.totalRows <= this.liveGrid.options.maxPrint);
    }
  }

  // menu items for hide/unhide
  var hiddenCols=this.liveGrid.listInvisible();
  for (var showableCnt=0,x=0; x<hiddenCols.length; x++)
    if (hiddenCols[x].canHideShow()) showableCnt++;
  if (showableCnt > 0 || column.canHideShow()) {
    this.hideshowmenu.clearMenu();
    this.addSubMenuItem(RicoTranslate.getPhraseById('gridmenuHideShow'),this.hideshowmenu,false);
    this.hideshowmenu.addMenuItemId('gridmenuChooseCols', this.liveGrid.chooseColumns.bindAsEventListener(this.liveGrid));
    var visibleCnt=this.liveGrid.columns.length-hiddenCols.length;
    var enabled=(visibleCnt>1 && column.visible && column.canHideShow());
    this.hideshowmenu.addMenuItem(RicoTranslate.getPhraseById('gridmenuHide',column.displayName), column.hideColumn.bind(column), enabled, false);
    for (var cnt=0,x=0; x<hiddenCols.length; x++) {
      if (hiddenCols[x].canHideShow()) {
        if (cnt++==0) this.hideshowmenu.addMenuBreak();
        this.hideshowmenu.addMenuItem(RicoTranslate.getPhraseById('gridmenuShow',hiddenCols[x].displayName), hiddenCols[x].showColumn.bind(hiddenCols[x]), true, false);
      }
    }
    if (hiddenCols.length > 1)
      this.hideshowmenu.addMenuItemId('gridmenuShowAll', this.liveGrid.showAll.bind(this.liveGrid));
  }
  return true;
}

}

Rico.includeLoaded('ricoLiveGridMenu.js');
