package anzsoft.iJabBar.client;

import com.google.gwt.core.client.GWT;

public class T {
	private static iJabBarConstants constants = null;

	public static iJabBarConstants t() {
		if (constants == null)
			constants = (iJabBarConstants) GWT.create(iJabBarConstants.class);
		return constants;
	}
}
