package anzsoft.iJabBar.client.resource;

import com.google.gwt.core.client.GWT;
import com.google.gwt.user.client.ui.AbstractImagePrototype;
import com.google.gwt.user.client.ui.ImageBundle;

@SuppressWarnings("deprecation")
public interface Icons extends ImageBundle {
	public static class App {
		private static Icons ourInstance = null;

		public static synchronized Icons getInstance() {
			if (ourInstance == null) {
				ourInstance = (Icons) GWT.create(Icons.class);
			}
			return ourInstance;
		}
	}

	@Resource("add.png")
	AbstractImagePrototype add();

	@Resource("away.png")
	AbstractImagePrototype away();

	@Resource("busy.png")
	AbstractImagePrototype busy();

	@Resource("cancel.png")
	AbstractImagePrototype cancel();

	@Resource("chat.png")
	AbstractImagePrototype chat();

	@Resource("chat-new-message-small.png")
	AbstractImagePrototype chatNewMessageSmall();

	@Resource("chat-small.png")
	AbstractImagePrototype chatSmall();

	@Resource("del.png")
	AbstractImagePrototype del();

	@Resource("group-chat.png")
	AbstractImagePrototype groupChat();

	@Resource("info.png")
	AbstractImagePrototype info();

	@Resource("info-lamp.png")
	AbstractImagePrototype infoLamp();

	@Resource("invisible.png")
	AbstractImagePrototype invisible();

	@Resource("message.png")
	AbstractImagePrototype message();

	@Resource("new-chat.png")
	AbstractImagePrototype newChat();

	@Resource("new-email.png")
	AbstractImagePrototype newEmail();

	@Resource("new-message.png")
	AbstractImagePrototype newMessage();

	@Resource("not-authorized.png")
	AbstractImagePrototype notAuthorized();

	@Resource("offline.png")
	AbstractImagePrototype offline();

	@Resource("online.png")
	AbstractImagePrototype online();

	@Resource("question.png")
	AbstractImagePrototype question();

	@Resource("room-new-message-small.png")
	AbstractImagePrototype roomNewMessageSmall();

	@Resource("room-small.png")
	AbstractImagePrototype roomSmall();

	@Resource("unavailable.png")
	AbstractImagePrototype unavailable();

	@Resource("user_add.png")
	AbstractImagePrototype userAdd();

	@Resource("xa.png")
	AbstractImagePrototype xa();

	@Resource("icon-search.gif")
	AbstractImagePrototype iconSearch();

	@Resource("icon-close.gif")
	AbstractImagePrototype iconClose();
}
