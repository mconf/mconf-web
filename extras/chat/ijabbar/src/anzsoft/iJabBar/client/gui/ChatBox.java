package anzsoft.iJabBar.client.gui;

import java.util.ArrayList;
import java.util.Date;
import java.util.List;
import anzsoft.iJabBar.client.GlobalHandler;
import anzsoft.iJabBar.client.CacheHandler;
import anzsoft.xmpp4gwt.client.Session;
import anzsoft.xmpp4gwt.client.SessionListener;
import anzsoft.xmpp4gwt.client.Storage;
import anzsoft.xmpp4gwt.client.Connector.BoshErrorCondition;
import anzsoft.xmpp4gwt.client.stanzas.Message;
import anzsoft.xmpp4gwt.client.stanzas.Message.Type;
import anzsoft.xmpp4gwt.client.xmpp.message.Chat;
import anzsoft.xmpp4gwt.client.xmpp.roster.RosterPlugin;

import com.extjs.gxt.ui.client.event.BoxComponentEvent;
import com.extjs.gxt.ui.client.event.Listener;
import com.extjs.gxt.ui.client.GXT;
import com.extjs.gxt.ui.client.Style.Orientation;
import com.extjs.gxt.ui.client.Style.Scroll;
import com.extjs.gxt.ui.client.event.Events;
import com.extjs.gxt.ui.client.widget.ContentPanel;
import com.extjs.gxt.ui.client.widget.Html;
import com.extjs.gxt.ui.client.widget.LayoutContainer;
import com.extjs.gxt.ui.client.widget.layout.FitLayout;
import com.extjs.gxt.ui.client.widget.layout.RowData;
import com.extjs.gxt.ui.client.widget.layout.RowLayout;
import com.google.gwt.dom.client.Element;
import com.google.gwt.dom.client.Node;
import com.google.gwt.event.dom.client.KeyPressEvent;
import com.google.gwt.event.dom.client.KeyPressHandler;
import com.google.gwt.json.client.JSONArray;
import com.google.gwt.json.client.JSONObject;
import com.google.gwt.json.client.JSONParser;
import com.google.gwt.json.client.JSONString;
import com.google.gwt.user.client.DOM;
import com.google.gwt.user.client.Window;
import com.google.gwt.user.client.ui.TextArea;

public class ChatBox extends ContentPanel implements SessionListener {
	private final static String MSG_DATE = "0";
	private final static String MSG_NICK = "1";
	private final static String MSG_MSG = "2";
	private final static String MSG_LOCAL = "3";

	private final Chat<ChatBox> item;
	private final RosterPlugin rosterPlugin;

	private ContentPanel messagePanel;
	private final TextArea message = new TextArea();

	private String lastNick = null;
	private String nick;
	private ChatPanelButton button;

	private final static int minTextHeight = 22;
	private final static int maxTextHeight = 77;

	private LayoutContainer widgetContainer;
	private RowData messagePanelRowData;
	boolean isInitLayout = false;

	private final List<JSONObject> messageHistorys = new ArrayList<JSONObject>();
	private final String storeKey;

	public ChatBox(Chat<ChatBox> item) {
		storeKey = "ijab_chats_" + item.getJid().getNode();
		setStyleName("chatbox");
		this.setLayoutOnChange(true);
		setBorders(false);
		setFrame(false);

		message.setStyleName("chat_input");
		message.addKeyPressHandler(new KeyPressHandler() {
			public void onKeyPress(KeyPressEvent event) {
				adjustInputSize();
				if (event.getCharCode() == 13) {
					message.cancelKey();
					send();
				}
			}
		});

		this.item = item;
		rosterPlugin = Session.instance().getRosterPlugin();

		nick = rosterPlugin.getNameByJid(item.getJid());
		if (nick == null || nick.length() == 0)
			nick = item.getJid().getNode();

		setLayout(new FitLayout());
		add(createWidget());
		message.setFocus(true);
		messagePanel.addListener(Events.Render,
				new Listener<BoxComponentEvent>() {
					public void handleEvent(BoxComponentEvent be) {

						adjustInputSize();
						resume();
					}

				});
		GlobalHandler.instance().addCacheHandler(new CacheHandler() {
			public void onSuspend() {

				suspend();
			}

			public void onResume() {
				//resume();
			}

		});
		Session.instance().addListener(this);
	}

	@Override
	public void focus() {
		super.focus();
		message.setFocus(true);
	}

	private void adjustInputSize() {
		if (!widgetContainer.isRendered() || !messagePanel.isRendered()) {
			return;
		}
		int containerHeight = widgetContainer.getHeight();
		int textHeight = message.getElement().getScrollHeight();
		if (textHeight == 0 || message.getValue().length() == 0) {
			textHeight = minTextHeight;
		}
		if (textHeight != minTextHeight) {
			if (GXT.isGecko)
				textHeight += 8;
			if (GXT.isChrome)
				textHeight += 3;
		}

		if (textHeight > maxTextHeight) {
			textHeight = maxTextHeight;
			if (GXT.isIE)
				message.removeStyleName("chat_input_overflowhidden");
		} else {
			if (GXT.isIE)
				message.addStyleName("chat_input_overflowhidden");
		}
		if (textHeight < minTextHeight) {
			textHeight = minTextHeight;
		}

		messagePanel.setHeight(containerHeight - textHeight + "px");
		message.setHeight(textHeight + "px");
	}

	public void setButton(ChatPanelButton button) {
		this.button = button;
	}

	public ChatPanelButton getButton() {
		return this.button;
	}

	private LayoutContainer createWidget() {
		widgetContainer = new LayoutContainer();
		widgetContainer.setLayout(new RowLayout(Orientation.VERTICAL));
		widgetContainer.setBorders(false);

		messagePanel = new ContentPanel();
		messagePanel.setLayoutOnChange(true);
		messagePanel.addStyleName("message_view");
		messagePanel.setHeaderVisible(false);
		messagePanel.setBorders(false);
		messagePanel.setFrame(false);
		messagePanel.setScrollMode(Scroll.AUTOY);

		messagePanelRowData = new RowData(1, -1);
		widgetContainer.add(messagePanel, messagePanelRowData);
		widgetContainer.add(message, new RowData(1, -1));

		return widgetContainer;
	}

	public Chat<ChatBox> getChatItem() {
		return item;
	}

	@SuppressWarnings("deprecation")
	public void process(Message message) {
		if (message.getType() == Type.error)
			return;
		final String body = message.getBody();
		if (body != null && !(body.length() == 0)) {
			addMessage((new Date()).toLocaleString(), this.nick, body, false);
		}
	}

	@SuppressWarnings("deprecation")
	public void processSyncSend(Message message) {
		if (message.getType() != Type.syncsend)
			return;
		final String body = message.getBody();
		if (body != null && body.length() != 0) {
			addMessage((new Date()).toLocaleString(), "Me", body, true);
		}
	}

	@SuppressWarnings("deprecation")
	public void send() {
		final String msg = this.message.getText();
		if (msg == null || msg.length() == 0)
			return;
		this.message.setText("");
		this.message.setFocus(true);
		adjustInputSize();

		addMessage((new Date()).toLocaleString(), "Me", msg, true);
		this.item.send(msg);
	}

	private void resume() {
		try {
			final String prefix = Session.instance().getUser().getStorageID();
			Storage storage = Storage.createStorage(storeKey, prefix);
			String data = storage.get(storeKey);
			if (data == null || data.length() == 0)
				return;
			JSONArray array = JSONParser.parse(data).isArray();
			if (array == null)
				return;
			for (int index = 0; index < array.size(); index++) {
				JSONObject obj = array.get(index).isObject();
				if (obj == null)
					continue;
				String dateString = obj.get(MSG_DATE).isString().stringValue();
				String nick = obj.get(MSG_NICK).isString().stringValue();
				String msg = obj.get(MSG_MSG).isString().stringValue();
				boolean local = obj.get(MSG_LOCAL).isString().stringValue()
						.equalsIgnoreCase("true") ? true : false;
				addMessage(dateString, nick, msg, local);
			}
		} catch (Exception e) {
			Window.alert(e.toString());
		}

	}

	private void suspend() {
		if (messageHistorys.isEmpty())
			return;
		try {
			JSONArray array = new JSONArray();
			for (int index = 0; index < messageHistorys.size(); index++) {
				array.set(index, messageHistorys.get(index));
			}
			final String prefix = Session.instance().getUser().getStorageID();
			Storage storage = Storage.createStorage(storeKey, prefix);
			storage.set(storeKey, array.toString());
		} catch (Exception e) {
			Window.alert(e.toString());
		}
	}

	private void addMessage(String dateString, final String nick,
			final String msg, boolean local) {

		JSONObject msgHistory = new JSONObject();
		msgHistory.put(MSG_DATE, new JSONString(dateString));
		msgHistory.put(MSG_NICK, new JSONString(nick));
		msgHistory.put(MSG_MSG, new JSONString(msg));
		msgHistory.put(MSG_LOCAL, new JSONString(local ? "true" : "false"));

		if (messageHistorys.size() >= 8) {
			messageHistorys.remove(0);
		}
		messageHistorys.add(msgHistory);

		boolean isConsecutiveMessage = false;
		if (lastNick != null && lastNick.equals(nick))
			isConsecutiveMessage = true;
		lastNick = nick;
		String htmlText;
		if (local) {
			String id = DOM.createUniqueId();
			if (isConsecutiveMessage)
				htmlText = "<p style='text-align:left;' class='p_self pic_padding' id='msg_"
						+ id + "'>%message%</p>";
			else
				htmlText = "<h5 class='self'> <span class='time_stamp ts_self'>%time%</span>%sender%</h5>"
						+ "<div class='pic_padding' id='pending_"
						+ id
						+ "' />"
						+ "<p style='text-align:left;' class='p_self pic_padding' id='msg_"
						+ id + "'>%message%</p>";
			htmlText = formatMessageHtml(htmlText, dateString, nick, msg);
		} else {
			if (isConsecutiveMessage)
				htmlText = "<p style='text-align:left;' class='p_other pic_padding'>%message%</p>";
			else
				htmlText = "<h5 class='other'> <span class='time_stamp ts_other'>%time%</span>%sender%</h5>"
						+ "<p style='text-align:left;' class='p_other pic_padding'>%message%</p>";
			htmlText = formatMessageHtml(htmlText, dateString, nick, msg);
		}
		Html msgWidget = new Html(htmlText);
		messagePanel.add(msgWidget);
		messagePanel.setVScrollPosition(getMessageContentheight());
	}

	private String formatMessageHtml(final String source, String dateString,
			final String nick, final String msg) {
		String out = source;
		out = out.replace("%time%", dateString);
		//out = out.replace("%message%", TextUtils.html_wordwrap(msg,20));
		out = out.replace("%message%", msg);
		out = out.replace("%sender%", nick);
		return out;
	}

	private int getMessageContentheight() {
		int ret = 0;
		Element bwrap = messagePanel.getElement("bwrap");
		Node contentParent = bwrap.getFirstChild();
		if (contentParent != null) {
			for (Node node = contentParent.getFirstChild(); node != null; node = node
					.getNextSibling()) {
				ret = ret + ((Element) node).getOffsetHeight();
			}
		}
		return ret;
	}

	public String getNick() {
		return this.nick;
	}

	public void onBeforeLogin() {
	}

	public void onEndLogin() {
	}

	public void onError(BoshErrorCondition boshErrorCondition, String message) {
		try {
			final String prefix = Session.instance().getUser().getStorageID();
			Storage storage = Storage.createStorage(storeKey, prefix);
			storage.remove(storeKey);
		} catch (Exception e) {

		}
		button.close();
	}

	public void onLoginOut() {
		try {
			final String prefix = Session.instance().getUser().getStorageID();
			Storage storage = Storage.createStorage(storeKey, prefix);
			storage.remove(storeKey);
		} catch (Exception e) {

		}
		button.close();
	}
}
