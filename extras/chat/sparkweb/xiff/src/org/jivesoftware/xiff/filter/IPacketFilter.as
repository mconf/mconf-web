package org.jivesoftware.xiff.filter
{
	import org.jivesoftware.xiff.data.XMPPStanza;
	
	public interface IPacketFilter
	{
		function accept(packet:XMPPStanza):void;
	}
}