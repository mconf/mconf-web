package anzsoft.iJabBar.client.utils;

public class TextUtils {

	// FIXME this utils are commont to kune, emiteui and emitelib

	// Original regexp from http://snippets.dzone.com/posts/show/452
	public static final String URL_REGEXP = "((ftp|http|https):\\/\\/(\\w+:{0,1}\\w*@)?(\\S+)(:[0-9]+)?(\\/|\\/([\\w#!:.?+=&%@!\\-\\/]))?)";

	// Original regexp from http://www.regular-expressions.info/email.html
	public static final String EMAIL_REGEXP = "[-!#$%&\'*+/=?_`{|}~a-z0-9^]+(\\.[-!#$%&\'*+/=?_`{|}~a-z0-9^]+)*@(localhost|([a-z0-9]([-a-z0-9]*[a-z0-9])?\\.)+[a-z0-9]([-a-z0-9]*[a-z0-9]))?";

	/*
	 * This method escape only some dangerous html chars
	 */
	public static String escape(final String source) {
		if (source == null) {
			return null;
		}
		String result = source;
		result = result.replaceAll("&", "&amp;");
		result = result.replaceAll("\"", "&quot;");
		// text = text.replaceAll("\'", "&#039;");
		result = result.replaceAll("<", "&lt;");
		result = result.replaceAll(">", "&gt;");
		return result;
	}

	/*
	 * This method unescape only some dangerous html chars for use in GWT Html
	 * widget for instance
	 */
	public static String unescape(final String source) {
		if (source == null) {
			return null;
		}
		String result = source;
		result = result.replaceAll("&amp;", "&");
		result = result.replaceAll("&quot;", "\"");
		result = result.replaceAll("&#039;", "\'");
		result = result.replaceAll("&lt;", "<");
		result = result.replaceAll("&gt;", ">");
		return result;
	}

	public static String genUniqueId() {
		char[] s = new char[5];
		char itoh[] = { '0', '1', '2', '3', '4', '5', '6', '7', '8', '9', 'A',
				'B', 'C', 'D', 'E', 'F' };
		for (int i = 0; i < 5; i++) {
			s[i] = (char) Math.floor(Math.random() * 0x10);
		}

		//s[14] = 4;
		//s[19] =(char) ((s[19] & 0x3) | 0x8);

		for (int i = 0; i < 5; i++)
			s[i] = itoh[s[i]];

		//s[8] = s[13] = s[18] = s[23] = '-';

		return new String(s);
	}

	public static boolean str2bool(final String str) {
		if (str.equalsIgnoreCase("true"))
			return true;

		return false;
	}

	public static String bool2str(boolean b) {
		if (b)
			return "true";
		else
			return "false";
	}

	public static native String html_wordwrap(String text, int wrapLimit)
	/*-{
		function htmlspecialchars(text)
		{
	  		if(typeof(text)=='undefined'||text===null||!text.toString)
	  		{
				return'';
	  		}
		 	if(text===false)
			{
				return'0';
			 }
	  		 else if(text===true)
	  		 {
				return'1';
			 }
	  		return text.toString().replace(/&/g,'&amp;').replace(/"/g,'&quot;').replace(/'/g,'&#039;').replace(/</g,'&lt;').replace(/>/g,'&gt;');
		}
		
		function htmlize(text)
		{
			return htmlspecialchars(text).replace(/\n/g,'<br />');
		}
		function html_wordwrap(str,wrap_limit,txt_fn)
		{
			if(typeof wrap_limit=='undefined')
			{
				wrap_limit=60;
			}
			if(typeof txt_fn!='function')
			{
				txt_fn=htmlize;
			}
			var regex=new RegExp("\\S{"+(wrap_limit+1)+"}",'g');
			var start=0;
			var str_remaining=str;
			var ret_arr=[];
			var matches=str.match(regex);
			if(matches)
			{
				for(var i=0;i<matches.length;i++)
				{
					var match=matches[i];
					var match_index=start+str_remaining.indexOf(match);
					var chunk=str.substring(start,match_index);
					if(chunk)
					{
						ret_arr.push(txt_fn(chunk));
					}
					ret_arr.push(txt_fn(match)+'<wbr/>');
					start=match_index+match.length;
					str_remaining=str.substring(start);
				}
			}
			if(str_remaining)
			{
				ret_arr.push(txt_fn(str_remaining));
			}
			return ret_arr.join('');
		}
		return html_wordwrap(text,wrapLimit);
	 }-*/;
}
