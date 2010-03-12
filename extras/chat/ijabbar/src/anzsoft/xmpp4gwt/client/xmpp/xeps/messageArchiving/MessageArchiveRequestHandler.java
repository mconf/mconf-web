package anzsoft.xmpp4gwt.client.xmpp.xeps.messageArchiving;

import anzsoft.xmpp4gwt.client.ResponseHandler;
import anzsoft.xmpp4gwt.client.stanzas.IQ;
import anzsoft.xmpp4gwt.client.xmpp.ErrorCondition;

public abstract class MessageArchiveRequestHandler implements ResponseHandler {

	private MessageArchivingPlugin plugin;

	public void onError(IQ iq, ErrorType errorType,
			ErrorCondition errorCondition, String text) {
	}

	public final void onResult(final IQ iq) {
		ResultSet rs = plugin.makeResultSet(iq);
		onSuccess(iq, rs);
	}

	public abstract void onSuccess(final IQ iq, ResultSet rs);

	void setPlugin(MessageArchivingPlugin plugin) {
		this.plugin = plugin;
	}

}
