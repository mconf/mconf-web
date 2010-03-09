package anzsoft.iJabBar.client.data;

import com.google.gwt.core.client.JavaScriptObject;

public class REXML {
	final private JavaScriptObject rootElement;

	public REXML(final String xml) {
		rootElement = create(xml);
	}

	public REXML(final JavaScriptObject rootElement) {
		this.rootElement = rootElement;
	}

	public native int getChildLength()
	/*-{
		try
		{
	 		return this.@anzsoft.iJabBar.client.data.REXML::rootElement.childElements.length;
		}
		catch(e)
		{
			return 0;
		}
	 }-*/;

	public native String getChildAttribute(int pos, String attribute)
	/*-{
		try
		{
			return this.@anzsoft.iJabBar.client.data.REXML::rootElement.childElements[pos].attribute(attribute);
		}
		catch(e)
		{
			return null;
		}
	}-*/;

	public native String getChildSubNodeValue(int pos, String nodeName)
	/*-{
		try
		{
			return this.@anzsoft.iJabBar.client.data.REXML::rootElement.childElements[pos].childElement(nodeName).text;
		}
		catch(e)
		{
			return null;
		}
	}-*/;

	private static native JavaScriptObject create(final String xml)
	/*-{
	 	var xmlDoc = new $wnd.REXML(xml);
	 	return xmlDoc.rootElement;
	 }-*/;

	public JavaScriptObject getJSO() {
		return this.rootElement;
	}

}
