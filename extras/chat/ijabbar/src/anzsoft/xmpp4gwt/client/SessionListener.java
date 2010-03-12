package anzsoft.xmpp4gwt.client;

import anzsoft.xmpp4gwt.client.Connector.BoshErrorCondition;

public interface SessionListener {
	void onBeforeLogin();

	void onEndLogin();

	void onLoginOut();

	void onError(BoshErrorCondition boshErrorCondition, String message);

}
