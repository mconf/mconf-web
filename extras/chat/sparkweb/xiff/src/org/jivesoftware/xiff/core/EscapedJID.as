package org.jivesoftware.xiff.core
{
	public class EscapedJID extends AbstractJID
	{
		public function EscapedJID(inJID:String, validate:Boolean=false)
		{
			super(inJID, validate);
			
			if(node) {
				_node = escapedNode(node);
			}
		}
		
		public function get unescaped():UnescapedJID
		{
			return new UnescapedJID(toString());
		}
		
		public function equals(testJID:EscapedJID, shouldTestBareJID:Boolean):Boolean 
    	{
        	if(shouldTestBareJID)
            	return testJID.bareJID == bareJID;
        	else
            	return testJID.toString() == toString();
    	}
	}
}