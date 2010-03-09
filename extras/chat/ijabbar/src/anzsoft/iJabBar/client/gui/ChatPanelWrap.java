package anzsoft.iJabBar.client.gui;

import com.extjs.gxt.ui.client.core.El;
import com.extjs.gxt.ui.client.widget.Container;
import com.extjs.gxt.ui.client.widget.Layout;
import com.google.gwt.user.client.DOM;
import com.google.gwt.user.client.Element;

public class ChatPanelWrap extends Layout {
	protected El innerCt = null;

	/**
	 * Creates a new layout instance.
	 */
	public ChatPanelWrap() {
	}

	@Override
	protected void onLayout(Container<?> container, El target) {

		if (innerCt == null) {
			// the innerCt prevents wrapping and shuffling while
			// the container is resizing
			Element div = DOM.createDiv();
			div.setClassName("ijab_chatpanel_wrap");
			innerCt = target.appendChild(div);
		}
		renderAll(container, innerCt);
	}
}
