package anzsoft.xmpp4gwt.client.packet;

import java.util.ArrayList;
import java.util.List;

import com.google.gwt.core.client.JavaScriptObject;
import com.google.gwt.core.client.JsArray;
import com.google.gwt.user.client.Window;

public class PacketREXMLImpl implements Packet {
	private final JavaScriptObject element;

	public PacketREXMLImpl(JavaScriptObject element) {
		this.element = element;
	}

	public Packet addChild(String nodeName, String xmlns) {
		Window
				.alert("Do not use PacketREXMLImpl as packet builder, it just for parser!");
		return null;
	}

	public native String getAsString()
	/*-{
		try
		{
			var jsxmlBuilder = new $wnd.JSXMLBuilder();
			jsxmlBuilder.load("",this.@anzsoft.xmpp4gwt.client.packet.PacketREXMLImpl::element);
			return jsxmlBuilder.generateXML();
		}
		catch(e)
		{
			return null;
		}
	}-*/;

	public native String getAtribute(String attrName)
	/*-{
		try
		{
			return this.@anzsoft.xmpp4gwt.client.packet.PacketREXMLImpl::element.attribute(attrName);
		}
		catch(e)
		{
			alert("get null attribute:"+attrName);
			return null;
		}
	}-*/;

	public native String getCData()
	/*-{
		try
		{
			var x = this.@anzsoft.xmpp4gwt.client.packet.PacketREXMLImpl::element.childElements[0];
			if(x != null)
				return x.getText();
			else
				return null;
		}
		catch(e)
		{
			return null;
		}
	}-*/;

	public List<? extends Packet> getChildren() {
		ArrayList<PacketREXMLImpl> result = new ArrayList<PacketREXMLImpl>();
		JsArray<JavaScriptObject> array = getChilderN();
		for (int index = 0; index < array.length(); index++) {
			result.add(new PacketREXMLImpl(array.get(index)));
		}
		return result;
	}

	private native JsArray<JavaScriptObject> getChilderN()
	/*-{
		return this.@anzsoft.xmpp4gwt.client.packet.PacketREXMLImpl::element.childElements;
	}-*/;

	public Packet getFirstChild(String name) {
		JavaScriptObject o = getFirstChildN(name);
		if (o != null)
			return new PacketREXMLImpl(o);
		else
			return null;
	}

	private native JavaScriptObject getFirstChildN(String name)
	/*-{
		try
		{
			return this.@anzsoft.xmpp4gwt.client.packet.PacketREXMLImpl::element.childElement(name);
		}
		catch(e)
		{
			return null;
		}
	}-*/;

	public native String getName()
	/*-{
		return this.@anzsoft.xmpp4gwt.client.packet.PacketREXMLImpl::element.name;
	}-*/;

	public void removeChild(Packet packet) {
		Window
				.alert("Do not use PacketREXMLImpl as packet builder, it just for parser!");
	}

	public void setAttribute(String attrName, String value) {
		Window
				.alert("Do not use PacketREXMLImpl as packet builder, it just for parser!");
	}

	public void setCData(String cdata) {
		Window
				.alert("Do not use PacketREXMLImpl as packet builder, it just for parser!");
	}

	public JavaScriptObject getJSO() {
		return this.element;
	}
}
