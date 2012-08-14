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
	import com.bit101.components.HUISlider;
	import com.bit101.components.Style;

	import de.nulldesign.nd2d.display.Scene2D;
	import de.nulldesign.nd2d.display.Sprite2D;
	import de.nulldesign.nd2d.display.Sprite2DBatch;
	import de.nulldesign.nd2d.display.Sprite2DCloud;
	import de.nulldesign.nd2d.materials.texture.Texture2D;
	import de.nulldesign.nd2d.materials.texture.TextureOption;
	import de.nulldesign.nd2d.materials.texture.TextureSheet;

	import flash.display.Sprite;
	import flash.events.Event;
	import flash.geom.Vector3D;

	public class TextureAndRotationOptionsTest extends Scene2D {

		[Embed(source="/assets/crate.jpg")]
		private var crateTexture:Class;

		[Embed(source="/assets/spritechar1.png")]
		private var spriteTexture:Class;

		private var sprite:Sprite2D;
		private var batch:Sprite2DBatch;
		private var cloud:Sprite2DCloud;

		private var container:Sprite;

		private var textureComboBox:ComboBox;
		private var mipMapComboBox:ComboBox;
		private var filteringComboBox:ComboBox;
		private var repeatComboBox:ComboBox;

		public function TextureAndRotationOptionsTest() {
			backgroundColor = 0x333333;

			addEventListener(Event.ADDED_TO_STAGE, addedToStage);
		}

		private function removedFromStage(e:Event):void {
			if(container) {
				stage.removeChild(container);
			}
		}

		private function addedToStage(e:Event):void {
			removeEventListener(Event.ADDED_TO_STAGE, addedToStage);

			container = new Sprite();
			stage.addChild(container);

			var slider:HUISlider;

			var oldStyle:uint = Style.LABEL_TEXT;

			Style.LABEL_TEXT = 0xffffff;

			slider = new HUISlider(container, 0, 130, "uvOffsetX", sliderChanged);
			slider.minimum = -2.0;
			slider.maximum = 2.0;
			slider.value = 0.0;

			slider = new HUISlider(container, 0, 150, "uvOffsetY", sliderChanged);
			slider.minimum = -2.0;
			slider.maximum = 2.0;
			slider.value = 0.0;

			slider = new HUISlider(container, 0, 170, "uvScaleX", sliderChanged);
			slider.minimum = 0.0;
			slider.maximum = 5.0;
			slider.value = 1.0;

			slider = new HUISlider(container, 0, 190, "uvScaleY", sliderChanged);
			slider.minimum = 0.0;
			slider.maximum = 5.0;
			slider.value = 1.0;

			slider = new HUISlider(container, 0, 330, "rotationX", sliderChanged);
			slider.minimum = 0.0;
			slider.maximum = 360.0;
			slider.value = 0.0;

			slider = new HUISlider(container, 0, 350, "rotationY", sliderChanged);
			slider.minimum = 0.0;
			slider.maximum = 360.0;
			slider.value = 0.0;

			Style.LABEL_TEXT = oldStyle;

			mipMapComboBox = new ComboBox(container, 10, 210, "mipmapping", ["mipdisable", "mipnearest", "miplinear"]);
			mipMapComboBox.width = 120;
			mipMapComboBox.selectedIndex = 2;
			mipMapComboBox.addEventListener(Event.SELECT, onTextureOptionChange);
			mipMapComboBox.numVisibleItems = 3;

			filteringComboBox = new ComboBox(container, 10, 240, "texture filtering", ["nearest", "linear"]);
			filteringComboBox.width = 120;
			filteringComboBox.selectedIndex = 1;
			filteringComboBox.addEventListener(Event.SELECT, onTextureOptionChange);
			filteringComboBox.numVisibleItems = 2;

			repeatComboBox = new ComboBox(container, 10, 270, "texture repeat", ["repeat", "clamp"]);
			repeatComboBox.width = 120;
			repeatComboBox.selectedIndex = 1;
			repeatComboBox.addEventListener(Event.SELECT, onTextureOptionChange);
			repeatComboBox.numVisibleItems = 2;

			textureComboBox = new ComboBox(container, 10, 300, "texture image", ["crate", "sprites"]);
			textureComboBox.width = 120;
			textureComboBox.selectedIndex = 1;
			textureComboBox.addEventListener(Event.SELECT, onTextureOptionChange);
			textureComboBox.numVisibleItems = 2;

			onTextureOptionChange();
		}

		private function onTextureOptionChange(e:Event = null):void {
			if(sprite) {
				sprite.dispose();
			}

			if(batch) {
				batch.dispose();
			}

			if(cloud) {
				cloud.dispose();
			}

			var tex:Texture2D;
			var scaleFactor:Number = 1.0;

			if(!textureComboBox.selectedIndex) {
				tex = Texture2D.textureFromBitmapData(new crateTexture().bitmapData);
			} else {
				tex = Texture2D.textureFromBitmapData(new spriteTexture().bitmapData);

				var sheet:TextureSheet = new TextureSheet(tex, 24, 32);
				sheet.addAnimation("blah", [0, 1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11], true, 2);

				scaleFactor = 5.0;
			}

			tex.textureOptions = 0;
			tex.textureOptions |= (mipMapComboBox.selectedIndex == 0 ? TextureOption.MIPMAP_DISABLE : 0);
			tex.textureOptions |= (mipMapComboBox.selectedIndex == 1 ? TextureOption.MIPMAP_NEAREST : 0);
			tex.textureOptions |= (mipMapComboBox.selectedIndex == 2 ? TextureOption.MIPMAP_LINEAR : 0);
			tex.textureOptions |= (filteringComboBox.selectedIndex == 0 ? TextureOption.FILTERING_NEAREST : 0);
			tex.textureOptions |= (filteringComboBox.selectedIndex == 1 ? TextureOption.FILTERING_LINEAR : 0);
			tex.textureOptions |= (repeatComboBox.selectedIndex == 0 ? TextureOption.REPEAT_NORMAL : 0);
			tex.textureOptions |= (repeatComboBox.selectedIndex == 1 ? TextureOption.REPEAT_CLAMP : 0);

			// sprite
			sprite = new Sprite2D(tex);
			sprite.position = new Vector3D(stage.stageWidth / 2 - 300.0, stage.stageHeight / 2);
			sprite.scale = 0.5 * scaleFactor;
			sprite.animation.play("blah");
			addChild(sprite);

			var s:Sprite2D;

			// batch
			batch = new Sprite2DBatch(tex);
			addChild(batch);

			s = new Sprite2D();
			batch.addChild(s);
			s.position = new Vector3D(stage.stageWidth / 2 - 50, stage.stageHeight / 2);
			s.scale = 1.0 * scaleFactor;
			s.animation.play("blah");

			// cloud
			cloud = new Sprite2DCloud(1, tex);
			addChild(cloud);

			s = new Sprite2D();
			cloud.addChild(s);
			s.position = new Vector3D(stage.stageWidth / 2 + 300.0, stage.stageHeight / 2);
			s.scale = 1.5 * scaleFactor;
			s.animation.play("blah");
		}

		private function sliderChanged(e:Event):void {
			var slider:HUISlider = e.target as HUISlider;

			switch(slider.label) {
				case "uvOffsetX":  {
					sprite.uvOffsetX = batch.childFirst.uvOffsetX = cloud.childFirst.uvOffsetX = slider.value;
					break;
				}
				case "uvOffsetY":  {
					sprite.uvOffsetY = batch.childFirst.uvOffsetY = cloud.childFirst.uvOffsetY = slider.value;
					break;
				}
				case "uvScaleX":  {
					sprite.uvScaleX = batch.childFirst.uvScaleX = cloud.childFirst.uvScaleX = slider.value;
					break;
				}
				case "uvScaleY":  {
					sprite.uvScaleY = batch.childFirst.uvScaleY = cloud.childFirst.uvScaleY = slider.value;
					break;
				}
				case "rotationX":  {
					sprite.rotationX = batch.childFirst.rotationX = cloud.childFirst.rotationX = slider.value;
					break;
				}
				case "rotationY":  {
					sprite.rotationY = batch.childFirst.rotationY = cloud.childFirst.rotationY = slider.value;
					break;
				}
			}
		}

		override public function step(elapsed:Number):void {
			if(sprite && batch && cloud) {
				sprite.rotation += 0.2;
				batch.childFirst.rotation += 0.2;
				cloud.childFirst.rotation += 0.2;
			}
		}

		override public function dispose():void {
			super.dispose();

			if(container) {
				stage.removeChild(container);
			}

			container = null;
			repeatComboBox = null;
			mipMapComboBox = null;
			textureComboBox = null;
			filteringComboBox = null;
		}
	}
}
