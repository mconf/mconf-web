//////////////////////////////////////////////////////////
////////// JSXML XML Tools                    ////////////
////////// Ver 1.3 Aug 29 2009                ////////////
////////// Copyright 2000-2009 Peter Tracey   ////////////
////////// http://levelthreesoltions.com/jsxml/
////
////	Objects:
////
////	REXML
////    Regular Expression-based XML parser
////
////	JSXMLIterator
////    Iterates through the tree structure without recursion
////
////	JSXMLBuilder
////    Loads xml into a linear structure and provides 
////	interface for adding and removing elements 
////	and setting attributes, generates XML
////
////	Utility functions:
////
////	ParseAttribute
////    Takes string of attibutes and attribute name
////    Returns attribute value
////
////	Array_Remove
////    Removes element in array
////
////	Array_Add
////    Adds element to array
////
////	RepeatChar
////    Repeats string specified number of times
////
///////////////////////////////////////////////////////////////


function REXML(XML) {
	this.XML = XML;

	this.rootElement = null;

	this.parse = REXML_parse;
	if (this.XML && this.XML != "") this.parse();
}

	function REXML_parse() {
		var reTag = new RegExp("<([^>/ ]*)([^>]*)>","g"); // matches that tag name $1 and attribute string $2
		var reTagText = new RegExp("<([^>/ ]*)([^>]*)>([^<]*)","g"); // matches tag name $1, attribute string $2, and text $3
		var strType = "";
		var strTag = "";
		var strText = "";
		var strAttributes = "";
		var strOpen = "";
		var strClose = "";
		var iElements = 0;
		var xmleLastElement = null;
		if (this.XML.length == 0) return;
		var arrElementsUnparsed = this.XML.match(reTag);
		var arrElementsUnparsedText = this.XML.match(reTagText);
		var i=0;
		if (arrElementsUnparsed[0].replace(reTag, "$1") == "?xml") i++;

		for (; i<arrElementsUnparsed.length; i++) {
			strTag = arrElementsUnparsed[i].replace(reTag,"$1");
			strAttributes = arrElementsUnparsed[i].replace(reTag,"$2");
			strText = arrElementsUnparsedText[i].replace(reTagText,"$3").replace(/[\r\n\t ]+/g, " "); // remove white space
			strClose = "";
			if (strTag.indexOf("![CDATA[") == 0) {
				strOpen = "<![CDATA[";
				strClose = "]]>";
				strType = "cdata";
			} else if (strTag.indexOf("!--") == 0) {
				strOpen = "<!--";
				strClose = "-->";
				strType = "comment";
			} else if (strTag.indexOf("?") == 0) {
				strOpen = "<?";
				strClose = "?>";
				strType = "pi";
			} else strType = "element";
			if (strClose != "") {
				strText = "";
				if (arrElementsUnparsedText[i].indexOf(strClose) > -1) strText = arrElementsUnparsedText[i];
				else {
					for (; i<arrElementsUnparsed.length && arrElementsUnparsedText[i].indexOf(strClose) == -1; i++) {
						strText += arrElementsUnparsedText[i];
					}
					strText += arrElementsUnparsedText[i];
				}
				if (strText.substring(strOpen.length, strText.indexOf(strClose)) != "")	{
					xmleLastElement.childElements[xmleLastElement.childElements.length] = new REXML_XMLElement(strType, "","",xmleLastElement,strText.substring(strOpen.length, strText.indexOf(strClose)));
					if (strType == "cdata") xmleLastElement.text += strText.substring(strOpen.length, strText.indexOf(strClose));
				}
				if (strText.indexOf(strClose)+ strClose.length < strText.length) {
					xmleLastElement.childElements[xmleLastElement.childElements.length] = new REXML_XMLElement("text", "","",xmleLastElement,strText.substring(strText.indexOf(strClose)+ strClose.length, strText.length));
					if (strType == "cdata") xmleLastElement.text += strText.substring(strText.indexOf(strClose)+ strClose.length, strText.length);
				}
				continue;
			}
			if (strText.replace(/ */, "") == "") strText = "";
			if (arrElementsUnparsed[i].substring(1,2) != "/") {
				if (iElements == 0) {
					xmleLastElement = this.rootElement = new REXML_XMLElement(strType, strTag,strAttributes,null,strText);
					iElements++;
					if (strText != "") xmleLastElement.childElements[xmleLastElement.childElements.length] = new REXML_XMLElement("text", "","",xmleLastElement,strText);
				} else if (arrElementsUnparsed[i].substring(arrElementsUnparsed[i].length-2,arrElementsUnparsed[i].length-1) != "/") {
					xmleLastElement = xmleLastElement.childElements[xmleLastElement.childElements.length] = new REXML_XMLElement(strType, strTag,strAttributes,xmleLastElement,"");
					iElements++;
					if (strText != "") {
						xmleLastElement.text += strText;
						xmleLastElement.childElements[xmleLastElement.childElements.length] = new REXML_XMLElement("text", "","",xmleLastElement,strText);
					}
				} else {
					xmleLastElement.childElements[xmleLastElement.childElements.length] = new REXML_XMLElement(strType, strTag,strAttributes,xmleLastElement,strText);
					if (strText != "") xmleLastElement.childElements[xmleLastElement.childElements.length] = new REXML_XMLElement("text", "","",xmleLastElement,strText);
				}
			} else {
				xmleLastElement = xmleLastElement.parentElement;
				iElements--;
				if (xmleLastElement && strText != "") {
					xmleLastElement.text += strText;
					xmleLastElement.childElements[xmleLastElement.childElements.length] = new REXML_XMLElement("text", "","",xmleLastElement,strText);
				}
			}
		}
	}

	function REXML_XMLElement(strType, strName, strAttributes, xmlParent, strText) {
		this.type = strType;
		this.name = strName;
		this.attributeString = strAttributes;
		this.attributes = null;
		this.childElements = new Array();
		this.parentElement = xmlParent;
		this.text = strText; // text of element

		this.getText = REXML_XMLElement_getText; // text of element and child elements
		this.childElement = REXML_XMLElement_childElement;
		this.attribute = REXML_XMLElement_attribute;
	}

		function REXML_XMLElement_getText() {
			if (this.type == "text" || this.type == "cdata") {
				return this.text;
			} else if (this.childElements.length) {
				var L = "";
				for (var i=0; i<this.childElements.length; i++) {
					L += this.childElements[i].getText();
				}
				return L;
			} else return null;
		}
		
		function REXML_XMLElement_childElement(strElementName) {
			for (var i=0; i<this.childElements.length; i++) if (this.childElements[i].name == strElementName) return this.childElements[i];
			return null;
		}

		function REXML_XMLElement_attribute(strAttributeName) {
			if (!this.attributes) {
				var reAttributes = new RegExp(" ([^= ]*)=","g"); // matches attributes
				if (this.attributeString.match(reAttributes) && this.attributeString.match(reAttributes).length) {
					var arrAttributes = this.attributeString.match(reAttributes);
					if (!arrAttributes.length) arrAttributes = null;
					else for (var j=0; j<arrAttributes.length; j++) {
						arrAttributes[j] = new Array(
							(arrAttributes[j]+"").replace(/[= ]/g,""),
							ParseAttribute(this.attributeString, (arrAttributes[j]+"").replace(/[= ]/g,""))
										);
					}
					this.attributes = arrAttributes;
				}
			}
			if (this.attributes) for (var i=0; i<this.attributes.length; i++) if (this.attributes[i][0] == strAttributeName) return this.attributes[i][1];
			return null;
		}


function JSXMLBuilder() {
	this.XML = "";
	this.elements = new Array();
	Array.prototype.remove = Array_Remove;
	Array.prototype.add = Array_Add;

	this.load = JSXMLBuilder_load;
	this.element = JSXMLBuilder_element;
	this.addElementAt = JSXMLBuilder_addElementAt;
	this.insertElementAt = JSXMLBuilder_insertElementAt;
	this.removeElement = JSXMLBuilder_removeElement;
	this.generateXML = JSXMLBuilder_generateXML;
	this.moveElement = JSXMLBuilder_moveElement;
	this.addChildElement = JSXMLBuilder_addChildElement;
}

	function JSXMLBuilder_load(strXML, xmleElem) {
		this.XML = strXML;

		if (!xmleElem) {
			if (strXML.length) xmleElem = (new REXML(strXML)).rootElement;
			else return false;
		}

		var xmlBuilder = new JSXMLIterator(xmleElem);

		while (true) {
			if (xmlBuilder.xmleElem.type == "element") {
				if (xmlBuilder.xmleElem.attributes) {
					this.addElementAt(xmlBuilder.xmleElem.name,xmlBuilder.xmleElem.attributes, xmlBuilder.xmleElem.text, this.elements.length, xmlBuilder.iElemLevel);
				} else {	
					this.addElementAt(xmlBuilder.xmleElem.name,xmlBuilder.xmleElem.attributeString, xmlBuilder.xmleElem.text, this.elements.length, xmlBuilder.iElemLevel);
				}
			}
			if (!xmlBuilder.getNextNode(false)) break;
		}
		for (var i=0; i<this.elements.length; i++) this.elements[i].index = i;
	}

	function JSXMLBuilder_element(iIndex) {
		return this.elements[iIndex];
	}
	
	function JSXMLBuilder_addChildElement(strElement)
	{
	    var Attributes = "";
	    var strText="";
	    var iElemIndex = 1;
	    var iElemLevel = 1;
	    iElemIndex = parseInt(iElemIndex);
		iElemLevel = parseInt(iElemLevel);
		if (iElemIndex < 0 || typeof(iElemIndex) != "number" || isNaN(iElemIndex)) iElemIndex = (this.elements.length>0) ? this.elements.length-1 : 0;
		if (iElemLevel < 0 || typeof(iElemLevel) != "number" || isNaN(iElemLevel)) iElemLevel = this.elements[iElemIndex-1].level;
		if (!Attributes) Attributes = "";
		var Elem = new Array();
		var iAddIndex = iElemIndex;
		if (iElemIndex > 0) {
			for (var i=iElemIndex; i<this.elements.length; i++) if (this.elements[i].level > iElemLevel) iAddIndex++;
			else if (this.elements[i].level <= this.elements[iElemIndex].level) break;
			Elem = new JSXMLBuilder_XMLElement(strElement,Attributes,strText,iElemLevel+1,this);
		} else {
			Elem = new JSXMLBuilder_XMLElement(strElement,Attributes,strText,1,this);
		}
		this.elements = this.elements.add(iAddIndex,Elem);
		for (var i=iAddIndex; i<this.elements.length; i++) this.elements[i].index = i;
		return Elem;
	}

	function JSXMLBuilder_addElementAt(strElement,Attributes,strText,iElemIndex,iElemLevel) {
		iElemIndex = parseInt(iElemIndex);
		iElemLevel = parseInt(iElemLevel);
		if (iElemIndex < 0 || typeof(iElemIndex) != "number" || isNaN(iElemIndex)) iElemIndex = (this.elements.length>0) ? this.elements.length-1 : 0;
		if (iElemLevel < 0 || typeof(iElemLevel) != "number" || isNaN(iElemLevel)) iElemLevel = this.elements[iElemIndex-1].level;
		if (!Attributes) Attributes = "";
		var Elem = new Array();
		var iAddIndex = iElemIndex;
		if (iElemIndex > 0) {
			for (var i=iElemIndex; i<this.elements.length; i++) if (this.elements[i].level > iElemLevel) iAddIndex++;
			else if (this.elements[i].level <= this.elements[iElemIndex].level) break;
			Elem = new JSXMLBuilder_XMLElement(strElement,Attributes,strText,iElemLevel+1,this);
		} else {
			Elem = new JSXMLBuilder_XMLElement(strElement,Attributes,strText,1,this);
		}
		this.elements = this.elements.add(iAddIndex,Elem);
		for (var i=iAddIndex; i<this.elements.length; i++) this.elements[i].index = i;
	}

	function JSXMLBuilder_insertElementAt(strElement,Attributes,strText,iElemIndex,iElemLevel) {
		iElemIndex = parseInt(iElemIndex);
		iElemLevel = parseInt(iElemLevel);
		if (iElemIndex < 0 || typeof(iElemIndex) != "number" || isNaN(iElemIndex)) iElemIndex = (this.elements.length>0) ? this.elements.length-1 : 0;
		if (iElemLevel < 0 || typeof(iElemLevel) != "number" || isNaN(iElemLevel)) iElemLevel = this.elements[iElemIndex-1].level;
		if (!Attributes) Attributes = "";
		var Elem = null;
		var iAddIndex = iElemIndex;
		if (iElemIndex > 0 && iElemLevel > 0) {
			Elem = new JSXMLBuilder_XMLElement(strElement,Attributes,strText,iElemLevel+1,this);
		} else {
			Elem = new JSXMLBuilder_XMLElement(strElement,Attributes,strText,1,this);
		}
		this.elements = this.elements.add(iAddIndex,Elem);
		for (var i=iAddIndex; i<this.elements.length; i++) this.elements[i].index = i;
	}


	function JSXMLBuilder_removeElement(iElemIndex) {
		iElemIndex = parseInt(iElemIndex);
		for (var iAfterElem=iElemIndex+1; iAfterElem<this.elements.length; iAfterElem++) if (this.elements[iAfterElem].level < this.elements[iElemIndex].level+1) break;

		this.elements = this.elements.slice(0,iElemIndex).concat(this.elements.slice(iAfterElem,this.elements.length));
		for (var i=iElemIndex; i<this.elements.length; i++) this.elements[i].index = i;
	}

	function JSXMLBuilder_moveElement(iElem1Index,iElem2Index) {
		var arrElem1Elements = new Array(this.elements[iElem1Index]);
		var arrElem2Elements = new Array(this.elements[iElem2Index]);
		for (var i=iElem1Index; i<this.elements.length; i++) if (this.elements[i].level > this.elements[iElem1Index].level) arrElem1Elements[arrElem1Elements.length] = this.elements[i]; else if (i>iElem1Index) break;
		for (var i=iElem2Index; i<this.elements.length; i++) if (this.elements[i].level > this.elements[iElem2Index].level) arrElem2Elements[arrElem2Elements.length] = this.elements[i]; else if (i>iElem2Index) break;
		var arrMovedElements = new Array();
		if (iElem1Index < iElem2Index) {
			for (i=0; i<iElem1Index; i++) arrMovedElements[arrMovedElements.length] = this.elements[i]; // start to the 1st element
			for (i=iElem1Index+arrElem1Elements.length; i<iElem2Index+arrElem2Elements.length; i++) arrMovedElements[arrMovedElements.length] = this.elements[i]; // end of 1st element to end of 2nd element
			for (i=0; i<arrElem1Elements.length; i++) arrMovedElements[arrMovedElements.length] = arrElem1Elements[i]; // 1st element and all child elements
			for (i=iElem2Index+arrElem2Elements.length; i<this.elements.length; i++) arrMovedElements[arrMovedElements.length] = this.elements[i]; // end of 2nd element to end
			this.elements = arrMovedElements;
		} else {
			for (i=0; i<iElem2Index; i++) arrMovedElements[arrMovedElements.length] = this.elements[i]; // start to the 2nd element
			for (i=0; i<arrElem1Elements.length; i++) arrMovedElements[arrMovedElements.length] = arrElem1Elements[i]; // 1st element and all child elements
			for (i=iElem2Index; i<iElem1Index; i++) arrMovedElements[arrMovedElements.length] = this.elements[i]; // 2nd element to 1st element
			for (i=iElem1Index+arrElem1Elements.length; i<this.elements.length; i++) arrMovedElements[arrMovedElements.length] = this.elements[i]; // end of 1st element to end
			this.elements = arrMovedElements;
		}
		for (var i=0; i<this.elements.length; i++) this.elements[i].index = i;
	}


	function JSXMLBuilder_generateXML(bXMLTag) {
		var strXML = "";
		var arrXML = new Array();
		if (bXMLTag) strXML += '<?xml version="1.0"?>\n\n'
		for (var i=0; i<this.elements.length; i++) {
			strXML += RepeatChar("\t",this.elements[i].level-1);
			strXML += "<" + this.element(i).name // open tag
			if (this.element(i).attributes) {
				for (var j=0; j<this.element(i).attributes.length; j++) { // set attributes
					if (this.element(i).attributes[j]) {
						strXML += ' ' + this.element(i).attributes[j][0] + '="' + this.element(i).attributes[j][1] + '"';
					}
				}
			} else strXML += this.element(i).attributeString.replace(/[\/>]$/gi, "");
			if (((this.elements[i+1] && this.elements[i+1].level <= this.elements[i].level) || // next element is a lower or equal to
				(!this.elements[i+1] && this.elements[i-1])) // no next element, previous element
				&& this.element(i).text == "") {
				strXML += "/";
			}
			strXML += ">";
			if (this.element(i).text != "") strXML += this.element(i).text;
			else strXML += "\n";
			if (((this.elements[i+1] && this.elements[i+1].level <= this.elements[i].level) || // next element is a lower or equal to
				(!this.elements[i+1] && this.elements[i-1])) // no next element, previous element
				&& this.element(i).text != "") strXML += "</" + this.element(i).name + ">\n";
			if (!this.elements[i+1]) {
				lastelem = i;
				for (var j=i; j>-1; j--) {
					if (this.elements[j].level >= this.elements[i].level) continue;
					else {
						if (this.elements[j].level < this.elements[lastelem].level) {
							strXML += RepeatChar("\t",this.elements[j].level-1) + "</" + this.element(j).name + ">\n";
							lastelem = j;
						}
					}
				}
			} else {
				if (this.elements[i+1].level < this.elements[i].level) {
					lastelem = i;
					for (var j=i; this.elements[j].level>=this.elements[i+1].level; j--) {
						if (this.elements[i] && this.elements[j] && this.elements[j].level < this.elements[i].level && this.elements[j].level < this.elements[lastelem].level) {
							strXML += RepeatChar("\t",this.elements[j].level-1) + "</" + this.element(j).name + ">\n";
							lastelem = j;
						}
					}
				}
			}
			if (strXML.length > 1000) {
				arrXML[arrXML.length] = strXML;
				strXML = "";
			}
		}
		arrXML[arrXML.length] = strXML;
		return arrXML.join("");
	}

	function JSXMLBuilder_XMLElement(strName,Attributes,strText,iLevel,xmlBuilder) {
		this.type = "element";
		this.name = strName;
		this.attributes = (typeof(Attributes) != "string") ? Attributes : null;
		this.attributeString = (typeof(Attributes) == "string") ? Attributes : "";
		this.text = strText;
		this.level = iLevel;
		this.index = -1;
		this.xmlBuilder = xmlBuilder;

		this.parseAttributes = JSXMLBuilder_XMLElement_parseAttributes;
		this.attribute = JSXMLBuilder_XMLElement_attribute;
		this.setAttribute = JSXMLBuilder_XMLElement_setAttribute;
		this.removeAttribute = JSXMLBuilder_XMLElement_removeAttribute;
		this.parentElement = JSXMLBuilder_XMLElement_parentElement;
		this.childElement = JSXMLBuilder_XMLElement_childElement;
	}

		function JSXMLBuilder_XMLElement_parseAttributes() {
			if (!this.attributes) {
				var reAttributes = new RegExp(" ([^= ]*)=","g"); // matches attributes
				if (this.attributeString.match(reAttributes) && this.attributeString.match(reAttributes).length) {
					var arrAttributes = this.attributeString.match(reAttributes);
					if (!arrAttributes.length) arrAttributes = null;
					else for (var j=0; j<arrAttributes.length; j++) {
						arrAttributes[j] = new Array(
							(arrAttributes[j]+"").replace(/[= ]/g,""),
							ParseAttribute(this.attributeString, (arrAttributes[j]+"").replace(/[= ]/g,""))
										);
					}
					this.attributes = arrAttributes;
				}
			}
		}
	
		function JSXMLBuilder_XMLElement_attribute(AttributeName) {
			if (!this.attributes) this.parseAttributes();
			if (this.attributes) for (var i=0; i<this.attributes.length; i++) if (this.attributes[i][0] == AttributeName) return this.attributes[i][1];
			return "";
		}

		function JSXMLBuilder_XMLElement_setAttribute(AttributeName,Value) {
			if (!this.attributes) this.parseAttributes();
			if (this.attributes) for (var i=0; i<this.attributes.length; i++) if (this.attributes[i][0] == AttributeName) {
				this.attributes[i][1] = Value;
				return;
			}
			this.attributes[this.attributes.length] = new Array(AttributeName,Value);
		}

		function JSXMLBuilder_XMLElement_removeAttribute(AttributeName,Value) {
			if (!this.attributes) this.parseAttributes();
			if (this.attributes) for (var i=0; i<this.attributes.length; i++) if (this.attributes[i][0] == AttributeName) {
				this.attributes = this.attributes.remove(i);
				return;
			}
		}

		function JSXMLBuilder_XMLElement_parentElement() {
			for (var i=this.index; this.xmlBuilder.element(i) && this.xmlBuilder.element(i).level != this.level-1; i--);
			return this.xmlBuilder.element(i);
		}

		function JSXMLBuilder_XMLElement_childElement(Child) {
			var iFind = -1;
			for (var i=this.index+1; i<this.xmlBuilder.elements.length; i++) {
				if (this.xmlBuilder.elements[i].level == this.level+1) {
					iFind++;
					if (iFind == Child || this.xmlBuilder.elements[i].name == Child) return this.xmlBuilder.elements[i];
				} else if (this.xmlBuilder.elements[i].level <= this.level) break;
			}
			return null;
		}


function JSXMLIterator(xmleElem) {
	this.xmleElem = xmleElem;
	
	this.iElemIndex = 0;
	this.arrElemIndex = new Array(0);
	this.iElemLevel = 0;
	this.iElem = 0;
	this.arrElemIndex[this.iElemLevel] = -1;

	this.getNextNode = JSXMLIterator_getNextNode;
}

	function JSXMLIterator_getNextNode() {
		if (!this.xmleElem || this.iElemLevel<0)	return false;
		if (this.xmleElem.childElements.length) {  // move up
			this.arrElemIndex[this.iElemLevel]++;
			this.iElemIndex++;
			this.iElemLevel++;
			this.arrElemIndex[this.iElemLevel] = 0;
			this.xmleElem = this.xmleElem.childElements[0];
		} else { // move next
			this.iElemIndex++;
			this.arrElemIndex[this.iElemLevel]++;
			if (this.xmleElem.parentElement && this.xmleElem.parentElement.childElements.length && this.arrElemIndex[this.iElemLevel] < this.xmleElem.parentElement.childElements.length) this.xmleElem = this.xmleElem.parentElement.childElements[this.arrElemIndex[this.iElemLevel]];
			else {
				if (this.iElemLevel>0) { // move down
					for (; this.iElemLevel > 0; this.iElemLevel--) {
						if (this.xmleElem.parentElement && this.xmleElem.parentElement.childElements[this.arrElemIndex[this.iElemLevel]]) {
							this.xmleElem = this.xmleElem.parentElement.childElements[this.arrElemIndex[this.iElemLevel]];
							this.iElemLevel++;
							this.arrElemIndex = this.arrElemIndex.slice(0,this.iElemLevel+1);
							break;
						} else {
							this.xmleElem = this.xmleElem.parentElement;
						}
					}
					this.iElemLevel--;
				} else {
					return false;
				}
			}
		}
		return (typeof(this.xmleElem) == "object" && this.iElemLevel > -1);
	}

function ParseAttribute(str,Attribute) {
	var str = str +  ">";
	if (str.indexOf(" "+Attribute + "='")>-1) var Attr = new RegExp(".*" +" "+ Attribute + "='([^']*)'.*>");
	else if (str.indexOf(" "+Attribute + '="')>-1) var Attr = new RegExp(".*" +" "+ Attribute + '="([^"]*)".*>');
	return str.replace(Attr, "$1");
}

function Array_Remove(c) {
	var tmparr = new Array();
	for (var i=0; i<this.length; i++) if (i!=c) tmparr[tmparr.length] = this[i];
	return tmparr;
}

function Array_Add(c, cont) {
	if (c == this.length) {
		this[this.length] = cont;
		return this;
	}
	var tmparr = new Array();
	for (var i=0; i<this.length; i++) {
		if (i==c) tmparr[tmparr.length] = cont;
		tmparr[tmparr.length] = this[i];
	}
	if (!tmparr[c]) tmparr[c] = cont;
	return tmparr;
}

function RepeatChar(sChar,iNum) {
	var L = "";
	for (var i=0; i<iNum; i++) L += sChar;
	return L;
}
