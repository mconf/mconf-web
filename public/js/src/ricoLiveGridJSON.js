/**
  *  Rico.Buffer.AjaxJSON
  *
  *  This class is used to populate the live grid with
  *  data retrieved as raw JavaScript objects.  The AjaxJSON
  *  buffer translates the JSON string received from the server
  *  into a JS data object. 
  *
  *  Data format:
  *  The data consumed by this buffer should be a JavaScript
  *  hash type object.  The format closely follows the XML based
  *  data consumed by the Rico.Buffer.AjaxSQL buffer.
  *
  *  Example:
  *  {
  *  "update_ui":"true",
  *  "offset":"0",
  *  "rowCount":"20",
  *  "rows":[
  *            {"id":"1","name":"Bob"},
  *            {"id":"2","name":"Bill"}
  *         ]
  *  }
  *
  *  The 'rows' value object of the data object is
  *  a normal JS Array with each element being a
  *  JS hash that represents the row.
  *
  *  Rico.Buffer.AjaxJSON - a live grid buffer that can make
  *  an AJAX call to the server and understand a response in
  *  JSON format.  Extended from
  *  Rico.Buffer.AjaxSQL
  *
  *  Example Usage:
  *  buffer=new Rico.Buffer.AjaxJSON(jsonUrl, bufferopts);
  *
  *  jsonUrl should return a string in the above format.  It will
  *  be parsed into JS objects.
  *
  *  JSON handling code for the Rico Live Grid written by
  *  Jeremy Green.  Adapted from code by Richard Cowin
  *  and Matt Brown.
  *
  *  (c) 2005-2007 Richard Cowin (http://openrico.org)
  *  (c) 2005-2007 Matt Brown (http://dowdybrown.com)
  *  (c) 2008 Jeremy Green (http://www.webEprint.com)
  *
  *  Rico is licensed under the Apache License, Version 2.0 (the "License"); you may not use this
  *  file except in compliance with the License. You may obtain a copy of the License at
  *   http://www.apache.org/licenses/LICENSE-2.0
  **/


Rico.Buffer.AjaxJSON = Class.create();

Rico.Buffer.AjaxJSON.prototype = {

initialize: function(url,options,ajaxOptions) {
  //log('initializing AjaxJSON');
  Object.extend(this, new Rico.Buffer.AjaxSQL());
  Object.extend(this, new Rico.Buffer.AjaxJSONMethods());
  this.dataSource=url;
  this.template = options.template;
  this.options.afterAjaxUpdate = options.afterAjaxUpdate;
  this.options.canFilter=true;
  this.options.largeBufferSize  = 7.0;   // 7 pages
  this.options.nearLimitFactor  = 1.0;   // 1 page
  this.ajaxFetch = this.fetch;
  Object.extend(this.options, options || {});
  Object.extend(this.ajaxOptions, ajaxOptions || {});
}

}



Rico.Buffer.AjaxJSONMethods = function() {};

Rico.Buffer.AjaxJSONMethods.prototype = {

ajaxUpdate: function(startPos,request) {
  this.jsonAjaxUpdate(startPos,request);
},

jsonAjaxUpdate: function(startPos,request) {
  var startTime = (new Date()).getTime();

  this.clearTimer();
  this.processingRequest=false;
  if (request.status != 200) {
    Rico.writeDebugMsg("ajaxUpdate: received http error="+request.status);
    this.liveGrid.showMsg('Received HTTP error: '+request.status);
    return;
  }
  var json = request.responseText.evalJSON(true);
  if (json == null) return;
  this.updateBuffer(json,startPos);
  if (this.options.onAjaxUpdate)
      this.options.onAjaxUpdate(json);

  this.updateGrid(startPos);

  if (this.options.afterAjaxUpdate)
      this.options.afterAjaxUpdate(json);

  if (this.options.TimeOut && this.timerMsg)
      this.restartSessionTimer();
  if (this.pendingRequest>=0) {
      var offset=this.pendingRequest;
      Rico.writeDebugMsg("ajaxUpdate: found pending request for offset="+offset);
      this.pendingRequest=-1;
      this.fetch(offset);
  }
  var endTime = (new Date()).getTime();
  //log('jsonAjaxUpdate took ' + (endTime - startTime) + 'ms');
},

updateBuffer: function(json, start) {
  //log('doing custom updateBuffer...');
  var startTime = (new Date()).getTime();
  json = $H(json);
  //log('json = ' + json);
  //log('json.toJSON() = ' + json.toJSON());
  Rico.writeDebugMsg("updateBuffer: "+start);
  this.rcvdRows = 0;
  var newRows = this.loadRows(json);
  //log('got back new rows ' + newRows);
  //log('newRows.length = ' + newRows.length);
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
  var endTime = (new Date()).getTime();
  //log('updateBuffer took ' + (endTime - startTime) + 'ms');
},

loadRows: function(json) {
  var startTime = (new Date()).getTime();
  //log('doing custom loadRows... ' + json);
  Rico.writeDebugMsg("loadRows");
  this.rcvdRowCount = false;
  //log("rowsElement = " + json.get("rows"));
  var rowsElement = json.get("rows");
  var rowcnt = json.get("rowCount");

  if (rowcnt) {
    this.rowcntContent = rowcnt;
    this.rcvdRowCount = true;
    this.foundRowCount = true;
    Rico.writeDebugMsg("loadRows, found RowCount="+this.rowcntContent);
    //log("loadRows, found RowCount="+this.rowcntContent);
  }
  this.updateUI = json.get("update_ui") == "true";
  this.rcvdOffset = json.get("offset");
  Rico.writeDebugMsg("loadRows, rcvdOffset="+this.rcvdOffset);
  //log("loadRows, rcvdOffset="+this.rcvdOffset);
  if(this.template){
    return this.template2jsTable(json,this.options.template);
  }else{
    return this.json2jsTable(json);
  }
  var endTime = (new Date()).getTime();
  //log('loadRows took ' + (endTime - startTime) + 'ms');
},


json2jsTable: function(json,firstRow) {
  var startTime = (new Date()).getTime();
  var newRows = new Array();
  var trs = json.get("rows");
  trs = $A(trs);
  var i = 0;
  var acceptAttr=this.options.acceptAttr;
  trs.each(function(rowData){
    var row = new Array();
    //var rowData = $H(pair.value);
    rowData = $H(rowData);
    var j = 0;
    rowData.each(function(p2){
      row[j]={};
      row[j].content=p2.value;
      for (var k=0; k<acceptAttr.length; k++)
        row[j]['_'+acceptAttr[k]]="";
      j++;
    });
    newRows.push( row );
    i++;
  });
  var endTime = (new Date()).getTime();
  //log('json2jsTable took ' + (endTime - startTime) + 'ms');
  return newRows;
},

template2jsTable: function(json,template){
  //log('templating');
  var startTime = (new Date()).getTime();
  var trs = json.get("rows");
  trs = $A(trs);
  var rowsString = '<table>';
  trs.each(function(rowData){
    rowsString += template.evaluate(rowData);
  });
  rowsString += '</table>';
  var rowDom = this.string2DOM(rowsString);
  return this.dom2jstable(rowDom);
  var endTime = (new Date()).getTime();
  //log('template2jsTable took ' + (endTime - startTime) + 'ms');
},

string2DOM: function(string){
  var startTime = (new Date()).getTime();
  var xmlDoc = null;
  try{ //Internet Explorer
    xmlDoc=new ActiveXObject("Microsoft.XMLDOM");
    xmlDoc.async="false";
    xmlDoc.loadXML(string);
  } catch(e) {
    try { //Firefox, Mozilla, Opera, etc.
      parser=new DOMParser();
      xmlDoc=parser.parseFromString(string,"text/xml");
    } catch(e) {
      alert(e.message);
    }
  }
  var el = document._importNode(xmlDoc.childNodes[0],true);
  var endTime = (new Date()).getTime();
  //log('string2DOM took ' + (endTime - startTime) + 'ms');
  return el;
}

}

Rico.includeLoaded('ricoLiveGridJSON.js');
