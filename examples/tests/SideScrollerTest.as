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
	import de.nulldesign.nd2d.display.ParticleSystem2D;
	import de.nulldesign.nd2d.display.Scene2D;
	import de.nulldesign.nd2d.display.Sprite2D;
	import de.nulldesign.nd2d.display.Sprite2DBatch;
	import de.nulldesign.nd2d.materials.BlendModePresets;
	import de.nulldesign.nd2d.materials.texture.Texture2D;
	import de.nulldesign.nd2d.materials.texture.TextureSheet;
	import de.nulldesign.nd2d.utils.NumberUtil;
	import de.nulldesign.nd2d.utils.ParticleSystemPreset;

	import flash.events.Event;

	import tests.objects.MorphGrid;

	public class SideScrollerTest extends Scene2D {

		[Embed(source="/assets/particle_small.png")]
		protected var particleTexture:Class;

		[Embed(source="/assets/star_particle.png")]
		protected var particleTexture2:Class;

		[Embed(source="/assets/world_background.png")]
		protected var backgroundTexture:Class;

		[Embed(source="/assets/world_background2.png")]
		protected var backgroundTexture2:Class;

		[Embed(source="/assets/ceiling_texture.png")]
		protected var ceilingTexture:Class;

		[Embed(source="/assets/grass_ground.png")]
		protected var grassTexture:Class;

		[Embed(source="/assets/blur_tree.png")]
		protected var treeTexture:Class;

		[Embed(source="/assets/plantsheet.png")]
		protected var plantTexture:Class;

		protected var grassSprites:Sprite2DBatch;
		protected var ceilingSprites:Sprite2DBatch;
		protected var backgroundSprites:Sprite2DBatch;
		protected var backgroundSprites2:Node2D;
		protected var treeSprites:Sprite2DBatch;
		protected var plantSprites:Sprite2DBatch;

		protected var plasma:ParticleSystem2D;
		protected var wind:ParticleSystem2D;

		protected var scrollX:Number = 0.0;

		public function SideScrollerTest() {
			addEventListener(Event.ADDED_TO_STAGE, addedToStage);
		}

		protected function addedToStage(e:Event):void {
			removeEventListener(Event.ADDED_TO_STAGE, addedToStage);

			// background
			var backgroundTex:Texture2D = Texture2D.textureFromBitmapData(new backgroundTexture().bitmapData);
			backgroundSprites = new Sprite2DBatch(backgroundTex);
			addChild(backgroundSprites);

			backgroundSprites.addChild(new Sprite2D());
			backgroundSprites.addChild(new Sprite2D());
			backgroundSprites.addChild(new Sprite2D());

			var i:uint;
			var node:Node2D;

			for(i = 0, node = backgroundSprites.childFirst; node; i++, node = node.next) {
				node.x = (i + 0.5) * node.width;
			}

			// background2
			var backgroundTex2:Texture2D = Texture2D.textureFromBitmapData(new backgroundTexture2().bitmapData);
			backgroundSprites2 = new Node2D();
			addChild(backgroundSprites2);

			backgroundSprites2.addChild(new MorphGrid(16, 8, backgroundTex2, 0.04));
			backgroundSprites2.addChild(new MorphGrid(16, 8, backgroundTex2, 0.04));
			backgroundSprites2.addChild(new MorphGrid(16, 8, backgroundTex2, 0.04));

			for(i = 0, node = backgroundSprites2.childFirst; node; i++, node = node.next) {
				node.blendMode = BlendModePresets.ADD;
				node.x = (i + 0.5) * node.width;
			}

			// wind
			var plasmaPreset:ParticleSystemPreset = new ParticleSystemPreset();
			plasmaPreset.minStartSize = 0.5;
			plasmaPreset.maxStartSize = 1.0;
			plasmaPreset.minEndSize = 0.01;
			plasmaPreset.maxEndSize = 0.01;
			plasmaPreset.startColor = plasmaPreset.startColorVariance = 0xFFFFFF;
			plasmaPreset.endColor = plasmaPreset.endColorVariance = 0xFFFFFF;
			plasmaPreset.startAlpha = 0.0;
			plasmaPreset.endAlpha = 0.6;
			plasmaPreset.minStartPosition.x = -stage.stageWidth * 0.5;
			plasmaPreset.maxStartPosition.x = stage.stageWidth * 0.5;
			plasmaPreset.minStartPosition.y = -stage.stageHeight * 0.5;
			plasmaPreset.maxStartPosition.y = stage.stageHeight * 0.5;
			plasmaPreset.spawnDelay = 0.0;

			wind = new ParticleSystem2D(Texture2D.textureFromBitmapData(new particleTexture2().bitmapData), 400, plasmaPreset);
			wind.blendMode = BlendModePresets.ADD;
			addChild(wind);

			// trees
			var treeTex:Texture2D = Texture2D.textureFromBitmapData(new treeTexture().bitmapData);
			treeSprites = new Sprite2DBatch(treeTex);
			addChild(treeSprites);

			treeSprites.addChild(new Sprite2D());
			treeSprites.addChild(new Sprite2D());
			treeSprites.addChild(new Sprite2D());

			for(i = 0, node = treeSprites.childFirst; node; i++, node = node.next) {
				node.x = NumberUtil.random(0, 1024);
				node.scale = NumberUtil.random(0.3, 1.5);
				node.scaleX *= Math.random() > 0.5 ? 1 : -1;
			}

			// grass
			var grassTex:Texture2D = Texture2D.textureFromBitmapData(new grassTexture().bitmapData);
			grassSprites = new Sprite2DBatch(grassTex);
			addChild(grassSprites);

			grassSprites.addChild(new Sprite2D());
			grassSprites.addChild(new Sprite2D());
			grassSprites.addChild(new Sprite2D());

			for(i = 0, node = grassSprites.childFirst; node; i++, node = node.next) {
				node.x = (i + 0.5) * node.width;
			}

			// plants
			// TODO: recreate texture to not give bad examples.. Textures should always be pixel aligned!
			var plantTex:Texture2D = Texture2D.textureFromBitmapData(new plantTexture().bitmapData);
			var sheet:TextureSheet = new TextureSheet(plantTex, plantTex.bitmapWidth / 5, plantTex.bitmapHeight / 7);
			var ar:Array = [];

			for(i = 2; i < 35; ++i) {
				ar.push(i);
			}

			for(i = 34; i >= 2; --i) {
				ar.push(i);
			}

			sheet.addAnimation("wave", ar, true, 20);

			plantSprites = new Sprite2DBatch(plantTex);
			addChild(plantSprites);

			var plant:Sprite2D = new Sprite2D();
			plant.scale = 3.0;
			plant.y = -220;
			plantSprites.addChild(plant);
			plant.animation.frame = 1;

			plant = new Sprite2D();
			plant.scale = 4.0;
			plant.x = 100;
			plant.y = -220;
			plantSprites.addChild(plant);
			plant.animation.play("wave", 30);

			plant = new Sprite2D();
			plant.scaleX = -2.0;
			plant.scaleY = 2.0;
			plant.x = 450;
			plant.y = -150;
			plantSprites.addChild(plant);
			plant.animation.play("wave", 25);

			plant = new Sprite2D();
			plant.x = 620;
			plant.y = -120;
			plantSprites.addChild(plant);
			plant.animation.play("wave", 10, 40);

			// ceiling
			var ceilingTex:Texture2D = Texture2D.textureFromBitmapData(new ceilingTexture().bitmapData);
			ceilingSprites = new Sprite2DBatch(ceilingTex);
			addChild(ceilingSprites);

			ceilingSprites.addChild(new Sprite2D());
			ceilingSprites.addChild(new Sprite2D());
			ceilingSprites.addChild(new Sprite2D());

			for(i = 0, node = ceilingSprites.childFirst; node; i++, node = node.next) {
				node.x = (i + 0.5) * node.width;
			}

			// plasma
			plasmaPreset = new ParticleSystemPreset();
			plasmaPreset.minStartSize = 1.0;
			plasmaPreset.maxStartSize = 2.0;
			plasmaPreset.minEndSize = 0.3;
			plasmaPreset.maxEndSize = 0.1;
			plasmaPreset.startColor = plasmaPreset.startColorVariance = 0x633888;
			plasmaPreset.endColor = plasmaPreset.endColorVariance = 0x1bb099;
			plasmaPreset.minStartPosition.x = -25;
			plasmaPreset.maxStartPosition.x = 25;
			plasmaPreset.minEmitAngle = 170.0;
			plasmaPreset.maxEmitAngle = 190.0;
			plasmaPreset.spawnDelay = 2.0;

			plasma = new ParticleSystem2D(Texture2D.textureFromBitmapData(new particleTexture().bitmapData), 200, plasmaPreset);
			plasma.x = 225;
			plasma.y = -55;
			plasma.blendMode = BlendModePresets.ADD;

			backgroundSprites2.childFirst.addChild(plasma);
		}

		override public function step(elapsed:Number):void {
			var node:Node2D;

			scrollX = -(mouseX - camera.sceneWidth * 0.5) * 0.05;

			for(node = backgroundSprites.childFirst; node; node = node.next) {
				node.x += scrollX * 0.25;
				node.height = camera.sceneHeight;
				node.y = camera.sceneHeight * 0.5;
			}

			manageInfiniteScroll(backgroundSprites);

			for(node = backgroundSprites2.childFirst; node; node = node.next) {
				node.x += scrollX * 0.5;
				node.height = camera.sceneHeight;
				node.y = camera.sceneHeight * 0.5;
			}

			manageInfiniteScroll(backgroundSprites2);

			for(node = grassSprites.childFirst; node; node = node.next) {
				node.x += scrollX;
				node.y = camera.sceneHeight - node.height * 0.5;
			}

			manageInfiniteScroll(grassSprites);

			for(node = ceilingSprites.childFirst; node; node = node.next) {
				node.x += scrollX;
				node.y = node.height * 0.5;
			}

			manageInfiniteScroll(ceilingSprites);

			// scroll trees
			for(node = treeSprites.childFirst; node; node = node.next) {
				node.x += scrollX * 0.45;
				node.y = camera.sceneHeight - 120 - node.height * 0.5;

				// left out
				if(node.x < -node.width * 0.5 && scrollX < 0) {
					node.x = camera.sceneWidth + NumberUtil.random(300, 800);
				} else if(node.x - node.width * 0.5 > camera.sceneWidth && scrollX > 0) {
					node.x = NumberUtil.random(-300, -800);
				}
			}

			// scroll plants
			for(node = plantSprites.childFirst; node; node = node.next) {
				node.x += scrollX * 0.85;
				node.y = camera.sceneHeight - 100 - node.height * 0.5;

				// left out
				if(node.x < -node.width * 0.5 && scrollX < 0) {
					node.x = camera.sceneWidth + NumberUtil.random(300, 800);
				} else if(node.x - node.width * 0.5 > camera.sceneWidth && scrollX > 0) {
					node.x = NumberUtil.random(-300, -800);
				}
			}

			plasma.y = camera.sceneHeight - 250;

			if(wind) {
				wind.x = camera.sceneWidth * 0.5;
				wind.y = camera.sceneHeight * 0.5;
				wind.gravity.x = 200.0 * scrollX;
			}
		}

		protected function manageInfiniteScroll(container:Node2D):void {
			var first:Node2D = container.childFirst;
			var last:Node2D = container.childLast;

			// left out
			if(first.x < -first.width * 0.5) {
				first.x = last.x + last.width;
				container.insertChildAfter(first, last);
			} else if(last.x - last.width * 0.5 > camera.sceneWidth) {
				last.x = first.x - first.width;
				container.insertChildBefore(last, first);
			}
		}
	}
}

