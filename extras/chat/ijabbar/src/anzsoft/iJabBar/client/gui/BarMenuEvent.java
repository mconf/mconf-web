package anzsoft.iJabBar.client.gui;

import com.extjs.gxt.ui.client.event.BoxComponentEvent;
import com.google.gwt.user.client.Event;

public class BarMenuEvent extends BoxComponentEvent {
	public BarMenu menu;

	public BarMenuEvent(BarMenu menu) {
		super(menu);
		this.menu = menu;
	}

	public BarMenuEvent(BarMenu menu, Event event) {
		this(menu);
		this.event = event;
	}

}
