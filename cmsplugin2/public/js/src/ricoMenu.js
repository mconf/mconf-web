Rico.Menu = Class.create();

Rico.Menu.prototype = {

  initialize: function(options) {
    Object.extend(this, new Rico.Popup());
    Object.extend(this.options, {
      width        : "15em"
    });
    if (typeof options=='string')
      this.options.width=options;
    else
      Object.extend(this.options, options || {});
    this.hideFunc=null;
    this.highlightElem=null;
    new Image().src = Rico.imgDir+'left.gif';
    new Image().src = Rico.imgDir+'right.gif';
  },
  
  createDiv: function(parentNode) {
    if (this.div) return;
    this.div = document.createElement('div');
    this.div.className = Prototype.Browser.WebKit ? 'ricoMenuSafari' : 'ricoMenu';
    this.div.style.position="absolute";
    this.div.style.top='0px';
    this.div.style.left='0px';
    this.div.style.width=this.options.width;
    if (!parentNode) parentNode = document.getElementsByTagName("body")[0];
    parentNode.appendChild(this.div);
    this.width=this.div.offsetWidth
    this.setDiv(this.div,this.cancelmenu.bindAsEventListener(this));
    this.direction=Element.getStyle(this.div,'direction') || 'ltr';
    this.direction=this.direction.toLowerCase();  // ltr or rtl
    this.hidemenu();
    this.itemCount=0;
  },
  
  showmenu: function(e,hideFunc){
    Event.stop(e);
    this.hideFunc=hideFunc;
    if (this.div.childNodes.length==0) {
      this.cancelmenu();
      return false;
    }
    this.openmenu(e.clientX,e.clientY,0,0);
  },
  
  openmenu: function(x,y,clickItemWi,clickItemHt) {
    var newLeft=RicoUtil.docScrollLeft()+x;
    //window.status='openmenu: newLeft='+newLeft+' width='+this.width+' windowWi='+RicoUtil.windowWidth();
    if (this.direction == 'rtl') {
      if (newLeft > this.width+clickItemWi) newLeft-=this.width+clickItemWi;
    } else {
      if (x+this.width+this.options.margin > RicoUtil.windowWidth()) newLeft-=this.width+clickItemWi;
    }
    var newTop=RicoUtil.docScrollTop()+y;
    this.div.style.visibility="hidden";
    this.div.style.display="block";
    var contentHt=this.div.offsetHeight;
    if (y+contentHt+this.options.margin > RicoUtil.windowHeight())
      newTop=Math.max(newTop-contentHt+clickItemHt,0);
    this.openPopup(newLeft,newTop);
    this.div.style.visibility ="visible";
    return false;
  },

  clearMenu: function() {
    this.div.innerHTML="";
    this.defaultAction=null;
    this.itemCount=0;
  },

  addMenuHeading: function(hdg) {
    var el=document.createElement('div')
    el.innerHTML=hdg;
    el.className='ricoMenuHeading';
    this.div.appendChild(el);
  },

  addMenuBreak: function() {
    var brk=document.createElement('div');
    brk.className="ricoMenuBreak";
    this.div.appendChild(brk);
  },

  addSubMenuItem: function(menutext, submenu, translate) {
    var dir=this.direction=='rtl' ? 'left' : 'right';
    var a=this.addMenuItem(menutext,null,true,null,translate);
    a.className='ricoSubMenu';
    a.style.backgroundImage='url('+Rico.imgDir+dir+'.gif)';
    a.style.backgroundRepeat='no-repeat';
    a.style.backgroundPosition=dir;
    a.onmouseover=this.showSubMenu.bind(this,a,submenu);
    a.onmouseout=this.subMenuOut.bindAsEventListener(this);
  },
  
  showSubMenu: function(a,submenu) {
    if (this.openSubMenu) this.hideSubMenu();
    this.openSubMenu=submenu;
    this.openMenuAnchor=a;
    var pos=Position.page(a);
    if (a.className=='ricoSubMenu') a.className='ricoSubMenuOpen';
    submenu.openmenu(pos[0]+a.offsetWidth, pos[1], a.offsetWidth-2, a.offsetHeight+2);
  },
  
  subMenuOut: function(e) {
    if (!this.openSubMenu) return;
    Event.stop(e);
    var elem=Event.element(e);
    var reltg = (e.relatedTarget) ? e.relatedTarget : e.toElement;
    try {
      while (reltg != null && reltg != this.openSubMenu.div)
        reltg=reltg.parentNode;
    } catch(err) {}
    if (reltg == this.openSubMenu.div) return;
    this.hideSubMenu();
  },
  
  hideSubMenu: function() {
    if (this.openMenuAnchor) {
      this.openMenuAnchor.className='ricoSubMenu';
      this.openMenuAnchor=null;
    }
    if (this.openSubMenu) {
      this.openSubMenu.hidemenu();
      this.openSubMenu=null;
    }
  },

  addMenuItemId: function(phraseId,action,enabled,title,target) {
    if ( arguments.length < 3 ) enabled=true;
    this.addMenuItem(RicoTranslate.getPhraseById(phraseId),action,enabled,title,false,target);
  },

  addMenuItem: function(menutext,action,enabled,title,translate,target) {
    this.itemCount++;
    if (translate==null) translate=true;
    var a = document.createElement(typeof action=='string' ? 'a' : 'div');
    if ( arguments.length < 3 || enabled ) {
      switch (typeof action) {
        case 'function': 
          a.onclick = action; 
          break;
        case 'string'  : 
          a.href = action; 
          if (target) a.target = target; 
          break
      }
      a.className = 'enabled';
      if (this.defaultAction==null) this.defaultAction=action;
    } else {
      a.disabled = true;
      a.className = 'disabled';
    }
    a.innerHTML = translate ? RicoTranslate.getPhrase(menutext) : menutext;
    if (typeof title=='string')
      a.title = translate ? RicoTranslate.getPhrase(title) : title;
    a=this.div.appendChild(a);
    Event.observe(a,"mouseover", this.mouseOver.bindAsEventListener(this));
    Event.observe(a,"mouseout", this.mouseOut.bindAsEventListener(this));
    return a;
  },
  
  mouseOver: function(e) {
    if (this.highlightElem && this.highlightElem.className=='enabled-hover') {
      // required for Safari
      this.highlightElem.className='enabled';
      this.highlightElem=null;
    }
    var elem=Event.element(e);
    if (this.openMenuAnchor && this.openMenuAnchor!=elem)
      this.hideSubMenu();
    if (elem.className=='enabled') {
      elem.className='enabled-hover';
      this.highlightElem=elem;
    }
  },

  mouseOut: function(e) {
    var elem=Event.element(e);
    if (elem.className=='enabled-hover') elem.className='enabled';
    if (this.highlightElem==elem) this.highlightElem=null;
  },

  isVisible: function() {
    return this.div && Element.visible(this.div);
  },
  
  cancelmenu: function() {
    if (!this.isVisible()) return;
    if (this.hideFunc) this.hideFunc();
    this.hideFunc=null;
    this.hidemenu();
  },

  hidemenu: function() {
    if (!this.div) return;
    if (this.openSubMenu) this.openSubMenu.hidemenu();
    this.closePopup();
  }

};

Rico.includeLoaded('ricoMenu.js');
