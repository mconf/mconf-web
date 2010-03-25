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
import flash.display.DisplayObject;
import mx.controls.ComboBox;
import mx.core.IFlexDisplayObject;
import mx.core.UIComponent;
import mx.controls.TextInput;

public class IconComboBox extends ComboBox
{
	public function IconComboBox() 
	{
		super();
	}

	private var iconHolder:UIComponent;

	override protected function createChildren():void
	{
		super.createChildren();

		iconHolder = new UIComponent();
		addChild(iconHolder);
	}
	
	public function getTextInput():TextInput
	{
		return textInput;
	}

	override protected function measure():void
	{
		super.measure();
		if (iterator)
		{
			var iconClass:Class = iterator.current.icon;
			var icon:IFlexDisplayObject = new iconClass() as IFlexDisplayObject;
			while (iconHolder.numChildren > 0)
				iconHolder.removeChildAt(0);
			iconHolder.addChild(DisplayObject(icon));
			measuredWidth += icon.measuredWidth;
			measuredHeight = Math.max(measuredHeight, icon.measuredHeight + borderMetrics.top + borderMetrics.bottom);
		}
	}

    override protected function updateDisplayList(unscaledWidth:Number,
                                                  unscaledHeight:Number):void
    {
        super.updateDisplayList(unscaledWidth, unscaledHeight);
		
		if(!selectedItem)
			return;
			
		var iconClass:Class = selectedItem.icon;
		var icon:IFlexDisplayObject = new iconClass() as IFlexDisplayObject;
		while (iconHolder.numChildren > 0)
			iconHolder.removeChildAt(0);
		iconHolder.addChild(DisplayObject(icon));
		iconHolder.y = (unscaledHeight - icon.measuredHeight) / 2;
		iconHolder.x = borderMetrics.left;
		textInput.setStyle("paddingLeft", 16);
//		textInput.x = iconHolder.x + icon.measuredWidth;
//		textInput.setActualSize(textInput.width - icon.measuredWidth, textInput.height);

	} 
   
}

}