package anzsoft.iJabBar.client.gui;

import com.extjs.gxt.ui.client.event.ComponentEvent;
import com.extjs.gxt.ui.client.event.Events;
import com.extjs.gxt.ui.client.event.SelectionListener;
import com.extjs.gxt.ui.client.widget.BoxComponent;
import com.google.gwt.user.client.DOM;
import com.google.gwt.user.client.Element;
import com.google.gwt.user.client.Event;

public class MenuHeadButton extends BoxComponent {
	protected String style;
	protected boolean cancelBubble = true;

	public MenuHeadButton() {
		this("");
	}

	/**
	 * Creates a new icon button. The 'over' style and 'disabled' style names
	 * determined by adding '-over' and '-disabled' to the base style name.
	 * 
	 * @param style the base style
	 */
	public MenuHeadButton(String style) {
		this.style = style;
	}

	/**
	 * Creates a new icon button. The 'over' style and 'disabled' style names
	 * determined by adding '-over' and '-disabled' to the base style name.
	 * 
	 * @param style the base style
	 * @param listener the click listener
	 */
	public MenuHeadButton(String style,
			SelectionListener<MenuHeadButtonEvent> listener) {
		this(style);
		addSelectionListener(listener);
	}

	/**
	 * @param listener
	 */
	public void addSelectionListener(
			SelectionListener<MenuHeadButtonEvent> listener) {
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
			SelectionListener<MenuHeadButtonEvent> listener) {
		removeListener(Events.Select, listener);
	}

	@Override
	protected ComponentEvent createComponentEvent(Event event) {
		return new MenuHeadButtonEvent(this, event);
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
		setElement(DOM.createAnchor(), target, index);
		addStyleName(style);
		sinkEvents(Event.ONCLICK | Event.MOUSEEVENTS);
		super.onRender(target, index);
	}
}
