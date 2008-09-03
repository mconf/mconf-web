//  Rico Tree Control
//  by Matt Brown
//  Oct 2006, rewritten Jan 2008
//  email: dowdybrown@yahoo.com
//  leafIcon logic added by Marco Catunda
//  Requires prototype.js and ricoCommon.js

//  Data for the tree is obtained via AJAX requests
//  Each record in the AJAX response should contain 5 or 6 cells:
//   cells[0]=parent node id
//   cells[1]=node id
//   cells[2]=description
//   cells[3]=L/zero (leaf), C/non-zero (container)
//   cells[4]=0->not selectable, 1->selectable (use default action), otherwise the node is selectable and cells[4] contains the action
//   cells[5]=leafIcon (optional)


Rico.TreeControl = Class.create();

Rico.TreeControl.prototype = {

  initialize: function(id,url,options) {
    Object.extend(this, new Rico.Popup({ignoreClicks:true}));
    Object.extend(this.options, {
      nodeIdDisplay:'none',   // first, last, tooltip, or none
      showCheckBox: false,
      showFolders: false,
      showPlusMinus: true,
      showLines: true,
      defaultAction: this.nodeClick.bindAsEventListener(this),
      height: '300px',
      width: '300px',
      leafIcon: Rico.imgDir+'doc.gif'  // 'none'=no leaf icon
    });
    Object.extend(this.options, options || {});
    this.id=id;
    this.dataSource=url;
    this.close=this.closePopup;
  },

  atLoad : function() {
    var imgsrc = ["node.gif","nodelast.gif","folderopen.gif","folderclosed.gif"];
    for (i=0;i<imgsrc.length;i++)
      new Image().src = Rico.imgDir+imgsrc[i];
    this.treeDiv=document.createElement("div");
    this.treeDiv.id=this.id;
    this.treeDiv.className='ricoTree';
    this.treeDiv.style.height=this.options.height;
    this.treeDiv.style.width=this.options.width;
    this.container=document.createElement("div");
    this.container.style.display="none"
    this.container.className='ricoTreeContainer';
    this.container.appendChild(this.treeDiv);
    document.body.appendChild(this.container);
    if (this.options.showCheckBox) {
      this.buttonDiv=document.createElement("div");
      this.buttonDiv.style.width=this.options.width;
      this.buttonDiv.className='ricoTreeButtons';
      if (Element.getStyle(this.container,'position')=='absolute') {
        var span=document.createElement("span");
        span.innerHTML=RicoTranslate.getPhraseById('treeSave');
        Element.setStyle(span,{float:'left',cursor:'pointer'});
        this.buttonDiv.appendChild(span);
        Event.observe(span,'click',this.saveSelection.bindAsEventListener(this));
      }
      var span=document.createElement("span");
      span.innerHTML=RicoTranslate.getPhraseById('treeClear');
      Element.setStyle(span,{float:'right',cursor:'pointer'});
      this.buttonDiv.appendChild(span);
      this.container.appendChild(this.buttonDiv);
      Event.observe(span,'click',this.clrCheckBoxEvent.bindAsEventListener(this));
    }
    this.setDiv(this.container);
    this.close();
  },

  setTreeDiv: function(divId) {
    this.treeDiv = $(divId);
    this.openPopup = function() {};
  },

  open: function() {
    this.openPopup();
    if (this.treeDiv.childNodes.length == 0 && this.dataSource) this.loadXMLDoc();
  },

  loadXMLDoc: function(branchPin) {
    var parms="id="+this.id;
    if (branchPin) parms+="&Parent="+branchPin;
    Rico.writeDebugMsg('Tree loadXMLDoc:\n'+parms+'\n'+this.dataSource);
    new Ajax.Request(this.dataSource, {parameters:parms,method:'get',onComplete:this.processResponse.bind(this)});
  },

  domID: function(nodeID,part) {
    return 'RicoTree_'+part+'_'+this.id+'_'+nodeID;
  },

  processResponse: function(request) {
    var response = request.responseXML.getElementsByTagName("ajax-response");
    if (response == null || response.length != 1) return;
    var rowsElement = response[0].getElementsByTagName('rows')[0];
    var trs = rowsElement.getElementsByTagName("tr");
    var rowdata=[];
    for (var i=0; i < trs.length; i++) {
      var cells = trs[i].getElementsByTagName("td");
      if (cells.length < 5) continue;
      var content=[];
      content[5]=this.options.leafIcon;
      for (var j=0; j<cells.length; j++)
        content[j]=this.getContent(cells[j]);
      content[3] = content[3].match(/^0|L$/i) ? 0 : 1;
      content[4] = parseInt(content[4]);
      rowdata.push(content);
    }
    for (var i=0; i < rowdata.length; i++) {
      var moreChildren=(i < rowdata.length-1) && (rowdata[i][0]==rowdata[i+1][0]);
      this.addNode(rowdata[i][0],rowdata[i][1],rowdata[i][2],rowdata[i][3],rowdata[i][4],rowdata[i][5],!moreChildren);
    }
  },

  getContent: function(cell) {
    if (cell.innerHTML) return cell.innerHTML;
    switch (cell.childNodes.length) {
      case 0:  return "";
      case 1:  return cell.firstChild.nodeValue;
      default: return cell.childNodes[1].nodeValue;
    }
  },

  DisplayImages: function(row,arNames) {
    var i,img,td
    for(i=0;i<arNames.length;i++) {
      img = document.createElement("img")
      img.src=Rico.imgDir+arNames[i] + ".gif"
      td=row.insertCell(-1)
      td.appendChild(img)
    }
  },

  addNode: function(parentId, nodeId, nodeDesc, isContainer, isSelectable, leafIcon, isLast) {
    var parentNode=$(this.domID(parentId,'Parent'));
    var parentChildren=$(this.domID(parentId,'Children'));
    var level=parentNode ? parentNode.TreeLevel+1 : 0;
    //alert("addNode at level " + level + " (" + nodeId + ")")
    var tab = document.createElement("table");
    var div = document.createElement("div");
    div.id=this.domID(nodeId,'Children');
    div.className='ricoTreeBranch';
    div.style.display=parentNode ? 'none' : '';
    tab.border=0;
    tab.cellSpacing=0;
    tab.cellPadding=0;
    tab.id=this.domID(nodeId,'Parent');
    tab.TreeLevel=level;
    tab.TreeContainer=isContainer;
    tab.TreeFetchedChildren=this.dataSource ? false : true;
    var row=tab.insertRow(0);
    var td=[];
    for (var i=0; i<level-1; i++)
      td[i]=row.insertCell(-1);
    if (level>1) {
      tdParent=parentNode.getElementsByTagName('td');
      for (var i=0; i<level-2; i++)
        td[i].innerHTML=tdParent[i].innerHTML;
      var img = document.createElement("img");
      img.src=Rico.imgDir+(parentChildren.nextSibling && this.options.showLines ? "nodeline" : "nodeblank")+".gif";
      td[level-2].appendChild(img);
    }
    if (level>0) {
      var suffix=isLast && this.options.showLines ? 'last' : '';
      var prefix=this.options.showLines ? 'node' : '';
      if (this.options.showPlusMinus && isContainer) {
        var img = document.createElement("img");
        img.name=nodeId;
        img.style.cursor='pointer';
        img.onclick=this.clickBranch.bindAsEventListener(this);
        img.src=Rico.imgDir+prefix+"p"+suffix+".gif";
        row.insertCell(-1).appendChild(img);
      } else if (this.options.showLines) {
        var img = document.createElement("img");
        img.src=Rico.imgDir+"node"+suffix+".gif"
        row.insertCell(-1).appendChild(img);
      }
      if (this.options.showFolders && (isContainer || (leafIcon && leafIcon!='none'))) {
        var img = document.createElement("img");
        if (!isContainer) {
          img.src=leafIcon;
        } else {
          img.name=nodeId;
          img.style.cursor='pointer';
          img.onclick=this.clickBranch.bindAsEventListener(this);
          img.src=Rico.imgDir+"folderclosed.gif";
        }
        row.insertCell(-1).appendChild(img);
      }
    }
    if (isSelectable && this.options.showCheckBox) {
      var chkbx=document.createElement("input");
      chkbx.type="checkbox";
      chkbx.value=nodeId;
      row.insertCell(-1).appendChild(chkbx);
    }

    if (isSelectable && !this.options.showCheckBox) {
      var span=document.createElement('a');
      if (typeof isSelectable=='string') {
        span.href=isSelectable;
      } else {
        span.href='#';
        span.onclick=this.options.defaultAction;
      }
    } else {
      var span=document.createElement('p');
    }
    span.id=this.domID(nodeId,'Desc');
    span.className='ricoTreeLevel'+level;
    switch (this.options.nodeIdDisplay) {
      case 'last': nodeDesc+=' ('+nodeId+')'; break;
      case 'first': nodeDesc=nodeId+' - '+nodeDesc; break;
      case 'tooltip': span.title=nodeId; break;
    }
  	span.appendChild(document.createTextNode(nodeDesc));
    row.insertCell(-1).appendChild(span);

    var parent=parentChildren || this.treeDiv;
    parent.appendChild(tab);
    parent.appendChild(div);
  },

  nodeClick: function(e) {
    var node=Event.element(e);
    if (this.returnValue) {
      var t=this.domID('','Desc');
      this.returnValue(node.id.substr(t.length),node.innerHTML);
    }
    this.close();
  },

  saveSelection: function(e) {
    if (this.returnValue)
      this.returnValue(this.getCheckedItems());
    this.close();
  },

  getCheckedItems: function() {
    var inp=this.treeDiv.getElementsByTagName('input');
    var vals=[];
    for (var i=0; i<inp.length; i++) {
      if (inp[i].type=='checkbox' && inp[i].checked)
        vals.push(inp[i].value);
    }
    return vals;
  },

  setCheckBoxes: function(val) {
    var inp=this.treeDiv.getElementsByTagName('input');
    for (var i=0; i<inp.length; i++)
      if (inp[i].type=='checkbox') inp[i].checked=val
  },

  clrCheckBoxEvent: function(e) {
    Event.stop(e);
    this.setCheckBoxes(false);
  },

  clickBranch: function(e) {
    var node=Event.element(e);
    var tab=RicoUtil.getParentByTagName(node,'table');
    if (!tab || !tab.TreeContainer) return;
    var a=tab.id.split('_');
    a[1]='Children';
    var childDiv=$(a.join('_'));
    Element.toggle(childDiv);
    if (node.tagName=='IMG') {
      var v=Element.visible(childDiv);
      if (node.src.match(/node(p|m)(last)?\.gif$/))
        node.src=node.src.replace(/nodep|nodem/,'node'+(v ? 'm' : 'p'));
      else if (node.src.match(/folder(open|closed)\.gif$/))
        node.src=node.src.replace(/folder(open|closed)/,'folder'+(v ? 'open' : 'closed'));
      else if (node.src.match(/\b(m|p)\.gif$/))
        node.src=node.src.replace(/(p|m)\.gif/,v ? 'm\.gif' : 'p\.gif');
    }
    if (!tab.TreeFetchedChildren) {
      tab.TreeFetchedChildren=1;
      this.loadXMLDoc(node.name)
    }
  }

}

Rico.includeLoaded('ricoTree.js');
