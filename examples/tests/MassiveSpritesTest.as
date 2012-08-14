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
	import de.nulldesign.nd2d.display.Sprite2DCloud;
	import de.nulldesign.nd2d.materials.BlendModePresets;
	import de.nulldesign.nd2d.materials.texture.Texture2D;

	import flash.display.BitmapData;
	import flash.display.BitmapDataChannel;
	import flash.events.Event;
	import flash.geom.Point;

	public class MassiveSpritesTest extends Scene2D {

		[Embed(source="/assets/particle_small.png")]
		private var cubeTexture:Class;

		private var spriteCloud:Node2D;

		private var perlinBmp:BitmapData;

		private var maxParticles:uint = 6000;

		public function MassiveSpritesTest() {
			mouseEnabled = false;

			addEventListener(Event.ADDED_TO_STAGE, addedToStage);
		}

		protected function randomizeParticle(node:Node2D):void {
			node.x = Math.random() * stage.stageWidth;
			node.y = Math.random() * stage.stageHeight;
			node.vx = (Math.random() - Math.random()) * 15;
			node.vy = (Math.random() - Math.random()) * 15;
			node.alpha = 1.0;
		}

		protected function addedToStage(e:Event):void {
			removeEventListener(Event.ADDED_TO_STAGE, addedToStage);

			var tex:Texture2D = Texture2D.textureFromBitmapData(new cubeTexture().bitmapData);
			var s:Sprite2D;

			// CPU 95%, FPS 60
			spriteCloud = new Sprite2DCloud(maxParticles, tex);

			// CPU 122%, FPS 46
			//spriteCloud = new Sprite2DBatch(tex);

			spriteCloud.blendMode = BlendModePresets.ADD;

			for(var i:int = 0; i < maxParticles; i++) {
				s = new Sprite2D();
				randomizeParticle(s);
				spriteCloud.addChild(s);
			}

			addChild(spriteCloud);

			perlinBmp = new BitmapData(stage.stageWidth, stage.stageHeight, false);
			perlinBmp.perlinNoise(stage.stageWidth * 0.1, stage.stageHeight * 0.1, 3, Math.random() * 20, false, false,
				BitmapDataChannel.RED | BitmapDataChannel.GREEN | BitmapDataChannel.BLUE, false);

			stage.addEventListener(Event.RESIZE, resizeStage);
		}

		protected function resizeStage(e:Event):void {
			if(stage) {
				if(perlinBmp) {
					perlinBmp.dispose();
				}

				perlinBmp = new BitmapData(stage.stageWidth, stage.stageHeight, false);
				perlinBmp.perlinNoise(stage.stageWidth * 0.1, stage.stageHeight * 0.1, 3, Math.random() * 20, true, false,
					BitmapDataChannel.RED | BitmapDataChannel.GREEN | BitmapDataChannel.BLUE, false);
			}
		}

		override public function step(elapsed:Number):void {
			var p:Number;
			var r:uint;
			var g:uint;
			var b:uint;
			var mdiff:Point = new Point(0.0, 0.0);

			for(var node:Node2D = spriteCloud.childFirst; node; node = node.next) {
				node.x += node.vx;
				node.y += node.vy;

				if(node.x < 0) {
					//s.x = 0;
					//s.vx *= -1;
					randomizeParticle(node);
				} else if(node.x > stage.stageWidth) {
					//s.x = stage.stageWidth;
					//s.vx *= -1;
					randomizeParticle(node);
				}

				if(node.y < 0) {
					//s.y = 0;
					//s.vy *= -1;
					randomizeParticle(node);
				} else if(node.y > stage.stageHeight) {
					//s.y = stage.stageHeight;
					//s.vy *= -1;
					randomizeParticle(node);
				}

				mdiff.x = stage.mouseX - node.x;
				mdiff.y = stage.mouseY - node.y;

				if(mdiff.length < 100.0) {
					node.vx -= mdiff.x * 0.02;
					node.vy -= mdiff.y * 0.02;
				}

				p = perlinBmp.getPixel(node.x, node.y);

				r = p >> 16;
				g = p >> 8 & 255;
				b = p & 255;

				node.vx += (r - b) * 0.003;
				node.vy += (g - b) * 0.003;

				// clip
				node.vx = Math.min(node.vx, 3);
				node.vy = Math.min(node.vy, 3);
				node.vx = Math.max(node.vx, -3);
				node.vy = Math.max(node.vy, -3);

				r = (node.x / stage.stageWidth) * 255;
				g = (node.y / stage.stageHeight) * 255;
				b = Math.abs(Math.round((node.vx + node.vy))) * 10;
				node.tint = (r << 16 | g << 8 | b);
				node.alpha -= 0.001;
			}
		}

		override public function dispose():void {
			super.dispose();

			if(perlinBmp) {
				perlinBmp.dispose();
				perlinBmp = null;
			}
		}
	}
}
