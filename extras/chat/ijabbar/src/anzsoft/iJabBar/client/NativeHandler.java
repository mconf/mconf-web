package anzsoft.iJabBar.client;

import anzsoft.xmpp4gwt.client.SessionListener;
import anzsoft.xmpp4gwt.client.Connector.BoshErrorCondition;

import com.google.gwt.core.client.JavaScriptObject;

public class NativeHandler implements SessionListener {
	final JavaScriptObject delegate;

	public NativeHandler(final JavaScriptObject delegate) {
		this.delegate = delegate;
	}

	private native void handleBeforeLogin()
	/*-{
		var delegate = this.@anzsoft.iJabBar.client.NativeHandler::delegate;
		delegate.onBeforeLogin();
	}-*/;

	private native void handleEndLogin()
	/*-{
		var delegate = this.@anzsoft.iJabBar.client.NativeHandler::delegate;
		delegate.onEndLogin();
	}-*/;

	private native void handleError(String message)
	/*-{
		var delegate = this.@anzsoft.iJabBar.client.NativeHandler::delegate;
		delegate.onError(message);
	}-*/;

	private native void handleLogout()
	/*-{
		var delegate = this.@anzsoft.iJabBar.client.NativeHandler::delegate;
		delegate.onLogout();
	}-*/;

	public void onBeforeLogin() {
		handleBeforeLogin();
	}

	public void onEndLogin() {
		handleEndLogin();
	}

	public void onError(BoshErrorCondition boshErrorCondition, String message) {
		handleError(message);
	}

	public void onLoginOut() {
		handleLogout();
	}

}
