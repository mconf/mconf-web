package anzsoft.xmpp4gwt.client.xmpp.xeps.messageArchiving;

import java.util.Date;

public class Item {

	public static enum Type {
		FROM, TO
	}

	private String body;

	private Date date;

	private final Type type;

	public Item(Type type) {
		this.type = type;
	}

	public Item(final Type type, final Date date, final String body) {
		this.type = type;
		this.date = date;
		this.body = body;
	}

	public String getBody() {
		return body;
	}

	public Date getDate() {
		return date;
	}

	public Type getType() {
		return type;
	}
}
