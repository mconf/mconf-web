package anzsoft.iJabBar.client.gui;

import com.extjs.gxt.ui.client.event.ComponentEvent;
import com.extjs.gxt.ui.client.event.Events;
import com.extjs.gxt.ui.client.event.SelectionListener;
import com.extjs.gxt.ui.client.widget.BoxComponent;
import com.google.gwt.user.client.DOM;
import com.google.gwt.user.client.Element;
import com.google.gwt.user.client.Event;

public class ChatPanelXButton extends BoxComponent {
	protected String style;
	protected boolean cancelBubble = true;

	public ChatPanelXButton(SelectionListener<ChatPanelXButtonEvent> listener) {
		this.style = "ijab_x_button";
		addSelectionListener(listener);
	}

	/**
	 * @param listener
	 */
	public void addSelectionListener(
			SelectionListener<ChatPanelXButtonEvent> listener) {
		addListener(Events.Select, listener);
	}

	/**
	 * Changes the icon style.
	 * 
	 * @param style the new icon style
	 */
	public void changeStyle(String style) {
		removeStyleName(this.style);
		removeStyleName(this.style + "-over");
		removeStyleName(this.style + "-disabled");
		addStyleName(style);
		this.style = style;
	}

	public void onComponentEvent(ComponentEvent ce) {
		switch (ce.getEventTypeInt()) {
		case Event.ONMOUSEOVER:
			addStyleName(style + "-over");
			break;
		case Event.ONMOUSEOUT:
			removeStyleName(style + "-over");
			break;
		case Event.ONCLICK:
			onClick(ce);
			break;
		}
	}

	/**
	 * Removes a previously added listener.
	 * 
	 * @param listener the listener to be removed
	 */
	public void removeSelectionListener(
			SelectionListener<ChatPanelXButtonEvent> listener) {
		removeListener(Events.Select, listener);
	}

	@Override
	protected ComponentEvent createComponentEvent(Event event) {
		return new ChatPanelXButtonEvent(this, event);
	}

	protected void onClick(ComponentEvent ce) {
		if (cancelBubble) {
			ce.cancelBubble();
		}
		removeStyleName(style + "-over");
		fireEvent(Events.Select, ce);
	}

	protected void onDisable() {
		addStyleName(style + "-disabled");
	}

	protected void onEnable() {
		removeStyleName(style + "-disabled");
	}

	protected void onRender(Element target, int index) {
		setElement(DOM.createDiv(), target, index);
		addStyleName(style);
		sinkEvents(Event.ONCLICK | Event.MOUSEEVENTS);
		//super.onRender(target, index);
	}

}
