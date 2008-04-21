
Rico.Dashboard = Class.create();
Rico.Dashboard.prototype = {
	initialize: function(dashboardId, columnCount, options) {
		this.dashboardDiv = $(dashboardId);
		this.numCol = columnCount;
		this.options = options || [];
		this.cols = new Array(); 
		this.insertionOutline = document.createElement("div");
		this.insertionOutline.id = "insertionOutline";
     
		//get panels before adding collumns
		var dashboard = this
   this.panelList = [];
   // this.panelList = parsePanels(this.dashboardDiv, function(title, content, panel)
  //		                      { return new Rico.DashboardPanel(title, content, panel, dashboard);})
		var colSizes = this.options.columnSizes 
    if (!colSizes){
      colSizes = [];
      for(var i=0; i<this.numCol; i++)
        colSizes[i] = 100 / columnCount;
    }

		for(var i=0; i< this.numCol;i++)	{
          var newColDiv = document.createElement("div");
          newColDiv.style.width = colSizes[i] + "%";
          newColDiv.style.minHeight = "1px";
          newColDiv.className = "column";
          newColDiv.id = "" + (i+1) ;
          this.cols.push(newColDiv);
          this.dashboardDiv.appendChild(newColDiv);
          //if (i < this.numCol-1){
         //    var borderDiv = document.createElement("div");
         //    borderDiv.style.width = "3px";
         //    borderDiv.style.height = "100%";
         //    borderDiv.style.background = "111111"
         //    borderDiv.className = "border";
         //    //borderDiv.style.visibility = "visible";
         //    this.dashboardDiv.appendChild(borderDiv);
         // }
		}
      //now add the panels to the columns
    for (var i=0; i< this.panelList.length; i++) {
         var panel = this.panelList[i];		
         this._addToCol(panel, panel.panelDiv.getAttribute('column'));
		}
	},
	
	addPanel: function(panel, col){
	  this.panelList.push(panel)
	  this._addToCol(panel, col)
	},
	
	_addToCol: function(panel, col) {
		panel.addToCol(this.cols[col-1]);	  
	},
	
	closeAllPanels: function() {
	  var panels = this.panelList;
	  for (var i=0; i<panels.length; i++)
	    panels[i].close();
	  this.panelList = [];
	},
	
	openAllPanels: function(open) {
		for (var i=0; i<this.panelList.length; i++) 
			this.panelList[i].setVisibility(open);
	},
	
	columnAt: function(x) {
		for (var i=this.cols.length-1; i >=0; i--)	{
			if (x >= Position.positionedOffset(this.cols[i])[0])
				return this.cols[i];
		}
		return this.cols[0];
	},
	
	destroy: function() {
		try{
			for (var i=0; i<this.panelList.length; i++) {
				delete this.panelList[i];
				this.panelList[i] = null;
			}
			delete this;
		}catch(e){}
	},
	
	dropPanel: function(panel){
	  panel.column.removeChild(panel.panelDiv);
	  panel.column = this.insertionColumn;
	  this.insertionColumn.replaceChild(panel.panelDiv, this.insertionOutline);
  },

  dragPanel: function(panel, left, top){
    var newCol = this.columnAt(left + panel.panelDiv.offsetWidth/2);

    if (!newCol) return;  
    
		this._moveInsertion(newCol);
		var panels = this.columnPanels(newCol);
		var insertPos = this._getInsertionPos(panels);

		if (insertPos != 0 && 
		    top <= Position.positionedOffset(panels[insertPos-1])[1]) {
			this.insertionColumn.removeChild(this.insertionOutline);
			newCol.insertBefore(this.insertionOutline, panels[insertPos-1]);
		}
		if (insertPos != (panels.length-1) && 
		    top >= Position.positionedOffset(panels[insertPos+1])[1]) {
			if (panels[insertPos + 2]) 
				  newCol.insertBefore(this.insertionOutline, panels[insertPos+2]);
			 else
				  newCol.appendChild(this.insertionOutline);
		}    
		this.insertionColumn = newCol;
  },

  _moveInsertion: function(column){
		if (this.insertionColumn != column) {
			this.insertionColumn.removeChild(this.insertionOutline)
			this.insertionColumn = column;
			column.appendChild(this.insertionOutline);
  	}
  },
  
	columnPanels: function(column){
			var panels = [];
			for (var i=0; i<column.childNodes.length; i++) {
				if (!column.childNodes[i].isDragging)  {
					panels.push(column.childNodes[i]);
				}
			}
			return panels;
	},
  
	_getInsertionPos : function(panels) {
		for (var i=0; i<panels.length; i++) {
			if (panels[i] == this.insertionOutline) 
			  return i;
		}
	},
	
	startInsertionOutline: function(panelDiv){
	  this.insertionOutline.style.height = panelDiv.offsetHeight + "px";
	  panelDiv.parentNode.insertBefore(this.insertionOutline, panelDiv);
	  this.insertionColumn = panelDiv.parentNode;
  }
}

Rico.PanelCreation = {
  create: function(title, url, dashboard) {	
		var panelDiv = document.createElement("div");
    var titleDiv = PanelCreation.createHeader(title)
    var contentDiv = PanelCreation.createContent()
		panelDiv.className = "panel";
		panelDiv.appendChild(titleDiv);
		panelDiv.appendChild(contentDiv);	
   	return new Rico.DashboardPanel(titleDiv, contentDiv, panelDiv, dashboard)
	},
	createHeader: function(title) {
		this.panelHeaderDiv = document.createElement("div");
		this.panelHeaderDiv.className = "panelHeader";
		this.panelHeaderDiv.innerHTML = document.createTextNode(this.title);
		initializeHeader(this.panelHeaderDiv);
		return this.panelHeaderDiv;
	},
	createContent: function() {
		this.panelContentDiv = document.createElement("div");
		this.panelContentDiv.className = "panelContent";
		this.panelContentDiv.innerHTML = "Loading";
		return this.panelContentDiv;
	}
}

Rico.DashboardPanel = Class.create();
Rico.DashboardPanel.prototype = {
	initialize: function(headerDiv, contentDiv, panelDiv, dashboard) {
		this.dashboard = dashboard;
		this.panelHeaderDiv = headerDiv;
		this.panelContentDiv = contentDiv;
		this.panelDiv = panelDiv;
		this.open = true;
		panelDiv.style.zIndex = 1000;
		this.initializeHeader(headerDiv);
   	Event.observe(headerDiv, "mousedown", this._startDrag.bind(this));
  },
    
	initializeHeader: function(headerDiv) {
		headerDiv.onmouseover = this.hover.bind(this);
		headerDiv.onmouseout = this.unHover.bind(this);
		
//		this.visibilityToggleDiv = document.createElement("div");
//		this.visibilityToggleDiv.className = "visibilityToggle";
//		this.visibilityToggleDiv.innerHTML = '<img src="/images/bkgd_panel_arrow.png"/>';
//		this.visibilityToggleDiv.style.visibility = "hidden";
//		this.visibilityToggleDiv.onmousedown = this.toggleVisibility.bind(this);
	
		this.titleDiv = document.createElement("div");
		this.titleDiv.innerHTML = headerDiv.innerHTML;		
		this.titleDiv.className = "title";
		
		headerDiv.innerHTML = '';
		
		this.closeDiv = document.createElement("div");
		this.closeDiv.className = "close";
		this.closeDiv.innerHTML = '<img src="/images/icn_close.png" alt="Remove" title="Remove this metric from the report" />';
		this.closeDiv.style.display = "none";
		this.closeDiv.onmousedown = this.close.bind(this);    
		
//		headerDiv.appendChild(this.visibilityToggleDiv);
		headerDiv.appendChild(this.closeDiv);
		headerDiv.appendChild(this.titleDiv);
	},

	addToCol: function(col, isNew) {
	  this.column  = col;
		if (isNew && toCol.hasChildNodes())
			this.column.insertBefore(this.panelDiv, this.column.firstChild);
		else
			this.column.appendChild(this.panelDiv);
	},
	
	moveToColumn: function(col){
		if (this.column != col) {
			this.column.removeChild(this.panelDiv)
			this.column = col;
			col.appendChild(this.panelDiv);
		}
	},    
    //this.obj.root.onDragStart(parseInt(panel.panelDiv.style.left), parseInt(pnel.panelDiv.style.top), 
		//                          event.clientX, event.clientY);
	_startDrag: function(event) {
		if (this.dashboard.options.startingDrag)
			this.dashboard.options.startingDrag();

		Position.absolutize(this.panelDiv)
		this.dashboard.startInsertionOutline(this.panelDiv)
		this.panelDiv.style.opacity = .7;
		this.panelDiv.style.zIndex = 900;
		//this.panelDiv.style.width = (parseInt(this.panelDiv.offestWidth)-4)+"px";
		new DragPanel(this, event);
		Event.stop(event);
	},
	
	hover: function() {
//		this.visibilityToggleDiv.style.visibility = "visible";
		this.closeDiv.show();
	},
	
	unHover: function() {
//		this.visibilityToggleDiv.style.visibility = "hidden";
		this.closeDiv.hide();
	},
	
	setVisibility: function(visibility) {
		if (visibility) {
			this.panelDiv.show(); 
		} else {
		   this.panelDiv.hide();
		}
	},
	
	toggleVisibility: function() {
	   this.setVisibility(this.panelContentDiv.style.display =='none');
	},
	
	close: function() {
    if (this.open)
		  this.panelDiv.parentNode.removeChild(this.panelDiv);
		  this.open = false;
	},
	
	show: function() {
		this.panelContentDiv.show();
		this.visibilityToggleDiv.firstChild.setAttribute("src", "/images/bkgd_panel_arrow.png");
	},

 	hide: function() {
		this.panelContentDiv.hide();
		this.visibilityToggleDiv.firstChild.setAttribute("src", "/images/bkgd_panel_arrow.png");
	},  
	
	drop: function() {
	  this.dashboard.dropPanel(this);
	  
	  this.panelDiv.style.position = "static";
		//this.panelDiv.style.width = "100%";
		this.unHover();
		this.panelDiv.style.opacity = 1;
		if (this.dashboard.options.endingDrag)
			this.dashboard.options.endingDrag();
	}
}

DragPanel = Class.create();
DragPanel.prototype = {
	initialize : function(panel,event){	
	    this.panel = panel;	    
			this.lastMouseX = event.clientX;
			this.lastMouseY = event.clientY;
			this.dragHandler = this.drag.bindAsEventListener(this)
			this.dropHandler = this.endDrag.bindAsEventListener(this)
			Event.observe(document, "mousemove", this.dragHandler);
			Event.observe(document, "mouseup", this.dropHandler);
			this.panel.panelDiv.isDragging = true
	},	
	drag : function(event){

	  panelDiv = this.panel.panelDiv
		var newLeft = parseInt(panelDiv.style.left) + event.clientX - this.lastMouseX;
		var newTop = parseInt(panelDiv.style.top) + event.clientY - this.lastMouseY;
		panelDiv.style.left = newLeft + "px";
		panelDiv.style.top = newTop + "px";			
		this.lastMouseX = event.clientX;
		this.lastMouseY = event.clientY;
    this.panel.dashboard.dragPanel(this.panel, newLeft, newTop);
    Event.stop(event);
	},
	endDrag : function(event){			
		Event.stopObserving(document, "mousemove", this.dragHandler);
  	Event.stopObserving(document, "mouseup", this.dropHandler);	
		this.panel.drop();	
		this.panel.panelDiv.style.zIndex = 1000;
		this.panel.panelDiv.isDragging = false;
		Event.stop(event);
	}
}

Rico.includeLoaded('ricoDashboard.js');
