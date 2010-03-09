/*
 * tigase-xmpp4gwt
 * Copyright (C) 2007 "Bartosz Małkowski" <bmalkow@tigase.org>
 *
 * This program is free software: you can redistribute it and/or modify
 * it under the terms of the GNU General Public License as published by
 * the Free Software Foundation, either version 3 of the License.
 *
 * This program is distributed in the hope that it will be useful,
 * but WITHOUT ANY WARRANTY; without even the implied warranty of
 * MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
 * GNU General Public License for more details.
 *
 * You should have received a copy of the GNU General Public License
 * along with this program. Look for COPYING file in the top folder.
 * If not, see http://www.gnu.org/licenses/.
 *
 * $Rev$
 * Last modified by $Author$
 * $Date$
 */
package anzsoft.xmpp4gwt.client;

public class TextUtils {

	private final static String CRLR = new String(new char[] { 13, 10 });

	private final static String CR = new String(new char[] { 13 });

	private final static String LR = new String(new char[] { 10 });

	public static String escape(final String source) {
		if (source == null) {
			return null;
		}
		String result = source;
		result = result.replaceAll("&", "&amp;");
		result = result.replaceAll(">", "&gt;");
		result = result.replaceAll("<", "&lt;");
		result = result.replaceAll("\"", "&quot;");
		result = result.replaceAll(CRLR, "<br/>");
		result = result.replaceAll(LR, "<br/>");
		result = result.replaceAll(CR, "<br/>");
		return result;
	}

	public static String unescape(final String source) {
		if (source == null) {
			return null;
		}
		String result = source;
		result = result.replaceAll("&amp;", "&");
		result = result.replaceAll("&gt;", ">");
		result = result.replaceAll("&lt;", "<");
		result = result.replaceAll("&quot;", "\"");
		result = result.replaceAll("&#039;", "\'");
		return result;
	}
}
