package anzsoft.iJabBar.client.gui;

import com.extjs.gxt.ui.client.event.BoxComponentEvent;
import com.google.gwt.user.client.Event;

public class MenuHeadButtonEvent extends BoxComponentEvent {
	public MenuHeadButton menuHeadButton;

	public MenuHeadButtonEvent(MenuHeadButton menuHeadButton) {
		super(menuHeadButton);
		this.menuHeadButton = menuHeadButton;
	}

	public MenuHeadButtonEvent(MenuHeadButton menuHeadButton, Event event) {
		this(menuHeadButton);
		this.event = event;
	}

}
