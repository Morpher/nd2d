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

	import com.bit101.components.ComboBox;
	import com.bit101.components.Style;

	import de.nulldesign.nd2d.display.Node2D;
	import de.nulldesign.nd2d.display.Scene2D;
	import de.nulldesign.nd2d.display.Sprite2D;
	import de.nulldesign.nd2d.display.Sprite2DBatch;
	import de.nulldesign.nd2d.display.Sprite2DCloud;
	import de.nulldesign.nd2d.materials.texture.Texture2D;
	import de.nulldesign.nd2d.materials.texture.TextureSheet;
	import de.nulldesign.nd2d.utils.Statistics;

	import flash.events.Event;
	import flash.geom.ColorTransform;

	public class SpeedTest extends Scene2D {

		private var comboBox:ComboBox;

		[Embed(source="/assets/spritechar2.png")]
		private var spriteTexture:Class;

		private var spriteCloud:Sprite2DCloud;
		private var spriteBatch:Sprite2DBatch;

		private var tex:Texture2D;
		private var sheet:TextureSheet;

		private var maxCloudSize:uint = 16383;

		private var spritesPerFrame:uint = 32;

		private var isShared:Boolean;
		private var isCloud:Boolean;
		private var isBatch:Boolean;
		private var isIndividual:Boolean;

		private var isStatic:Boolean;
		private var isAnimated:Boolean;
		private var isMoving:Boolean;

		public function SpeedTest() {
			mouseEnabled = false;
			backgroundColor = 0x666666;

			addEventListener(Event.ADDED_TO_STAGE, addedToStage);
		}

		private function addedToStage(e:Event):void {
			removeEventListener(Event.ADDED_TO_STAGE, addedToStage);

			comboBox = new ComboBox(stage, 0, 130, "- Select -", [
				"Sprite2D (static)",
				"   Sprite2D (animated)",
				"   Sprite2D (moving)",
				"Sprite2DCloud (static)",
				"   Sprite2DCloud (animated)",
				"   Sprite2DCloud (moving)",
				"Sprite2DBatch (static)",
				"   Sprite2DBatch (animated)",
				"   Sprite2DBatch (moving)",
				"Sprite2D individual Texture",
				"   animated",
				"   moving",
				"Clear"]);
			comboBox.width = 150;
			comboBox.addEventListener(Event.SELECT, onTestSelect);
			comboBox.numVisibleItems = 13;

			// don't dispose this bitmap and sheet when we dispose the childs but always
			// remember to manually dispose it when no longer needed (see dispose function below)
			tex = Texture2D.textureFromBitmapData(new spriteTexture().bitmapData, false);

			// for maximum speed on low-end devices
			//tex.textureOptions = TextureOption.QUALITY_LOW;

			sheet = new TextureSheet(tex, 24, 32);
			sheet.addAnimation("blah", [0, 1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11], true, 5);
		}

		private function onTestSelect(e:Event):void {
			// clean up
			if(spriteBatch) {
				spriteBatch.dispose();
				spriteBatch = null;
			}

			if(spriteCloud) {
				spriteCloud.dispose();
				spriteCloud = null;
			}

			while(childLast) {
				var sprite:Sprite2D = childLast as Sprite2D;

				// dispose individual textures
				if(sprite && sprite.texture != tex) {
					if(sprite.texture.bitmap) {
						sprite.texture.bitmap.dispose();
						sprite.texture.bitmap = null;
					}

					sprite.texture.sheet = null;
				}

				childLast.dispose();
			}

			var selectedIndex:int = comboBox.selectedIndex;

			isShared = selectedIndex == 0
				|| selectedIndex == 1
				|| selectedIndex == 2;

			isCloud = selectedIndex == 3
				|| selectedIndex == 4
				|| selectedIndex == 5;

			isBatch = selectedIndex == 6
				|| selectedIndex == 7
				|| selectedIndex == 8;

			isIndividual = selectedIndex == 9
				|| selectedIndex == 10
				|| selectedIndex == 11;

			isStatic = selectedIndex == 0
				|| selectedIndex == 3
				|| selectedIndex == 6
				|| selectedIndex == 9;

			isAnimated = selectedIndex == 1
				|| selectedIndex == 4
				|| selectedIndex == 7
				|| selectedIndex == 10;

			isMoving = selectedIndex == 2
				|| selectedIndex == 5
				|| selectedIndex == 8
				|| selectedIndex == 11;

			if(isCloud) {
				spriteCloud = new Sprite2DCloud(maxCloudSize, tex);
				addChild(spriteCloud);
			} else if(isBatch) {
				spriteBatch = new Sprite2DBatch(tex);
				addChild(spriteBatch);
			}
		}

		override public function step(elapsed:Number):void {
			super.step(elapsed);

			// camera movement comes for "free", keep that in mind! it's
			// faster to move the camera instead of hundreds of sprites
			camera.x = Math.cos(world.timeSinceStartInSeconds) * 50;

			if(Statistics.fps >= stage.frameRate) {
				var sprite:Sprite2D;

				for(var i:uint = 0; i < spritesPerFrame; i++) {
					if(isShared) {
						sprite = new Sprite2D(tex);
						addChild(sprite);
					} else if(isCloud) {
						if(spriteCloud.numChildren >= maxCloudSize) {
							spriteCloud = new Sprite2DCloud(maxCloudSize, tex);
							addChild(spriteCloud);
						}

						sprite = new Sprite2D();
						spriteCloud.addChild(sprite);
					} else if(isBatch) {
						sprite = new Sprite2D();
						spriteBatch.addChild(sprite);
					} else if(isIndividual) {
						var rndTex:Texture2D = Texture2D.textureFromBitmapData(new spriteTexture().bitmapData, false);
						rndTex.textureOptions = tex.textureOptions;
						rndTex.setSheet(sheet);

						// optional, just makes it more obvious
						var color:ColorTransform = new ColorTransform();
						color.redMultiplier = Math.random();
						color.greenMultiplier = Math.random();
						color.blueMultiplier = Math.random();
						rndTex.bitmap.colorTransform(rndTex.bitmap.rect, color);

						sprite = new Sprite2D(rndTex);
						addChild(sprite);
					}

					if(sprite) {
						sprite.x = camera.sceneWidth * Math.random();
						sprite.y = camera.sceneHeight * Math.random();

						if(isAnimated) {
							sprite.animation.play("blah", 1000 * Math.random(), 1 + 4 * Math.random());
						}
					}
				}
			}

			if(isMoving) {
				for(var node:Node2D = childFirst; node; node = node.next) {
					if(node is Sprite2DBatch || node is Sprite2DCloud) {
						for(var child:Node2D = node.childFirst; child; child = child.next) {
							child.rotation += 100 * elapsed;
						}
					} else {
						node.rotation += 100 * elapsed;
					}
				}
			}
		}

		override public function dispose():void {
			super.dispose();

			// force dispose of texture because we
			// created it with "autoCleanUpResources = false"
			if(tex) {
				tex.dispose(true);
				tex = null;
			}

			if(comboBox) {
				stage.removeChild(comboBox);
			}

			sheet = null;
			comboBox = null;
			spriteCloud = null;
			spriteBatch = null;
		}
	}
}
