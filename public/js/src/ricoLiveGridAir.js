/**
  *  (c) 2005-2008 Richard Cowin (http://openrico.org)
  *  (c) 2005-2008 Matt Brown (http://dowdybrown.com)
  *
  *  Rico is licensed under the Apache License, Version 2.0 (the "License"); you may not use this
  *  file except in compliance with the License. You may obtain a copy of the License at
  *   http://www.apache.org/licenses/LICENSE-2.0
  **/

if(typeof Rico=='undefined') throw("LiveGridAir requires the Rico JavaScript framework");
if(typeof RicoUtil=='undefined') throw("LiveGridAir requires the RicoUtil object");
if(typeof Rico.Buffer=='undefined') throw("LiveGridAir requires the Rico.Buffer object");
if(typeof window.runtime=='undefined') throw("LiveGridAir requires the Adobe AIR runtime");


Rico.writeDebugMsg = function(msg) {
  window.runtime.trace(this.timeStamp()+msg);
}


/**
 * Data source is an Adobe AIR SQLite database
 */
Rico.Buffer.AirSQL = Class.create();

Rico.Buffer.AirSQL.prototype = {

initialize: function(dbConn, fromClause, options) {
  Object.extend(this, new Rico.Buffer.AjaxSQL(null, options));
  Object.extend(this, new Rico.Buffer.AirSQLMethods());
  this.dataSource=this.airFetch;
  this.colnames=[];
  this.colsql=[];
  this.fromClause=' from '+fromClause;
  this.dbConn=dbConn;
  this.SQLStatement = window.runtime.flash.data.SQLStatement;
  this.options.sortParmFmt='index';
}

}

Rico.Buffer.AirSQLMethods = function() {};

Rico.Buffer.AirSQLMethods.prototype = {

addColumn: function(sql,name) {
  this.colsql.push(sql);
  this.colnames.push(name);
},

allColumnsSql: function() {
  var s='';
  for (var i=0; i<this.colnames.length; i++) {
    if (i>0) s+=',';
    s+=this.colsql[i];
    if (this.colnames[i]) s+=" AS '"+this.colnames[i]+"'"
  }
  return s;
},

// override
formQueryHashSQL: function(startPos,fetchSize) {
  var queryHash=this.formQueryHashXML(startPos,fetchSize);
  Object.extend(queryHash,this.sortParm);

  // filters
  queryHash.filters=[];
  for (var n=0; n<this.liveGrid.columns.length; n++) {
    var c=this.liveGrid.columns[n];
    if (c.filterType == Rico.TableColumn.UNFILTERED) continue;
    var colnum=c.format.filterUI && c.format.filterUI.length > 1 ? parseInt(c.format.filterUI.substr(1)) : c.index;
    var f={};
    f.columnIndex=colnum;
    f.op=c.filterOp;
    f.values=c.filterValues;
    queryHash.filters.push(f);
  }
  return queryHash;
},

addCondition: function(whereClause,colnum,op,value) {
  var field=this.colsql[colnum];
  whereClause+=(whereClause ? ' and ' : ' where ');
  whereClause+='('+field+op+value+')';
  return whereClause;
},

airFetch: function(options) {
  Rico.writeDebugMsg("airFetch");
  var sqlwhere='';
  var parms=options.parameters;
  var sqlparms=[];
  var sqlorder=parms.sort_dir ? ' order by '+(parms.sort_col+1)+' '+parms.sort_dir : '';
  for (var n=0; n<parms.filters.length; n++) {
    var f=parms.filters[n];
    var v0=f.values[0];
    switch (f.op) {
      case "EQ":
        sqlparms.push(v0);
        sqlwhere=this.addCondition(sqlwhere,f.columnIndex,'=','?');
        break;
      case "LE":
        sqlparms.push(v0);
        sqlwhere=this.addCondition(sqlwhere,f.columnIndex,'<=','?');
        break;
      case "GE":
        sqlparms.push(v0);
        sqlwhere=this.addCondition(sqlwhere,f.columnIndex,'>=','?');
        break;
      case "NE":
        var ne="(";
        for (var i=0; i<f.values.length; i++) {
          if (i>0) ne+=",";
          ne+='?';
          sqlparms.push(f.values[i]);
        }
        ne+=")";
        sqlwhere=this.addCondition(sqlwhere,f.columnIndex,' NOT IN ',ne);
        break;
      case "LIKE":
        if (v0.indexOf('*')==-1) v0='*'+v0+'*';
        sqlparms.push(v0.replace(/\*/g,"%"));
        sqlwhere=this.addCondition(sqlwhere,f.columnIndex,' LIKE ','?');
        break;
    }
  }
  if (typeof(this.sqltotalrows)=='undefined' || options.parameters.get_total=='true') {
    var stmt = new this.SQLStatement();
    stmt.sqlConnection = this.dbConn;
    stmt.text = "select count(*) as cnt"+this.fromClause+sqlwhere;
    for (var i=0; i<sqlparms.length; i++) stmt.parameters[i]=sqlparms[i];
    stmt.execute();
    this.sqltotalrows=stmt.getResult().data[0].cnt;
  }
  var stmt = new this.SQLStatement();
  stmt.sqlConnection = this.dbConn;
  var newRows=[];
  var offset=options.parameters.offset;
  var limit=Math.min(this.sqltotalrows-offset,options.parameters.page_size)
  stmt.text = "select "+this.allColumnsSql()+this.fromClause+sqlwhere+sqlorder+" LIMIT "+limit+" OFFSET "+offset;
  for (var i=0; i<sqlparms.length; i++) stmt.parameters[i]=sqlparms[i];
  Rico.writeDebugMsg(stmt.text);
  stmt.execute();
  var result = stmt.getResult();
  if( result.data == null ) {
    Rico.writeDebugMsg('no data');
  } else {
    for (var i = 0; i < result.data.length; i++) {
      var dataRow = result.data[i];
      var newRow=[];
      for (var j=0; j<this.colnames.length; j++)
        newRow.push(dataRow[this.colnames[j]]);
      newRows.push(newRow);
    }
  }
  options.onComplete(newRows,false,this.sqltotalrows);
}

};

Rico.includeLoaded('ricoLiveGridAir.js');
