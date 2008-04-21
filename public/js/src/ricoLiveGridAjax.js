if(typeof Rico=='undefined') throw("LiveGridAjax requires the Rico JavaScript framework");
if(typeof RicoUtil=='undefined') throw("LiveGridAjax requires the RicoUtil object");
if(typeof Rico.Buffer=='undefined') throw("LiveGridAjax requires the Rico.Buffer object");


/**
 * Data source is a static XML file located on the server
 */
Rico.Buffer.AjaxXML = Class.create();

Rico.Buffer.AjaxXML.prototype = {

  initialize: function(url,options,ajaxOptions) {
    Object.extend(this, new Rico.Buffer.Base());
    Object.extend(this, new Rico.Buffer.AjaxXMLMethods);
    this.dataSource=url;
    this.options.bufferTimeout=20000;            // time to wait for ajax response (milliseconds)
    this.options.requestParameters=[];
    this.options.waitMsg="Waiting for data...";  // replace this with an image tag if you prefer
    Object.extend(this.options, options || {});
    this.ajaxOptions = { parameters: null, method : 'get' };
    Object.extend(this.ajaxOptions, ajaxOptions || {});
    this.requestCount=0;
    this.processingRequest=false;
    this.pendingRequest=-1;
    this.sortParm={};
  }
}

Rico.Buffer.AjaxXMLMethods = function() {};

Rico.Buffer.AjaxXMLMethods.prototype = {

  fetch: function(offset) {
    if ( this.isInRange(offset) ) {
      Rico.writeDebugMsg("AjaxXML fetch: in buffer");
      this.liveGrid.refreshContents(offset);
      return;
    }
    Rico.writeDebugMsg("AjaxXML fetch, offset="+offset);
    if (offset < 0) {
      this.clear();
      this.setTotalRows(0);
      this.foundRowCount = false;
      offset=0;
    }
    this.processingRequest=true
    this.liveGrid.showMsg(this.options.waitMsg);
    this.timeoutHandler = setTimeout( this.handleTimedOut.bind(this), this.options.bufferTimeout);
    this.sendAjaxRequest(offset,0,this.ajaxUpdate.bind(this,offset));
  },

/**
 * Server did not respond in time... assume that there could have been
 * an error, and allow requests to be processed again.
 */
  handleTimedOut: function() {
    Rico.writeDebugMsg("Request Timed Out");
    this.liveGrid.showMsg("Request for data timed out!");
  },

  formQueryHash: function(startPos,fetchSize) {
    if (typeof fetchSize!='number') fetchSize=this.totalRows;
    var queryHash= {
      id: this.liveGrid.tableId,
      page_size: fetchSize,
      offset: startPos
    };
    if (!this.foundRowCount) queryHash['get_total']='true';
    if (this.options.requestParameters) {
      for ( var i=0; i < this.options.requestParameters.length; i++ ) {
        var anArg = this.options.requestParameters[i];
        if ( anArg.name != undefined && anArg.value != undefined ) {
          queryHash[anArg.name]=anArg.value;
        } else {
          var ePos  = anArg.indexOf('=');
          var argName  = anArg.substring( 0, ePos );
          var argValue = anArg.substring( ePos + 1 );
          queryHash[argName]=argValue;
        }
      }
    }
    
    // sort
    Object.extend(queryHash,this.sortParm);

    // filters
    for (n=0; n<this.liveGrid.columns.length; n++) {
      var c=this.liveGrid.columns[n];
      if (c.filterType == Rico.TableColumn.UNFILTERED) continue;
      queryHash['f['+c.index+'][op]']=c.filterOp;
      queryHash['f['+c.index+'][len]']=c.filterValues.length
      for (var i=0; i<c.filterValues.length; i++)
        queryHash['f['+c.index+']['+i+']']=c.filterValues[i];
    }
      
    return queryHash;
  },

  sendAjaxRequest: function(startPos,fetchSize,onComplete) {
    this.ajaxOptions.parameters = this.formQueryHash(startPos,fetchSize);
    this.ajaxOptions.onComplete = onComplete;
    this.requestCount++;
    Rico.writeDebugMsg('sending ajax req #'+this.requestCount);
    new Ajax.Request(this.dataSource, this.ajaxOptions);
  },
  
  clearTimer: function() {
    if(typeof this.timeoutHandler != "number") return;
    window.clearTimeout(this.timeoutHandler);
    delete this.timeoutHandler;
  },

  ajaxUpdate: function(startPos,request) {
    this.clearTimer();
    this.processingRequest=false;
    if (request.status != 200) {
      Rico.writeDebugMsg("ajaxUpdate: received http error="+request.status);
      this.liveGrid.showMsg('Received HTTP error: '+request.status);
      return;
    }
    var response = request.responseXML.getElementsByTagName("ajax-response");
    if (response == null || response.length != 1) return;
    this.updateBuffer(response[0],startPos);
    if (this.options.onAjaxUpdate)
      this.options.onAjaxUpdate();
    this.updateGrid(startPos);
    if (this.options.TimeOut && this.timerMsg)
      this.restartSessionTimer();
    if (this.pendingRequest>=0) {
      var offset=this.pendingRequest;
      Rico.writeDebugMsg("ajaxUpdate: found pending request for offset="+offset);
      this.pendingRequest=-1;
      this.fetch(offset);
    }
  },

  updateGrid: function(offset) {
    Rico.writeDebugMsg("updateGrid, size="+this.size+' rcv cnt type='+typeof(this.rowcntContent));
    if (this.rcvdRowCount==true) {
      Rico.writeDebugMsg("found row cnt: "+this.rowcntContent);
      var eofrow=parseInt(this.rowcntContent);
      var lastTotalRows=this.totalRows;
      if (!isNaN(eofrow) && eofrow!=lastTotalRows) {
        this.setTotalRows(eofrow);
        var newpos=Math.min(this.liveGrid.topOfLastPage(),offset);
        Rico.writeDebugMsg("updateGrid: new rowcnt="+eofrow+" newpos="+newpos);
        if (lastTotalRows==0 && this.liveGrid.sizeTo=='data')
          this.liveGrid.adjustPageSize();
        this.liveGrid.scrollToRow(newpos);
        if ( this.isInRange(newpos) ) {
          this.liveGrid.refreshContents(newpos);
        } else {
          this.fetch(newpos);
        }
        return;
      }
    } else {
      var lastbufrow=offset+this.rcvdRows;
      if (lastbufrow>this.totalRows) {
        var newcnt=lastbufrow;
        Rico.writeDebugMsg("extending totrows to "+newcnt);
        this.setTotalRows(newcnt);
      }
    }
    var newpos=this.liveGrid.pixeltorow(this.liveGrid.scrollDiv.scrollTop);
    Rico.writeDebugMsg("updateGrid: newpos="+newpos);
    this.liveGrid.refreshContents(newpos);
  },

  updateBuffer: function(ajaxResponse, start) {
    Rico.writeDebugMsg("updateBuffer: "+start);
    this.rcvdRows = 0;
    var newRows = this.loadRows(ajaxResponse);
    if (newRows==null) return;
    this.rcvdRows = newRows.length;
    Rico.writeDebugMsg("updateBuffer: # of rows="+this.rcvdRows);
    if (this.rows.length == 0) { // initial load
      this.rows = newRows;
      this.startPos = start;
    } else if (start > this.startPos) { //appending
      if (this.startPos + this.rows.length < start) {
        this.rows =  newRows;
        this.startPos = start;//
      } else {
        this.rows = this.rows.concat( newRows.slice(0, newRows.length));
        if (this.rows.length > this.maxBufferSize) {
          var fullSize = this.rows.length;
          this.rows = this.rows.slice(this.rows.length - this.maxBufferSize, this.rows.length)
          this.startPos = this.startPos +  (fullSize - this.rows.length);
        }
      }
    } else { //prepending
      if (start + newRows.length < this.startPos) {
        this.rows =  newRows;
      } else {
        this.rows = newRows.slice(0, this.startPos).concat(this.rows);
        if (this.maxBufferSize && this.rows.length > this.maxBufferSize)
          this.rows = this.rows.slice(0, this.maxBufferSize)
      }
      this.startPos =  start;
    }
    this.size = this.rows.length;
  },

  loadRows: function(ajaxResponse) {
    Rico.writeDebugMsg("loadRows");
    this.rcvdRowCount = false;
    var debugtags = ajaxResponse.getElementsByTagName('debug');
    for (var i=0; i<debugtags.length; i++)
      Rico.writeDebugMsg("loadRows, debug msg "+i+": "+RicoUtil.getContentAsString(debugtags[i],this.options.isEncoded));
    var error = ajaxResponse.getElementsByTagName('error');
    if (error.length > 0) {
      var msg=RicoUtil.getContentAsString(error[0],this.options.isEncoded);
      alert("Data provider returned an error:\n"+msg);
      Rico.writeDebugMsg("Data provider returned an error:\n"+msg);
      return null;
    }
    var rowsElement = ajaxResponse.getElementsByTagName('rows')[0];
    var rowcnttags = ajaxResponse.getElementsByTagName('rowcount');
    if (rowcnttags && rowcnttags.length==1) {
      this.rowcntContent = RicoUtil.getContentAsString(rowcnttags[0],this.options.isEncoded);
      this.rcvdRowCount = true;
      this.foundRowCount = true;
      Rico.writeDebugMsg("loadRows, found RowCount="+this.rowcntContent);
    }
    this.updateUI = rowsElement.getAttribute("update_ui") == "true";
    this.rcvdOffset = rowsElement.getAttribute("offset");
    Rico.writeDebugMsg("loadRows, rcvdOffset="+this.rcvdOffset);
    return this.dom2jstable(rowsElement);
  }

};



Rico.Buffer.AjaxSQL = Class.create();

Rico.Buffer.AjaxSQL.prototype = {

  initialize: function(url,options,ajaxOptions) {
    Object.extend(this, new Rico.Buffer.AjaxXML());
    Object.extend(this, new Rico.Buffer.AjaxSQLMethods());
    this.dataSource=url;
    this.options.canFilter=true;
    this.options.largeBufferSize  = 7.0;   // 7 pages
    this.options.nearLimitFactor  = 1.0;   // 1 page
    Object.extend(this.options, options || {});
    Object.extend(this.ajaxOptions, ajaxOptions || {});
  }
}
  
Rico.Buffer.AjaxSQLMethods = function() {};

Rico.Buffer.AjaxSQLMethods.prototype = {

  registerGrid: function(liveGrid) {
    this.liveGrid = liveGrid;
    this.sessionExpired=false;
    this.timerMsg=$(liveGrid.tableId+'_timer');
    if (this.options.TimeOut && this.timerMsg) {
      if (!this.timerMsg.title) this.timerMsg.title=RicoTranslate.getPhrase("minutes before your session expires")
      this.restartSessionTimer();
    }
  },
  
  setBufferSize: function(pageSize) {
    this.maxFetchSize = Math.max(50,parseInt(this.options.largeBufferSize * pageSize));
    this.nearLimit = parseInt(this.options.nearLimitFactor * pageSize);
    this.maxBufferSize = this.maxFetchSize * 3;
  },

  restartSessionTimer: function() {
    if (this.sessionExpired==true) return;
    this.timeRemaining=this.options.TimeOut+1;
    if (this.sessionTimer) clearTimeout(this.sessionTimer);
    this.updateSessionTimer();
  },
  
  updateSessionTimer: function() {
    if (--this.timeRemaining<=0) {
      this.displaySessionTimer(RicoTranslate.getPhrase("EXPIRED"));
      this.timerMsg.style.backgroundColor="red";
      this.sessionExpired=true;
    } else {
      this.displaySessionTimer(this.timeRemaining);
      this.sessionTimer=setTimeout(this.updateSessionTimer.bind(this),60000);
    }
  },
  
  displaySessionTimer: function(msg) {
    this.timerMsg.innerHTML='&nbsp;'+msg+'&nbsp;';
  },
  
  /**
   * Update the grid with fresh data from the database, maintaining scroll position.
   * @param resetRowCount indicates whether the total row count should be refreshed as well
   */
  refresh: function(resetRowCount) {
    var lastGridPos=this.liveGrid.lastRowPos
    this.clear();
    if (resetRowCount) {
      this.setTotalRows(0);
      this.foundRowCount = false;
    }
    this.liveGrid.clearBookmark();
    this.liveGrid.clearRows();
    this.fetch(lastGridPos);
  },
  
  /**
   * Fetch data from database.
   * @param offset position (row) within the dataset (-1=clear existing buffer before issuing request)
   */
  fetch: function(offset) {
    Rico.writeDebugMsg("AjaxSQL fetch, offset="+offset+' lastOffset='+this.lastOffset);
    if (this.processingRequest) {
      Rico.writeDebugMsg("AjaxSQL fetch: queue request");
      this.pendingRequest=offset;
      return;
    }
    if (offset < 0) {
      this.clear();
      this.setTotalRows(0);
      this.foundRowCount = false;
      offset=0;
    }
    var lastOffset = this.lastOffset;
    this.lastOffset = offset;
    var inRange=this.isInRange(offset);
    if (inRange) {
      Rico.writeDebugMsg("AjaxSQL fetch: in buffer");
      this.liveGrid.refreshContents(offset);
      if (offset > lastOffset) {
        if (offset+this.liveGrid.pageSize < this.endPos()-this.nearLimit) return;
        if (this.endPos()==this.totalRows && this.foundRowCount) return;
      } else if (offset < lastOffset) {
        if (offset > this.startPos+this.nearLimit) return;
        if (this.startPos==0) return;
      } else return;
    }
    if (offset >= this.totalRows && this.foundRowCount) return;
    
    this.processingRequest=true
    Rico.writeDebugMsg("AjaxSQL fetch, processing offset="+offset);
    var bufferStartPos = this.getFetchOffset(offset);
    var fetchSize = this.getFetchSize(bufferStartPos);
    var partialLoaded = false;

    if (!inRange) this.liveGrid.showMsg(this.options.waitMsg);
    this.timeoutHandler = setTimeout( this.handleTimedOut.bind(this), this.options.bufferTimeout);
    this.sendAjaxRequest(bufferStartPos,fetchSize,this.ajaxUpdate.bind(this,bufferStartPos));
  },

  getFetchSize: function(adjustedOffset) {
    var adjustedSize = 0;
    if (adjustedOffset >= this.startPos) { //appending
      var endFetchOffset = this.maxFetchSize + adjustedOffset;
      adjustedSize = endFetchOffset - adjustedOffset;
      if(adjustedOffset == 0 && adjustedSize < this.maxFetchSize)
        adjustedSize = this.maxFetchSize;
      Rico.writeDebugMsg("getFetchSize/append, adjustedSize="+adjustedSize+" adjustedOffset="+adjustedOffset+' endFetchOffset='+endFetchOffset);
    } else { //prepending
      adjustedSize = Math.min(this.startPos - adjustedOffset,this.maxFetchSize);
    }
    return adjustedSize;
  },

  getFetchOffset: function(offset) {
    var adjustedOffset = offset;
    if (offset > this.startPos)
      adjustedOffset = Math.max(offset, this.endPos());  //appending
    else if (offset + this.maxFetchSize >= this.startPos)
      adjustedOffset = Math.max(this.startPos - this.maxFetchSize, 0);  //prepending
    return adjustedOffset;
  },

  sortBuffer: function(colnum,sortdir,coltype) {
    this.sortParm={};
    if (this.options.sortParmFmt && this.options.sortParmFmt=='displayName') {
      this.sortParm['sort_col']=this.liveGrid.columns[colnum].displayName.toLowerCase();
      this.sortParm['sort_dir']=sortdir;
    }else{
     this.sortParm['s'+colnum]=sortdir;
    }
    this.clear();
  },
  
  exportAllRows: function(populate,finish) {
    this.exportPopulate=populate;
    this.exportFinish=finish;
    //this.liveGrid.showMsg(this.options.waitMsg);
    this.sendExportRequest(0);
  },
  
/**
 * Make ajax request for print window data
 */
  sendExportRequest: function(offset) {
    this.timeoutHandler = setTimeout(this.exportTimedOut.bind(this), this.options.bufferTimeout);
    this.sendAjaxRequest(offset,200,this.exportAppend.bind(this,offset));
  },

  exportTimedOut: function() {
    Rico.writeDebugMsg("Print Request Timed Out");
    this.liveGrid.showMsg("Request for data timed out!");
    this.exportFinish();
  },

  exportAppend: function(startPos,request) {
    this.clearTimer();
    Rico.writeDebugMsg("exportAppend");
    var response = request.responseXML.getElementsByTagName("ajax-response");
    if (response == null || response.length != 1) return;
    var rowsElement = response[0].getElementsByTagName('rows')[0];
    var rows=this.dom2jstable(rowsElement);
    this.exportPopulate(rows,startPos);
    if (rows.length==0)
      this.exportFinish();
    else
      this.sendExportRequest(startPos+rows.length);
  }

};

Rico.includeLoaded('ricoLiveGridAjax.js');
