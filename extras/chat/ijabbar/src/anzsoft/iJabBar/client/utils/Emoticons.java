package anzsoft.iJabBar.client.utils;

import com.google.gwt.core.client.GWT;
import com.google.gwt.user.client.ui.AbstractImagePrototype;
import com.google.gwt.user.client.ui.ImageBundle;

@SuppressWarnings("deprecation")
public interface Emoticons extends ImageBundle {

	public static class App {
		private static Emoticons ourInstance = null;

		public static synchronized Emoticons getInstance() {
			if (ourInstance == null) {
				ourInstance = (Emoticons) GWT.create(Emoticons.class);
			}
			return ourInstance;
		}
	}

	@Resource("1.gif")
	AbstractImagePrototype pic_1();

	@Resource("10.gif")
	AbstractImagePrototype pic_10();

	@Resource("100.gif")
	AbstractImagePrototype pic_100();

	@Resource("101.gif")
	AbstractImagePrototype pic_101();

	@Resource("102.gif")
	AbstractImagePrototype pic_102();

	@Resource("103.gif")
	AbstractImagePrototype pic_103();

	@Resource("104.gif")
	AbstractImagePrototype pic_104();

	@Resource("105.gif")
	AbstractImagePrototype pic_105();

	@Resource("106.gif")
	AbstractImagePrototype pic_106();

	@Resource("107.gif")
	AbstractImagePrototype pic_107();

	@Resource("108.gif")
	AbstractImagePrototype pic_108();

	@Resource("109.gif")
	AbstractImagePrototype pic_109();

	@Resource("110.gif")
	AbstractImagePrototype pic_110();

	@Resource("111.gif")
	AbstractImagePrototype pic_111();

	@Resource("112.gif")
	AbstractImagePrototype pic_112();

	@Resource("114.gif")
	AbstractImagePrototype pic_114();

	@Resource("116.gif")
	AbstractImagePrototype pic_116();

	@Resource("118.gif")
	AbstractImagePrototype pic_118();

	@Resource("119.gif")
	AbstractImagePrototype pic_119();

	@Resource("120.gif")
	AbstractImagePrototype pic_120();

	@Resource("121.gif")
	AbstractImagePrototype pic_121();

	@Resource("122.gif")
	AbstractImagePrototype pic_122();

	@Resource("123.gif")
	AbstractImagePrototype pic_123();

	@Resource("124.gif")
	AbstractImagePrototype pic_124();

	@Resource("13.gif")
	AbstractImagePrototype pic_13();

	@Resource("16.gif")
	AbstractImagePrototype pic_16();

	@Resource("18.gif")
	AbstractImagePrototype pic_18();

	@Resource("19.gif")
	AbstractImagePrototype pic_19();

	@Resource("2.gif")
	AbstractImagePrototype pic_2();

	@Resource("20.gif")
	AbstractImagePrototype pic_20();

	@Resource("21.gif")
	AbstractImagePrototype pic_21();

	@Resource("22.gif")
	AbstractImagePrototype pic_22();

	@Resource("23.gif")
	AbstractImagePrototype pic_23();

	@Resource("24.gif")
	AbstractImagePrototype pic_24();

	@Resource("25.gif")
	AbstractImagePrototype pic_25();

	@Resource("26.gif")
	AbstractImagePrototype pic_26();

	@Resource("27.gif")
	AbstractImagePrototype pic_27();

	@Resource("29.gif")
	AbstractImagePrototype pic_29();

	@Resource("30.gif")
	AbstractImagePrototype pic_30();

	@Resource("32.gif")
	AbstractImagePrototype pic_32();

	@Resource("33.gif")
	AbstractImagePrototype pic_33();

	@Resource("34.gif")
	AbstractImagePrototype pic_34();

	@Resource("35.gif")
	AbstractImagePrototype pic_35();

	@Resource("36.gif")
	AbstractImagePrototype pic_36();

	@Resource("37.gif")
	AbstractImagePrototype pic_37();

	@Resource("38.gif")
	AbstractImagePrototype pic_38();

	@Resource("39.gif")
	AbstractImagePrototype pic_39();

	@Resource("46.gif")
	AbstractImagePrototype pic_46();

	@Resource("5.gif")
	AbstractImagePrototype pic_5();

	@Resource("53.gif")
	AbstractImagePrototype pic_53();

	@Resource("54.gif")
	AbstractImagePrototype pic_54();

	@Resource("55.gif")
	AbstractImagePrototype pic_55();

	@Resource("56.gif")
	AbstractImagePrototype pic_56();

	@Resource("57.gif")
	AbstractImagePrototype pic_57();

	@Resource("59.gif")
	AbstractImagePrototype pic_59();

	@Resource("61.gif")
	AbstractImagePrototype pic_61();

	@Resource("69.gif")
	AbstractImagePrototype pic_69();

	@Resource("7.gif")
	AbstractImagePrototype pic_7();

	@Resource("74.gif")
	AbstractImagePrototype pic_74();

	@Resource("75.gif")
	AbstractImagePrototype pic_75();

	@Resource("78.gif")
	AbstractImagePrototype pic_78();

	@Resource("79.gif")
	AbstractImagePrototype pic_79();

	@Resource("8.gif")
	AbstractImagePrototype pic_8();

	@Resource("89.gif")
	AbstractImagePrototype pic_89();

	@Resource("9.gif")
	AbstractImagePrototype pic_9();

	@Resource("96.gif")
	AbstractImagePrototype pic_96();

	@Resource("97.gif")
	AbstractImagePrototype pic_97();

	@Resource("98.gif")
	AbstractImagePrototype pic_98();

	@Resource("99.gif")
	AbstractImagePrototype pic_99();

	@Resource("angry.gif")
	AbstractImagePrototype pic_angry();

	@Resource("beer.gif")
	AbstractImagePrototype pic_beer();

	@Resource("biggrin.gif")
	AbstractImagePrototype pic_biggrin();

	@Resource("blush.gif")
	AbstractImagePrototype pic_blush();

	@Resource("boy.gif")
	AbstractImagePrototype pic_boy();

	@Resource("brflower.gif")
	AbstractImagePrototype pic_brflower();

	@Resource("brheart.gif")
	AbstractImagePrototype pic_brheart();

	@Resource("coffee.gif")
	AbstractImagePrototype pic_coffee();

	@Resource("coolglasses.gif")
	AbstractImagePrototype pic_coolglasses();

	@Resource("cry.gif")
	AbstractImagePrototype pic_cry();

	@Resource("flower.gif")
	AbstractImagePrototype pic_flower();

	@Resource("frowning.gif")
	AbstractImagePrototype pic_frowning();

	@Resource("heart.gif")
	AbstractImagePrototype pic_heart();

	@Resource("kiss.gif")
	AbstractImagePrototype pic_kiss();

	@Resource("no.gif")
	AbstractImagePrototype pic_no();

	@Resource("oh.gif")
	AbstractImagePrototype pic_oh();

	@Resource("smile.gif")
	AbstractImagePrototype pic_smile();

	@Resource("stare.gif")
	AbstractImagePrototype pic_stare();

	@Resource("tongue.gif")
	AbstractImagePrototype pic_tongue();

	@Resource("unhappy.gif")
	AbstractImagePrototype pic_unhappy();

	@Resource("wink.gif")
	AbstractImagePrototype pic_wink();

	@Resource("yes.gif")
	AbstractImagePrototype pic_yes();
}
