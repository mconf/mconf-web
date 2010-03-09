package anzsoft.iJabBar.client.utils;

import com.google.gwt.user.client.ui.HTML;

public class ChatTextFormatter {
	/*
	private static final String JOYFUL = "KuneProtIniJOYFULKuneProtEnd";
	private static final String ANGRY = "KuneProtIniANGRYKuneProtEnd";
	private static final String BLUSHING = "KuneProtIniBLUSHINGKuneProtEnd";
	private static final String CRYING = "KuneProtIniCRYINGKuneProtEnd";
	private static final String POUTY = "KuneProtIniPOUTYKuneProtEnd";
	private static final String SURPRISED = "KuneProtIniSURPRISEDKuneProtEnd";
	private static final String GRIN = "KuneProtIniGRINKuneProtEnd";
	private static final String ANGEL = "KuneProtIniANGELKuneProtEnd";
	private static final String KISSING = "KuneProtIniKISSINGKuneProtEnd";
	private static final String SMILE = "KuneProtIniSMILEKuneProtEnd";
	private static final String TONGUE = "KuneProtIniTONGUEKuneProtEnd";
	private static final String UNCERTAIN = "KuneProtIniUNCERTAINKuneProtEnd";
	private static final String COOL = "KuneProtIniCOOLKuneProtEnd";
	private static final String WINK = "KuneProtIniWINKKuneProtEnd";
	private static final String HAPPY = "KuneProtIniHAPPYKuneProtEnd";
	private static final String ALIEN = "KuneProtIniALIENKuneProtEnd";
	private static final String ANDY = "KuneProtIniANDYKuneProtEnd";
	private static final String DEVIL = "KuneProtIniDEVILKuneProtEnd";
	private static final String LOL = "KuneProtIniLOLKuneProtEnd";
	private static final String NINJA = "KuneProtIniNINJAKuneProtEnd";
	private static final String SAD = "KuneProtIniSADKuneProtEnd";
	private static final String SICK = "KuneProtIniSICKKuneProtEnd";
	private static final String SIDEWAYS = "KuneProtIniSIDEWAYSKuneProtEnd";
	private static final String SLEEPING = "KuneProtIniSLEEPINGKuneProtEnd";
	private static final String UNSURE = "KuneProtIniUNSUREKuneProtEnd";
	private static final String WONDERING = "KuneProtIniWONDERINGKuneProtEnd";
	private static final String LOVE = "KuneProtIniLOVEKuneProtEnd";
	private static final String PINCHED = "KuneProtIniPINCHEDKuneProtEnd";
	private static final String POLICEMAN = "KuneProtIniPOLICEMANKuneProtEnd";
	private static final String W00T = "KuneProtIniWOOTKuneProtEnd";
	private static final String WHISTLING = "KuneProtIniWHISLINGKuneProtEnd";
	private static final String WIZARD = "KuneProtIniWIZARDKuneProtEnd";
	private static final String BANDIT = "KuneProtIniBANDITKuneProtEnd";
	private static final String HEART = "KuneProtIniHEARTKuneProtectRepEnd";
	 */

	private static final String PICsmile = "KuneProtIniPICsmileKuneProtEnd";
	private static final String PICwink = "KuneProtIniPICwinkKuneProtEnd";
	private static final String PICtongue = "KuneProtIniPICtongueKuneProtEnd";
	private static final String PIC13 = "KuneProtIniPIC13KuneProtEnd";
	private static final String PICbiggrin = "KuneProtIniPICbiggrinKuneProtEnd";
	private static final String PICunhappy = "KuneProtIniPICunhappyKuneProtEnd";
	private static final String PICcry = "KuneProtIniPICcryKuneProtEnd";
	private static final String PICoh = "KuneProtIniPICohKuneProtEnd";
	private static final String PICangry = "KuneProtIniPICangryKuneProtEnd";
	private static final String PICblush = "KuneProtIniPICblushKuneProtEnd";
	private static final String PICstare = "KuneProtIniPICstareKuneProtEnd";
	private static final String PICfrowning = "KuneProtIniPICfrowningKuneProtEnd";
	private static final String PIC101 = "KuneProtIniPIC101KuneProtEnd";
	private static final String PIC1 = "KuneProtIniPIC1KuneProtEnd";
	private static final String PIC2 = "KuneProtIniPIC2KuneProtEnd";
	private static final String PIC5 = "KuneProtIniPIC5KuneProtEnd";
	private static final String PIC7 = "KuneProtIniPIC7KuneProtEnd";
	private static final String PIC8 = "KuneProtIniPIC8KuneProtEnd";
	private static final String PIC9 = "KuneProtIniPIC9KuneProtEnd";
	private static final String PIC10 = "KuneProtIniPIC10KuneProtEnd";
	private static final String PIC16 = "KuneProtIniPIC16KuneProtEnd";
	private static final String PIC96 = "KuneProtIniPIC96KuneProtEnd";
	private static final String PIC18 = "KuneProtIniPIC18KuneProtEnd";
	private static final String PIC19 = "KuneProtIniPIC19KuneProtEnd";
	private static final String PIC20 = "KuneProtIniPIC20KuneProtEnd";
	private static final String PIC21 = "KuneProtIniPIC21KuneProtEnd";
	private static final String PIC22 = "KuneProtIniPIC22KuneProtEnd";
	private static final String PIC23 = "KuneProtIniPIC23KuneProtEnd";
	private static final String PIC24 = "KuneProtIniPIC24KuneProtEnd";
	private static final String PIC25 = "KuneProtIniPIC25KuneProtEnd";
	private static final String PIC26 = "KuneProtIniPIC26KuneProtEnd";
	private static final String PIC27 = "KuneProtIniPIC27KuneProtEnd";
	private static final String PIC29 = "KuneProtIniPIC29KuneProtEnd";
	private static final String PIC30 = "KuneProtIniPIC30KuneProtEnd";
	private static final String PIC32 = "KuneProtIniPIC32KuneProtEnd";
	private static final String PIC33 = "KuneProtIniPIC33KuneProtEnd";
	private static final String PIC34 = "KuneProtIniPIC34KuneProtEnd";
	private static final String PIC35 = "KuneProtIniPIC35KuneProtEnd";
	private static final String PIC36 = "KuneProtIniPIC36KuneProtEnd";
	private static final String PIC37 = "KuneProtIniPIC37KuneProtEnd";
	private static final String PIC38 = "KuneProtIniPIC38KuneProtEnd";
	private static final String PIC39 = "KuneProtIniPIC39KuneProtEnd";
	private static final String PIC97 = "KuneProtIniPIC97KuneProtEnd";
	private static final String PIC98 = "KuneProtIniPIC98KuneProtEnd";
	private static final String PIC99 = "KuneProtIniPIC99KuneProtEnd";
	private static final String PIC100 = "KuneProtIniPIC100KuneProtEnd";
	private static final String PIC102 = "KuneProtIniPIC102KuneProtEnd";
	private static final String PIC103 = "KuneProtIniPIC103KuneProtEnd";
	private static final String PIC104 = "KuneProtIniPIC104KuneProtEnd";
	private static final String PIC105 = "KuneProtIniPIC105KuneProtEnd";
	private static final String PIC106 = "KuneProtIniPIC106KuneProtEnd";
	private static final String PIC107 = "KuneProtIniPIC107KuneProtEnd";
	private static final String PIC108 = "KuneProtIniPIC108KuneProtEnd";
	private static final String PIC109 = "KuneProtIniPIC109KuneProtEnd";
	private static final String PIC110 = "KuneProtIniPIC110KuneProtEnd";
	private static final String PIC111 = "KuneProtIniPIC111KuneProtEnd";
	private static final String PICheart = "KuneProtIniPICheartKuneProtEnd";
	private static final String PICbrheart = "KuneProtIniPICbrheartKuneProtEnd";
	private static final String PICyes = "KuneProtIniPICyesKuneProtEnd";
	private static final String PICno = "KuneProtIniPICnoKuneProtEnd";
	private static final String PICboy = "KuneProtIniPICboyKuneProtEnd";
	private static final String PICgirl = "KuneProtIniPICgirlKuneProtEnd";
	private static final String PICflower = "KuneProtIniPICflowerKuneProtEnd";
	private static final String PICbrflower = "KuneProtIniPICbrflowerKuneProtEnd";
	private static final String PIC116 = "KuneProtIniPIC116KuneProtEnd";
	private static final String PICbeer = "KuneProtIniPICbeerKuneProtEnd";
	private static final String PICcoffee = "KuneProtIniPICcoffeeKuneProtEnd";
	private static final String PICkiss = "KuneProtIniPICkissKuneProtEnd";
	private static final String PIC112 = "KuneProtIniPIC112KuneProtEnd";
	private static final String PIC89 = "KuneProtIniPIC89KuneProtEnd";
	private static final String PIC114 = "KuneProtIniPIC114KuneProtEnd";
	private static final String PIC61 = "KuneProtIniPIC61KuneProtEnd";
	private static final String PIC46 = "KuneProtIniPIC46KuneProtEnd";
	private static final String PIC53 = "KuneProtIniPIC53KuneProtEnd";
	private static final String PIC54 = "KuneProtIniPIC54KuneProtEnd";
	private static final String PIC55 = "KuneProtIniPIC55KuneProtEnd";
	private static final String PIC56 = "KuneProtIniPIC56KuneProtEnd";
	private static final String PIC57 = "KuneProtIniPIC57KuneProtEnd";
	private static final String PIC59 = "KuneProtIniPIC59KuneProtEnd";
	private static final String PIC75 = "KuneProtIniPIC75KuneProtEnd";
	private static final String PIC74 = "KuneProtIniPIC74KuneProtEnd";
	private static final String PIC69 = "KuneProtIniPIC69KuneProtEnd";
	private static final String PIC78 = "KuneProtIniPIC78KuneProtEnd";
	private static final String PIC79 = "KuneProtIniPIC79KuneProtEnd";
	private static final String PIC118 = "KuneProtIniPIC118KuneProtEnd";
	private static final String PIC119 = "KuneProtIniPIC119KuneProtEnd";
	private static final String PIC120 = "KuneProtIniPIC120KuneProtEnd";
	private static final String PIC121 = "KuneProtIniPIC121KuneProtEnd";
	private static final String PIC122 = "KuneProtIniPIC122KuneProtEnd";
	private static final String PIC123 = "KuneProtIniPIC123KuneProtEnd";
	private static final String PIC124 = "KuneProtIniPIC124KuneProtEnd";

	public static HTML format(final String messageOrig) {
		String message = messageOrig;
		message = escapeHtmlLight(message);
		message = message.replaceAll("\n", "<br>\n");
		message = formatUrls(message);
		message = formatEmoticons(message);

		return new HTML(message);
	}

	static String formatUrls(String message) {
		return message = message.replaceAll(TextUtils.URL_REGEXP,
				"<a href=\"$1\" target=\"_blank\">$1</a>");
	}

	static String escapeHtmlLight(String textOrig) {
		String text = textOrig;
		text = text.replaceAll("&", "&amp;");
		text = text.replaceAll("\"", "&quot;");
		text = text.replaceAll("<", "&lt;");
		text = text.replaceAll(">", "&gt;");
		return text;
	}

	static String preFormatEmoticons(String message) {
		message = replace(message, new String[] { ":-\\)", ":\\)" }, PICsmile);
		message = replace(message, new String[] { ";-\\)", ";\\)" }, PICwink);
		message = replace(message, new String[] { ":-P", ":-p", ":P", ":p" },
				PICtongue);
		message = replace(message, new String[] { ":D", ":d" }, PIC13);
		message = replace(message, new String[] { ":-D", ":-d", ":-&gt;",
				":&gt;" }, PICbiggrin);
		message = replace(message, new String[] { ":-\\(", ":\\(" }, PICunhappy);
		message = replace(message, new String[] { ":'-\\(", ":'\\(", ";-\\(",
				";\\(" }, PICcry);
		message = replace(message, new String[] { ":O", ":o" }, PICoh);
		message = replace(message, new String[] { ":-@", ":@" }, PICangry);
		message = replace(message, new String[] { ":-\\$", ":\\$" }, PICblush);
		message = replace(message, new String[] { ":\\|" }, PICstare);
		message = replace(message, new String[] { ":-S", ":-s", ":S", ":s" },
				PICfrowning);
		message = replace(message, new String[] { "B-\\)", "B\\)", "\\(H\\)",
				"\\(h\\)" }, PIC101);
		message = replace(message, new String[] { ":~" }, PIC1);
		message = replace(message, new String[] { ":B" }, PIC2);
		message = replace(message, new String[] { ":&lt;" }, PIC5);
		message = replace(message, new String[] { ":X" }, PIC7);
		message = replace(message, new String[] { ":Z" }, PIC8);
		message = replace(message, new String[] { ":'\\(" }, PIC9);
		message = replace(message, new String[] { ":-\\|" }, PIC10);
		message = replace(message, new String[] { ":\\+" }, PIC16);
		message = replace(message, new String[] { "--b" }, PIC96);
		message = replace(message, new String[] { ":Q" }, PIC18);
		message = replace(message, new String[] { ":T" }, PIC19);
		message = replace(message, new String[] { ";P" }, PIC20);
		message = replace(message, new String[] { ";-D" }, PIC21);
		message = replace(message, new String[] { ";d" }, PIC22);
		message = replace(message, new String[] { ";o" }, PIC23);
		message = replace(message, new String[] { ":g" }, PIC24);
		message = replace(message, new String[] { "\\|-\\)" }, PIC25);
		message = replace(message, new String[] { ":!" }, PIC26);
		message = replace(message, new String[] { ":L" }, PIC27);
		message = replace(message, new String[] { ":;" }, PIC29);
		message = replace(message, new String[] { ";f" }, PIC30);
		message = replace(message, new String[] { "\\(?\\)" }, PIC32);
		message = replace(message, new String[] { ";x" }, PIC33);
		message = replace(message, new String[] { ";@" }, PIC34);
		message = replace(message, new String[] { ":8" }, PIC35);
		message = replace(message, new String[] { ";!" }, PIC36);
		message = replace(message, new String[] { "!!!" }, PIC37);
		message = replace(message, new String[] { "\\(xx\\)" }, PIC38);
		message = replace(message, new String[] { "\\(bye\\)" }, PIC39);
		message = replace(message, new String[] { "\\(wipe\\)" }, PIC97);
		message = replace(message, new String[] { "\\(dig\\)" }, PIC98);
		message = replace(message, new String[] { "\\(handclap\\)" }, PIC99);
		message = replace(message, new String[] { "&amp;-\\(" }, PIC100);
		message = replace(message, new String[] { "&lt;@" }, PIC102);
		message = replace(message, new String[] { "@&lt;" }, PIC103);
		message = replace(message, new String[] { ":-O", ":-o" }, PIC104);
		message = replace(message, new String[] { "&gt;-\\|" }, PIC105);
		message = replace(message, new String[] { "P-\\(" }, PIC106);
		message = replace(message, new String[] { ";'\\|" }, PIC107);
		message = replace(message, new String[] { "X-\\)" }, PIC108);
		message = replace(message, new String[] { ":\\*" }, PIC109);
		message = replace(message, new String[] { "@x" }, PIC110);
		message = replace(message, new String[] { "8\\*" }, PIC111);
		message = replace(message, new String[] { "\\(L\\)", "\\(l\\)" },
				PICheart);
		message = replace(message, new String[] { "\\(U\\)", "\\(u\\)" },
				PICbrheart);
		message = replace(message, new String[] { "\\(Y\\)", "\\(y\\)" },
				PICyes);
		message = replace(message, new String[] { "\\(N\\)", "\\(n\\)" }, PICno);
		message = replace(message, new String[] { "\\(Z\\)", "\\(z\\)" },
				PICboy);
		message = replace(message, new String[] { "\\(X\\)", "\\(x\\)" },
				PICgirl);
		message = replace(message, new String[] { "\\(F\\)", "\\(f\\)" },
				PICflower);
		message = replace(message, new String[] { "\\(W\\)", "\\(w\\)" },
				PICbrflower);
		message = replace(message, new String[] { "\\(showlove\\)" }, PIC116);
		message = replace(message, new String[] { "\\(B\\)", "\\(b\\)" },
				PICbeer);
		message = replace(message, new String[] { "\\(C\\)", "\\(c\\)" },
				PICcoffee);
		message = replace(message, new String[] { "\\(K\\)", "\\(k\\)" },
				PICkiss);
		message = replace(message, new String[] { "\\(pd\\)" }, PIC112);
		message = replace(message, new String[] { "&lt;W&gt;" }, PIC89);
		message = replace(message, new String[] { "\\(basketb\\)" }, PIC114);
		message = replace(message, new String[] { "\\(eat\\)" }, PIC61);
		message = replace(message, new String[] { "\\(pig\\)" }, PIC46);
		message = replace(message, new String[] { "\\(cake\\)" }, PIC53);
		message = replace(message, new String[] { "\\(li\\)" }, PIC54);
		message = replace(message, new String[] { "\\(bome\\)" }, PIC55);
		message = replace(message, new String[] { "\\(kn\\)" }, PIC56);
		message = replace(message, new String[] { "\\(footb\\)" }, PIC57);
		message = replace(message, new String[] { "\\(shit\\)" }, PIC59);
		message = replace(message, new String[] { "\\(moon\\)" }, PIC75);
		message = replace(message, new String[] { "\\(sun\\)" }, PIC74);
		message = replace(message, new String[] { "\\(gift\\)" }, PIC69);
		message = replace(message, new String[] { "\\(share\\)" }, PIC78);
		message = replace(message, new String[] { "\\(v\\)" }, PIC79);
		message = replace(message, new String[] { "@\\)" }, PIC118);
		message = replace(message, new String[] { "\\(jj\\)" }, PIC119);
		message = replace(message, new String[] { "@@" }, PIC120);
		message = replace(message, new String[] { "\\(bad\\)" }, PIC121);
		message = replace(message, new String[] { "\\(loveu\\)" }, PIC122);
		message = replace(message, new String[] { "\\(no\\)" }, PIC123);
		message = replace(message, new String[] { "\\(ok\\)" }, PIC124);
		return message;
	}

	private static String formatEmoticons(String message) {
		//final Emoticons img = Emoticons.App.getInstance();

		message = preFormatEmoticons(message);

		/*
		message = message.replaceAll(PICsmile, getImgHtml(img.pic_smile()));
		message = message.replaceAll(PICwink, getImgHtml(img.pic_wink()));
		message = message.replaceAll(PICtongue, getImgHtml(img.pic_tongue()));
		message = message.replaceAll(PIC13, getImgHtml(img.pic_13()));
		message = message.replaceAll(PICbiggrin, getImgHtml(img.pic_biggrin()));
		message = message.replaceAll(PICunhappy, getImgHtml(img.pic_unhappy()));
		message = message.replaceAll(PICcry, getImgHtml(img.pic_cry()));
		message = message.replaceAll(PICoh, getImgHtml(img.pic_oh()));
		message = message.replaceAll(PICangry, getImgHtml(img.pic_angry()));
		message = message.replaceAll(PICblush, getImgHtml(img.pic_blush()));
		message = message.replaceAll(PICstare, getImgHtml(img.pic_stare()));
		message = message.replaceAll(PICfrowning, getImgHtml(img.pic_frowning()));
		message = message.replaceAll(PIC101, getImgHtml(img.pic_101()));
		message = message.replaceAll(PIC1, getImgHtml(img.pic_1()));
		message = message.replaceAll(PIC2, getImgHtml(img.pic_2()));
		message = message.replaceAll(PIC5, getImgHtml(img.pic_5()));
		message = message.replaceAll(PIC7, getImgHtml(img.pic_7()));
		message = message.replaceAll(PIC8, getImgHtml(img.pic_8()));
		message = message.replaceAll(PIC9, getImgHtml(img.pic_9()));
		message = message.replaceAll(PIC10, getImgHtml(img.pic_10()));
		message = message.replaceAll(PIC16, getImgHtml(img.pic_16()));
		message = message.replaceAll(PIC96, getImgHtml(img.pic_96()));
		message = message.replaceAll(PIC18, getImgHtml(img.pic_18()));
		message = message.replaceAll(PIC19, getImgHtml(img.pic_19()));
		message = message.replaceAll(PIC20, getImgHtml(img.pic_20()));
		message = message.replaceAll(PIC21, getImgHtml(img.pic_21()));
		message = message.replaceAll(PIC22, getImgHtml(img.pic_22()));
		message = message.replaceAll(PIC23, getImgHtml(img.pic_23()));
		message = message.replaceAll(PIC24, getImgHtml(img.pic_24()));
		message = message.replaceAll(PIC25, getImgHtml(img.pic_25()));
		message = message.replaceAll(PIC26, getImgHtml(img.pic_26()));
		message = message.replaceAll(PIC27, getImgHtml(img.pic_27()));
		message = message.replaceAll(PIC29, getImgHtml(img.pic_29()));
		message = message.replaceAll(PIC30, getImgHtml(img.pic_30()));
		message = message.replaceAll(PIC32, getImgHtml(img.pic_32()));
		message = message.replaceAll(PIC33, getImgHtml(img.pic_33()));
		message = message.replaceAll(PIC34, getImgHtml(img.pic_34()));
		message = message.replaceAll(PIC35, getImgHtml(img.pic_35()));
		message = message.replaceAll(PIC36, getImgHtml(img.pic_36()));
		message = message.replaceAll(PIC37, getImgHtml(img.pic_37()));
		message = message.replaceAll(PIC38, getImgHtml(img.pic_38()));
		message = message.replaceAll(PIC39, getImgHtml(img.pic_39()));
		message = message.replaceAll(PIC97, getImgHtml(img.pic_97()));
		message = message.replaceAll(PIC98, getImgHtml(img.pic_98()));
		message = message.replaceAll(PIC99, getImgHtml(img.pic_99()));
		message = message.replaceAll(PIC100, getImgHtml(img.pic_100()));
		message = message.replaceAll(PIC102, getImgHtml(img.pic_102()));
		message = message.replaceAll(PIC103, getImgHtml(img.pic_103()));
		message = message.replaceAll(PIC104, getImgHtml(img.pic_104()));
		message = message.replaceAll(PIC105, getImgHtml(img.pic_105()));
		message = message.replaceAll(PIC106, getImgHtml(img.pic_106()));
		message = message.replaceAll(PIC107, getImgHtml(img.pic_107()));
		message = message.replaceAll(PIC108, getImgHtml(img.pic_108()));
		message = message.replaceAll(PIC109, getImgHtml(img.pic_109()));
		message = message.replaceAll(PIC110, getImgHtml(img.pic_110()));
		message = message.replaceAll(PIC111, getImgHtml(img.pic_111()));
		message = message.replaceAll(PICheart, getImgHtml(img.pic_heart()));
		message = message.replaceAll(PICbrheart, getImgHtml(img.pic_brheart()));
		message = message.replaceAll(PICyes, getImgHtml(img.pic_yes()));
		message = message.replaceAll(PICno, getImgHtml(img.pic_no()));
		message = message.replaceAll(PICboy, getImgHtml(img.pic_boy()));
		message = message.replaceAll(PICflower, getImgHtml(img.pic_flower()));
		message = message.replaceAll(PICbrflower, getImgHtml(img.pic_brflower()));
		message = message.replaceAll(PIC116, getImgHtml(img.pic_116()));
		message = message.replaceAll(PICbeer, getImgHtml(img.pic_beer()));
		message = message.replaceAll(PICcoffee, getImgHtml(img.pic_coffee()));
		message = message.replaceAll(PICkiss, getImgHtml(img.pic_kiss()));
		message = message.replaceAll(PIC112, getImgHtml(img.pic_112()));
		message = message.replaceAll(PIC89, getImgHtml(img.pic_89()));
		message = message.replaceAll(PIC114, getImgHtml(img.pic_114()));
		message = message.replaceAll(PIC61, getImgHtml(img.pic_61()));
		message = message.replaceAll(PIC46, getImgHtml(img.pic_46()));
		message = message.replaceAll(PIC53, getImgHtml(img.pic_53()));
		message = message.replaceAll(PIC54, getImgHtml(img.pic_54()));
		message = message.replaceAll(PIC55, getImgHtml(img.pic_55()));
		message = message.replaceAll(PIC56, getImgHtml(img.pic_56()));
		message = message.replaceAll(PIC57, getImgHtml(img.pic_57()));
		message = message.replaceAll(PIC59, getImgHtml(img.pic_59()));
		message = message.replaceAll(PIC75, getImgHtml(img.pic_75()));
		message = message.replaceAll(PIC74, getImgHtml(img.pic_74()));
		message = message.replaceAll(PIC69, getImgHtml(img.pic_69()));
		message = message.replaceAll(PIC78, getImgHtml(img.pic_78()));
		message = message.replaceAll(PIC79, getImgHtml(img.pic_79()));
		message = message.replaceAll(PIC118, getImgHtml(img.pic_118()));
		message = message.replaceAll(PIC119, getImgHtml(img.pic_119()));
		message = message.replaceAll(PIC120, getImgHtml(img.pic_120()));
		message = message.replaceAll(PIC121, getImgHtml(img.pic_121()));
		message = message.replaceAll(PIC122, getImgHtml(img.pic_122()));
		message = message.replaceAll(PIC123, getImgHtml(img.pic_123()));
		message = message.replaceAll(PIC124, getImgHtml(img.pic_124()));
		 */

		message = message.replaceAll(PICsmile, getImgSrcHtml("smile.gif"));
		message = message.replaceAll(PICwink, getImgSrcHtml("wink.gif"));
		message = message.replaceAll(PICtongue, getImgSrcHtml("tongue.gif"));
		message = message.replaceAll(PIC13, getImgSrcHtml("13.gif"));
		message = message.replaceAll(PICbiggrin, getImgSrcHtml("biggrin.gif"));
		message = message.replaceAll(PICunhappy, getImgSrcHtml("unhappy.gif"));
		message = message.replaceAll(PICcry, getImgSrcHtml("cry.gif"));
		message = message.replaceAll(PICoh, getImgSrcHtml("oh.gif"));
		message = message.replaceAll(PICangry, getImgSrcHtml("angry.gif"));
		message = message.replaceAll(PICblush, getImgSrcHtml("blush.gif"));
		message = message.replaceAll(PICstare, getImgSrcHtml("stare.gif"));
		message = message
				.replaceAll(PICfrowning, getImgSrcHtml("frowning.gif"));
		message = message.replaceAll(PIC101, getImgSrcHtml("101.gif"));
		message = message.replaceAll(PIC1, getImgSrcHtml("1.gif"));
		message = message.replaceAll(PIC2, getImgSrcHtml("2.gif"));
		message = message.replaceAll(PIC5, getImgSrcHtml("5.gif"));
		message = message.replaceAll(PIC7, getImgSrcHtml("7.gif"));
		message = message.replaceAll(PIC8, getImgSrcHtml("8.gif"));
		message = message.replaceAll(PIC9, getImgSrcHtml("9.gif"));
		message = message.replaceAll(PIC10, getImgSrcHtml("10.gif"));
		message = message.replaceAll(PIC16, getImgSrcHtml("16.gif"));
		message = message.replaceAll(PIC96, getImgSrcHtml("96.gif"));
		message = message.replaceAll(PIC18, getImgSrcHtml("18.gif"));
		message = message.replaceAll(PIC19, getImgSrcHtml("19.gif"));
		message = message.replaceAll(PIC20, getImgSrcHtml("20.gif"));
		message = message.replaceAll(PIC21, getImgSrcHtml("21.gif"));
		message = message.replaceAll(PIC22, getImgSrcHtml("22.gif"));
		message = message.replaceAll(PIC23, getImgSrcHtml("23.gif"));
		message = message.replaceAll(PIC24, getImgSrcHtml("24.gif"));
		message = message.replaceAll(PIC25, getImgSrcHtml("25.gif"));
		message = message.replaceAll(PIC26, getImgSrcHtml("26.gif"));
		message = message.replaceAll(PIC27, getImgSrcHtml("27.gif"));
		message = message.replaceAll(PIC29, getImgSrcHtml("29.gif"));
		message = message.replaceAll(PIC30, getImgSrcHtml("30.gif"));
		message = message.replaceAll(PIC32, getImgSrcHtml("32.gif"));
		message = message.replaceAll(PIC33, getImgSrcHtml("33.gif"));
		message = message.replaceAll(PIC34, getImgSrcHtml("34.gif"));
		message = message.replaceAll(PIC35, getImgSrcHtml("35.gif"));
		message = message.replaceAll(PIC36, getImgSrcHtml("36.gif"));
		message = message.replaceAll(PIC37, getImgSrcHtml("37.gif"));
		message = message.replaceAll(PIC38, getImgSrcHtml("38.gif"));
		message = message.replaceAll(PIC39, getImgSrcHtml("39.gif"));
		message = message.replaceAll(PIC97, getImgSrcHtml("97.gif"));
		message = message.replaceAll(PIC98, getImgSrcHtml("98.gif"));
		message = message.replaceAll(PIC99, getImgSrcHtml("99.gif"));
		message = message.replaceAll(PIC100, getImgSrcHtml("100.gif"));
		message = message.replaceAll(PIC102, getImgSrcHtml("102.gif"));
		message = message.replaceAll(PIC103, getImgSrcHtml("103.gif"));
		message = message.replaceAll(PIC104, getImgSrcHtml("104.gif"));
		message = message.replaceAll(PIC105, getImgSrcHtml("105.gif"));
		message = message.replaceAll(PIC106, getImgSrcHtml("106.gif"));
		message = message.replaceAll(PIC107, getImgSrcHtml("107.gif"));
		message = message.replaceAll(PIC108, getImgSrcHtml("108.gif"));
		message = message.replaceAll(PIC109, getImgSrcHtml("109.gif"));
		message = message.replaceAll(PIC110, getImgSrcHtml("110.gif"));
		message = message.replaceAll(PIC111, getImgSrcHtml("111.gif"));
		message = message.replaceAll(PICheart, getImgSrcHtml("heart.gif"));
		message = message.replaceAll(PICbrheart, getImgSrcHtml("brheart.gif"));
		message = message.replaceAll(PICyes, getImgSrcHtml("yes.gif"));
		message = message.replaceAll(PICno, getImgSrcHtml("no.gif"));
		message = message.replaceAll(PICboy, getImgSrcHtml("boy.gif"));
		message = message.replaceAll(PICgirl, getImgSrcHtml("girl.gif"));
		message = message.replaceAll(PICflower, getImgSrcHtml("flower.gif"));
		message = message
				.replaceAll(PICbrflower, getImgSrcHtml("brflower.gif"));
		message = message.replaceAll(PIC116, getImgSrcHtml("116.gif"));
		message = message.replaceAll(PICbeer, getImgSrcHtml("beer.gif"));
		message = message.replaceAll(PICcoffee, getImgSrcHtml("coffee.gif"));
		message = message.replaceAll(PICkiss, getImgSrcHtml("kiss.gif"));
		message = message.replaceAll(PIC112, getImgSrcHtml("112.gif"));
		message = message.replaceAll(PIC89, getImgSrcHtml("89.gif"));
		message = message.replaceAll(PIC114, getImgSrcHtml("114.gif"));
		message = message.replaceAll(PIC61, getImgSrcHtml("61.gif"));
		message = message.replaceAll(PIC46, getImgSrcHtml("46.gif"));
		message = message.replaceAll(PIC53, getImgSrcHtml("53.gif"));
		message = message.replaceAll(PIC54, getImgSrcHtml("54.gif"));
		message = message.replaceAll(PIC55, getImgSrcHtml("55.gif"));
		message = message.replaceAll(PIC56, getImgSrcHtml("56.gif"));
		message = message.replaceAll(PIC57, getImgSrcHtml("57.gif"));
		message = message.replaceAll(PIC59, getImgSrcHtml("59.gif"));
		message = message.replaceAll(PIC75, getImgSrcHtml("75.gif"));
		message = message.replaceAll(PIC74, getImgSrcHtml("74.gif"));
		message = message.replaceAll(PIC69, getImgSrcHtml("69.gif"));
		message = message.replaceAll(PIC78, getImgSrcHtml("78.gif"));
		message = message.replaceAll(PIC79, getImgSrcHtml("79.gif"));
		message = message.replaceAll(PIC118, getImgSrcHtml("118.gif"));
		message = message.replaceAll(PIC119, getImgSrcHtml("119.gif"));
		message = message.replaceAll(PIC120, getImgSrcHtml("120.gif"));
		message = message.replaceAll(PIC121, getImgSrcHtml("121.gif"));
		message = message.replaceAll(PIC122, getImgSrcHtml("122.gif"));
		message = message.replaceAll(PIC123, getImgSrcHtml("123.gif"));
		message = message.replaceAll(PIC124, getImgSrcHtml("124.gif"));
		return message;
	}

	private static String getImgSrcHtml(final String name) {
		return "<img align=\"absmiddle\" src=\"images/face/" + name + "\"/>";
	}

	private static String replace(String message, final String[] from,
			final String to) {
		for (int j = 0; j < from.length; j++) {
			message = message.replaceAll("(^|[\\s])" + from[j] + "([\\s]|$)",
					"$1" + to + "$2");
			// two times for: :) :) :) :)
			message = message.replaceAll("(^|[\\s])" + from[j] + "([\\s]|$)",
					"$1" + to + "$2");
		}
		return message;
	}

	public ChatTextFormatter() {
	}

}
