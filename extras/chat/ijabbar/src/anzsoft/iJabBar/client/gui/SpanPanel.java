package anzsoft.iJabBar.client.gui;

import com.google.gwt.dom.client.Node;
import com.google.gwt.user.client.DOM;
import com.google.gwt.user.client.ui.ComplexPanel;
import com.google.gwt.user.client.ui.Widget;

/**
 * A panel that formats its child widgets using the default HTML layout
 * behavior.
 * 
 * <p>
 * <img class='gallery' src='FlowPanel.png'/>
 * </p>
 */
public class SpanPanel extends ComplexPanel {

	/**
	 * Creates an empty flow panel.
	 */
	public SpanPanel() {
		setElement(DOM.createSpan());
	}

	/**
	 * Adds a new child widget to the panel.
	 * 
	 * @param w the widget to be added
	 */
	@Override
	public void add(Widget w) {
		add(w, getElement());
	}

	@Override
	public void clear() {
		//super.doLogicalClear();

		// Remove all existing child nodes.
		Node child = getElement().getFirstChild();
		while (child != null) {
			getElement().removeChild(child);
			child = getElement().getFirstChild();
		}
	}

	/**
	 * Inserts a widget before the specified index.
	 * 
	 * @param w the widget to be inserted
	 * @param beforeIndex the index before which it will be inserted
	 * @throws IndexOutOfBoundsException if <code>beforeIndex</code> is out of
	 *           range
	 */
	public void insert(Widget w, int beforeIndex) {
		insert(w, getElement(), beforeIndex, true);
	}
}
