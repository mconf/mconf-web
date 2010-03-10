package anzsoft.iJabBar.client.gui;

import java.util.ArrayList;
import java.util.List;

import com.extjs.gxt.ui.client.core.El;
import com.extjs.gxt.ui.client.event.SelectionListener;
import com.extjs.gxt.ui.client.widget.BoxComponent;
import com.extjs.gxt.ui.client.widget.ComponentHelper;
import com.google.gwt.user.client.DOM;
import com.google.gwt.user.client.Element;

public class MenuHeader extends BoxComponent {
	private String heading;
	private El headerButtons, headerText;
	private MenuHeadButton minButton, closeButton;
	private boolean haveMinButton = true;
	private boolean haveCloseButton = true;
	private List<BarMenuListener> listeners = new ArrayList<BarMenuListener>();

	public MenuHeader(boolean haveMinButton, boolean haveCloseButton) {
		this.haveCloseButton = haveCloseButton;
		this.haveMinButton = haveMinButton;
	}

	public void setMinButton(boolean b) {
		haveMinButton = b;
		//TODO: 
	}

	public void setCloseButton(boolean b) {
		haveCloseButton = b;
		//TODO:
	}

	public void setHeading(String text) {
		this.heading = text;
		if (this.isRendered()) {
			headerText.setInnerHtml(this.heading);
		}
	}

	public void addHeaderListener(BarMenuListener l) {
		listeners.add(l);
	}

	public void removeHeaderListener(BarMenuListener l) {
		listeners.remove(l);
	}

	@Override
	protected void onRender(Element target, int index) {
		super.onRender(target, index);
		setElement(DOM.createDiv(), target, index);

		el().setStyleName("ijab_barmenu_header");
		headerButtons = el().createChild(
				"<div class='ijab_barmenu_header_buttons'></div>");
		if (haveCloseButton) {
			closeButton = new MenuHeadButton("ijab_barmenu_header_close");
			closeButton.render(headerButtons.dom);
			headerButtons.appendChild(closeButton.getElement());
			closeButton
					.addSelectionListener(new SelectionListener<MenuHeadButtonEvent>() {
						public void componentSelected(MenuHeadButtonEvent ce) {
							fireOnClose();
						}
					});
		}
		if (haveMinButton) {
			minButton = new MenuHeadButton("ijab_barmenu_header_min");
			minButton.render(headerButtons.dom);
			headerButtons.appendChild(minButton.getElement());
			minButton
					.addSelectionListener(new SelectionListener<MenuHeadButtonEvent>() {
						public void componentSelected(MenuHeadButtonEvent ce) {
							fireOnMin();
						}
					});
		}

		headerText = el().createChild(
				"<div class='ijab_barmenu_header_text'></div>");
		headerText.setInnerHtml(heading);
	}

	@Override
	protected void doAttachChildren() {
		super.doAttachChildren();
		ComponentHelper.doAttach(minButton);
		ComponentHelper.doAttach(closeButton);
	}

	@Override
	protected void doDetachChildren() {
		super.doDetachChildren();
		ComponentHelper.doDetach(minButton);
		ComponentHelper.doDetach(closeButton);
	}

	private void fireOnClose() {
		for (BarMenuListener l : listeners) {
			l.onClose();
		}
	}

	private void fireOnMin() {
		for (BarMenuListener l : listeners) {
			l.onMin();
		}
	}
}
