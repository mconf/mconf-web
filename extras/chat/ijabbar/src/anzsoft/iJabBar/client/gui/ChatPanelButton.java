package anzsoft.iJabBar.client.gui;

import java.util.ArrayList;
import java.util.List;

import anzsoft.xmpp4gwt.client.xmpp.message.Chat;

import com.extjs.gxt.ui.client.GXT;
import com.extjs.gxt.ui.client.core.El;
import com.extjs.gxt.ui.client.event.ComponentEvent;
import com.extjs.gxt.ui.client.event.Events;
import com.extjs.gxt.ui.client.event.Listener;
import com.extjs.gxt.ui.client.event.SelectionListener;
import com.extjs.gxt.ui.client.widget.Html;
import com.extjs.gxt.ui.client.widget.LayoutContainer;
import com.google.gwt.core.client.GWT;
import com.google.gwt.user.client.Element;
import com.google.gwt.user.client.Event;

public class ChatPanelButton extends LayoutContainer {
	protected String text;
	protected String iconSrc;

	protected Html hitElement;
	protected ChatPanelXButton xButton;
	protected BarMenu menu;

	private List<ChatPanelButtonListener> buttonListeners = new ArrayList<ChatPanelButtonListener>();
	private final ChatBox cb;

	private String nick;

	public ChatPanelButton(ChatBox cb) {
		setLayout(new ChatPanelButtonLayout());
		setLayoutOnChange(true);

		this.cb = cb;
		cb.setButton(this);

		setId("ijab_chatpanel_button_"
				+ cb.getChatItem().getJid().toStringBare());

		baseStyle = "ijab_chatpanel_button";
		this.setStyleName("ijab_chatpanel_button");

		if (GXT.isIE)
			addStyleName("ijab_chatpanel_button_ie");

		//create the hit button element
		hitElement = new Html();
		hitElement.setStyleName("ijab_chatpanel_button_hit");
		add(hitElement);

		//create the xButton
		xButton = new ChatPanelXButton(
				new SelectionListener<ChatPanelXButtonEvent>() {
					public void componentSelected(ChatPanelXButtonEvent ce) {
						fireOnClose();
					}
				});
		add(xButton);

		menu = new BarMenu(true, true, new BarMenuListener() {
			public void onClose() {
				fireOnClose();
			}

			public void onMin() {
				fireOnMin();
			}
		});
		menu.addStyleName("ijab_chatpanel_button_menu");
		menu.setHeading(cb.getNick());
		menu.attachWidget(this.cb, 230);
		menu.setWidth(221);

		menu.addListener(Events.Hide, new Listener<BarMenuEvent>() {
			public void handleEvent(BarMenuEvent be) {
				removeStyleName("ijab_menubutton-focus");
				removeStyleName("ijab_chatpanel_button-focus");
				fireOnDeActive();
			}
		});
		menu.addListener(Events.Show, new Listener<BarMenuEvent>() {
			public void handleEvent(BarMenuEvent be) {
				addStyleName("ijab_menubutton-focus");
				addStyleName("ijab_chatpanel_button-focus");
				fireOnActive();
			}
		});
		add(menu);
		setNick(cb.getNick());
	}

	public Chat<ChatBox> getChat() {
		return this.cb.getChatItem();
	}

	private String updateHitHtml() {
		String ret = "<div class='ijab_chatpanel_button_name'>"
				+ "<span class='ijab_chatpanel_button_nametext'>" + nick
				+ "</span>" + "<img src='" + GWT.getModuleBaseURL()
				+ "images/spacer.gif' class='ijab_chatpanel_button_status'/>"
				+ "</div>";
		return ret;
	}

	public void setNick(String nick) {
		this.nick = nick;
		hitElement.setHtml(updateHitHtml());
	}

	@Override
	protected El getFocusEl() {
		return el();
	}

	@Override
	protected void onRender(Element target, int index) {
		super.onRender(target, index);

		if (getFocusEl() != null) {
			getFocusEl().addEventsSunk(Event.FOCUSEVENTS);
		}
		el().addEventsSunk(Event.ONCLICK | Event.MOUSEEVENTS | Event.KEYEVENTS);
	}

	protected void onClick(ComponentEvent ce) {
		if (menu != null && !menu.isVisible()) {
			showMenu();
			fireEvent(Events.MenuShow, ce);
		}
	}

	protected void onMouseOver(ComponentEvent ce) {
		addStyleName("ijab_menubutton-over");
	}

	protected void onMouseOut(ComponentEvent ce) {
		removeStyleName("ijab_menubutton-over");
	}

	@Override
	public void onComponentEvent(ComponentEvent ce) {
		super.onComponentEvent(ce);
		switch (ce.getEventTypeInt()) {
		case Event.ONMOUSEOVER:
			onMouseOver(ce);
			break;
		case Event.ONMOUSEOUT:
			onMouseOut(ce);
			break;
		case Event.ONCLICK:
			onClick(ce);
			break;
		}
	}

	private void fireOnMin() {
		for (ChatPanelButtonListener l : buttonListeners) {
			l.onMin();
		}
	}

	private void fireOnClose() {
		for (ChatPanelButtonListener l : buttonListeners) {
			l.onClose();
		}
	}

	private void fireOnActive() {
		for (ChatPanelButtonListener l : buttonListeners) {
			l.onActive();
		}
	}

	private void fireOnDeActive() {
		for (ChatPanelButtonListener l : buttonListeners) {
			l.onDeActive();
		}
	}

	public void addButtonLister(ChatPanelButtonListener l) {
		buttonListeners.add(l);
	}

	public void removeButtonListener(ChatPanelButtonListener l) {
		buttonListeners.remove(l);
	}

	public void showMenu() {
		if (isRendered()) {
			menu.showChatMenu(getElement());
		}
	}

	public void hideMenu() {
		if (isRendered()) {
			menu.hide();
		}
	}

	public void close() {
		fireOnClose();
	}
}
