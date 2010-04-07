package org.jivesoftware.xiff.data{
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
	 * An interface for objects that abstract XML data by providing accessors
	 * to the original XML data stored within.
	 *
	 * @author Sean Treadway
	 * @since 2.0.0
	 * @availability Flash Player 7
	 * @toc-path Interfaces
	 * @toc-sort 1
	 */
	import flash.xml.XMLNode;

	public interface INodeProxy
	{
		/**
		 * Gets the XML node that is being abstracted.
		 *
		 * @availability Flash Player 7
		 */
		function getNode():XMLNode;
		
		/**
		 * Sets the XML node that will be abstracted.
		 *
		 * @availability Flash Player 7
		 */
		function setNode( node:XMLNode ):Boolean;
	}
}