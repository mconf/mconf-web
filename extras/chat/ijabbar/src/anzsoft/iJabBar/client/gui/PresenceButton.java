package anzsoft.iJabBar.client.gui;

import java.util.ArrayList;
import java.util.List;

import anzsoft.iJabBar.client.T;
import anzsoft.xmpp4gwt.client.JID;
import anzsoft.xmpp4gwt.client.Session;
import anzsoft.xmpp4gwt.client.stanzas.Presence;
import anzsoft.xmpp4gwt.client.xmpp.presence.PresenceListener;
import anzsoft.xmpp4gwt.client.xmpp.roster.RosterItem;
import anzsoft.xmpp4gwt.client.xmpp.roster.RosterListener;

import com.extjs.gxt.ui.client.GXT;
import com.extjs.gxt.ui.client.core.El;
import com.extjs.gxt.ui.client.event.ComponentEvent;
import com.extjs.gxt.ui.client.event.Events;
import com.extjs.gxt.ui.client.event.Listener;
import com.google.gwt.core.client.GWT;
import com.google.gwt.user.client.DOM;
import com.google.gwt.user.client.Element;
import com.google.gwt.user.client.Event;

public class PresenceButton extends MenuButton {
	protected String text;
	protected String countText;
	protected String iconSrc;

	protected Element mainElement;
	protected Element buttonElement;
	protected Element imgElement;
	protected Element buddyElement;
	protected Element countElement;

	int contactCount = 0;
	int onlineCount = 0;
	private List<BarButtonListener> listeners = new ArrayList<BarButtonListener>();

	public PresenceButton(final ContactView contactView) {
		super();
		setId("ijab_presencebutton");
		setMenuAlign("bl-tl");
		this.addStyleName("ijab_presencebutton");

		menu = new BarMenu(true, false, new BarMenuListener() {
			public void onClose() {
			}

			public void onMin() {
			}

		});
		menu.addStyleName("ijab_presencebutton_menu");
		menu.setHeading(T.t().Chat());
		menu.attachWidget(contactView, 220);
		if (GXT.isIE)
			menu.setWidth(221);
		else
			menu.setWidth(220);
		//menu.setHeight(200);
		contactView.layout();
		menu.addListener(Events.Hide, new Listener<BarMenuEvent>() {
			public void handleEvent(BarMenuEvent be) {

				removeStyleName("ijab_menubutton-focus");
				removeStyleName("ijab_presencebutton-focus");
			}
		});
		menu.addListener(Events.Show, new Listener<BarMenuEvent>() {
			public void handleEvent(BarMenuEvent be) {
				contactView.notifyShow();
				addStyleName("ijab_menubutton-focus");
				addStyleName("ijab_presencebutton-focus");
			}
		});

		setText("Offline");
		setIconSrc(GWT.getModuleBaseURL() + "images/offline.png");

		Session.instance().getPresencePlugin().addPresenceListener(
				new PresenceListener() {
					public void beforeSendInitialPresence(Presence presence) {
					}

					public void onBigPresenceChanged() {
					}

					public void onContactAvailable(Presence presenceItem) {
					}

					public void onContactUnavailable(Presence presenceItem) {
					}

					public void onPresenceChange(Presence presenceItem) {
						contactCount = Session.instance().getRosterPlugin()
								.getAllRosterItemCount();
						onlineCount = Session.instance().getPresencePlugin()
								.getOnlineCount();
						setCountText(onlineCount + "/" + contactCount);
					}
				});

		Session.instance().getRosterPlugin().addRosterListener(
				new RosterListener() {
					public void beforeAddItem(JID jid, String name,
							List<String> groupsNames) {
					}

					public void onAddItem(RosterItem item) {
						contactCount = Session.instance().getRosterPlugin()
								.getAllRosterItemCount();
						onlineCount = Session.instance().getPresencePlugin()
								.getOnlineCount();
						setCountText(onlineCount + "/" + contactCount);
					}

					public void onEndRosterUpdating() {
					}

					public void onRemoveItem(RosterItem item) {
						contactCount = Session.instance().getRosterPlugin()
								.getAllRosterItemCount();
						onlineCount = Session.instance().getPresencePlugin()
								.getOnlineCount();
						setCountText(onlineCount + "/" + contactCount);
					}

					public void onStartRosterUpdating() {
					}

					public void onUpdateItem(RosterItem item) {
					}

					public void onInitRoster() {
						contactCount = Session.instance().getRosterPlugin()
								.getAllRosterItemCount();
						onlineCount = Session.instance().getPresencePlugin()
								.getOnlineCount();
						setCountText(onlineCount + "/" + contactCount);
					}
				});

	}

	public void setText(String t) {
		text = t;
		if (isRendered()) {
			String mainText = (text != null && !text.equals("")) ? text : "";
			buddyElement.setInnerText(mainText);
			buddyElement.appendChild(countElement);
		}
	}

	public void setCountText(String t) {
		countText = t;
		if (isRendered()) {
			String count = (countText != null && !countText.equals("")) ? "(<strong>"
					+ countText + "</strong>)"
					: "";
			countElement.setInnerHTML(count);
			buddyElement.appendChild(countElement);
		}
	}

	public void setIconSrc(String icon) {
		iconSrc = icon;
		if (isRendered()) {
			if (iconSrc != null && !(iconSrc.length() == 0))
				imgElement.setAttribute("src", iconSrc);
			else
				imgElement.setAttribute("style", "display:none !important;");
		}
	}

	@Override
	protected El getFocusEl() {
		return el();
	}

	@Override
	protected void onRender(Element target, int index) {
		super.onRender(target, index);
		String mainText = (text != null && !text.equals("")) ? text : "";
		String count = (countText != null && !countText.equals("")) ? "(<strong>"
				+ countText + "</strong>)"
				: "";

		//createElement 
		mainElement = DOM.createDiv();
		setElement(mainElement, target, index);
		buttonElement = DOM.createDiv();
		buttonElement.setClassName("inner_button");

		imgElement = DOM.createImg();
		imgElement.setClassName("buddy_icon");
		if (iconSrc != null && !(iconSrc.length() == 0))
			imgElement.setAttribute("src", iconSrc);
		else
			imgElement.setAttribute("style", "display:none !important;");
		buttonElement.appendChild(imgElement);

		buddyElement = DOM.createSpan();
		buddyElement.setClassName("buddy_count");
		buddyElement.setInnerText(mainText);

		countElement = DOM.createSpan();
		countElement.setClassName("buddy_count_num");
		countElement.setInnerHTML(count);
		buddyElement.appendChild(countElement);

		buttonElement.appendChild(buddyElement);

		mainElement.appendChild(buttonElement);

		if (getFocusEl() != null) {
			getFocusEl().addEventsSunk(Event.FOCUSEVENTS);
		}

		listener = new Listener<ComponentEvent>() {

			public void handleEvent(ComponentEvent be) {
				//monitorMouseOver(be.getEvent());
			}
		};

		el().addEventsSunk(Event.ONCLICK | Event.MOUSEEVENTS);
	}

	public void hide() {
		hideMenu();
		super.hide();
	}

	public void addButtonListener(BarButtonListener l) {
		listeners.add(l);
	}

	public void removeButtonListener(BarButtonListener l) {
		listeners.remove(l);
	}

	private void fireOnClick() {
		for (BarButtonListener l : listeners) {
			l.onClick();
		}
	}

	protected void onClick(ComponentEvent ce) {
		if (!Session.instance().isDisconnected())
			super.onClick(ce);
		fireOnClick();
	}
}
