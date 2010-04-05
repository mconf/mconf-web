package org.jivesoftware.xiff.data.im
{
	/*
	 * Copyright (C) 2008
	 * Jive Software
	 *
	 * This library is free software; you can redistribute it and/or
	 * modify it under the terms of the GNU Lesser General Public
	 * License as published by the Free Software Foundation; either
	 * version 2.1 of the License, or (at your option) any later version.
	 * 
	 * This library is distributed in the hope that it will be useful,
	 * but WITHOUT ANY WARRANTY; without even the implied warranty of
	 * MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the GNU
	 * Lesser General Public License for more details.
	 * 
	 * You should have received a copy of the GNU Lesser General Public
	 * License along with this library; if not, write to the Free Software
	 * Foundation, Inc., 59 Temple Place, Suite 330, Boston, MA  02111-1307  USA 
	 *
	 */
	 
	import mx.collections.ArrayCollection;
	import mx.collections.Sort;
	import mx.collections.SortField;
	
	public class RosterGroup extends ArrayCollection
	{
		public var label:String;
		public var shared:Boolean = false;
		
		public function RosterGroup(l:String)
		{
			var s:Sort = new Sort();
		    s.fields = [new SortField("displayName", true)];
		    sort = s;
		    refresh();
			label = l;
		}
		
		public override function addItem(item:Object):void
		{
			if(!item is RosterItemVO)
				throw new Error("Assertion Failure: attempted to add something other than a RosterItemVO to a RosterGroup");
			if(source.indexOf(item) == -1)
				super.addItem(item);
		}
		
		public function removeItem(item:RosterItemVO):void
		{
			var itemIndex:int = getItemIndex(item);
			if(itemIndex >= 0)
				removeItemAt(itemIndex);
			else
			{
				itemIndex =	source.indexOf(item);
				if(itemIndex >= 0)
					source.splice(itemIndex, 1);
			}
		}
		
		public override function set filterFunction(f:Function):void
		{
			throw new Error("Setting the filterFunction on RosterGroup is not allowed; Wrap it in a ListCollectionView and filter that.");
		}

		private function sortContacts(item1:RosterItemVO, item2:RosterItemVO, fields:Array = null):int
		{
			if(item1.displayName.toLowerCase() < item2.displayName.toLowerCase())
				return -1;
			else if(item1.displayName.toLowerCase() > item2.displayName.toLowerCase())
				return 1;
			return 0;
		}
	}
}