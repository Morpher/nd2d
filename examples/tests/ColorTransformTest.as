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
	import de.nulldesign.nd2d.display.Sprite2D;
	import de.nulldesign.nd2d.display.Sprite2DBatch;
	import de.nulldesign.nd2d.display.Sprite2DCloud;
	import de.nulldesign.nd2d.materials.BlendModePresets;
	import de.nulldesign.nd2d.materials.texture.Texture2D;
	import de.nulldesign.nd2d.materials.texture.TextureSheet;

	import flash.display.Sprite;
	import flash.events.Event;
	import flash.geom.ColorTransform;

	public class ColorTransformTest extends TextureAtlasTest {

		[Embed(source="/assets/circle_mask.png")]
		protected var maskBitmap:Class;

		[Embed(source="/assets/spritechar1_alpha.png")]
		protected var spriteAlphaTexture:Class;

		private var maskSprite1:Sprite2D;
		private var maskSprite2:Sprite2D;

		private var panel:Sprite;

		private var sliders:Vector.<HUISlider> = new Vector.<HUISlider>();

		public function ColorTransformTest() {
			addEventListener(Event.ADDED_TO_STAGE, addedToStage);
			super();
		}

		override protected function init():void {
			backgroundColor = 0x666666;

			var tex:Texture2D = Texture2D.textureFromBitmapData(new spriteAlphaTexture().bitmapData);
			var maskTex:Texture2D = Texture2D.textureFromBitmapData(new maskBitmap().bitmapData);

			var sheet:TextureSheet = new TextureSheet(tex, 24, 32);
			sheet.addAnimation("blah", [0, 1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11], true, 10);

			// normal
			s = addChild(new Sprite2D(tex)) as Sprite2D;
			s.x = 200.0;
			s.y = 200.0;
			s.animation.play("blah");

			var spriteCloud:Sprite2DCloud = addChild(new Sprite2DCloud(1, tex)) as Sprite2DCloud;
			spriteCloud.x = 220.0;
			spriteCloud.y = 200.0;
			spriteCloud.addChild(new Sprite2D());
			Sprite2D(spriteCloud.childFirst).animation.play("blah");

			var spriteBatch:Sprite2DBatch = addChild(new Sprite2DBatch(tex)) as Sprite2DBatch;
			spriteBatch.x = 240.0;
			spriteBatch.y = 200.0;
			spriteBatch.addChild(new Sprite2D());
			Sprite2D(spriteBatch.childFirst).animation.play("blah");

			var spriteWithMask:Sprite2D = addChild(new Sprite2D(tex)) as Sprite2D;
			spriteWithMask.x = 260.0;
			spriteWithMask.y = 200.0;
			spriteWithMask.animation.play("blah");

			maskSprite1 = new Sprite2D(maskTex);
			maskSprite1.x = 280.0;
			maskSprite1.y = 200.0;
			maskSprite1.scaleY = 0.2;
			spriteWithMask.setMask(maskSprite1);

			// blend
			s = addChild(new Sprite2D(tex)) as Sprite2D;
			s.x = 200.0;
			s.y = 240.0;
			s.blendMode = BlendModePresets.NORMAL_NO_PREMULTIPLIED_ALPHA;
			s.animation.play("blah");

			spriteCloud = addChild(new Sprite2DCloud(1, tex)) as Sprite2DCloud;
			spriteCloud.x = 220.0;
			spriteCloud.y = 240.0;
			spriteCloud.addChild(new Sprite2D());
			spriteCloud.blendMode = BlendModePresets.NORMAL_NO_PREMULTIPLIED_ALPHA;
			Sprite2D(spriteCloud.childFirst).animation.play("blah");

			spriteBatch = addChild(new Sprite2DBatch(tex)) as Sprite2DBatch;
			spriteBatch.x = 240.0;
			spriteBatch.y = 240.0;
			spriteBatch.addChild(new Sprite2D());
			spriteBatch.blendMode = BlendModePresets.NORMAL_NO_PREMULTIPLIED_ALPHA;
			Sprite2D(spriteBatch.childFirst).animation.play("blah");

			spriteWithMask = addChild(new Sprite2D(tex)) as Sprite2D;
			spriteWithMask.x = 260.0;
			spriteWithMask.y = 240.0;
			spriteWithMask.blendMode = BlendModePresets.NORMAL_NO_PREMULTIPLIED_ALPHA;
			spriteWithMask.animation.play("blah");

			maskSprite2 = new Sprite2D(maskTex);
			maskSprite2.x = 280.0;
			maskSprite2.y = 240.0;
			maskSprite2.scaleY = 0.2;
			spriteWithMask.setMask(maskSprite2);
		}

		override public function step(elapsed:Number):void {
			maskSprite1.y = 200.0 + Math.sin(world.timeSinceStartInSeconds * 2.0) * 20.0;
			maskSprite2.y = 240.0 + Math.sin(world.timeSinceStartInSeconds * 2.0) * 20.0;
		}

		protected function addedToStage(event:Event):void {
			var c:HUISlider;

			removeEventListener(Event.ADDED_TO_STAGE, addedToStage);

			panel = new Sprite();
			panel.y = 280.0;
			panel.graphics.beginFill(0x000000, 0.6);
			panel.graphics.drawRoundRect(0, 0, 180, 160, 10);
			panel.graphics.endFill();

			var oldStyle:uint = Style.LABEL_TEXT;

			Style.LABEL_TEXT = 0xffffff;

			c = new HUISlider(panel, 0, 0, "redMultiplier", changeHandler);
			c.minimum = 0.0;
			c.maximum = 1.0;
			c.value = 1.0;

			sliders.push(c);

			c = new HUISlider(panel, 0, 20, "greenMultiplier", changeHandler);
			c.minimum = 0.0;
			c.maximum = 1.0;
			c.value = 1.0;

			sliders.push(c);

			c = new HUISlider(panel, 0, 40, "blueMultiplier", changeHandler);
			c.minimum = 0.0;
			c.maximum = 1.0;
			c.value = 1.0;

			sliders.push(c);

			c = new HUISlider(panel, 0, 60, "alphaMultiplier", changeHandler);
			c.minimum = 0.0;
			c.maximum = 1.0;
			c.value = 1.0;

			sliders.push(c);

			c = new HUISlider(panel, 0, 80, "redOffset", changeHandler);
			c.minimum = 0.0;
			c.maximum = 255.0;
			c.value = 0.0;

			sliders.push(c);

			c = new HUISlider(panel, 0, 100, "greenOffset", changeHandler);
			c.minimum = 0.0;
			c.maximum = 255.0;
			c.value = 0.0;

			sliders.push(c);

			c = new HUISlider(panel, 0, 120, "blueOffset", changeHandler);
			c.minimum = 0.0;
			c.maximum = 255.0;
			c.value = 0.0;

			sliders.push(c);

			c = new HUISlider(panel, 0, 140, "alphaOffset", changeHandler);
			c.minimum = 0.0;
			c.maximum = 255.0;
			c.value = 0.0;

			sliders.push(c);

			Style.LABEL_TEXT = oldStyle;

			stage.addChild(panel);
		}

		private function changeHandler(e:Event):void {
			var c:ColorTransform = new ColorTransform();
			c.redMultiplier = sliders[0].value;
			c.greenMultiplier = sliders[1].value;
			c.blueMultiplier = sliders[2].value;
			c.alphaMultiplier = sliders[3].value;
			c.redOffset = sliders[4].value;
			c.greenOffset = sliders[5].value;
			c.blueOffset = sliders[6].value;
			c.alphaOffset = sliders[7].value;

			for(var node:Node2D = childFirst; node; node = node.next) {
				node.colorTransform = c;
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
