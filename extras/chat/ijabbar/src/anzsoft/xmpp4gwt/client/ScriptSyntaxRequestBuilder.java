package anzsoft.xmpp4gwt.client;

import com.google.gwt.http.client.URL;

public class ScriptSyntaxRequestBuilder {
	private final String url;
	private int timeoutMillis;
	private static int ID = 0;
	private ScriptSendImpl sendImpl = null;

	public ScriptSyntaxRequestBuilder(String url) {
		this.url = url;
	}

	public String sendRequest(String body, ScriptSyntaxRequestCallback callback) {
		String callbackID = "transId" + ID++;
		if (sendImpl != null)
			sendImpl.sendRequest(URL.encode(body), url, callbackID,
					this.timeoutMillis, callback);
		else
			sendRequestImpl(URL.encode(body), url, callbackID,
					this.timeoutMillis, callback);
		return callbackID;
	}

	public void setTimeoutMillis(int timeoutMillis) {
		if (timeoutMillis < 0) {
			throw new IllegalArgumentException("Timeouts cannot be negative");
		}

		this.timeoutMillis = timeoutMillis;
	}

	private native void sendRequestImpl(String body, String url,
			String callbackID, int timeOut,
			ScriptSyntaxRequestCallback callbackHandler)
	/*-{
		var callback = callbackID;
		var script = document.createElement("script");
		script.setAttribute("src", url+"?xml="+body+"&callback="+callbackID);
		//script.setAttribute("src", url+"?"+body);
		script.setAttribute("type", "text/javascript");
		script.setAttribute("id",callbackID);
		window[callback] = function(xml)
		{
			callbackHandler.@anzsoft.xmpp4gwt.client.ScriptSyntaxRequestCallback::onResponseReceived(Ljava/lang/String;Ljava/lang/String;)(callbackID,xml);
			window[callback + "done"] = true;
		};
		
		setTimeout(function()
		{
			if (!window[callback + "done"]) 
			{
	   			callbackHandler.@anzsoft.xmpp4gwt.client.ScriptSyntaxRequestCallback::onError(Ljava/lang/String;)(callbackID);
	 		}
	 		
	 		document.body.removeChild(script);
		    delete window[callback];
		    delete window[callback + "done"];
		},timeOut*1000);
		document.body.appendChild(script);
	}-*/;

	public void setSendImpl(ScriptSendImpl sendImpl) {
		this.sendImpl = sendImpl;
	}

	public ScriptSendImpl getSendImpl() {
		return sendImpl;
	}

}
