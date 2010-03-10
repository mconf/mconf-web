package anzsoft.xmpp4gwt.client;

public interface ScriptSendImpl {
	void sendRequest(String body, String url, String callbackID, int timeOut,
			ScriptSyntaxRequestCallback callbackHandler);
}
