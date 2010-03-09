package anzsoft.xmpp4gwt.client.util;

public class StringUtil {
	public static String[] splitString(final String str, int size) {
		int count = str.length() / size + 1;
		String[] ret = new String[count];
		for (int index = 0; index < count; index++) {
			int begin = index * size;
			int end = (index + 1) * size;
			if (end > str.length())
				end = str.length();
			ret[index] = str.substring(begin, end);
		}
		return ret;
	}
}
