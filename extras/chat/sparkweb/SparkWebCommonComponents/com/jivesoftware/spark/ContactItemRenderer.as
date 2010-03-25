/*
 *This file is part of SparkWeb.
 *
 *SparkWeb is free software: you can redistribute it and/or modify
 *it under the terms of the GNU Lesser General Public License as published by
 *the Free Software Foundation, either version 3 of the License, or
 *(at your option) any later version.
 *
 *SparkWeb is distributed in the hope that it will be useful,
 *but WITHOUT ANY WARRANTY; without even the implied warranty of
 *MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
 *GNU Lesser General Public License for more details.
 *
 *You should have received a copy of the GNU Lesser General Public License
 *along with SparkWeb.  If not, see <http://www.gnu.org/licenses/>.
 */

package com.jivesoftware.spark
{
	import mx.controls.treeClasses.TreeItemRenderer;
    import mx.controls.treeClasses.TreeListData;
    import mx.controls.Tree;
    import mx.containers.HBox;
    import mx.core.UITextField;
   // import com.jivesoftware.spark.DropDownButton;
    import mx.states.SetStyle;
    import mx.controls.Label;

    public class ContactItemRenderer extends TreeItemRenderer
    {
    	private var descriptionLabel:UITextField;
        private var hbox:HBox;
        private var title:Label;
        
        override protected function createChildren():void
        {
            if (hbox == null)
            {
                hbox = new HBox();
                hbox.horizontalScrollPolicy = "off";
                hbox.x = 0;
                hbox.y = 0;
                hbox.height = 20; //set inital height, if I had more time I would measure this some how
                hbox.setStyle("horizontalGap", 0);
                addChild(hbox);
            }
            
            if (!title)
            {
                title = new Label();
                label = new UITextField();
                hbox.addChild(title);
            }
            
            // add the butn first show it shows on the left.
            if (descriptionLabel == null){
                 descriptionLabel = new UITextField();
                 hbox.addChild(descriptionLabel);
            }
          
            // do this last so we can create the label field before the super class.
            super.createChildren();
        }
        
        /**
         * Notice I dont call super.updateDisplayList
         * Thats because it is that super class that will freak out things
         * But this is really just a copy and paste from the base class
         * with a bit of tweaking
         **/
        override protected function updateDisplayList(unscaledWidth:Number, unscaledHeight:Number):void
        {
            if(super.data) {
                 if (TreeListData(super.listData)){
                    var startx:Number = TreeListData(super.listData) ? TreeListData(super.listData).indent : 0;
                    
                    if (disclosureIcon)
                    {
                        disclosureIcon.x = startx;
                        startx = disclosureIcon.x + disclosureIcon.width;
                        disclosureIcon.setActualSize(disclosureIcon.width,
                                                     disclosureIcon.height);
                        disclosureIcon.visible = TreeListData(super.listData) ?
                                                 TreeListData(super.listData).hasChildren :
                                                 false;
                    }
                    if (icon)
                    {
                        icon.x = startx;
                        startx = icon.x + icon.measuredWidth;
                        icon.setActualSize(icon.measuredWidth, icon.measuredHeight);
                    }
                    
                    
                    hbox.x = startx;
                    hbox.width = unscaledWidth - startx, measuredHeight;
                    
                    var verticalAlign:String = getStyle("verticalAlign");
                    if (verticalAlign == "top")
                    {
                        title.y = 0;
                        if (icon)
                            icon.y = 0;
                        if (disclosureIcon)
                            disclosureIcon.y = 0;
                    }
                    else if (verticalAlign == "bottom")
                    {
                        title.y = unscaledHeight - title.height + 2; // 2 for gutter
                        if (icon)
                            icon.y = unscaledHeight - icon.height;
                        if (disclosureIcon)
                            disclosureIcon.y = unscaledHeight - disclosureIcon.height;
                    }
                    else
                    {
                        title.y = (unscaledHeight - title.height) / 2;
                        if (icon)
                            icon.y = (unscaledHeight - icon.height) / 2;
                        if (disclosureIcon)
                            disclosureIcon.y = (unscaledHeight - disclosureIcon.height) / 2;
                    }
            
                    var labelColor:Number;
            
                    var type:String = tmp.@type;
                    var tmp:XMLList = new XMLList(TreeListData(super.listData).item);
                    var myStr:int = tmp[0].children().length();
                    if( !TreeListData(super.listData).hasChildren && type != 'group') {
						var str:String = tmp[0].@status;
						title.htmlText = "<font size='10' color='#555F6A'>"+TreeListData(super.listData).label+"</font>";
               
						if(str != null && str.length > 0){
							descriptionLabel.textColor = 0x808080;
                    		descriptionLabel.text = "- "+str;
						}
                    }
                    else {
						var html:String =  "<font size='11' color='#666666'><b>"+TreeListData(super.listData).label + " (" + myStr + ")"+"</b></font>";
                    	if(title.htmlText != html){
                    		title.htmlText = html;
                    	}
                    }
                    
                
                }
            }
        }
    }
}