package anzsoft.iJabBar.client.gui;

import anzsoft.iJabBar.client.JabberApp;
import anzsoft.iJabBar.client.T;
import anzsoft.xmpp4gwt.client.Session;
import anzsoft.xmpp4gwt.client.SessionListener;
import anzsoft.xmpp4gwt.client.Connector.BoshErrorCondition;

import com.extjs.gxt.ui.client.GXT;
import com.extjs.gxt.ui.client.event.Events;
import com.extjs.gxt.ui.client.event.Listener;
import com.extjs.gxt.ui.client.widget.LayoutContainer;
import com.google.gwt.core.client.GWT;

public class MainBarRight extends LayoutContainer implements SessionListener {
	private final PresenceButton pButton;
	private final BarAButton optionsButton;
	private final BarMenu presenceMenu;
	private final BarMenu optionsMenu;
	private final BarButton errorButton;
	private final OptionsBox optionsBox;
	private final LoginBox loginBox;

	public MainBarRight(ContactView contactView, ChatPanel chatPanel) {
		setId("ijab_mainbar_right");
		this.setStyleName("ijab_mainbar_right");
		pButton = new PresenceButton(contactView);

		loginBox = new LoginBox();

		optionsButton = new BarAButton();
		optionsButton.setTooltip("iJab Options");
		//optionsButton.setTooltip(T.t().Nonotification());
		optionsButton.addStyleName("ijab_optionsbutton");
		optionsButton.setMenuHeadeing(T.t().Options());
		optionsButton.setMenuStyle("ijab_optionsbutton_menu");
		optionsButton.setMenuAlign("br-tr");
		optionsButton.setImgSrc(GWT.getModuleBaseURL() + "images/options.png");

		optionsBox = new OptionsBox();

		//optionsButton.attatchMenuWidget(NotifyBox.instance(), 150);
		optionsButton.attatchMenuWidget(optionsBox, 150);
		//NotifyBox.instance().setButton(optionsButton);

		presenceMenu = pButton.getMenu();
		optionsMenu = optionsButton.getMenu();
		//NotifyBox.instance().setMenu(optionsMenu);
		if (GXT.isIE)
			optionsMenu.setWidth(221);
		else
			optionsMenu.setWidth(218);

		presenceMenu.addListener(Events.Show, new Listener<BarMenuEvent>() {
			public void handleEvent(BarMenuEvent be) {
				optionsMenu.hide();
			}
		});

		optionsMenu.addListener(Events.Show, new Listener<BarMenuEvent>() {
			public void handleEvent(BarMenuEvent be) {
				presenceMenu.hide();
			}
		});

		optionsMenu.addListener(Events.Hide, new Listener<BarMenuEvent>() {
			public void handleEvent(BarMenuEvent be) {
				optionsBox.changeStatus();
			}
		});

		errorButton = new BarButton();
		errorButton.addStyleName("ijab_error_button");
		errorButton.setImgSrc(GWT.getModuleBaseURL() + "images/error.gif");

		errorButton.addButtonListener(new BarButtonListener() {
			public void onClick() {
				if (JabberApp.instance().enableLoginBox)
					loginBox.show();
			}

		});

		pButton.addButtonListener(new BarButtonListener() {
			public void onClick() {
				if (!Session.instance().isDisconnected())
					return;
				if (JabberApp.instance().enableLoginBox)
					loginBox.show();
			}
		});

		//add(optionsButton);
		add(pButton);
		add(errorButton);
		add(chatPanel.getRightScroll());
		add(chatPanel);
		add(chatPanel.getLeftScroll());
		add(presenceMenu);
		add(optionsMenu);
		add(loginBox);

		errorButton.hide();
		Session.instance().addListener(this);
	}

	public void onBeforeLogin() {
		errorButton.hide();
		pButton.show();
		pButton.setText(T.t().Connecting());
		pButton.setIconSrc(GWT.getModuleBaseURL() + "images/loading.gif");
		pButton.setCountText("");
	}

	public void onEndLogin() {
		errorButton.hide();
		pButton.show();
		pButton.setText(T.t().Friends());
		pButton.setIconSrc(GWT.getModuleBaseURL() + "images/online.png");
	}

	public void onError(BoshErrorCondition boshErrorCondition, String message) {
		pButton.hideMenu();
		pButton.hide();
		errorButton.show();
		errorButton.setTooltip(message);
	}

	public void onLoginOut() {
		errorButton.hide();
		pButton.hideMenu();
		pButton.show();
		pButton.setText(T.t().Offline());
		pButton.setIconSrc(GWT.getModuleBaseURL() + "images/offline.png");
		pButton.setCountText("");
	}
}
