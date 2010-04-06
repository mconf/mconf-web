
package org.jivesoftware.xiff.data{
	/*
	 * Copyright (C) 2003-2007 
	 * Nick Velloff <nick.velloff@gmail.com>
	 * Derrick Grigg <dgrigg@rogers.com>
	 * Sean Voisen <sean@voisen.org>
	 * Sean Treadway <seant@oncotype.dk>
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
	
	import org.jivesoftware.xiff.data.IExtension;
	import org.jivesoftware.xiff.data.IExtendable;
	 
	/**
	 * Contains the implementation for a generic extension container.  Use the static method "decorate" to implement the IExtendable interface on a class.
	 *
	 * @author Sean Treadway
	 * @since 2.0.0
	 * @availability Flash Player 7
	 * @toc-path Data
	 * @toc-sort 1
	 */
	public class ExtensionContainer implements IExtendable
	{
		public var _exts:Object;
		
		public function ExtensionContainer(){
			_exts = new Object();
		}
	
		public function addExtension( ext:IExtension ):IExtension
		{
			if (_exts[ext.getNS()] == null){
				_exts[ext.getNS()] = new Array();
			}
			_exts[ext.getNS()].push(ext);
			return ext;
		}
	
		public function removeExtension( ext:IExtension ):Boolean
		{
			var extensions:Object = _exts[ext.getNS()];
			for (var i:String in extensions) {
			//for (var i in extensions) { untyped var throws compiler warning
				if (extensions[i] === ext) {
					extensions[i].remove();
					extensions.splice(Number(i), 1);
					return true;
				}
			}
			return false;
		}
		public function removeAllExtensions( ns:String ):void
		{
			//for (var i in this[_exts][namespace]) {
			for (var i:String in _exts[ns]) {
				_exts[ns][i].ns();
			}
			_exts[ns] = new Array();
		}
	
		public function getAllExtensionsByNS( ns:String ):Array
		{
			return _exts[ns];
		}
		
		public function getExtension( name:String ):Extension
		{
			return getAllExtensions().filter(function(obj:IExtension, idx:int, arr:Array):Boolean { return obj.getElementName() == name; })[0];
		}
	
		public function getAllExtensions():Array
		{
			var exts:Array = new Array();
			for (var ns:String in _exts) {
			//for (var ns in this[_exts]) {
				exts = exts.concat(_exts[ns]);
			}
			return exts;
		}
	}
}