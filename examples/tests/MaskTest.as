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

	import de.nulldesign.nd2d.display.Scene2D;
	import de.nulldesign.nd2d.display.Sprite2D;
	import de.nulldesign.nd2d.materials.texture.Texture2D;
	import de.nulldesign.nd2d.utils.NumberUtil;

	public class MaskTest extends Scene2D {
		[Embed(source="/assets/crate.jpg")]
		private var spriteImage:Class;

		[Embed(source="/assets/circle_mask.png")]
		private var maskImage:Class;

		private var sprite:Sprite2D;
		private var sprite2:Sprite2D;
		private var mask:Sprite2D;

		public function MaskTest() {
			var tex:Texture2D = Texture2D.textureFromBitmapData(new spriteImage().bitmapData);

			// set up test sprite and mask
			sprite = new Sprite2D(tex);
			addChild(sprite);

			sprite2 = new Sprite2D(tex);
			addChild(sprite2);

			mask = new Sprite2D(Texture2D.textureFromBitmapData(new maskImage().bitmapData));

			// apply the mask
			sprite.setMask(mask);
			sprite2.setMask(mask);
		}

		override public function step(elapsed:Number):void {
			super.step(elapsed);

			sprite.x = camera.sceneWidth * 0.5;
			sprite.y = camera.sceneHeight * 0.5;
			sprite.rotation += 2.0;

			sprite2.x = camera.sceneWidth * 0.5 + 256.0;
			sprite2.y = camera.sceneHeight * 0.5;
			sprite2.rotation += 2.5;

			mask.x = mouseX;
			mask.y = mouseY;
			mask.scaleY = NumberUtil.sin(world.timeSinceStartInSeconds * 3.0, 0.25);
			mask.rotation -= 100 * elapsed;
		}
	}
}
