package anzsoft.iJabBar.client.gui;

import com.extjs.gxt.ui.client.event.BoxComponentEvent;
import com.google.gwt.user.client.Event;

public class ChatPanelXButtonEvent extends BoxComponentEvent {
	public ChatPanelXButton xButton;

	public ChatPanelXButtonEvent(ChatPanelXButton xButton) {
		super(xButton);
		this.xButton = xButton;
	}

	public ChatPanelXButtonEvent(ChatPanelXButton xButton, Event event) {
		this(xButton);
		this.event = event;
	}

}
