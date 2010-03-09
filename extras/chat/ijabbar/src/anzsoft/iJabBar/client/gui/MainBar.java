package anzsoft.iJabBar.client.gui;

import anzsoft.xmpp4gwt.client.Session;
import anzsoft.xmpp4gwt.client.xmpp.message.ChatManager;

import com.extjs.gxt.ui.client.GXT;
import com.extjs.gxt.ui.client.widget.LayoutContainer;
import com.google.gwt.core.client.GWT;

public class MainBar extends LayoutContainer {
	//private ResizeHandler handler;

	protected MainBarRight rightBar;
	protected MainBarLeft leftBar;

	private final ChatManager<ChatBox> chatManager;
	private final ChatPanel chatWindowManager;

	public MainBar(ContactView contactView) {
		setLayout(new MainBarUI());
		this.setId("ijab_mainbar");
		this.addStyleName("clearfix");
		if (GXT.isIE6)
			addStyleName("ie6");

		chatManager = new ChatManager<ChatBox>(Session.instance()
				.getChatPlugin());
		Session.instance().getChatPlugin().setChatManager(chatManager);
		chatWindowManager = new ChatPanel(chatManager);
		contactView.addListener(chatWindowManager);

		rightBar = new MainBarRight(contactView, chatWindowManager);
		leftBar = new MainBarLeft();

		add(leftBar);
		add(rightBar);

		//addLeftBarButton(GWT.getModuleBaseURL()+"images/anzsoft.gif","Go to anzsoft","http://www.anzsoft.com","_blank");
	}

	public void addLeftBarButton(String imgUrl, String tooltip, String url,
			String target) {
		BarButton btn = new BarButton();
		btn.setImgSrc(imgUrl);
		btn.setTooltip(tooltip);
		btn.setTargetUrl(url, target);
		leftBar.add(btn);
	}

	public MainBarRight getRightBar() {
		return rightBar;
	}

	public MainBarLeft getLeftBar() {
		return leftBar;
	}

	public ChatPanel getChatManager() {
		return chatWindowManager;
	}
}
