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
	import de.nulldesign.nd2d.geom.UV;
	import de.nulldesign.nd2d.geom.Vertex;
	import de.nulldesign.nd2d.materials.shader.Shader2D;
	import de.nulldesign.nd2d.materials.shader.ShaderCache;
	import de.nulldesign.nd2d.materials.texture.Texture2D;
	import de.nulldesign.nd2d.utils.Statistics;
	import de.nulldesign.nd2d.utils.TextureHelper;
	import de.nulldesign.nd2d.utils.VectorUtil;

	import flash.display3D.Context3D;
	import flash.display3D.Context3DProgramType;
	import flash.display3D.Context3DVertexBufferFormat;
	import flash.display3D.IndexBuffer3D;
	import flash.display3D.VertexBuffer3D;
	import flash.geom.Point;
	import flash.geom.Rectangle;

	/**
	 * Sprite2DCloud
	 * <p>Use a sprite cloud to batch sprites with the same Texture, SpriteSheet
	 * or TextureAtlas. The SpriteSheet or TextureAtlas is cloned and passed to
	 * each child.
	 * So you can control each child individually.
	 * All sprites will be rendered in one single draw call. It uses more CPU
	 * resources, than the Sprite2DBatch, but can be a lot faster on slow GPU
	 * machines.</p>
	 *
	 * Limitations:
	 * <ul>
	 * <li>Mouseevents are disabled and won't work for childs</li>
	 * <li>Add/remove to/at the end is very fast but reordering childs (sort,
	 * add/remove) is very expensive. Try to avoid it! A Sprite2DBatch might
	 * work better in this case</li>
	 * <li>Subchilds are not rendered. The cloud will only render it's own childs,
	 * you can't nest nodes deeper with a cloud.</li>
	 * <li>rotationX,Y won't work for Sprite2DCloud childs</li>
	 * </ul>
	 *
	 * <p>If you have a SpriteSheet or TextureAtlas for your batch, make sure to
	 * add animations BEFORE you add any childs to the batch, because the
	 * SpriteSheet/TextureAtlas get's cloned and is copied to each added
	 * child</p>
	 */
	public class Sprite2DCloud extends Node2D {

		public var texture:Texture2D;

		protected var uv1:UV;
		protected var uv2:UV;
		protected var uv3:UV;
		protected var uv4:UV;

		protected var v1:Vertex;
		protected var v2:Vertex;
		protected var v3:Vertex;
		protected var v4:Vertex;

		protected var faceList:Vector.<Face>;

		private const numFloatsPerVertex:uint = 16;

		private const VERTEX_SHADER:String =
			"alias va0, position;" +
			"alias va1, uv;" +
			"alias va2, uvSheet;" +
			"alias va3, colorMultiplier;" +
			"alias va4, colorOffset;" +

			"alias vc0, viewProjection;" +
			"alias vc4, clipSpace;" +

			"temp0 = mul4x4(position, clipSpace);" +
			"output = mul4x4(temp0, viewProjection);" +

			"#if !USE_UV;" +
			"	temp0 = uv * uvSheet.zw;" +
			"	temp0 += uvSheet.xy;" +
			"#else;" +
			"	temp0 = uv;" +
			"#endif;" +

			// pass to fragment shader
			"v0 = temp0;" +
			"v1 = colorMultiplier;" +
			"v2 = colorOffset;" +
			"v3 = uvSheet;";

		private const FRAGMENT_SHADER:String =
			"alias v0, texCoord;" +
			"alias v1, colorMultiplier;" +
			"alias v2, colorOffset;" +
			"alias v3, uvSheet;" +

			"temp0 = sampleUV(texCoord, texture0, uvSheet);" +

			"output = colorize(temp0, colorMultiplier, colorOffset);";

		protected var maxCapacity:uint;

		protected var elapsed:Number;
		protected var shaderData:Shader2D;
		protected var indexBuffer:IndexBuffer3D;
		protected var vertexBuffer:VertexBuffer3D;
		protected var mVertexBuffer:Vector.<Number>;
		protected var mIndexBuffer:Vector.<uint>;

		protected var _static:Boolean = false;

		protected var staticIdx:uint = 0;
		protected var staticLast:Node2D = null;

		protected var lastUsesUV:Boolean = false;
		protected var lastUsesColor:Boolean = false;
		protected var lastUsesColorOffset:Boolean = false;

		public function Sprite2DCloud(maxCapacity:uint, textureObject:Texture2D) {
			texture = textureObject;
			faceList = TextureHelper.generateQuadFromDimensions(2, 2);

			v1 = faceList[0].v1;
			v2 = faceList[0].v2;
			v3 = faceList[0].v3;
			v4 = faceList[1].v3;

			uv1 = faceList[0].uv1;
			uv2 = faceList[0].uv2;
			uv3 = faceList[0].uv3;
			uv4 = faceList[1].uv3;

			this.maxCapacity = maxCapacity;

			mVertexBuffer = new Vector.<Number>(maxCapacity * numFloatsPerVertex * 4, true);
			mIndexBuffer = new Vector.<uint>(maxCapacity * 6, true);
		}

		public function get static():Boolean {
			return _static;
		}

		/**
		 * If <code>true</code>, makes this container really static. Childs can
		 * still be added but any changes you apply to them, like position, color,
		 * alpha etc. will not be visible.
		 *
		 * <p>This allows you to display a huge amount of static sprites at
		 * virtually no (CPU) cost. Works best if GPU is faster than CPU
		 * (dektop).</p>
		 *
		 * @see invalidateStatic()
		 */
		public function set static(value:Boolean):void {
			_static = value;

			invalidateStatic();
		}

		/**
		 * If <code>static</code> is set, this will force an invalidation of all
		 * childs to update their current state like position, color, alpha, etc.
		 *
		 * <p>This function call is expensive but has no effect if
		 * <code>static</code> is <code>false</code>.</p>
		 *
		 * @see static
		 */
		public function invalidateStatic():void {
			staticIdx = 0;
			staticLast = childFirst;
		}

		/**
		 * @private
		 */
		public function invalidateChilds(child:Node2D):void {
			for(var node:Node2D = child; node; node = node.next) {
				node.invalidateUV = true;
				node.invalidateMatrix = true;
				node.invalidateVisibility = true;
			}
		}

		override public function addChild(child:Node2D):Node2D {
			if(child is Sprite2DCloud) {
				throw new Error("You can't nest Sprite2DClouds");
			}

			if(childCount < maxCapacity) {
				super.addChild(child);

				var sprite:Sprite2D = child as Sprite2D;

				// distribute texture/sheet to sprites
				if(sprite && texture && !sprite.texture) {
					sprite.setTexture(texture);
				}

				return child;
			}

			return null;
		}

		override public function removeChild(child:Node2D):void {
			if(child == childLast) {
				staticIdx -= numFloatsPerVertex * 4;
				staticLast = child.prev;
			} else {
				invalidateStatic();
			}

			invalidateChilds(child.next);

			super.removeChild(child);
		}

		override public function insertChildBefore(child1:Node2D, child2:Node2D):void {
			super.insertChildBefore(child1, child2);

			invalidateStatic();
			invalidateChilds(child1);
		}

		override public function insertChildAfter(child1:Node2D, child2:Node2D):void {
			super.insertChildAfter(child1, child2);

			if(child1 != childLast) {
				invalidateStatic();
			}

			invalidateChilds(child1);
		}

		override public function swapChildren(child1:Node2D, child2:Node2D):void {
			super.swapChildren(child1, child2);

			invalidateStatic();

			child1.invalidateUV = true;
			child1.invalidateMatrix = true;
			child1.invalidateVisibility = true;

			child2.invalidateUV = true;
			child2.invalidateMatrix = true;
			child2.invalidateVisibility = true;
		}

		override internal function drawNode(context:Context3D, camera:Camera2D, elapsed:Number):void {
			if(!visible) {
				return;
			}

			step(elapsed);

			if(invalidateColors) {
				updateColors();
				invalidateColors = true;
			}

			if(invalidateMatrix || parent.invalidateMatrix) {
				if(invalidateMatrix) {
					updateLocalMatrix();
				}

				updateWorldMatrix();

				invalidateMatrix = true;
			}

			this.elapsed = elapsed;

			draw(context, camera);

			// don't call draw on childs....

			invalidateColors = false;
			invalidateMatrix = false;
		}

		override public function draw(context:Context3D, camera:Camera2D):void {
			if(!childFirst) {
				return;
			}

			var vIdx:uint = 0;
			var rMultiplier:Number;
			var gMultiplier:Number;
			var bMultiplier:Number;
			var aMultiplier:Number;
			var rOffset:Number;
			var gOffset:Number;
			var bOffset:Number;
			var aOffset:Number;
			var uvSheet:Rectangle;
			var rot:Number;
			var cr:Number;
			var sr:Number;
			var node:Node2D;
			var child:Sprite2D;
			var sx:Number;
			var sy:Number;
			var pivotX:Number, pivotY:Number;
			var offsetX:Number, offsetY:Number;
			var somethingChanged:Boolean = false;
			var atlasOffset:Point = new Point();
			var currentUsesUV:Boolean = false;
			var currentUsesColor:Boolean = false;
			var currentUsesColorOffset:Boolean = false;
			const halfTextureWidth:Number = texture.bitmapWidth >> 1;
			const halfTextureHeight:Number = texture.bitmapHeight >> 1;

			if(_static && staticLast) {
				vIdx = staticIdx;
				node = staticLast.next;
			} else {
				node = childFirst;
			}

			for(; node; node = node.next) {
				child = node as Sprite2D;

				node.step(elapsed);

				if(child.invalidateUV || child.animation.frameUpdated) {
					if(child.invalidateUV) {
						child.updateUV();
					}

					uvSheet = (texture.sheet ? child.animation.frameUV : texture.uvRect);
					child.animation.frameUpdated = false;

					// v1
					mVertexBuffer[vIdx + 2] = uv1.u * child.uvScaleX + child.uvOffsetX;
					mVertexBuffer[vIdx + 3] = uv1.v * child.uvScaleY + child.uvOffsetY;
					mVertexBuffer[vIdx + 4] = uvSheet.x;
					mVertexBuffer[vIdx + 5] = uvSheet.y;
					mVertexBuffer[vIdx + 6] = uvSheet.width;
					mVertexBuffer[vIdx + 7] = uvSheet.height;

					// v2
					mVertexBuffer[vIdx + 18] = uv2.u * child.uvScaleX + child.uvOffsetX;
					mVertexBuffer[vIdx + 19] = uv2.v * child.uvScaleY + child.uvOffsetY;
					mVertexBuffer[vIdx + 20] = uvSheet.x;
					mVertexBuffer[vIdx + 21] = uvSheet.y;
					mVertexBuffer[vIdx + 22] = uvSheet.width;
					mVertexBuffer[vIdx + 23] = uvSheet.height;

					// v3
					mVertexBuffer[vIdx + 34] = uv3.u * child.uvScaleX + child.uvOffsetX;
					mVertexBuffer[vIdx + 35] = uv3.v * child.uvScaleY + child.uvOffsetY;
					mVertexBuffer[vIdx + 36] = uvSheet.x;
					mVertexBuffer[vIdx + 37] = uvSheet.y;
					mVertexBuffer[vIdx + 38] = uvSheet.width;
					mVertexBuffer[vIdx + 39] = uvSheet.height;

					// v4
					mVertexBuffer[vIdx + 50] = uv4.u * child.uvScaleX + child.uvOffsetX;
					mVertexBuffer[vIdx + 51] = uv4.v * child.uvScaleY + child.uvOffsetY;
					mVertexBuffer[vIdx + 52] = uvSheet.x;
					mVertexBuffer[vIdx + 53] = uvSheet.y;
					mVertexBuffer[vIdx + 54] = uvSheet.width;
					mVertexBuffer[vIdx + 55] = uvSheet.height;

					somethingChanged = true;
				}

				if(child.invalidateMatrix || child.invalidateClipSpace) {
					if(texture.sheet) {
						atlasOffset = child.animation.frameOffset;
						sx = child.scaleX * (child.animation.frameRect.width >> 1);
						sy = child.scaleY * (child.animation.frameRect.height >> 1);
					} else {
						sx = child.scaleX * halfTextureWidth;
						sy = child.scaleY * halfTextureHeight;
					}

					if(child.rotation) {
						rot = VectorUtil.deg2rad(child.rotation);
						cr = Math.cos(rot);
						sr = Math.sin(rot);
					} else {
						cr = 1.0;
						sr = 0.0;
					}

					pivotX = child.pivot.x;
					pivotY = child.pivot.y;

					offsetX = child.x + atlasOffset.x;
					offsetY = child.y + atlasOffset.y;

					// v1
					mVertexBuffer[vIdx] = (v1.x * sx - pivotX) * cr - (v1.y * sy - pivotY) * sr + offsetX;
					mVertexBuffer[vIdx + 1] = (v1.x * sx - pivotX) * sr + (v1.y * sy - pivotY) * cr + offsetY;

					// v2
					mVertexBuffer[vIdx + 16] = (v2.x * sx - pivotX) * cr - (v2.y * sy - pivotY) * sr + offsetX;
					mVertexBuffer[vIdx + 17] = (v2.x * sx - pivotX) * sr + (v2.y * sy - pivotY) * cr + offsetY;

					// v3
					mVertexBuffer[vIdx + 32] = (v3.x * sx - pivotX) * cr - (v3.y * sy - pivotY) * sr + offsetX;
					mVertexBuffer[vIdx + 33] = (v3.x * sx - pivotX) * sr + (v3.y * sy - pivotY) * cr + offsetY;

					// v4
					mVertexBuffer[vIdx + 48] = (v4.x * sx - pivotX) * cr - (v4.y * sy - pivotY) * sr + offsetX;
					mVertexBuffer[vIdx + 49] = (v4.x * sx - pivotX) * sr + (v4.y * sy - pivotY) * cr + offsetY;

					somethingChanged = true;
				}

				if(invalidateColors || child.invalidateColors || child.invalidateVisibility) {
					if(child.invalidateColors) {
						child.updateColors();
					}

					if(child.visible) {
						rMultiplier = child.combinedColorTransform.redMultiplier;
						gMultiplier = child.combinedColorTransform.greenMultiplier;
						bMultiplier = child.combinedColorTransform.blueMultiplier;
						aMultiplier = child.combinedColorTransform.alphaMultiplier;
						rOffset = child.combinedColorTransform.redOffset;
						gOffset = child.combinedColorTransform.greenOffset;
						bOffset = child.combinedColorTransform.blueOffset;
						aOffset = child.combinedColorTransform.alphaOffset;
					} else {
						rMultiplier = 0.0;
						gMultiplier = 0.0;
						bMultiplier = 0.0;
						aMultiplier = 0.0;
						rOffset = 0.0;
						gOffset = 0.0;
						bOffset = 0.0;
						aOffset = 0.0;
					}

					// v1
					mVertexBuffer[vIdx + 8] = rMultiplier;
					mVertexBuffer[vIdx + 9] = gMultiplier;
					mVertexBuffer[vIdx + 10] = bMultiplier;
					mVertexBuffer[vIdx + 11] = aMultiplier;
					mVertexBuffer[vIdx + 12] = rOffset;
					mVertexBuffer[vIdx + 13] = gOffset;
					mVertexBuffer[vIdx + 14] = bOffset;
					mVertexBuffer[vIdx + 15] = aOffset;

					// v2
					mVertexBuffer[vIdx + 24] = rMultiplier;
					mVertexBuffer[vIdx + 25] = gMultiplier;
					mVertexBuffer[vIdx + 26] = bMultiplier;
					mVertexBuffer[vIdx + 27] = aMultiplier;
					mVertexBuffer[vIdx + 28] = rOffset;
					mVertexBuffer[vIdx + 29] = gOffset;
					mVertexBuffer[vIdx + 30] = bOffset;
					mVertexBuffer[vIdx + 31] = aOffset;

					// v3
					mVertexBuffer[vIdx + 40] = rMultiplier;
					mVertexBuffer[vIdx + 41] = gMultiplier;
					mVertexBuffer[vIdx + 42] = bMultiplier;
					mVertexBuffer[vIdx + 43] = aMultiplier;
					mVertexBuffer[vIdx + 44] = rOffset;
					mVertexBuffer[vIdx + 45] = gOffset;
					mVertexBuffer[vIdx + 46] = bOffset;
					mVertexBuffer[vIdx + 47] = aOffset;

					// v4
					mVertexBuffer[vIdx + 56] = rMultiplier;
					mVertexBuffer[vIdx + 57] = gMultiplier;
					mVertexBuffer[vIdx + 58] = bMultiplier;
					mVertexBuffer[vIdx + 59] = aMultiplier;
					mVertexBuffer[vIdx + 60] = rOffset;
					mVertexBuffer[vIdx + 61] = gOffset;
					mVertexBuffer[vIdx + 62] = bOffset;
					mVertexBuffer[vIdx + 63] = aOffset;

					somethingChanged = true;
				}

				vIdx += numFloatsPerVertex * 4;

				// update static references
				staticIdx = vIdx;
				staticLast = node;

				child.invalidateUV = false;
				child.invalidateMatrix = false;
				child.invalidateClipSpace = false;
				child.invalidateVisibility = false;

				currentUsesUV = currentUsesUV || child.usesUV;
				currentUsesColor = currentUsesColor || child.usesColor || !child.visible;
				currentUsesColorOffset = currentUsesColorOffset || child.usesColorOffset;
			}

			if(somethingChanged) {
				if(!vertexBuffer) {
					vertexBuffer = context.createVertexBuffer(mVertexBuffer.length / numFloatsPerVertex, numFloatsPerVertex);
				}

				// upload changed vertexBuffer
				vertexBuffer.uploadFromVector(mVertexBuffer, 0, mVertexBuffer.length / numFloatsPerVertex);

				if(!indexBuffer) {
					var i:uint = 0;
					var idx:uint = 0;
					var refIdx:uint = 0;

					while(i++ < maxCapacity) {
						mIndexBuffer[idx++] = refIdx;
						mIndexBuffer[idx++] = refIdx + 1;
						mIndexBuffer[idx++] = refIdx + 2;
						mIndexBuffer[idx++] = refIdx + 2;
						mIndexBuffer[idx++] = refIdx + 3;
						mIndexBuffer[idx++] = refIdx;

						refIdx += 4;
					}

					indexBuffer = context.createIndexBuffer(mIndexBuffer.length);
					indexBuffer.uploadFromVector(mIndexBuffer, 0, mIndexBuffer.length);
				}
			}

			if(currentUsesUV != lastUsesUV || currentUsesColor != lastUsesColor || currentUsesColorOffset != lastUsesColorOffset) {
				shaderData = null;
				lastUsesUV = currentUsesUV;
				lastUsesColor = currentUsesColor;
				lastUsesColorOffset = currentUsesColorOffset;
			}

			if(!shaderData) {
				var defines:Array = ["Sprite2DCloud",
					"USE_UV", currentUsesUV,
					"USE_COLOR", currentUsesColor,
					"USE_COLOR_OFFSET", currentUsesColorOffset];

				shaderData = ShaderCache.getShader(context, defines, VERTEX_SHADER, FRAGMENT_SHADER, numFloatsPerVertex, texture);
			}

			context.setProgram(shaderData.shader);

			context.setVertexBufferAt(0, vertexBuffer, 0, Context3DVertexBufferFormat.FLOAT_2); // vertex
			context.setVertexBufferAt(1, vertexBuffer, 2, Context3DVertexBufferFormat.FLOAT_2); // uv
			context.setVertexBufferAt(2, vertexBuffer, 4, Context3DVertexBufferFormat.FLOAT_4); // uvSheet
			context.setVertexBufferAt(3, vertexBuffer, 8, Context3DVertexBufferFormat.FLOAT_4); // colorMultiplier
			context.setVertexBufferAt(4, vertexBuffer, 12, Context3DVertexBufferFormat.FLOAT_4); // colorOffset

			if(worldScrollRect) {
				context.setScissorRectangle(worldScrollRect);
			}

			context.setTextureAt(0, texture.getTexture(context));

			context.setBlendFactors(blendMode.src, blendMode.dst);

			context.setProgramConstantsFromMatrix(Context3DProgramType.VERTEX, 0, camera.getViewProjectionMatrix(false), true);
			context.setProgramConstantsFromMatrix(Context3DProgramType.VERTEX, 4, clipSpaceMatrix, true);

			context.drawTriangles(indexBuffer, 0, childCount << 1);

			Statistics.drawCalls++;
			Statistics.sprites += childCount;
			Statistics.triangles += (childCount << 1);

			context.setTextureAt(0, null);

			context.setVertexBufferAt(0, null);
			context.setVertexBufferAt(1, null);
			context.setVertexBufferAt(2, null);
			context.setVertexBufferAt(3, null);
			context.setVertexBufferAt(4, null);

			context.setScissorRectangle(null);
		}

		override public function handleDeviceLoss():void {
			super.handleDeviceLoss();

			shaderData = null;
			indexBuffer = null;
			vertexBuffer = null;
			texture.texture = null;

			invalidateChilds(childFirst);
		}

		override public function dispose():void {
			super.dispose();

			if(vertexBuffer) {
				vertexBuffer.dispose();
				vertexBuffer = null;
			}

			if(indexBuffer) {
				indexBuffer.dispose();
				indexBuffer = null;
			}

			if(texture) {
				texture.dispose();
				texture = null;
			}

			faceList = null;
			shaderData = null;
			mIndexBuffer = null;
			mVertexBuffer = null;
		}
	}
}

