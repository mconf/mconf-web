package org.jivesoftware.xiff.events {
	
import flash.events.*;

import org.jivesoftware.xiff.vcard.VCard;
	
public class VCardEvent extends Event {
 
 	public static const LOADED:String = "vcardLoaded";
 	public static const AVATAR_LOADED:String = "vcardAvatarLoaded";
 	public static const ERROR:String = "vcardError";
    private var _vcard:VCard;

    public function VCardEvent( type:String, vcard:VCard, bubbles:Boolean, cancelable:Boolean ) {
    	super( type, bubbles, cancelable )
        _vcard = vcard;
    }

    public override function clone():Event {
      return new VCardEvent( type, _vcard, bubbles, cancelable );
    }
    
    public function get vcard():VCard {
    	return _vcard;
    }
    
    
  }
}