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

	import com.bit101.components.PushButton;

	import de.nulldesign.nd2d.display.Node2D;
	import de.nulldesign.nd2d.display.Scene2D;
	import de.nulldesign.nd2d.display.Sprite2D;
	import de.nulldesign.nd2d.display.Sprite2DCloud;
	import de.nulldesign.nd2d.materials.texture.Texture2D;
	import de.nulldesign.nd2d.materials.texture.TextureSheet;

	import flash.events.Event;
	import flash.events.MouseEvent;
	import flash.geom.Point;

	public class MassiveSpriteCloudTest extends Scene2D {

		[Embed(source="/assets/spritechar2.png")]
		private var cubeTexture:Class;

		private var spriteCloud:Sprite2DCloud;

		private var numSprites:uint = 1600;

		private var addSpritesButton:PushButton;

		public function MassiveSpriteCloudTest() {
			backgroundColor = 0x666666;
			mouseEnabled = false;

			var tex:Texture2D = Texture2D.textureFromBitmapData(new cubeTexture().bitmapData);

			var sheet:TextureSheet = new TextureSheet(tex, 24, 32);
			sheet.addAnimation("up", [0, 1, 2], true, 10);
			sheet.addAnimation("right", [3, 4, 5], true, 10);
			sheet.addAnimation("down", [6, 7, 8], true, 10);
			sheet.addAnimation("left", [9, 10, 11], true, 10);

			spriteCloud = new Sprite2DCloud(numSprites, tex);

			addSpritesClick();

			addChild(spriteCloud);

			addEventListener(Event.ADDED_TO_STAGE, addedToStage);
		}

		private function addSpritesClick(event:MouseEvent = null):void {
			var s:Sprite2D;

			for(var i:int = 0; i < 100; i++) {
				s = new Sprite2D();
				s.x = Math.round(Math.random() * 1000);
				s.y = Math.round(Math.random() * 1000);
				s.vx = (Math.random() - Math.random()) * 3;
				s.vy = (Math.random() - Math.random()) * 3;
				s.pivot = new Point(0, -15);

				spriteCloud.addChild(s);

				if(spriteCloud.childCount == 1) {   // alpha, tint & scale test for sprites in clouds
					s.alpha = 0.5;
					s.tint = 0x00FF00;
					s.scaleX = s.scaleY = 2.0;
				}
			}
		}

		private function addedToStage(event:Event):void {
			removeEventListener(Event.ADDED_TO_STAGE, addedToStage);

			addSpritesButton = new PushButton(stage, 0.0, 150.0, "addChild", addSpritesClick);
		}

		override public function step(elapsed:Number):void {
			var s:Sprite2D;
			var vxabs:Number;
			var vyabs:Number;

			for(var node:Node2D = spriteCloud.childFirst; node; node = node.next) {
				s = node as Sprite2D;
				s.x += s.vx;
				s.y += s.vy;

				//s.rotation += 10;

				if(s.x < 0) {
					s.x = 0;
					s.vx *= -1;
				} else if(s.x > stage.stageWidth) {
					s.x = stage.stageWidth;
					s.vx *= -1;
				}

				if(s.y < 0) {
					s.y = 0;
					s.vy *= -1;
				} else if(s.y > stage.stageHeight) {
					s.y = stage.stageHeight;
					s.vy *= -1;
				}

				vxabs = Math.abs(s.vx);
				vyabs = Math.abs(s.vy);

				if(s.vx > 0 && vxabs > vyabs) { // right
					s.animation.play("right");
				} else if(s.vx < 0 && vxabs > vyabs) { // left
					s.animation.play("left");
				} else if(s.vy > 0 && vyabs > vxabs) { // down
					s.animation.play("down");
				} else if(s.vy < 0 && vyabs > vxabs) { // up
					s.animation.play("up");
				}

				s.rotation += 5.0;
			}
		}

		override public function dispose():void {
			super.dispose();

			if(addSpritesButton) {
				stage.removeChild(addSpritesButton);
				addSpritesButton = null;
			}

			spriteCloud = null;
		}
	}
}

