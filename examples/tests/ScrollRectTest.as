/*
 * ND2D - A Flash Molehill GPU accelerated 2D engine
 *
 * Author: Lars Gerckens
 * Copyright (c) nulldesign 2011
 * Repository URL: http://github.com/nulldesign/nd2d
 * Getting started: https://github.com/nulldesign/nd2d/wiki
 *
 *
 * Licence Agreement
 *
 * Permission is hereby granted, free of charge, to any person obtaining a copy
 * of this software and associated documentation files (the "Software"), to deal
 * in the Software without restriction, including without limitation the rights
 * to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
 * copies of the Software, and to permit persons to whom the Software is
 * furnished to do so, subject to the following conditions:
 *
 * The above copyright notice and this permission notice shall be included in
 * all copies or substantial portions of the Software.
 *
 * THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
 * IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
 * FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
 * AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
 * LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
 * OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
 * THE SOFTWARE.
 */

package tests {

	import com.bit101.components.HUISlider;
	import com.bit101.components.Style;

	import de.nulldesign.nd2d.display.Node2D;
	import de.nulldesign.nd2d.display.Scene2D;
	import de.nulldesign.nd2d.display.Sprite2D;
	import de.nulldesign.nd2d.display.Sprite2DBatch;
	import de.nulldesign.nd2d.display.Sprite2DCloud;
	import de.nulldesign.nd2d.materials.texture.Texture2D;
	import de.nulldesign.nd2d.materials.texture.TextureSheet;
	import de.nulldesign.nd2d.utils.NumberUtil;

	import flash.display.Sprite;
	import flash.events.Event;
	import flash.geom.Rectangle;

	public class ScrollRectTest extends Scene2D {

		[Embed(source="/assets/spritechar1.png")]
		protected var spriteBitmap:Class;

		private var panel:Sprite;
		private var sliders:Vector.<HUISlider> = new Vector.<HUISlider>();

		public function ScrollRectTest() {
			super();
			backgroundColor = 0x666666;
			addEventListener(Event.ADDED_TO_STAGE, addedToStage);
		}

		protected function addedToStage(event:Event):void {
			removeEventListener(Event.ADDED_TO_STAGE, addedToStage);

			var tex:Texture2D = Texture2D.textureFromBitmapData(new spriteBitmap().bitmapData);

			var sheet:TextureSheet = new TextureSheet(tex, 24, 32);
			sheet.addAnimation("blah", [0, 1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11], true, 10);

			var i:uint;
			var sprite:Sprite2D;

			// container
			var container:Node2D = new Node2D();
			container.x = 200;
			container.y = 150;
			container.scrollRect = new Rectangle(0, 0, 100, 100);

			addChild(container);

			// batch
			var containerBatch:Sprite2DBatch = new Sprite2DBatch(tex);
			containerBatch.x = 350;
			containerBatch.y = 150;
			containerBatch.scrollRect = new Rectangle(0, 0, 100, 100);

			addChild(containerBatch);

			// cloud
			var containerCloud:Sprite2DCloud = new Sprite2DCloud(50, tex);
			containerCloud.x = 500;
			containerCloud.y = 150;
			containerCloud.scrollRect = new Rectangle(0, 0, 100, 100);

			addChild(containerCloud);

			// add some sprites to each container
			for(var node:Node2D = childFirst; node; node = node.next) {
				for(i = 0; i < 50; i++) {
					sprite = new Sprite2D(tex);

					sprite.x = int(NumberUtil.random(-100, 100));
					sprite.y = int(NumberUtil.random(-100, 100));
					sprite.animation.play("blah", Math.random() * 100);

					if(node is Sprite2DBatch) {
						sprite.tint = 0x00ff00;
					} else if(node is Sprite2DCloud) {
						sprite.tint = 0x0000ff;
					} else {
						sprite.tint = 0xff0000;
					}

					node.addChild(sprite);
				}
			}

			// control panel
			panel = new Sprite();
			panel.y = 280.0;
			panel.graphics.beginFill(0x000000, 0.6);
			panel.graphics.drawRoundRect(0, 0, 180, 80, 10);
			panel.graphics.endFill();

			var oldStyle:uint = Style.LABEL_TEXT;

			Style.LABEL_TEXT = 0xffffff;

			var slider:HUISlider;

			slider = new HUISlider(panel, 0, 0, "x", changeHandler);
			slider.setSliderParams(-50, 50, 0);
			sliders.push(slider);

			slider = new HUISlider(panel, 0, 20, "y", changeHandler);
			slider.setSliderParams(-50, 50, 0);
			sliders.push(slider);

			slider = new HUISlider(panel, 0, 40, "width", changeHandler);
			slider.setSliderParams(1, 200, 100);
			sliders.push(slider);

			slider = new HUISlider(panel, 0, 60, "height", changeHandler);
			slider.setSliderParams(1, 200, 100);
			sliders.push(slider);

			Style.LABEL_TEXT = oldStyle;

			stage.addChild(panel);
		}

		private function changeHandler(e:Event):void {
			for(var node:Node2D = childFirst; node; node = node.next) {
				var scrollRect:Rectangle = node.scrollRect.clone();
				scrollRect.x = int(sliders[0].value);
				scrollRect.y = int(sliders[1].value);
				scrollRect.width = sliders[2].value;
				scrollRect.height = sliders[3].value;

				node.scrollRect = scrollRect;
			}
		}

		override public function dispose():void {
			super.dispose();

			sliders = null;

			if(panel) {
				stage.removeChild(panel);
				panel = null;
			}
		}
	}
}
