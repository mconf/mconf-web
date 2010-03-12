package anzsoft.iJabBar.client.gui;

import anzsoft.xmpp4gwt.client.xmpp.message.Notify;

import com.extjs.gxt.ui.client.widget.DataListItem;

@SuppressWarnings("deprecation")
public class NotifyItem extends DataListItem {
	private Notify notify;

	public NotifyItem() {
		super();
	}

	public NotifyItem(String text, Notify notify) {
		super(text);
		this.notify = notify;
	}

	public void setNotify(Notify notify) {
		this.notify = notify;
	}

	public Notify getNotify() {
		return notify;
	}
}
