package anzsoft.iJabBar.client.gui;

import anzsoft.iJabBar.client.JabberApp;
import anzsoft.iJabBar.client.T;

import com.extjs.gxt.ui.client.Style.HorizontalAlignment;
import com.extjs.gxt.ui.client.event.ButtonEvent;
import com.extjs.gxt.ui.client.event.ComponentEvent;
import com.extjs.gxt.ui.client.event.KeyListener;
import com.extjs.gxt.ui.client.event.SelectionListener;
import com.extjs.gxt.ui.client.widget.ContentPanel;
import com.extjs.gxt.ui.client.widget.Html;
import com.extjs.gxt.ui.client.widget.LayoutContainer;
import com.extjs.gxt.ui.client.widget.button.Button;
import com.extjs.gxt.ui.client.widget.form.TextField;
import com.extjs.gxt.ui.client.widget.layout.FitLayout;
import com.extjs.gxt.ui.client.widget.layout.FlowLayout;
import com.google.gwt.user.client.Cookies;
import com.google.gwt.user.client.Window;

public class LoginBox extends ContentPanel {
	private TextField<String> idField = new TextField<String>();
	private TextField<String> passField = new TextField<String>();
	private Button loginButton = new Button();
	private Button cancelButton = new Button();

	public LoginBox() {
		setId("ijab_loginbox_container");
		setSize(300, 150);
		this.setHeading(T.t().Login());
		this.setLayout(new FitLayout());
		add(createWidget());
		hide();
	}

	private ContentPanel createWidget() {
		ContentPanel loginBox = new ContentPanel();
		loginBox.setBorders(false);
		loginBox.setFrame(false);
		loginBox.setHeaderVisible(false);
		loginBox.setId("ijab_loginbox");

		loginBox.setLayout(new FlowLayout());

		idField.setFieldLabel(T.t().User());
		idField.setAllowBlank(false);
		idField.setTabIndex(0);

		passField.setPassword(true);
		passField.setFieldLabel(T.t().Password());
		passField.setAllowBlank(false);
		passField.setTabIndex(1);
		passField.addKeyListener(new KeyListener() {
			public void componentKeyPress(ComponentEvent event) {
				if (event.getKeyCode() == 13) {
					doLogin();
				}
			}
		});
		Html idLabel = new Html("ID:");
		idLabel.setTagName("span");
		idLabel.setStyleName("ijab_login_label");
		loginBox.add(idLabel);
		SpanPanel textWrap = new SpanPanel();
		textWrap.setStyleName("ijab_login_field");
		textWrap.add(idField);
		loginBox.add(textWrap);
		Html pwdLabel = new Html(T.t().Password() + ":");
		pwdLabel.setTagName("span");
		pwdLabel.setStyleName("ijab_login_label");
		loginBox.add(pwdLabel);
		textWrap = new SpanPanel();
		textWrap.setStyleName("ijab_login_field");
		textWrap.add(passField);
		loginBox.add(textWrap);

		loginBox.setButtonAlign(HorizontalAlignment.CENTER);
		loginButton.setText(T.t().Login());
		loginButton.setTabIndex(2);
		loginButton.addSelectionListener(new SelectionListener<ButtonEvent>() {
			public void componentSelected(ButtonEvent ce) {
				doLogin();
			}

		});
		LayoutContainer buttonContainer = new LayoutContainer();
		buttonContainer.setStyleName("button_container");
		SpanPanel buttonWrap = new SpanPanel();
		buttonWrap.setStyleName("button_wrap");
		buttonWrap.add(loginButton);
		buttonContainer.add(buttonWrap);

		cancelButton.setText(T.t().Cancel());
		cancelButton.setTabIndex(3);
		cancelButton.addSelectionListener(new SelectionListener<ButtonEvent>() {
			public void componentSelected(ButtonEvent ce) {
				hide();
			}
		});

		buttonWrap = new SpanPanel();
		buttonWrap.setStyleName("button_wrap");
		buttonWrap.add(cancelButton);
		buttonContainer.add(buttonWrap);

		loginBox.add(buttonContainer);
		return loginBox;
	}

	private void doLogin() {
		String user = idField.getRawValue();
		String pass = passField.getRawValue();
		if (user.length() == 0 || pass.length() == 0) {
			Window.alert(T.t().Uopcbe());
			idField.focus();
			return;
		}
		idField.setRawValue("");
		passField.setRawValue("");
		JabberApp.instance().loginForce(user, pass);
		hide();
	}
}
