if(typeof Rico=='undefined') throw("LiveGridForms requires the Rico JavaScript framework");
if(typeof RicoUtil=='undefined') throw("LiveGridForms requires the RicoUtil object");
if(typeof RicoTranslate=='undefined') throw("LiveGridForms requires the RicoTranslate object");


Rico.TableEdit = Class.create();

Rico.TableEdit.prototype = {

  initialize: function(liveGrid) {
    Rico.writeDebugMsg('Rico.TableEdit initialize: '+liveGrid.tableId);
    this.grid=liveGrid;
    this.options = {
      maxDisplayLen    : 20,    // max displayed text field length
      panelHeight      : 200,   // size of tabbed panels
      panelWidth       : 500,
      hoverClass       : 'tabHover',
      selectedClass    : 'tabSelected',
      compact          : false,    // compact corners
      RecordName       : RicoTranslate.getPhraseById("record"),
      updateURL        : window.location.pathname, // default is that updates post back to the generating page
      readOnlyColor    : '#AAA',   // read-only fields displayed using this color
      showSaveMsg      : 'errors'  // disposition of database update responses (full - show full response, errors - show full response for errors and short response otherwise)
    }
    Object.extend(this.options, liveGrid.options);
    this.hasWF2=(document.implementation && document.implementation.hasFeature && document.implementation.hasFeature('WebForms', '2.0'));
    this.menu=liveGrid.menu;
    this.menu.options.dataMenuHandler=this.editMenu.bind(this);
    this.menu.ignoreClicks();
    RicoEditControls.atLoad();
    this.createEditDiv();
    this.createKeyArray();
    this.saveMsg=$(liveGrid.tableId+'_savemsg');
    Event.observe(document,"click", this.clearSaveMsg.bindAsEventListener(this), false);
    this.extraMenuItems=new Array();
    this.responseHandler=this.processResponse.bind(this);
    Rico.writeDebugMsg("Rico.TableEdit.initialize complete, hasWF2="+this.hasWF2);
  },

  canDragFunc: function(elem,event) {
    if (elem.componentFromPoint && elem.componentFromPoint(event.clientX,event.clientY)!='') return false;
    return (elem==this.editDiv || elem.tagName=='FORM');
  },

  createKeyArray: function() {
    this.keys=[];
    for (var i=0; i<this.grid.columns.length; i++)
      if (this.grid.columns[i].format && this.grid.columns[i].format.isKey)
        this.keys.push(i);
  },

  createEditDiv: function() {

    // create editDiv (form)

    this.requestCount=1;
    this.editDiv = this.grid.createDiv('edit',document.body);
    this.editDiv.style.display='none';
    if (this.options.canEdit || this.options.canAdd) {
      this.startForm();
      this.createForm(this.form);
    } else {
      var button=this.createButton(RicoTranslate.getPhraseById("close"));
      Event.observe(button,"click", this.cancelEdit.bindAsEventListener(this), false);
      this.createForm(this.editDiv);
    }
    this.editDivCreated=true;
    this.formPopup=new Rico.Popup({ignoreClicks:true, canDragFunc: this.canDragFunc.bind(this) }, this.editDiv);

    // create responseDialog

    this.responseDialog = this.grid.createDiv('editResponse',document.body);
    this.responseDialog.style.display='none';

    var button = document.createElement('button');
    button.appendChild(document.createTextNode('OK'));
    button.onclick=this.ackResponse.bindAsEventListener(this);
    this.responseDialog.appendChild(button);

    this.responseDiv = this.grid.createDiv('editResponseText',this.responseDialog);

    if (this.panelGroup) {
      Rico.writeDebugMsg("createEditDiv complete, requestCount="+this.requestCount);
      setTimeout(this.initPanelGroup.bind(this),50);
    }
  },

  initPanelGroup: function() {
    this.requestCount--;
    Rico.writeDebugMsg("initPanelGroup: "+this.requestCount);
    if (this.requestCount>0) return;
    var wi=parseInt(this.options.panelWidth);
    this.form.style.width=(wi+10)+'px';
    if (Prototype.Browser.WebKit) this.editDiv.style.display='block';  // this causes display to flash briefly
    this.options.bgColor = Rico.Color.createColorFromBackground(this.form);
    this.editDiv.style.display='none';
    this.options.panelHdrWidth=(Math.floor(wi / this.options.panels.length)-4)+'px';
    this.Accordion=new Rico.TabbedPanel(this.panelHdr.findAll(this.notEmpty), this.panelContent.findAll(this.notEmpty), this.options);
  },

  notEmpty: function(v) {
    return typeof(v)!='undefined';
  },

  startForm: function() {
    this.form = document.createElement('form');
    this.form.onsubmit=function() {return false;};
    this.editDiv.appendChild(this.form);

    var tab = document.createElement('table');
    var row = tab.insertRow(-1);
    var cell = row.insertCell(-1);
    var button=cell.appendChild(this.createButton(RicoTranslate.getPhraseById("saveRecord",this.options.RecordName)));
    Event.observe(button,"click", this.TESubmit.bindAsEventListener(this), false);
    var cell = row.insertCell(-1);
    var button=cell.appendChild(this.createButton(RicoTranslate.getPhraseById("cancel")));
    Event.observe(button,"click", this.cancelEdit.bindAsEventListener(this), false);
    this.form.appendChild(tab);

    // hidden fields
    this.hiddenFields = document.createElement('div');
    this.hiddenFields.style.display='none';
    this.action = this.appendHiddenField(this.grid.tableId+'__action','');
    for (var i=0; i<this.grid.columns.length; i++) {
      var fldSpec=this.grid.columns[i].format;
      if (fldSpec && fldSpec.FormView && fldSpec.FormView=="hidden")
        this.appendHiddenField(fldSpec.FieldName,fldSpec.ColData);
    }
    this.form.appendChild(this.hiddenFields);
  },

  createButton: function(buttonLabel) {
    var button = document.createElement('button');
    button.innerHTML="<span style='text-decoration:underline;'>"+buttonLabel.charAt(0)+"</span>"+buttonLabel.substr(1);
    button.accessKey=buttonLabel.charAt(0);
    return button;
  },

  createPanel: function(i) {
    var hasFields=false;
    for (var j=0; j<this.grid.columns.length; j++) {
      var fldSpec=this.grid.columns[j].format;
      if (!fldSpec) continue;
      if (!fldSpec.EntryType) continue
      if (fldSpec.EntryType=='H') continue;
      var panelIdx=fldSpec.panelIdx || 0;
      if (panelIdx==i) {
        hasFields=true;
        break;
      }
    }
    if (!hasFields) return false;
    this.panelHdr[i] = document.createElement('div');
    this.panelHdr[i].className='tabHeader';
    this.panelHdr[i].innerHTML=this.options.panels[i];
    this.panelHdrs.appendChild(this.panelHdr[i]);
    this.panelContent[i] = document.createElement('div');
    this.panelContent[i].className='tabContent';
    this.panelContents.appendChild(this.panelContent[i]);
    return true;
  },

  createForm: function(parentDiv) {
    var tables=[];
    this.panelHdr=[];
    this.panelContent=[];
    if (this.options.panels) {
      this.panelGroup = document.createElement('div');
      this.panelGroup.className='tabPanelGroup';
      this.panelHdrs = document.createElement('div');
      this.panelGroup.appendChild(this.panelHdrs);
      this.panelContents = document.createElement('div');
      this.panelContents.className='tabContentContainer';
      this.panelGroup.appendChild(this.panelContents);
      parentDiv.appendChild(this.panelGroup);
      if (this.grid.direction=='rtl') {
        for (var i=this.options.panels.length-1; i>=0; i--)
          if (this.createPanel(i))
            tables[i]=this.createFormTable(this.panelContent[i],'tabContent');
      } else {
        for (var i=0; i<this.options.panels.length; i++)
          if (this.createPanel(i))
            tables[i]=this.createFormTable(this.panelContent[i],'tabContent');
      }
      parentDiv.appendChild(this.panelGroup);
    } else {
      var div=document.createElement('div');
      div.className='noTabContent';
      tables[0]=this.createFormTable(div);
      parentDiv.appendChild(div);
    }
    for (var i=0; i<this.grid.columns.length; i++) {
      var fldSpec=this.grid.columns[i].format;
      if (!fldSpec) continue;
      var panelIdx=fldSpec.panelIdx || 0;
      if (tables[panelIdx]) this.appendFormField(this.grid.columns[i],tables[panelIdx]);
      if (typeof fldSpec.pattern=='string') {
        switch (fldSpec.pattern) {
          case 'email':
            fldSpec.regexp=/^[_a-zA-Z0-9-]+(\.[_a-zA-Z0-9-]+)*@[a-zA-Z0-9-]+(\.[a-zA-Z0-9-]+)*\.(([0-9]{1,3})|([a-zA-Z]{2,3})|(aero|coop|info|museum|name))$/;
            break;
          case 'float-unsigned':
            fldSpec.regexp=/^\d+(\.\d+)?$/;
            break;
          case 'float-signed':
            fldSpec.regexp=/^[-+]?\d+(\.\d+)?$/;
            break;
          case 'int-unsigned':
            fldSpec.regexp=/^\d+$/;
            break;
          case 'int-signed':
            fldSpec.regexp=/^[-+]?\d+$/;
            break;
          default:
            fldSpec.regexp=new RegExp(fldSpec.pattern);
            break;
        }
      }
    }
  },

  createFormTable: function(div) {
    var tab=document.createElement('table');
    tab.border=0;
    div.appendChild(tab);
    return tab;
  },

  appendHiddenField: function(name,value) {
    var field=RicoUtil.createFormField(this.hiddenFields,'input','hidden',name,name);
    field.value=value;
    return field;
  },

  appendFormField: function(column, table) {
    var fmt=column.format;
    if (!fmt.EntryType) return;
    if (fmt.EntryType=="H") return;
    if (fmt.FormView) return;
    Rico.writeDebugMsg('appendFormField: '+column.displayName+' - '+fmt.EntryType);
    var row = table.insertRow(-1);
    var hdr = row.insertCell(-1);
    column.formLabel=hdr;
    if (hdr.noWrap) hdr.noWrap=true;
    var entry = row.insertCell(-1);
    if (entry.noWrap) entry.noWrap=true;
    hdr.innerHTML=column.displayName;
    hdr.id='lbl_'+fmt.FieldName;
    if (fmt.Help) {
      hdr.title=fmt.Help;
      hdr.className='ricoEditLabelWithHelp';
    } else {
      hdr.className='ricoEditLabel';
    }
    var field, name=fmt.FieldName;
    switch (fmt.EntryType) {
      case 'TA','tinyMCE':
        field=RicoUtil.createFormField(entry,'textarea',null,name);
        field.cols=fmt.TxtAreaCols;
        field.rows=fmt.TxtAreaRows;
        field.innerHTML=fmt.ColData;
        hdr.style.verticalAlign='top';
        break;
      case 'R':
      case 'RL':
        field=RicoUtil.createFormField(entry,'div',null,name);
        if (fmt.isNullable) this.addSelectNone(field);
        this.selectValuesRequest(field,fmt);
        break;
      case 'N':
        field=RicoUtil.createFormField(entry,'select',null,name);
        if (fmt.isNullable) this.addSelectNone(field);
        field.onchange=this.checkSelectNew.bindAsEventListener(this);
        this.selectValuesRequest(field,fmt);
        field=document.createElement('span');
        field.className='ricoEditLabel';
        field.id='labelnew__'+fmt.FieldName;
        field.innerHTML='&nbsp;&nbsp;&nbsp;'+RicoTranslate.getPhraseById('formNewValue').replace(' ','&nbsp;');
        entry.appendChild(field);
        name='textnew__'+fmt.FieldName;
        field=RicoUtil.createFormField(entry,'input','text',name,name);
        break;
      case 'S':
      case 'SL':
        field=RicoUtil.createFormField(entry,'select',null,name);
        if (fmt.isNullable) this.addSelectNone(field);
        this.selectValuesRequest(field,fmt);
        break;
      case 'D':
        if (!fmt.isNullable) fmt.required=true;
        if (typeof fmt.min=='string') fmt.min=fmt.min.toISO8601Date() || new Date(fmt.min);
        if (typeof fmt.max=='string') fmt.max=fmt.max.toISO8601Date() || new Date(fmt.max);
        if (this.hasWF2) {
          field=RicoUtil.createFormField(entry,'input','date',name,name);
          field.required=fmt.required;
          if (fmt.min) field.min=fmt.min.toISO8601String(3);
          if (fmt.max) field.max=fmt.max.toISO8601String(3);
          field.required=fmt.required;
          fmt.SelectCtl=null;  // use the WebForms calendar instead of the Rico calendar
        } else {
          field=RicoUtil.createFormField(entry,'input','text',name,name);
        }
        this.initField(field,fmt);
        break;
      case 'I':
        if (!fmt.isNullable) fmt.required=true;
        if (!fmt.pattern) fmt.pattern='int-signed';
        if (this.hasWF2) {
          field=RicoUtil.createFormField(entry,'input','number',name,name);
          field.required=fmt.required;
          field.min=fmt.min;
          field.max=fmt.max;
          field.step=1;
        } else {
          field=RicoUtil.createFormField(entry,'input','text',name,name);
        }
        if (typeof fmt.min=='string') fmt.min=parseInt(fmt.min);
        if (typeof fmt.max=='string') fmt.max=parseInt(fmt.max);
        this.initField(field,fmt);
        break;
      case 'F':
        if (!fmt.isNullable) fmt.required=true;
        if (!fmt.pattern) fmt.pattern='float-signed';
        field=RicoUtil.createFormField(entry,'input','text',name,name);
        this.initField(field,fmt);
        if (typeof fmt.min=='string') fmt.min=parseFloat(fmt.min);
        if (typeof fmt.max=='string') fmt.max=parseFloat(fmt.max);
        break;
      default:
        field=RicoUtil.createFormField(entry,'input','text',name,name);
        if (!fmt.isNullable && fmt.EntryType!='T') fmt.required=true;
        this.initField(field,fmt);
        break;
    }
    if (field) {
      if (fmt.SelectCtl)
        RicoEditControls.applyTo(column,field);
    }
  },

  addSelectNone: function(field) {
    this.addSelectOption(field,this.options.TableSelectNone,RicoTranslate.getPhraseById("selectNone"));
  },

  initField: function(field,fmt) {
    if (fmt.Length) {
      field.maxLength=fmt.Length;
      field.size=Math.min(fmt.Length, this.options.maxDisplayLen);
    }
    field.value=fmt.ColData;
  },

  checkSelectNew: function(e) {
    this.updateSelectNew(Event.element(e));
  },

  updateSelectNew: function(SelObj) {
    var vis=(SelObj.value==this.options.TableSelectNew) ? "" : "hidden";
    $("labelnew__" + SelObj.id).style.visibility=vis
    $("textnew__" + SelObj.id).style.visibility=vis
  },

  selectValuesRequest: function(elem,fldSpec) {
    if (fldSpec.SelectValues) {
      var valueList=fldSpec.SelectValues.split(',');
      for (var i=0; i<valueList.length; i++)
        this.addSelectOption(elem,valueList[i],valueList[i],i);
    } else {
      this.requestCount++;
      var options={};
      Object.extend(options, this.grid.buffer.ajaxOptions);
      options.parameters = 'id='+fldSpec.FieldName+'&offset=0&page_size=-1';
      options.onComplete = this.selectValuesUpdate.bind(this);
      new Ajax.Request(this.grid.buffer.dataSource, options);
      Rico.writeDebugMsg("selectValuesRequest: "+options.parameters);
    }
  },

  selectValuesUpdate: function(request) {
    var response = request.responseXML.getElementsByTagName("ajax-response");
    Rico.writeDebugMsg("selectValuesUpdate: "+request.status);
    if (response == null || response.length != 1) return;
    response=response[0];
    var error = response.getElementsByTagName('error');
    if (error.length > 0) {
      var errmsg=RicoUtil.getContentAsString(error[0],this.grid.buffer.isEncoded);
      Rico.writeDebugMsg("Data provider returned an error:\n"+errmsg);
      alert(RicoTranslate.getPhraseById("requestError",errmsg));
      return null;
    }
    response=response.getElementsByTagName('response')[0];
    var id = response.getAttribute("id").slice(0,-8);
    var rowsElement = response.getElementsByTagName('rows')[0];
    var rows = this.grid.buffer.dom2jstable(rowsElement);
    var elem=$(id);
    //alert('selectValuesUpdate:'+id+' '+elem.tagName);
    Rico.writeDebugMsg("selectValuesUpdate: id="+id+' rows='+rows.length);
    for (var i=0; i<rows.length; i++) {
      if (rows[i].length>0) {
        var c0=rows[i][0];
        var c1=(rows[i].length>1) ? rows[i][1] : c0;
        this.addSelectOption(elem,c0,c1,i);
      }
    }
    if ($('textnew__'+id))
      this.addSelectOption(elem,this.options.TableSelectNew,RicoTranslate.getPhraseById("selectNewVal"));
    if (this.panelGroup)
      setTimeout(this.initPanelGroup.bind(this),50);
  },

  addSelectOption: function(elem,value,text,idx) {
    switch (elem.tagName.toLowerCase()) {
      case 'div':
        var opt=RicoUtil.createFormField(elem,'input','radio',elem.id+'_'+idx,elem.id);
        opt.value=value;
        var lbl=document.createElement('label');
        lbl.innerHTML=text;
        lbl.htmlFor=opt.id;
        elem.appendChild(lbl);
        break;
      case 'select':
        RicoUtil.addSelectOption(elem,value,text);
        break;
    }
  },

  clearSaveMsg: function() {
    if (this.saveMsg) this.saveMsg.innerHTML="";
  },

  addMenuItem: function(menuText,menuAction,enabled) {
    this.extraMenuItems.push({menuText:menuText,menuAction:menuAction,enabled:enabled});
  },

  editMenu: function(grid,r,c,onBlankRow) {
    this.clearSaveMsg();
    if (this.grid.buffer.sessionExpired==true || this.grid.buffer.startPos<0) return;
    this.rowIdx=r;
    var elemTitle=$('pageTitle');
    var pageTitle=elemTitle ? elemTitle.innerHTML : document.title;
    this.menu.addMenuHeading(pageTitle);
    for (var i=0; i<this.extraMenuItems.length; i++)
      this.menu.addMenuItem(this.extraMenuItems[i].menuText,this.extraMenuItems[i].menuAction,this.extraMenuItems[i].enabled);
    if (onBlankRow==false) {
      var menutxt=RicoTranslate.getPhraseById("editRecord",this.options.RecordName);
      this.menu.addMenuItem(menutxt,this.editRecord.bindAsEventListener(this),this.options.canEdit);
      var menutxt=RicoTranslate.getPhraseById("deleteRecord",this.options.RecordName);
      this.menu.addMenuItem(menutxt,this.deleteRecord.bindAsEventListener(this),this.options.canDelete);
      if (this.options.canClone) {
        var menutxt=RicoTranslate.getPhraseById("cloneRecord",this.options.RecordName);
        this.menu.addMenuItem(menutxt,this.cloneRecord.bindAsEventListener(this),this.options.canAdd && this.options.canEdit);
      }
    }
    var menutxt=RicoTranslate.getPhraseById("addRecord",this.options.RecordName);
    this.menu.addMenuItem(menutxt,this.addRecord.bindAsEventListener(this),this.options.canAdd);
    return true;
  },

  cancelEdit: function(e) {
    Event.stop(e);
    for (var i=0; i<this.grid.columns.length; i++)
      if (this.grid.columns[i].format && this.grid.columns[i].format.SelectCtl)
        RicoEditControls.close(this.grid.columns[i].format.SelectCtl);
    this.makeFormInvisible();
    this.grid.highlightEnabled=true;
    this.menu.cancelmenu();
    return false;
  },

  setField: function(fldSpec,fldvalue) {
    var e=$(fldSpec.FieldName);
    if (!e) return;
    Rico.writeDebugMsg('setField: '+fldSpec.FieldName+'='+fldvalue);
    switch (e.tagName.toUpperCase()) {
      case 'DIV':
        var elems=e.getElementsByTagName('INPUT');
        var fldcode=this.getLookupValue(fldvalue)[0];
        for (var i=0; i<elems.length; i++)
          elems[i].checked=(elems[i].value==fldcode);
        break;
      case 'INPUT':
        if (fldSpec.SelectCtl)
          fldvalue=this.getLookupValue(fldvalue)[0];
        if (fldSpec.EntryType=='D') {
          // remove time data if it exists
          var a=fldvalue.split(/\s|T/);
          fldvalue=a[0];
        }
        e.value=fldvalue;
        break;
      case 'SELECT':
        var opts=e.options;
        var fldcode=this.getLookupValue(fldvalue)[0];
        //alert('setField SELECT: id='+e.id+'\nvalue='+fldcode+'\nopt cnt='+opts.length)
        for (var i=0; i<opts.length; i++) {
          if (opts[i].value==fldcode) {
            e.selectedIndex=i;
            break;
          }
        }
        if (fldSpec.EntryType=='N') {
          var txt=$('textnew__'+e.id);
          if (!txt) alert('Warning: unable to find id "textnew__'+e.id+'"');
          txt.value=fldvalue;
          if (e.selectedIndex!=i) e.selectedIndex=opts.length-1;
          this.updateSelectNew(e);
        }
        return;
      case 'TEXTAREA':
        e.value=fldvalue;
        if (fldSpec.EntryType=='tinyMCE' && typeof(tinyMCE)!='undefined' && this.initialized)
          tinyMCE.updateContent(e.id);
        return;
    }
  },

  getLookupValue: function(value) {
    switch (typeof value) {
      case 'number': return [value.toString(),value.toString()];
      case 'string': return value.match(/<span\s+class=(['"]?)ricolookup\1>(.*)<\/span>/i) ? [RegExp.$2,RegExp.leftContext] : [value,value];
      default:       return ['',''];
    }
  },

  // use with care: Prototype 1.5 does not include disabled fields in the post-back
  setReadOnly: function(addFlag) {
    for (var i=0; i<this.grid.columns.length; i++) {
      var fldSpec=this.grid.columns[i].format;
      if (!fldSpec) continue;
      var e=$(fldSpec.FieldName);
      if (!e) continue;
      var ro=!fldSpec.Writeable || fldSpec.ReadOnly || (fldSpec.InsertOnly && !addFlag) || (fldSpec.UpdateOnly && addFlag);
      var color=ro ? this.options.readOnlyColor : '';
      switch (e.tagName.toUpperCase()) {
        case 'DIV':
          var elems=e.getElementsByTagName('INPUT');
          for (var j=0; j<elems.length; j++)
            elems[j].disabled=ro;
          break;
        case 'SELECT':
          if (fldSpec.EntryType=='N') {
            var txt=$('textnew__'+e.id);
            txt.disabled=ro;
          }
          e.disabled=ro;
          break;
        case 'TEXTAREA':
        case 'INPUT':
          e.readOnly=ro;
          e.style.color=color;
          if (fldSpec.selectIcon) fldSpec.selectIcon.style.display=ro ? 'none' : '';
          break;
      }
    }
  },

  hideResponse: function(msg) {
    this.responseDiv.innerHTML=msg;
    this.responseDialog.style.display='none';
  },

  showResponse: function() {
    var offset=Position.page(this.grid.outerDiv);
    offset[1]+=RicoUtil.docScrollTop();
    this.responseDialog.style.top=offset[1]+"px";
    this.responseDialog.style.left=offset[0]+"px";
    this.responseDialog.style.display='';
  },

  processResponse: function() {
    var responseText,success=true;
    var respNodes=Element.select(this.responseDiv,'.ricoFormResponse');
    if (respNodes) {
      // generate a translated response
      var phraseId=$w(respNodes[0].className)[1];
      responseText=RicoTranslate.getPhraseById(phraseId,this.options.RecordName);
    } else {
      // present the response as sent from the server (untranslated)
      var ch=this.responseDiv.childNodes;
      for (var i=ch.length-1; i>=0; i--) {
        if (ch[i].nodeType==1 && ch[i].nodeName!='P' && ch[i].nodeName!='DIV' && ch[i].nodeName!='BR')
          this.responseDiv.removeChild(ch[i]);
      }
      responseText=this.responseDiv.innerHTML.stripTags();
      success=(responseText.toLowerCase().indexOf('error')==-1);
    }
    if (success && this.options.showSaveMsg!='full') {
      this.hideResponse('');
      this.grid.resetContents();
      this.grid.buffer.foundRowCount = false;
      this.grid.buffer.fetch(this.grid.lastRowPos || 0);
      if (this.saveMsg) this.saveMsg.innerHTML='&nbsp;'+responseText+'&nbsp;';
    }
    this.processCallback(this.options.onSubmitResponse);
  },

  processCallback: function(callback) {
    switch (typeof callback) {
      case 'string': eval(callback); break;
      case 'function': callback(); break;
    }
  },

  // called when ok pressed on error response message
  ackResponse: function() {
    this.hideResponse('');
    this.grid.highlightEnabled=true;
  },

  cloneRecord: function() {
    this.displayEditForm("ins");
  },

  editRecord: function() {
    this.displayEditForm("upd");
  },

  displayEditForm: function(action) {
    this.grid.highlightEnabled=false;
    this.menu.cancelmenu();
    this.hideResponse(RicoTranslate.getPhraseById('saving'));
    this.grid.outerDiv.style.cursor = 'auto';
    this.action.value=action;
    for (var i=0; i<this.grid.columns.length; i++) {
      if (this.grid.columns[i].format) {
        var c=this.grid.columns[i];
        var v=c.getValue(this.rowIdx);
        this.setField(c.format,v);
        if (c.format.selectDesc)
          c.format.selectDesc.innerHTML=c._format(v);
        if (c.format.SelectCtl)
          RicoEditControls.displayClrImg(c, !c.format.InsertOnly);
      }
    }
    this.setReadOnly(false);
    this.key=this.getKey();
    this.makeFormVisible(this.rowIdx);
  },

  addRecord: function() {
    this.menu.cancelmenu();
    this.hideResponse(RicoTranslate.getPhraseById('saving'));
    this.setReadOnly(true);
    this.form.reset();
    this.action.value="ins";
    for (var i=0; i<this.grid.columns.length; i++) {
      if (this.grid.columns[i].format) {
        this.setField(this.grid.columns[i].format,this.grid.columns[i].format.ColData);
        if (this.grid.columns[i].format.SelectCtl)
          RicoEditControls.resetValue(this.grid.columns[i]);
      }
    }
    this.key='';
    this.makeFormVisible(-1);
    if (this.Accordion) this.Accordion.selectionSet.selectIndex(0);
  },

  drillDown: function(e,masterColNum,detailColNum) {
    var cell=Event.element(e || window.event);
    cell=RicoUtil.getParentByTagName(cell,'div','ricoLG_cell');
    if (!cell) return;
    this.grid.unhighlight();
    var idx=this.grid.winCellIndex(cell);
    this.grid.menuIdx=idx;  // ensures selection gets cleared when menu is displayed
    this.grid.highlight(idx);
    var drillValue=this.grid.columns[masterColNum].getValue(idx.row);
    for (var i=3; i<arguments.length; i++)
      arguments[i].setDetailFilter(detailColNum,drillValue);
    return idx.row;
  },

  // set filter on a detail grid that is in a master-detail relationship
  setDetailFilter: function(colNumber,filterValue) {
    var c=this.grid.columns[colNumber];
    c.format.ColData=filterValue;
    c.setSystemFilter('EQ',filterValue);
  },

  makeFormVisible: function(row) {
    this.editDiv.style.display='block';

    // set left position
    var editWi=this.editDiv.offsetWidth;
    var odOffset=Position.page(this.grid.outerDiv);
    var winWi=RicoUtil.windowWidth();
    if (editWi+odOffset[0] > winWi)
      this.editDiv.style.left=(winWi-editWi)+'px';
    else
      this.editDiv.style.left=(odOffset[0]+1)+'px';

    // set top position
    var scrTop=RicoUtil.docScrollTop();
    var editHt=this.editDiv.offsetHeight;
    var newTop=odOffset[1]+this.grid.hdrHt+scrTop;
    var bottom=RicoUtil.windowHeight()+scrTop;
    if (row >= 0) {
      newTop+=(row+1)*this.grid.rowHeight;
      if (newTop+editHt>bottom) newTop-=(editHt+this.grid.rowHeight);
    } else {
      if (newTop+editHt>bottom) newTop=bottom-editHt;
    }

    this.processCallback(this.options.formOpen);
    this.formPopup.openPopup(null,Math.max(newTop,scrTop));
    this.editDiv.style.visibility='visible';
    if (this.initialized) return;

    for (i = 0; i < this.grid.columns.length; i++) {
      spec=this.grid.columns[i].format;
      if (!spec || !spec.EntryType || !spec.FieldName) continue;
      switch (spec.EntryType) {
        case 'tinyMCE':
          if (typeof tinyMCE!='undefined') tinyMCE.execCommand('mceAddControl', true, spec.FieldName);
          break;
      }
    }

    if (!this.panelGroup) {
      this.editDiv.style.width=(this.editDiv.offsetWidth-this.grid.options.scrollBarWidth+2)+"px";
      this.editDiv.style.height=(this.editDiv.offsetHeight-this.grid.options.scrollBarWidth+2)+"px";
    }

    this.formPopup.openPopup();  // tinyMCE may have changed the dimensions of the form
    this.initialized=true;
  },

  makeFormInvisible: function() {
    this.editDiv.style.visibility='hidden';
    this.formPopup.closePopup();
    this.processCallback(this.options.formClose);
  },

  getConfirmDesc: function(rowIdx) {
    var desc=this.grid.columns[this.options.ConfirmDeleteCol].cell(rowIdx).innerHTML;
    desc=this.getLookupValue(desc)[1];
    return desc.stripTags().unescapeHTML();
  },

  deleteRecord: function() {
    this.menu.cancelmenu();
    var desc;
    switch(this.options.ConfirmDeleteCol){
			case -1 :
			  desc=RicoTranslate.getPhraseById("thisRecord",this.options.RecordName);
			  break;
			case -2 : // Use key/column header to identify the row
        for (var k=0; k<this.keys.length; k++) {
          var i=this.keys[k];
          var value=this.grid.columns[i].getValue(this.rowIdx);
          value=this.getLookupValue(value)[0];
  				if (desc) desc+=', ';
  				desc+=this.grid.columns[i].displayName+" "+value;
        }
				break;
			default   :
				desc='\"' + this.getConfirmDesc(this.rowIdx).truncate(50) + '\"'
    }
    if (!this.options.ConfirmDelete.valueOf || confirm(RicoTranslate.getPhraseById("confirmDelete",desc))) {
      this.hideResponse(RicoTranslate.getPhraseById('deleting'));
      this.showResponse();
      var parms=this.action.name+"=del"+this.getKey();
      new Ajax.Updater(this.responseDiv, this.options.updateURL, {parameters:parms,onComplete:this.processResponse.bind(this)});
    }
    this.menu.cancelmenu();
  },

  getKey: function() {
    var key='';
    for (var k=0; k<this.keys.length; k++) {
      var i=this.keys[k];
      var value=this.grid.columns[i].getValue(this.rowIdx);
      value=this.getLookupValue(value)[0];
      key+='&_k'+i+'='+value;
    }
    return key;
  },

  validationMsg: function(elem,colnum,phraseId) {
    var col=this.grid.columns[colnum];
    if (this.Accordion) this.Accordion.openByIndex(col.format.panelIdx);
    var msg=RicoTranslate.getPhraseById(phraseId," \"" + col.formLabel.innerHTML + "\"");
    Rico.writeDebugMsg(' Validation error: '+msg);
    if (col.format.Help) msg+="\n\n"+col.format.Help;
    alert(msg);
    setTimeout(function() { try { elem.focus(); elem.select(); } catch(e) {}; }, 10);
    return false;
  },

  TESubmit: function(e) {
    var i,lbl,spec,elem,n;

    Event.stop(e || event);
    Rico.writeDebugMsg('Event: TESubmit called to validate input');

    // check fields that are supposed to be non-blank

    for (i = 0; i < this.grid.columns.length; i++) {
      spec=this.grid.columns[i].format;
      if (!spec || !spec.EntryType || !spec.FieldName) continue;
      elem=$(spec.FieldName);
      if (!elem) continue;
      if (elem.tagName.toLowerCase()!='input') continue;
      if (elem.type.toLowerCase()!='text') continue;
      Rico.writeDebugMsg(' Validating field #'+i+' EntryType='+spec.EntryType+' ('+spec.FieldName+')');

      // check for blanks
      if (elem.value.length == 0 && spec.required)
        return this.validationMsg(elem,i,"formPleaseEnter");

      // check pattern
      if (elem.value.length > 0 && spec.regexp && !spec.regexp.test(elem.value))
        return this.validationMsg(elem,i,"formInvalidFmt");

      // check min/max
      switch (spec.EntryType.charAt(0)) {
        case 'I': n=parseInt(elem.value); break;
        case 'F': n=parseFloat(elem.value); break;
        case 'D': n=new Date(); n.setISO8601(elem.value); break;
        default:  n=NaN;
      }
      if (typeof spec.min!='undefined' && !isNaN(n) && n < spec.min)
        return this.validationMsg(elem,i,"formOutOfRange");
      if (typeof spec.max!='undefined' && !isNaN(n) && n > spec.max)
        return this.validationMsg(elem,i,"formOutOfRange");
    }

    // update drop-down for any columns with entry type of N

    for (i = 0; i < this.grid.columns.length; i++) {
      spec=this.grid.columns[i].format;
      if (!spec || !spec.EntryType || !spec.FieldName) continue;
      if (spec.EntryType.charAt(0) != 'N') continue;
      var SelObj=$(spec.FieldName);
      if (!SelObj || SelObj.value!=this.options.TableSelectNew) continue;
      var newtext=$("textnew__" + SelObj.id).value;
      this.addSelectOption(SelObj,newtext,newtext);
    }

    if (typeof tinyMCE!='undefined') tinyMCE.triggerSave();
    this.makeFormInvisible();
    this.showResponse();
    var parms=Form.serialize(this.form)+this.key
    Rico.writeDebugMsg("TESubmit:"+parms);
    new Ajax.Updater(this.responseDiv, this.options.updateURL, {parameters:parms,onComplete:this.responseHandler});
    this.menu.cancelmenu();
    return false;
  }
}


/**
 * @singleton
 * Registers custom popup widgets to fill in a text box (e.g. ricoCalendar and ricoTree)
 *
 * Custom widget must implement:
 *   open() method (make control visible)
 *   close() method (hide control)
 *   container property (div element that contains the control)
 *   id property (uniquely identifies the widget class)
 *
 * widget calls returnValue method to return a value to the caller
 *
 * this object handles clicks on the control's icon and positions the control appropriately.
 */
var RicoEditControls = {
  widgetList : $H(),
  elemList   : $H(),
  clearImg   : Rico.imgDir+'delete.gif',

  register: function(widget, imgsrc) {
    this.widgetList.set(widget.id, {imgsrc:imgsrc, widget:widget, currentEl:''});
    widget.returnValue=this.setValue.bind(this,widget);
    Rico.writeDebugMsg("RicoEditControls.register:"+widget.id);
  },

  atLoad: function() {
    this.widgetList.each(function(pair) { if (pair.value.widget.atLoad) pair.value.widget.atLoad(); });
  },

  applyTo: function(column,inputCtl) {
    var wInfo=this.widgetList.get(column.format.SelectCtl);
    if (!wInfo) return null;
    Rico.writeDebugMsg('RicoEditControls.applyTo: '+column.displayName+' : '+column.format.SelectCtl);
    var descSpan = document.createElement('span');
    var newimg = document.createElement('img');
    newimg.style.paddingLeft='4px';
    newimg.style.cursor='pointer';
    newimg.align='top';
    newimg.src=wInfo.imgsrc;
    newimg.id=this.imgId(column.format.FieldName);
    newimg.onclick=this.processClick.bindAsEventListener(this);
    inputCtl.parentNode.appendChild(descSpan);
    inputCtl.parentNode.appendChild(newimg);
    inputCtl.style.display='none';    // comment out this line for debugging
    if (column.format.isNullable) {
      var clrimg = document.createElement('img');
      clrimg.style.paddingLeft='4px';
      clrimg.style.cursor='pointer';
      clrimg.align='top';
      clrimg.src=this.clearImg;
      clrimg.id=newimg.id+'_clear';
      clrimg.alt=RicoTranslate.getPhraseById('clear');
      clrimg.onclick=this.processClear.bindAsEventListener(this);
      inputCtl.parentNode.appendChild(clrimg);
    }
    this.elemList.set(newimg.id, {descSpan:descSpan, inputCtl:inputCtl, widget:wInfo.widget, listObj:wInfo, column:column, clrimg:clrimg});
    column.format.selectIcon=newimg;
    column.format.selectDesc=descSpan;
  },

  displayClrImg: function(column,bool) {
    var el=this.elemList.get(this.imgId(column.format.FieldName));
    if (el && el.clrimg) el.clrimg.style.display=bool ? '' : 'none';
  },

  processClear: function(e) {
    var elem=Event.element(e);
    var el=this.elemList.get(elem.id.slice(0,-6));
    if (!el) return;
    el.inputCtl.value='';
    el.descSpan.innerHTML=el.column._format('');
  },

  processClick: function(e) {
    var elem=Event.element(e);
    var el=this.elemList.get(elem.id);
    if (!el) return;
    if (el.listObj.currentEl==elem.id && el.widget.container.style.display!='none') {
      el.widget.close();
      el.listObj.currentEl='';
    } else {
      el.listObj.currentEl=elem.id;
      Rico.writeDebugMsg('RicoEditControls.processClick: '+el.widget.id+' : '+el.inputCtl.value);
      RicoUtil.positionCtlOverIcon(el.widget.container,elem);
      el.widget.open(el.inputCtl.value);
    }
  },

  imgId: function(fieldname) {
    return 'icon_'+fieldname;
  },

  resetValue: function(column) {
    var el=this.elemList.get(this.imgId(column.format.FieldName));
    if (!el) return;
    el.inputCtl.value=column.format.ColData;
    el.descSpan.innerHTML=column._format(column.format.ColData);
  },

  setValue: function(widget,newVal,newDesc) {
    var wInfo=this.widgetList.get(widget.id);
    if (!wInfo) return null;
    var id=wInfo.currentEl;
    if (!id) return null;
    var el=this.elemList.get(id);
    if (!el) return null;
    el.inputCtl.value=newVal;
    if (!newDesc) newDesc=el.column._format(newVal);
    el.descSpan.innerHTML=newDesc;
    //alert(widget.id+':'+id+':'+el.inputCtl.id+':'+el.inputCtl.value+':'+newDesc);
  },

  close: function(id) {
    var wInfo=this.widgetList.get(id);
    if (!wInfo) return;
    if (wInfo.widget.container.style.display!='none')
      wInfo.widget.close();
  }
}

Rico.includeLoaded('ricoLiveGridForms.js');
