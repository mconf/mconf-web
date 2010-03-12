package anzsoft.iJabBar.client.gui;

import com.extjs.gxt.ui.client.Style.Orientation;
import com.extjs.gxt.ui.client.event.BaseEvent;
import com.extjs.gxt.ui.client.event.Events;
import com.extjs.gxt.ui.client.event.Listener;
import com.extjs.gxt.ui.client.widget.LayoutContainer;
import com.extjs.gxt.ui.client.widget.layout.RowData;
import com.extjs.gxt.ui.client.widget.layout.RowLayout;
import com.google.gwt.user.client.Element;
import com.google.gwt.user.client.ui.Widget;

public class BarMenu extends LayoutContainer {
	private final MenuHeader header;
	private Widget widget;

	@SuppressWarnings("unchecked")
	public BarMenu(boolean haveMinButton, boolean haveCloseButton,
			BarMenuListener listener) {
		header = new MenuHeader(haveMinButton, haveCloseButton);
		header.addHeaderListener(listener);
		header.addHeaderListener(new BarMenuListener() {
			public void onClose() {
				hide();
			}

			public void onMin() {
				hide();
			}

		});
		addStyleName("ijab_barmenu");
		setLayout(new RowLayout(Orientation.VERTICAL));
		add(header, new RowData(1, -1));
		this.addListener(Events.Render, new Listener() {
			public void handleEvent(BaseEvent be) {
				hide();
			}
		});
	}

	public BarMenu(Element parentElement, int width, BarMenuListener listener) {
		this(true, true, listener);
	}

	public void setMinButton(boolean b) {
		header.setMinButton(b);
	}

	public void setCloseButton(boolean b) {
		header.setCloseButton(b);
	}

	public void setHeading(String text) {
		header.setHeading(text);
	}

	public void attachWidget(Widget widget, int height) {
		this.widget = widget;
		add(widget, new RowData(1, height));
	}

	public ChatBox getChatBox() {
		if (widget instanceof ChatBox) {
			return (ChatBox) widget;
		} else
			return null;
	}

	public void show() {
		onShow();
		el().updateZIndex(0);
		if (widget instanceof ChatBox) {
			ChatBox chatBox = (ChatBox) widget;
			chatBox.focus();
		}
		//focus();
		BarMenuEvent event = new BarMenuEvent(this);
		fireEvent(Events.Show, event);
	}

	public void showChatMenu(Element elem) {
		onShow();
		el().updateZIndex(0);
		if (widget instanceof ChatBox) {
			ChatBox chatBox = (ChatBox) widget;
			chatBox.focus();
		}
		BarMenuEvent event = new BarMenuEvent(this);
		fireEvent(Events.Show, event);
	}

	public void hide() {
		el().hide();
		BarMenuEvent event = new BarMenuEvent(this);
		fireEvent(Events.Hide, event);
	}

	@Override
	protected void onShow() {
		el().show();
		BarMenuEvent event = new BarMenuEvent(this);
		fireEvent(Events.Show, event);
	}
}
