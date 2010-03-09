package anzsoft.iJabBar.client.gui;

import com.extjs.gxt.ui.client.core.El;
import com.extjs.gxt.ui.client.widget.Container;
import com.extjs.gxt.ui.client.widget.Layout;
import com.google.gwt.user.client.Element;
import com.google.gwt.user.client.DOM;

public class ChatPanelButtonLayout extends Layout {
	protected El innerCt = null;

	public ChatPanelButtonLayout() {

	}

	@Override
	protected void onLayout(Container<?> container, El target) {

		if (innerCt == null) {
			Element div = DOM.createDiv();
			div.setClassName("ijab_chatpanel_button_maindiv");
			innerCt = target.appendChild(div);
		}
		renderAll(container, innerCt);
	}
}
