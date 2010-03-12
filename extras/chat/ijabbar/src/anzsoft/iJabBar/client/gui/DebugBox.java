package anzsoft.iJabBar.client.gui;

import java.util.Date;
import java.util.List;

import com.extjs.gxt.ui.client.Style.LayoutRegion;
import com.extjs.gxt.ui.client.Style.Scroll;
import com.extjs.gxt.ui.client.util.Margins;
import com.extjs.gxt.ui.client.widget.ContentPanel;
import com.extjs.gxt.ui.client.widget.Html;
import com.extjs.gxt.ui.client.widget.layout.BorderLayout;
import com.extjs.gxt.ui.client.widget.layout.BorderLayoutData;
import com.google.gwt.http.client.Response;
import com.google.gwt.i18n.client.DateTimeFormat;
import com.google.gwt.user.client.ui.KeyboardListener;
import com.google.gwt.user.client.ui.TextArea;
import com.google.gwt.user.client.ui.Widget;

import anzsoft.iJabBar.client.utils.TextUtils;
import anzsoft.xmpp4gwt.client.Bosh2Connector;
import anzsoft.xmpp4gwt.client.Connector;
import anzsoft.xmpp4gwt.client.ConnectorListener;
import anzsoft.xmpp4gwt.client.Connector.BoshErrorCondition;
import anzsoft.xmpp4gwt.client.packet.Packet;
import anzsoft.xmpp4gwt.client.xmpp.ErrorCondition;

@SuppressWarnings("deprecation")
public class DebugBox extends ContentPanel implements ConnectorListener {
	enum Type {
		in, out
	}

	private ContentPanel center = new ContentPanel();

	private final Html chat = new Html();

	private final Bosh2Connector connector;

	private DateTimeFormat dtf = DateTimeFormat.getFormat("HH:mm:ss");

	private final TextArea message = new TextArea();

	public DebugBox(Bosh2Connector connector) {

		this.connector = connector;
		this.connector.addListener(this);

		this.setId("ijab_debug_box");
		this.setHeading("Debug Wnidow");
		this.setSize(300, 300);

		setLayout(new BorderLayout());

		BorderLayoutData centerData = new BorderLayoutData(LayoutRegion.CENTER);
		centerData.setMargins(new Margins(5, 0, 0, 0));

		BorderLayoutData southData = new BorderLayoutData(LayoutRegion.SOUTH,
				100);
		southData.setSplit(true);
		southData.setCollapsible(true);
		southData.setFloatable(true);
		southData.setMargins(new Margins(5, 0, 0, 0));

		center.setHeaderVisible(false);
		center.add(this.chat);
		center.setScrollMode(Scroll.AUTO);

		ContentPanel south = new ContentPanel();
		south.setHeaderVisible(false);
		this.message.setSize("100%", "100%");
		south.add(this.message);

		add(center, centerData);
		add(south, southData);

		message.setTabIndex(100);

		this.message.addKeyboardListener(new KeyboardListener() {
			public void onKeyDown(Widget sender, char keyCode, int modifiers) {
			}

			public void onKeyPress(Widget sender, char keyCode, int modifiers) {
				if (keyCode == KEY_ENTER) {
					message.cancelKey();
					send();
				}
			}

			public void onKeyUp(Widget sender, char keyCode, int modifiers) {
			}
		});

	}

	private void add(String x) {
		String m = this.chat.getHtml();
		m = m + x + "<br/>";
		this.chat.setHtml(m);
		center.setVScrollPosition(this.chat.getHeight());
	}

	private void add(Type type, String message) {
		String style;
		String n;
		if (type == Type.in) {
			style = "peer";
			n = "IN:";
		} else {
			style = "me";
			n = "OUT:";
		}
		String x = "[" + dtf.format(new Date()) + "]&nbsp;" + n
				+ "&nbsp;<br/><span class='" + style + "'>"
				+ TextUtils.escape(message) + "</span><br/>";
		add(x);
	}

	public void onBodyReceive(Response code, String body) {
		add(Type.in, body);
	}

	public void onBodySend(String body) {
		add(Type.out, body);
	}

	public void onBoshError(ErrorCondition xmppErrorCondition,
			BoshErrorCondition boshErrorCondition, String message) {
	}

	public void onBoshTerminate(Connector con,
			BoshErrorCondition boshErrorCondition) {
	}

	public void onConnect(Connector con) {
	}

	public void onStanzaReceived(List<? extends Packet> nodes) {
	}

	private void send() {
		final String message = this.message.getText();
		this.message.setText("");
		connector.sendStanza(message);
	}
}
