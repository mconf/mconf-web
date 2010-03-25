package org.jivesoftware.xiff.data.muc{
	/*
	 * Copyright (C) 2003-2007 
	 * Nick Velloff <nick.velloff@gmail.com>
	 * Derrick Grigg <dgrigg@rogers.com>
	 * Sean Voisen <sean@voisen.org>
	 * Sean Treadway <seant@oncotype.dk>
	 *
	 * This library is free software; you can redistribute it and/or
	 * modify it under the terms of the GNU Lesser General Public
	 * License as published by the Free Software Foundation; either
	 * version 2.1 of the License, or (at your option) any later version.
	 * 
	 * This library is distributed in the hope that it will be useful,
	 * but WITHOUT ANY WARRANTY; without even the implied warranty of
	 * MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the GNU
	 * Lesser General Public License for more details.
	 * 
	 * You should have received a copy of the GNU Lesser General Public
	 * License along with this library; if not, write to the Free Software
	 * Foundation, Inc., 59 Temple Place, Suite 330, Boston, MA  02111-1307  USA 
	 *
	 */
	
	/**
	 * This class contains a series of static constants that are used throughout the
	 * multi-user conferencing extensions. The constants include the following for
	 * conference room affiliations:
	 * <ul>
	 * <li>ADMIN_AFFILIATION</li>
	 * <li>MEMBER_AFFILIATION</li>
	 * <li>NO_AFFILIATION</li>
	 * <li>OUTCAST_AFFILIATION</li>
	 * <li>OWNER_AFFILIATION</li>
	 * </ul>
	 *
	 * And the following constants for room roles:
	 * <ul>
	 * <li>MODERATOR_ROLE</li>
	 * <li>NO_ROLE</li>
	 * <li>PARTICIPANT_ROLE</li>
	 * <li>VISITOR_ROLE</li>
	 * </ul>
	 *
	 * @author Sean Treadway
	 * @since 2.0.0
	 * @availability Flash Player 7
	 * @toc-path Extensions/Conferencing
	 * @toc-sort 1/2
	 */
	
	import org.jivesoftware.xiff.data.ExtensionClassRegistry;
	import org.jivesoftware.xiff.data.muc.MUCExtension;
	import org.jivesoftware.xiff.data.muc.MUCUserExtension;
	import org.jivesoftware.xiff.data.muc.MUCOwnerExtension;
	import org.jivesoftware.xiff.data.muc.MUCAdminExtension;
	
	public class MUC
	{
		public static var ADMIN_AFFILIATION:String = "admin";
		public static var MEMBER_AFFILIATION:String = "member";
		public static var NO_AFFILIATION:String = "none";
		public static var OUTCAST_AFFILIATION:String = "outcast";
		public static var OWNER_AFFILIATION:String = "owner";
	
		public static var MODERATOR_ROLE:String = "moderator";
		public static var NO_ROLE:String = "none";
		public static var PARTICIPANT_ROLE:String = "participant";
		public static var VISITOR_ROLE:String = "visitor";
	
		private static var staticDependencies:Array = [ ExtensionClassRegistry, MUCExtension, MUCUserExtension, MUCOwnerExtension, MUCAdminExtension ];
	
	    /** 
	     * Register the multi-user chat extension capabilities with this method
	     * @availability Flash Player 7
	     */
	    public static function enable():void
	    {
	        ExtensionClassRegistry.register( MUCExtension );
	        ExtensionClassRegistry.register( MUCUserExtension );
	        ExtensionClassRegistry.register( MUCOwnerExtension );
	        ExtensionClassRegistry.register( MUCAdminExtension );
	    }
	}
}