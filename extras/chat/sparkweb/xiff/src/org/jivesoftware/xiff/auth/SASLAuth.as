package org.jivesoftware.xiff.auth
{
	import flash.xml.XMLNode;
	
	public class SASLAuth
	{
		protected var stage:int;
		protected var req:XMLNode;
		
		public function get request():XMLNode
		{
			return req;
		}
		
		public function handleResponse(stage:int, response:XMLNode):Object
		{
			throw new Error("Don't call this method on SASLAuth; use a subclass");
		}
	}
}