package org.jivesoftware.xiff.auth
{
	import flash.xml.XMLNode;
	
	import org.jivesoftware.xiff.core.XMPPConnection;
	
	public class Anonymous extends SASLAuth
	{
		public function Anonymous(connection:XMPPConnection):void
		{
		    var attrs:Object = {
				mechanism: "ANONYMOUS",
				xmlns: "urn:ietf:params:xml:ns:xmpp-sasl"
			};
		
		    req = new XMLNode(1, "auth");
		    req.attributes = attrs;
		
		    stage = 0;
		}
		
		public override function handleResponse(stage:int, response:XMLNode):Object {
        	var success:Boolean = response.nodeName == "success";
       		return {
        		authComplete: true,
            	authSuccess: success,
           		authStage: stage++
        	};
    	}
	}
}