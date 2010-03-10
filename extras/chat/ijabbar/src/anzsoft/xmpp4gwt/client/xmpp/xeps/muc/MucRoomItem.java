package anzsoft.xmpp4gwt.client.xmpp.xeps.muc;

public class MucRoomItem {
	private String jid;
	private String name;

	public MucRoomItem(final String jid, final String name) {
		this.jid = jid;
		this.name = name;
	}

	public String getName() {
		return this.name;
	}

	public String getJid() {
		return this.jid;
	}

	public void setName(final String name) {
		this.name = name;
	}

	public void setJid(final String jid) {
		this.jid = jid;
	}
}
