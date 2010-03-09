package anzsoft.iJabBar.client.gui;

import com.extjs.gxt.ui.client.GXT;
import com.extjs.gxt.ui.client.core.El;
import com.extjs.gxt.ui.client.widget.Container;
import com.extjs.gxt.ui.client.widget.Layout;
import com.google.gwt.user.client.DOM;
import com.google.gwt.user.client.Element;

public class MainBarUI extends Layout {
	protected El innerCt;

	/**
	 * Creates a new layout instance.
	 */
	public MainBarUI() {
	}

	@Override
	protected void onLayout(Container<?> container, El target) {

		if (innerCt == null) {
			// the innerCt prevents wrapping and shuffling while
			// the container is resizing
			Element div = DOM.createDiv();
			div.setClassName("ijab_mainbar_ui clearfix");

			Element divP = DOM.createDiv();
			divP.setClassName("presencebar");
			div.appendChild(divP);
			innerCt = target.appendChild(div);
			if (GXT.isIE6)
				innerCt.addStyleName(".ie6 .clearfix");
			else if (GXT.isIE7)
				innerCt.addStyleName(".ie7 .clearfix");
			else if (GXT.isIE8)
				innerCt.addStyleName(".ie8 .clearfix");

		}
		renderAll(container, innerCt.getChild(0));
	}
}
