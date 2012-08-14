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

	import de.nulldesign.nd2d.display.Node2D;
	import de.nulldesign.nd2d.display.Scene2D;
	import de.nulldesign.nd2d.display.Sprite2D;
	import de.nulldesign.nd2d.display.Sprite2DBatch;
	import de.nulldesign.nd2d.materials.texture.Texture2D;
	import de.nulldesign.nd2d.materials.texture.TextureSheet;
	import de.nulldesign.nd2d.utils.NumberUtil;

	import flash.events.Event;

	public class Transform3DTest extends Scene2D {

		[Embed(source="../assets/test_image.jpg")]
		private var imageBitmap:Class;

		private var batchNode:Sprite2DBatch;

		public function Transform3DTest() {
			addEventListener(Event.ADDED_TO_STAGE, addedToStage);
		}

		private function addedToStage(e:Event):void {
			removeEventListener(Event.ADDED_TO_STAGE, addedToStage);

			var tex:Texture2D = Texture2D.textureFromBitmapData(new imageBitmap().bitmapData);

			batchNode = new Sprite2DBatch(tex);
			addChild(batchNode);

			var sheet:TextureSheet = new TextureSheet(tex, 780 / 10, 208 / 4);

			for(var i:int = 0; i < 40; i++) {
				var s:Sprite2D = new Sprite2D();
				batchNode.addChild(s);

				s.x = (i % 10) * 78.0 - 780.0 * 0.5;
				s.y = Math.floor(i / 10) * 52.0 - 208.0 * 0.5;
				s.animation.frame = i;
			}
		}

		override public function step(elapsed:Number):void {
			batchNode.x = stage.stageWidth * 0.5;
			batchNode.y = stage.stageHeight * 0.5;

			var i:uint = 0;

			for(var node:Node2D = batchNode.childFirst; node; node = node.next, i++) {
				node.rotationX = NumberUtil.sin(world.timeSinceStartInSeconds * 0.8, 0, 180) * (Math.floor(i / 10) % 2 ? 1 : -1);
				node.rotationY = NumberUtil.sin(world.timeSinceStartInSeconds * 0.8, 0, 90) * (i % 2 ? -1 : 1);
			}
		}
	}
}
