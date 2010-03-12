package anzsoft.iJabBar.client.gui;

import anzsoft.xmpp4gwt.client.JID;

public interface ContactViewListener {
	public void onOpenChat(final JID jid);

	public void onOpenVCard(final JID jid);

	public void onAuthReq(final JID jid);

	public void onRemoveUser(final JID jid);

	public void onRenameUser(final JID jid, final String newName);

	public void onChangeGroup(final JID jid, final String newGroupName);

	public void onRenameGroup(final String oldGroupName,
			final String newGroupName);
}
