package anzsoft.iJabBar.client.gui;

import anzsoft.xmpp4gwt.client.Session;

import com.extjs.gxt.ui.client.event.ComponentEvent;
import com.extjs.gxt.ui.client.event.KeyListener;
import com.extjs.gxt.ui.client.widget.ContentPanel;
import com.extjs.gxt.ui.client.widget.Html;
import com.extjs.gxt.ui.client.widget.LayoutContainer;
import com.extjs.gxt.ui.client.widget.form.TextArea;
import com.extjs.gxt.ui.client.widget.layout.FitLayout;
import com.extjs.gxt.ui.client.widget.layout.RowData;
import com.extjs.gxt.ui.client.widget.layout.RowLayout;

public class OptionsBox extends ContentPanel {
	private TextArea statusText;
	private String oldStatus = "";

	public OptionsBox() {
		setHeading("Powered by <a href='http://www.anzsoft.com' >AnzSoft</a>");
		getHeader().addStyleName("options_heading");
		setLayout(new FitLayout());
		setBorders(false);
		setFrame(false);

		add(createWidgets());
	}

	private LayoutContainer createWidgets() {
		LayoutContainer container = new LayoutContainer();
		container.setLayout(new RowLayout());
		container.addStyleName("optionsbox_container");

		Html statusLabel = new Html();
		statusLabel.setTagName("strong");
		statusLabel.setHtml("My status");

		statusText = new TextArea();
		statusText.addStyleName("optionsbox_status_textarea");
		statusText.addKeyListener(new KeyListener() {
			public void componentKeyPress(ComponentEvent event) {
				if (event.getKeyCode() == 13) {
					changeStatus();
					event.stopEvent();
				}
				if (event.getKeyCode() == 27) {
					statusText.setRawValue(oldStatus);
				}
			}
		});

		container.add(statusLabel, new RowData(1, -1));
		container.add(statusText, new RowData(1, -1));
		return container;
	}

	public void changeStatus() {
		if (!Session.instance().isActive())
			return;
		if (!oldStatus.equals(statusText.getRawValue())) {
			Session.instance().getPresencePlugin().sendStatusText(
					statusText.getRawValue());
			oldStatus = statusText.getRawValue();
		}
	}

	public void setStatus(String status) {
		if (status == null)
			oldStatus = "";
		else
			oldStatus = status;
		statusText.setRawValue(oldStatus);
	}
}
