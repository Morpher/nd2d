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

package de.nulldesign.nd2d.display {

	import de.nulldesign.nd2d.geom.Face;
	import de.nulldesign.nd2d.materials.Sprite2DBatchDynamicMaterial;
	import de.nulldesign.nd2d.materials.Sprite2DBatchMaterial;
	import de.nulldesign.nd2d.materials.texture.Texture2D;
	import de.nulldesign.nd2d.utils.TextureHelper;

	import flash.display3D.Context3D;

	/**
	 * Sprite2DBatch
	 *
	 * <p>Batches as many sprites as possible, sharing the same Texture,
	 * TextureSheet or TextureAtlas into one drawcall.</p>
	 *
	 * <p>Similar to a Sprite2DCloud, the main difference it that the Batch
	 * supports nested nodes, while the cloud just draws it's own children and
	 * not the subchilds.
	 *
	 * It uses less CPU resources and does more processing on the GPU. Depending
	 * on your target system, it can be faster than the cloud.
	 *
	 * It supports mouse events for childs and adding or removing childs doesn't
	 * slow down the rendering, it's free.
	 *
	 * So in particular cases it could be faster.</p>
	 */
	public class Sprite2DBatch extends Node2D {

		public var texture:Texture2D;

		private var dynamic:Boolean;
		private var faceList:Vector.<Face>;
		private var material:Sprite2DBatchMaterial;

		/**
		 * Batches multiple sprites sharing the same texture into one drawcall.
		 *
		 * @param texture
		 * @param dynamic	If true, allows childs to use different textures and
		 * even materials (blur, mask, etc.)
		 */
		public function Sprite2DBatch(texture:Texture2D, dynamic:Boolean = false) {
			this.texture = texture;
			this.dynamic = dynamic;

			faceList = TextureHelper.generateQuadFromDimensions(2, 2);

			if(dynamic) {
				material = new Sprite2DBatchDynamicMaterial();
			} else {
				material = new Sprite2DBatchMaterial();
			}
		}

		public function addBatchParent(child:Node2D):void {
			child.batchParent = this;

			var sprite:Sprite2D = child as Sprite2D;

			// distribute texture/sheet to sprites
			if(sprite && texture && !sprite.texture) {
				sprite.setTexture(texture);
			}

			for(var node:Node2D = child.childFirst; node; node = node.next) {
				addBatchParent(node);
			}
		}

		public function removeBatchParent(child:Node2D):void {
			child.batchParent = null;

			for(var node:Node2D = child.childFirst; node; node = node.next) {
				removeBatchParent(node);
			}
		}

		override public function addChild(child:Node2D):Node2D {
			if(child is Sprite2DBatch) {
				throw new Error("You can't nest Sprite2DBatches");
			}

			addBatchParent(child);

			return super.addChild(child);
		}

		override internal function drawNode(context:Context3D, camera:Camera2D, elapsed:Number):void {
			if(!visible) {
				return;
			}

			// can't use UV on the container

			step(elapsed);

			if(invalidateColors) {
				updateColors();
			}

			if(invalidateMatrix || parent.invalidateMatrix) {
				if(invalidateMatrix) {
					updateLocalMatrix();
				}

				updateWorldMatrix();

				invalidateMatrix = true;
			}

			material.elapsed = elapsed;

			draw(context, camera);

			// don't call draw on childs....

			invalidateMatrix = false;
		}

		override public function draw(context:Context3D, camera:Camera2D):void {
			material.camera = camera;
			material.blendMode = blendMode;
			material.scrollRect = worldScrollRect;
			material.modelMatrix = worldModelMatrix;
			material.viewProjectionMatrix = camera.getViewProjectionMatrix(false);
			material.texture = texture;
			material.usesColor = usesColor;
			material.usesColorOffset = usesColorOffset;
			material.renderBatch(context, faceList, childFirst);
		}

		override public function handleDeviceLoss():void {
			super.handleDeviceLoss();
			material.handleDeviceLoss();
		}

		override public function dispose():void {
			if(material) {
				material.dispose();
				material = null;
			}

			if(texture) {
				texture.dispose();
				texture = null;
			}

			faceList = null;

			super.dispose();
		}
	}
}
