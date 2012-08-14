/**
 * tests
 * @Author: Lars Gerckens (lars@nulldesign.de)
 * Date: 16.11.11 21:00
 */
package tests {

	import de.nulldesign.nd2d.display.Scene2D;
	import de.nulldesign.nd2d.display.TextField2D;
	import de.nulldesign.nd2d.utils.NumberUtil;

	import flash.filters.GlowFilter;

	import flashx.textLayout.formats.TextAlign;

	public class TextFieldTest extends Scene2D {

		private var txt:TextField2D;

		private var lastUpdate:Number = 0;

		public function TextFieldTest() {
			backgroundColor = 0x666666;

			txt = new TextField2D();
			txt.font = "Webdings";
			txt.textColor = 0xFFFFFF;
			txt.size = 100.0;
			txt.align = TextAlign.CENTER;
			txt.text = "Hello <font color='#FA8072'>N</font><font color='#98FB98'>D</font><font color='#6495ED'>2</font><font color='#F0E68C'>D</font> Text!";
			txt.filters = [new GlowFilter(0x000000, 1.0, 8, 8, 10)];

			addChild(txt);
		}

		override public function step(elapsed:Number):void {
			txt.x = stage.stageWidth >> 1;
			txt.y = stage.stageHeight >> 1;
			txt.rotation += 50 * elapsed;
			txt.scale = NumberUtil.sin(world.timeSinceStartInSeconds, 0.25, 1);

			lastUpdate += elapsed;

			// change font every 2.5 seconds
			if(lastUpdate >= 2.5) {
				lastUpdate = 0;

				if(txt.font == "Webdings") {
					txt.font = "Arial";
				} else {
					txt.font = "Webdings";
				}
			}
		}
	}
}
