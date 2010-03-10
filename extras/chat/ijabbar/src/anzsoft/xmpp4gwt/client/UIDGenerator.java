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

public class UIDGenerator {

	private static final String ELEMENTS = "0123456789abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ";

	private int[] key = new int[9];

	private int state = 10000;

	public UIDGenerator() {
		for (int i = 0; i < key.length; i++) {
			int a = ((int) Math.round(Math.random() * 719)) % ELEMENTS.length();
			key[i] = a;
		}
	}

	public String nextUID() {
		int x = state++;

		int last = ((int) Math.round(Math.random() * 719)) % ELEMENTS.length();
		String r = "" + ELEMENTS.charAt(last);
		int c = 0;
		while (x > 0) {
			int a = x % ELEMENTS.length();
			x = x / ELEMENTS.length();
			r = ELEMENTS.charAt((key[(c++) % key.length] + a + last)
					% ELEMENTS.length())
					+ r;
			last = last + a + key[a % key.length];
		}
		return r;
	}

}
