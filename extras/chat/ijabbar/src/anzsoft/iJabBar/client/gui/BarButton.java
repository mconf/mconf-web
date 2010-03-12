package anzsoft.iJabBar.client.gui;

import java.util.ArrayList;
import java.util.List;

import com.extjs.gxt.ui.client.core.El;
import com.extjs.gxt.ui.client.event.ComponentEvent;
import com.extjs.gxt.ui.client.widget.BoxComponent;
import com.google.gwt.dom.client.Style;
import com.google.gwt.user.client.DOM;
import com.google.gwt.user.client.Element;
import com.google.gwt.user.client.Event;
import com.google.gwt.user.client.Window;

public class BarButton extends BoxComponent {
	private String toolTip = null;
	private String imgSrc = null;

	private Element mainElement;
	private Element buttonElement;
	private Element imgElement;
	private Element tipElement;

	private String url;
	private String name;

	private List<BarButtonListener> listeners = new ArrayList<BarButtonListener>();

	public BarButton() {
		addStyleName("ijab_abutton");
		addStyleName("ijab_menubutton");
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
		buttonElement.setClassName("inner_button");

		imgElement = DOM.createImg();
		imgElement.setClassName("ijab_abutton_img");
		if (imgSrc != null)
			imgElement.setAttribute("src", imgSrc);

		buttonElement.appendChild(imgElement);

		tipElement = DOM.createDiv();
		tipElement.setClassName("ijab_abutton_tooltip ");
		if (toolTip != null)
			tipElement.setInnerHTML("<strong>" + toolTip + "</strong>");

		mainElement.appendChild(tipElement);
		mainElement.appendChild(buttonElement);

		if (getFocusEl() != null) {
			getFocusEl().addEventsSunk(Event.FOCUSEVENTS);
		}
		el().addEventsSunk(Event.ONCLICK | Event.MOUSEEVENTS);
	}

	public void setTooltip(String tip) {
		toolTip = tip;
		if (isRendered()) {
			tipElement.setInnerHTML("<strong>" + tip + "</strong>");
		}
	}

	public void setImgSrc(String src) {
		imgSrc = src;
		if (isRendered()) {
			imgElement.setAttribute("src", src);
		}
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

	protected void onClick(ComponentEvent ce) {
		hideToolTip();
		fireOnClick();
		if (url != null && !(url.length() == 0))
			Window.open(url, name, "");
	}

	protected void onMouseOver(ComponentEvent ce) {
		addStyleName("ijab_menubutton-over");
		showToolTip();
	}

	protected void onMouseOut(ComponentEvent ce) {
		removeStyleName("ijab_menubutton-over");
		hideToolTip();
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

	public void addButtonListener(BarButtonListener l) {
		listeners.add(l);
	}

	public void removeButtonListener(BarButtonListener l) {
		listeners.remove(l);
	}

	public void fireOnClick() {
		for (BarButtonListener l : listeners) {
			l.onClick();
		}
	}

	public void setTargetUrl(String url, String name) {
		this.url = url;
		this.name = name;
	}

	public void setEnabled(boolean enabled) {
		super.setEnabled(enabled);
		if (!enabled)
			removeStyleName("ijab_menubutton-over");
	}
}
