package anzsoft.xmpp4gwt.client;

public interface ScriptSyntaxRequestCallback {
	void onResponseReceived(String callbackID, String responseText);

	void onError(String callbackID);
}
