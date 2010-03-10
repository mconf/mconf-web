package anzsoft.iJabBar.client.gui;

import com.extjs.gxt.ui.client.core.El;
import com.extjs.gxt.ui.client.event.ComponentEvent;
import com.extjs.gxt.ui.client.event.Events;
import com.extjs.gxt.ui.client.event.Listener;
import com.google.gwt.dom.client.Style;
import com.google.gwt.user.client.DOM;
import com.google.gwt.user.client.Element;
import com.google.gwt.user.client.Event;
import com.google.gwt.user.client.ui.Widget;

public class NotifyButton extends MenuButton {
	private String toolTip = null;
	private int count = 0;

	private Element mainElement;
	private Element buttonElement;
	private Element countElement;
	private Element tipElement;

	public NotifyButton() {
		setMenuAlign("bl-tl");
		addStyleName("ijab_abutton");
		menu = new BarMenu(true, false, new BarMenuListener() {
			public void onClose() {
			}

			public void onMin() {
			}
		});
		menu.addListener(Events.Hide, new Listener<BarMenuEvent>() {
			public void handleEvent(BarMenuEvent be) {
				removeStyleName("ijab_menubutton-focus");
				removeStyleName("ijab_notificationbutton-focus");
			}
		});
		menu.addListener(Events.Show, new Listener<BarMenuEvent>() {
			public void handleEvent(BarMenuEvent be) {
				addStyleName("ijab_menubutton-focus");
				addStyleName("ijab_notificationbutton-focus");
			}
		});
	}

	public void setMenuStyle(String style) {
		menu.addStyleName(style);
	}

	public void setMenuHeadeing(String heading) {
		menu.setHeading(heading);
	}

	public void attatchMenuWidget(Widget widget, int height) {
		menu.attachWidget(widget, height);
	}

	@Override
	protected El getFocusEl() {
		return el();
	}

	@Override
	protected void onRender(Element target, int index) {
		super.onRender(target, index);
		mainElement = DOM.createAnchor();
		setElement(mainElement, target, index);

		buttonElement = DOM.createDiv();
		buttonElement.setClassName("inner_button notify_button");

		countElement = DOM.createSpan();
		countElement.setClassName("emobig");
		countElement.setInnerText("" + count);
		buttonElement.appendChild(countElement);

		tipElement = DOM.createDiv();
		tipElement.setClassName("ijab_abutton_tooltip");
		if (toolTip != null)
			tipElement.setInnerHTML("<strong>" + toolTip + "</strong");

		if (menu != null) {
			menu.render(buttonElement);
			buttonElement.appendChild(menu.getElement());
		}

		mainElement.appendChild(tipElement);
		mainElement.appendChild(buttonElement);

		if (getFocusEl() != null) {
			getFocusEl().addEventsSunk(Event.FOCUSEVENTS);
		}

		listener = new Listener<ComponentEvent>() {

			public void handleEvent(ComponentEvent be) {
				//monitorMouseOver(be.getEvent());
			}
		};

		el().addEventsSunk(Event.ONCLICK | Event.MOUSEEVENTS);
	}

	public void hideToolTip() {
		Style style = tipElement.getStyle();
		style.setProperty("display", "none");
	}

	public void showToolTip() {
		if (toolTip == null || toolTip.length() == 0)
			return;
		Style style = tipElement.getStyle();
		style.setProperty("display", "block");
	}

	public void setTooltip(String tip) {
		toolTip = tip;
		if (isRendered()) {
			tipElement.setInnerHTML("<strong>" + tip + "</strong>");
		}
	}

	protected void onClick(ComponentEvent ce) {
		super.onClick(ce);
		hideToolTip();
	}

	protected void onMouseOver(ComponentEvent ce) {
		super.onMouseOut(ce);
		showToolTip();
	}

	protected void onMouseOut(ComponentEvent ce) {
		super.onMouseOut(ce);
		hideToolTip();
	}

	public void setCount(int count) {
		this.count = count;
		if (this.isRendered()) {
			countElement.setInnerText("" + count);
		}
	}
}
