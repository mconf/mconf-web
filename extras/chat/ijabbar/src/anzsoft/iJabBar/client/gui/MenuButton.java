package anzsoft.iJabBar.client.gui;

import com.extjs.gxt.ui.client.core.El;
import com.extjs.gxt.ui.client.event.ComponentEvent;
import com.extjs.gxt.ui.client.event.Events;
import com.extjs.gxt.ui.client.event.Listener;
import com.extjs.gxt.ui.client.widget.BoxComponent;
import com.google.gwt.user.client.DOM;
import com.google.gwt.user.client.Event;

public class MenuButton extends BoxComponent {
	protected BarMenu menu;
	protected boolean monitoringMouseOver;
	protected Listener<ComponentEvent> listener;
	protected String menuAlign = "tl-bl?";

	public MenuButton() {
		this.addStyleName("ijab_menubutton");
	}

	@Override
	protected void onDetach() {
		super.onDetach();
		if (getFocusEl() != null) {
			DOM.setEventListener(getFocusEl().dom, null);
		}
	}

	@Override
	protected void onAttach() {
		super.onAttach();
		El focusEl = getFocusEl();
		if (focusEl != null) {
			DOM.setEventListener(getFocusEl().dom, this);
		}
	}

	protected void onClick(ComponentEvent ce) {
		ce.preventDefault();
		focus();
		hideToolTip();
		if (menu != null && !menu.isVisible()) {
			showMenu();
			fireEvent(Events.MenuShow, ce);
		}
	}

	protected void onMouseOver(ComponentEvent ce) {
		addStyleName("ijab_menubutton-over");
	}

	protected void onMouseOut(ComponentEvent ce) {
		removeStyleName("ijab_menubutton-over");
	}

	protected void onMenuHide(ComponentEvent ce) {
		removeStyleName("ijab_menubutton-focus");
	}

	protected void onMenuShow(ComponentEvent ce) {
		addStyleName("ijab_menubutton-focus");
	}

	@Override
	public void onComponentEvent(ComponentEvent ce) {
		super.onComponentEvent(ce);

		switch (ce.getEventTypeInt()) {
		case Event.ONMOUSEOVER:
			onMouseOver(ce);
			break;
		case Event.ONMOUSEOUT:
			onMouseOut(ce);
			break;
		case Event.ONCLICK:
			onClick(ce);
			break;
		}
	}

	public void setMenu(BarMenu m) {
		this.menu = m;
	}

	public void showMenu() {
		if (menu != null) {
			menu.show();
		}
	}

	public void hideMenu() {
		if (menu != null) {
			menu.hide();
		}
	}

	public void setMenuAlign(String menuAlign) {
		this.menuAlign = menuAlign;
	}

	public BarMenu getMenu() {
		return menu;
	}
}
