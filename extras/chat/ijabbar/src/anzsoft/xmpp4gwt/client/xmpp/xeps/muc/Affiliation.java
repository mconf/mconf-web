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
package anzsoft.xmpp4gwt.client.xmpp.xeps.muc;

/**
 * @author bmalkow
 * 
 */
public enum Affiliation {
	admin(30, true, true, true, true, true, true, true, false, false, false,
			false, true), member(20, true, true, true, true, false, false,
			false, false, false, false, false, false), none(10, true, true,
			false, false, false, false, false, false, false, false, false,
			false), outcast(0, false, false, false, false, false, false, false,
			false, false, false, false, false), owner(40, true, true, true,
			true, true, true, true, true, true, true, true, true);

	private final boolean banMembersAndUnaffiliatedUsers;

	private final boolean changeRoomDefinition;

	private final boolean destroyRoom;

	private final boolean editAdminList;

	private final boolean editMemberList;

	private final boolean editModeratorList;

	private final boolean editOwnerList;

	private final boolean enterMembersOnlyRoom;

	private final boolean enterOpenRoom;

	private final boolean registerWithOpenRoom;

	private final boolean retrieveMemberList;

	private final boolean viewOccupantsJid;

	private final int weight;

	private Affiliation(int weight, boolean enterOpenRoom,
			boolean registerWithOpenRoom, boolean retrieveMemberList,
			boolean enterMembersOnlyRoom,
			boolean banMembersAndUnaffiliatedUsers, boolean editMemberList,
			boolean editModeratorList, boolean editAdminList,
			boolean editOwnerList, boolean changeRoomDefinition,
			boolean destroyRoom, boolean viewOccupantsJid) {
		this.weight = weight;
		this.enterOpenRoom = enterOpenRoom;
		this.registerWithOpenRoom = registerWithOpenRoom;
		this.retrieveMemberList = retrieveMemberList;
		this.enterMembersOnlyRoom = enterMembersOnlyRoom;
		this.banMembersAndUnaffiliatedUsers = banMembersAndUnaffiliatedUsers;
		this.editMemberList = editMemberList;
		this.editModeratorList = editModeratorList;
		this.editAdminList = editAdminList;
		this.editOwnerList = editOwnerList;
		this.changeRoomDefinition = changeRoomDefinition;
		this.destroyRoom = destroyRoom;
		this.viewOccupantsJid = viewOccupantsJid;
	}

	public int getWeight() {
		return weight;
	}

	public boolean isBanMembersAndUnaffiliatedUsers() {
		return banMembersAndUnaffiliatedUsers;
	}

	public boolean isChangeRoomDefinition() {
		return changeRoomDefinition;
	}

	public boolean isDestroyRoom() {
		return destroyRoom;
	}

	public boolean isEditAdminList() {
		return editAdminList;
	}

	public boolean isEditMemberList() {
		return editMemberList;
	}

	public boolean isEditModeratorList() {
		return editModeratorList;
	}

	public boolean isEditOwnerList() {
		return editOwnerList;
	}

	public boolean isEnterMembersOnlyRoom() {
		return enterMembersOnlyRoom;
	}

	public boolean isEnterOpenRoom() {
		return enterOpenRoom;
	}

	public boolean isRegisterWithOpenRoom() {
		return registerWithOpenRoom;
	}

	public boolean isRetrieveMemberList() {
		return retrieveMemberList;
	}

	public boolean isViewOccupantsJid() {
		return viewOccupantsJid;
	}
}
