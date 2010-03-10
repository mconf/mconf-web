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
package anzsoft.xmpp4gwt.client.events;

import java.util.ArrayList;
import java.util.Collection;
import java.util.HashMap;
import java.util.List;

import com.google.gwt.core.client.GWT;

public class EventsManager {

	private final HashMap<Enum<?>, List<Listener<? extends Event>>> eventsCollections = new HashMap<Enum<?>, List<Listener<? extends Event>>>();

	public void addListener(Enum<?> eventType,
			Listener<? extends Event> listener) {
		List<Listener<? extends Event>> ecol = this.eventsCollections
				.get(eventType);
		if (ecol == null) {
			ecol = new ArrayList<Listener<? extends Event>>();
			this.eventsCollections.put(eventType, ecol);
		}
		ecol.add(listener);
	}

	@SuppressWarnings("unchecked")
	public void fireEvent(Enum<?> eventType, Event event) {
		GWT.log("Fire event " + eventType.name() + " [" + event.toString()
				+ "]", null);
		System.out.println("Fire event " + eventType.name() + " ["
				+ event.toString() + "]");
		event.setEventType(eventType);
		List<Listener<? extends Event>> ecol = this.eventsCollections
				.get(eventType);
		if (ecol != null) {
			for (Listener listener : ecol) {
				listener.handleEvent(event);
			}
		}
	}

	public void fireEvent(Signal signal) {
		fireEvent(signal.getEventType(), signal.getEvent());
	}

	public void fireEvents(Collection<Signal> signals) {
		if (signals != null)
			for (Signal signal : signals) {
				fireEvent(signal);
			}
	}

	public void removeListener(Listener<? extends Event> listener) {
		for (List<Listener<? extends Event>> c : this.eventsCollections
				.values()) {
			c.remove(listener);
		}
	}
}
