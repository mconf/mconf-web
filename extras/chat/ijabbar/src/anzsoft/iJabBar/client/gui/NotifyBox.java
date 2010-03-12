package anzsoft.iJabBar.client.gui;

import java.util.List;

import anzsoft.iJabBar.client.T;
import anzsoft.xmpp4gwt.client.Session;
import anzsoft.xmpp4gwt.client.Storage;
import anzsoft.xmpp4gwt.client.packet.Packet;
import anzsoft.xmpp4gwt.client.packet.PacketGwtImpl;
import anzsoft.xmpp4gwt.client.xmpp.message.Notify;

import com.extjs.gxt.ui.client.Style.SelectionMode;
import com.extjs.gxt.ui.client.event.ComponentEvent;
import com.extjs.gxt.ui.client.event.Events;
import com.extjs.gxt.ui.client.event.Listener;
import com.extjs.gxt.ui.client.widget.ContentPanel;
import com.extjs.gxt.ui.client.widget.DataList;
import com.extjs.gxt.ui.client.widget.DataListItem;
import com.extjs.gxt.ui.client.widget.layout.FitLayout;
import com.google.gwt.core.client.GWT;
import com.google.gwt.json.client.JSONArray;
import com.google.gwt.json.client.JSONParser;
import com.google.gwt.json.client.JSONString;
import com.google.gwt.user.client.Window;
import com.google.gwt.xml.client.Element;
import com.google.gwt.xml.client.XMLParser;

@SuppressWarnings("deprecation")
public class NotifyBox extends ContentPanel {
	private DataList notifyList;

	private static NotifyBox _instance = null;
	private BarAButton button;
	private BarMenu menu;
	static private String STORAGEKEY = "IJABNOTIFY";

	public static NotifyBox instance() {
		if (_instance == null)
			_instance = new NotifyBox();
		return _instance;
	}

	private NotifyBox() {
		getHeader().addStyleName("options_heading");
		setLayout(new FitLayout());
		setBorders(false);
		setFrame(false);

		createWidget();

		add(notifyList);
	}

	private void createWidget() {
		notifyList = new DataList();
		notifyList.setSelectionMode(SelectionMode.SINGLE);
		notifyList.setBorders(false);
		notifyList.addListener(Events.SelectionChange,
				new Listener<ComponentEvent>() {
					public void handleEvent(ComponentEvent be) {
						DataList l = (DataList) be.getComponent();
						NotifyItem item = (NotifyItem) l.getSelectedItem();
						openNotify(item);
					}
				});
	}

	private void openNotify(NotifyItem item) {
		if (item == null)
			return;
		Notify notify = item.getNotify();
		String url = notify.getUrl();
		notifyList.remove(item);
		updateTitle();
		Window.open(url, "_self", "_self");
	}

	public void notifyReceived(final Notify notify) {
		NotifyItem item = new NotifyItem(notify.getTitle(), notify);
		item.setText(notify.getTitle());
		notifyList.add(item);
		menu.show();
		updateTitle();
	}

	public void updateTitle() {
		int count = notifyList.getItemCount();
		String heading = count == 0 ? T.t().Nonotification() : T.t().Youhave()
				+ count + T.t().Notifications();
		button.setTooltip(heading);
		setHeading(heading);
	}

	public void setButton(BarAButton button) {
		this.button = button;
	}

	public void setMenu(BarMenu menu) {
		this.menu = menu;
	}

	public void suspend() {
		try {
			JSONArray jNotifys = new JSONArray();
			final String prefix = Session.instance().getUser().getStorageID();
			Storage storage = Storage.createStorage(STORAGEKEY, prefix);
			List<DataListItem> notifyItems = notifyList.getItems();
			int index = 0;
			for (DataListItem item : notifyItems) {
				NotifyItem notifyItem = (NotifyItem) item;
				Notify notify = notifyItem.getNotify();
				String notifyData = notify.toString();
				jNotifys.set(index, new JSONString(notifyData));
				index++;
			}
			storage.set(STORAGEKEY, jNotifys.toString());

		} catch (Exception e) {

		}
	}

	public void resume() {
		try {
			final String prefix = Session.instance().getUser().getStorageID();
			Storage storage = Storage.createStorage(STORAGEKEY, prefix);
			String data = storage.get(STORAGEKEY);
			if (data == null || data.length() == 0)
				return;
			JSONArray jNotifys = JSONParser.parse(data).isArray();
			if (jNotifys == null)
				return;
			for (int index = 0; index < jNotifys.size(); index++) {
				String notifyString = jNotifys.get(index).isString()
						.stringValue();
				if (notifyString == null || notifyString.length() == 0)
					continue;
				Notify notify = new Notify(parse(notifyString));
				notifyReceived(notify);
			}
		} catch (Exception e) {

		}
	}

	private Packet parse(String s) {
		if (s == null || s.length() == 0) {
			return null;
		} else {
			try {
				Element element = XMLParser.parse(s).getDocumentElement();
				return new PacketGwtImpl(element);
			} catch (Exception e) {
				GWT.log("Parsing error (\"" + s + "\")", e);
				return null;
			}
		}
	}

}
