package org.jivesoftware.xiff.core
{
	public class UnescapedJID extends AbstractJID
	{
		public function UnescapedJID(inJID:String, validate:Boolean=false)
		{
			super(inJID, validate);			
			
			if(node) {
   				_node = unescapedNode(node);
   			}
		}
		
		public function get escaped():EscapedJID
		{
			return new EscapedJID(toString());
		}
		
		public function equals(testJID:UnescapedJID, shouldTestBareJID:Boolean):Boolean 
    	{
        	if(shouldTestBareJID)
            	return testJID.bareJID == bareJID;
        	else
            	return testJID.toString() == toString();
    	}
	}
}