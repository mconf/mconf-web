package anzsoft.iJabBar.client.gui;

import java.util.HashMap;
import java.util.List;
import java.util.Map;
import java.util.Stack;

import anzsoft.iJabBar.client.CacheHandler;
import anzsoft.iJabBar.client.GlobalHandler;
import anzsoft.iJabBar.client.JabberApp;
import anzsoft.iJabBar.client.T;
import anzsoft.xmpp4gwt.client.JID;
import anzsoft.xmpp4gwt.client.Session;
import anzsoft.xmpp4gwt.client.SessionListener;
import anzsoft.xmpp4gwt.client.Connector.BoshErrorCondition;
import anzsoft.xmpp4gwt.client.stanzas.Message;
import anzsoft.xmpp4gwt.client.xmpp.message.Chat;
import anzsoft.xmpp4gwt.client.xmpp.message.ChatListener;
import anzsoft.xmpp4gwt.client.xmpp.message.ChatManager;
import anzsoft.xmpp4gwt.client.xmpp.message.Notify;

import com.extjs.gxt.ui.client.GXT;
import com.extjs.gxt.ui.client.widget.BoxComponent;
import com.extjs.gxt.ui.client.widget.Component;
import com.extjs.gxt.ui.client.widget.LayoutContainer;
import com.google.gwt.core.client.GWT;
import com.google.gwt.user.client.Cookies;
import com.google.gwt.user.client.Timer;
import com.google.gwt.user.client.Window;

public class ChatPanel extends LayoutContainer implements
		ChatListener<ChatBox>, ContactViewListener, SessionListener {
	private ChatPanelButton activeButton = null;
	private ChatPanelButton lastMinButton = null;
	//for chat
	private final ChatManager<ChatBox> chatManager;
	/*
	private final SoundController soundController = new SoundController();
	//private final Sound soundSend;
	private final Sound soundMessageNew;
	private final Sound soundMessage;
	 */

	private final Map<String, Chat<ChatBox>> chats = new HashMap<String, Chat<ChatBox>>();
	private final Stack<ChatPanelButton> leftStack = new Stack<ChatPanelButton>();
	private final Stack<ChatPanelButton> rightStack = new Stack<ChatPanelButton>();

	private final BarButton leftScrollButton = new BarButton();
	private final BarButton rightScrollButton = new BarButton();

	private int maxWidth = 0;

	public ChatPanel(ChatManager<ChatBox> manager) {
		setLayout(new ChatPanelWrap());
		setLayoutOnChange(true);// It's important
		setMonitorWindowResize(true);
		this.chatManager = manager;
		//soundSend = soundController.createSound(Sound.MIME_TYPE_AUDIO_MPEG, "sound/im_send.wav");
		/*
		soundMessageNew = soundController.createSound(Sound.MIME_TYPE_AUDIO_MPEG, "sound/im_new.wav");
		soundMessage = soundController.createSound(Sound.MIME_TYPE_AUDIO_MPEG, "sound/im.wav");
		 */
		chatManager.addListener(this);
		setId("ijab_chatpanel");
		setStyleName("ijab_chatpanel");

		leftScrollButton.setTooltip(T.t().Scrolltoleft());
		leftScrollButton.setImgSrc(GWT.getModuleBaseURL() + "images/left.gif");
		leftScrollButton.addStyleName("ijab_chatpanel_scroll");
		leftScrollButton.addButtonListener(new BarButtonListener() {
			public void onClick() {
				scrollLeft();
			}
		});

		rightScrollButton.setTooltip(T.t().Scrolltoright());
		rightScrollButton
				.setImgSrc(GWT.getModuleBaseURL() + "images/right.gif");
		rightScrollButton.addStyleName("ijab_chatpanel_scroll");
		rightScrollButton.addButtonListener(new BarButtonListener() {
			public void onClick() {
				scrollRight();
			}
		});

		updateScrollButtons();

		GlobalHandler.instance().addCacheHandler(new CacheHandler() {
			public void onSuspend() {

				suspend();
			}

			public void onResume() {
				resume();
			}

		});

		Session.instance().addListener(this);

	}

	public BarButton getLeftScroll() {
		return leftScrollButton;
	}

	public BarButton getRightScroll() {
		return rightScrollButton;
	}

	private void scrollLeft() {
		try {
			ChatPanelButton pushRightButton = (ChatPanelButton) getItem(getItemCount() - 1);
			ChatPanelButton popLeftButton = leftStack.pop();

			removeButton(pushRightButton);
			rightStack.push(pushRightButton);

			insert(popLeftButton, 0);
			updateScrollButtons();
		} catch (Exception e) {
			GWT.log("error scrollLeft", null);
			GWT.log(e.toString(), null);
			GWT.log(e.getStackTrace().toString(), null);
		}
	}

	private void scrollRight() {
		try {
			ChatPanelButton pushLeftButton = (ChatPanelButton) getItem(0);
			ChatPanelButton popRightButton = rightStack.pop();

			removeButton(pushLeftButton);
			leftStack.push(pushLeftButton);

			add(popRightButton);
			updateScrollButtons();
		} catch (Exception e) {
			GWT.log("error scrollRight", null);
			GWT.log(e.toString(), null);
			GWT.log(e.getStackTrace().toString(), null);
		}
	}

	private void updateScrollButtons() {
		try {
			leftScrollButton.setEnabled(!leftStack.isEmpty());
			rightScrollButton.setEnabled(!rightStack.isEmpty());
			if (leftStack.isEmpty() && rightStack.isEmpty()) {
				leftScrollButton.hide();
				rightScrollButton.hide();
			} else {
				leftScrollButton.show();
				rightScrollButton.show();
			}
		} catch (Exception e) {
			GWT.log("error updateScrollButtons", null);
			GWT.log(e.toString(), null);
			GWT.log(e.getStackTrace().toString(), null);
		}
	}

	private void pushTest() {
		try {
			while (getMaxWidth() < getChildsWidth()) {
				if (getItemCount() <= 1)
					break;
				//push right first
				if (getItem(getItemCount() - 1) != activeButton) {
					ChatPanelButton pushRightButton = (ChatPanelButton) getItem(getItemCount() - 1);
					rightStack.push(pushRightButton);
					removeButton(pushRightButton);
					updateScrollButtons();
				} else if (getItem(0) != activeButton) {
					ChatPanelButton pushLeftButton = (ChatPanelButton) getItem(0);
					leftStack.push(pushLeftButton);
					removeButton(pushLeftButton);
					updateScrollButtons();
				}
			}
		} catch (Exception e) {
			Window.alert("error pushTest");
			Window.alert(e.toString());
			Window.alert(e.getStackTrace().toString());
		}
	}

	private void popTest() {
		//pop left first
		try {
			if (!leftStack.isEmpty()) {
				ChatPanelButton leftPopButton = leftStack.pop();
				insert(leftPopButton, 0);
				//if width is more than chatpanel, push the button back
				// the other ways popTest againg
				if (getMaxWidth() < getChildsWidth()) {
					leftStack.push(leftPopButton);
					removeButton(leftPopButton);
				} else
					popTest();
			} else if (!rightStack.isEmpty()) {
				ChatPanelButton rightPopButton = rightStack.pop();
				add(rightPopButton);
				if (getMaxWidth() < getChildsWidth()) {
					rightStack.push(rightPopButton);
					removeButton(rightPopButton);
				} else
					popTest();
			}
		} catch (Exception e) {
			Window.alert("error popTest");
			Window.alert(e.toString());
			Window.alert(e.getStackTrace().toString());
		}
	}

	protected void onWindowResize(int width, int height) {
		// reset the max width to zero
		try {
			maxWidth = 0;
			if (getMaxWidth() < getChildsWidth()) {
				pushTest();
			} else {
				popTest();
				updateScrollButtons();
			}
		} catch (Exception e) {
			Window.alert("error onWindowSize");
			Window.alert(e.toString());
			Window.alert(e.getStackTrace().toString());
		}
	}

	private int getMaxWidth() {
		try {
			MainBar mainBar = JabberApp.instance().getMainBar();
			if (maxWidth == 0) {
				if (GXT.isIE6 || GXT.isIE7)
					maxWidth = mainBar.getRightBar().getWidth() - 300;
				else
					maxWidth = mainBar.getWidth() - 400;
			}
		} catch (Exception e) {
			Window.alert(e.toString());
			Window.alert(e.getStackTrace().toString());
		}
		return maxWidth;
	}

	public ChatPanelButton createButton(ChatBox cb) {
		final ChatPanelButton btn = new ChatPanelButton(cb);
		try {
			while (!leftStack.isEmpty()) {
				scrollLeft();
			}
			this.insert(btn, 0);
			if (getChildsWidth() > getMaxWidth()) {
				ChatPanelButton pushRightButton = (ChatPanelButton) getItem(getItemCount() - 1);
				removeButton(pushRightButton);
				rightStack.push(pushRightButton);
				updateScrollButtons();
			}
			btn.addButtonLister(new ChatPanelButtonListener() {
				public void onClose() {
					removeButton(btn);
					if (!leftStack.isEmpty()) {
						ChatPanelButton popLeftButton = leftStack.pop();
						insert(popLeftButton, 0);
						updateScrollButtons();
					} else if (!rightStack.isEmpty()) {
						ChatPanelButton popRightButton = rightStack.pop();
						add(popRightButton);
						updateScrollButtons();
					}
					if (activeButton == btn)
						activeButton = null;
					if (lastMinButton == btn)
						lastMinButton = null;
				}

				public void onMin() {
				}

				public void onActive() {
					if (activeButton != null && activeButton != btn)
						activeButton.hideMenu();
					activeButton = btn;
				}

				public void onDeActive() {
					if (activeButton == btn) {
						lastMinButton = btn;
						activeButton = null;
					}
				}
			});
			btn.showMenu();

		} catch (Exception e) {
			Window.alert(e.toString());
			Window.alert(e.getStackTrace().toString());
		}
		return btn;
	}

	public ChatPanelButton findChatButton(ChatPanelButton btn) {
		for (Component c : getItems()) {
			if (c instanceof ChatPanelButton && c == btn) {
				return (ChatPanelButton) c;
			}
		}
		return null;
	}

	private void showButton(ChatPanelButton btn) {
		try {
			if (findChatButton(btn) == null) {
				if (leftStack.contains(btn) || rightStack.contains(btn)) {
					while (leftStack.contains(btn))
						scrollLeft();
					while (rightStack.contains(btn))
						scrollRight();
				} else {
					while (!leftStack.isEmpty())
						scrollLeft();
					insert(btn, 0);
					if (getChildsWidth() > getMaxWidth()) {
						ChatPanelButton pushRightButton = (ChatPanelButton) getItem(getItemCount() - 1);
						rightStack.push(pushRightButton);
						removeButton(pushRightButton);
						updateScrollButtons();
					}
				}
			}
			btn.showMenu();
		} catch (Exception e) {
			Window.alert(e.toString());
			Window.alert(e.getStackTrace().toString());
		}
	}

	private int getChildsWidth() {
		int ret = 0;
		List<Component> widgets = getItems();
		for (Component widget : widgets) {
			ret = ret + ((BoxComponent) widget).getWidth();
		}
		return ret;
	}

	public void removeButton(ChatPanelButton btn) {
		if (btn == activeButton) {
			btn.hideMenu();
		}
		remove(btn);
	}

	public void onMessageReceived(Chat<ChatBox> chat, Message message,
			boolean firstMessage) {
		/*
		try
		{
			if(firstMessage)
				soundMessageNew.play();
			else
				soundMessage.play();
		}
		catch(Exception e)
		{
		}
		 */

		ChatBox cw = chat.getUserData();
		if (cw != null) {
			cw.process(message);
			ChatPanelButton btn = cw.getButton();
			if (activeButton != btn) {
				showButton(btn);
			}
		}
	}

	public void onStartNewChat(Chat<ChatBox> chat) {
		if (chat.getUserData() == null) {
			ChatBox cb = new ChatBox(chat);
			chat.setUserData(cb);
			createButton(cb);
		}
	}

	public void onOpenChat(JID jid) {
		try {
			Chat<ChatBox> ct = chats.get(jid.toStringBare());
			if (ct != null && ct.getUserData() != null) {
				ChatBox cw = ct.getUserData();
				;
				ChatPanelButton btn = cw.getButton();
				if (btn == null)
					createButton(cw);
				else {
					if (activeButton != btn)
						showButton(btn);
				}
			} else {
				chats.put(jid.toStringBare(), chatManager.startChat(jid));
			}
		} catch (Exception e) {
			Window.alert("error onOpenChat");
			//Window.alert(e.toString());
			//Window.alert(e.getStackTrace().toString());
		}
	}

	public void onAuthReq(JID jid) {
	}

	public void onChangeGroup(JID jid, String newGroupName) {
	}

	public void onOpenVCard(JID jid) {
	}

	public void onRemoveUser(JID jid) {
	}

	public void onRenameGroup(String oldGroupName, String newGroupName) {
	}

	public void onRenameUser(JID jid, String newName) {
	}

	public void onNotifyReceive(Notify notify) {
		//TODO: receive a Notify
		NotifyBox.instance().notifyReceived(notify);
	}

	private void suspend() {
		if (activeButton == null && lastMinButton == null) {
			Cookies.removeCookie("ijab_last_chat");
			return;
		}
		ChatPanelButton suspendButton = null;
		if (activeButton != null)
			suspendButton = activeButton;
		else
			suspendButton = lastMinButton;
		String lastActiveChat = suspendButton.getChat().getJid().toStringBare();
		Cookies.setCookie("ijab_last_caht", lastActiveChat, null, null, "/",
				false);

	}

	private void resume() {
		String lastActiveChat = Cookies.getCookie("ijab_last_chat");
		if (lastActiveChat != null && lastActiveChat.length() != 0) {
			final JID jid = JID.fromString(lastActiveChat);
			Timer t = new Timer() {
				@Override
				public void run() {
					//maybe error at resume
					String key = Cookies.getCookie("ijab_last_chat");
					Cookies.removeCookie("ijab_last_chat");
					if (key != null && key.length() != 0)
						onOpenChat(jid);
				}
			};
			t.schedule(500);
		}
	}

	public void onSyncRecv(Chat<ChatBox> chat, Message message,
			boolean firstMessage) {
		ChatBox cw = chat.getUserData();
		if (cw != null) {
			cw.process(message);
			ChatPanelButton btn = cw.getButton();
			if (activeButton != btn) {
				showButton(btn);
			}
		}

	}

	public void onSyncSend(Chat<ChatBox> chat, Message message,
			boolean firstMessage) {
		ChatBox cw = chat.getUserData();
		if (cw != null) {
			cw.processSyncSend(message);
			ChatPanelButton btn = cw.getButton();
			if (activeButton != btn) {
				showButton(btn);
			}
		}
	}

	public void onBeforeLogin() {

	}

	public void onEndLogin() {

	}

	public void onError(BoshErrorCondition boshErrorCondition, String message) {
		Cookies.removeCookie("ijab_last_chat");
	}

	public void onLoginOut() {
		Cookies.removeCookie("ijab_last_chat");
	}
}
