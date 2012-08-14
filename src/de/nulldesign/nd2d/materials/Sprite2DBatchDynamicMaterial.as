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

package de.nulldesign.nd2d.materials {

	import de.nulldesign.nd2d.display.Node2D;
	import de.nulldesign.nd2d.display.Sprite2D;
	import de.nulldesign.nd2d.geom.Face;
	import de.nulldesign.nd2d.materials.texture.Texture2D;
	import de.nulldesign.nd2d.utils.NodeBlendMode;
	import de.nulldesign.nd2d.utils.Statistics;

	import flash.display3D.Context3D;
	import flash.display3D.Context3DProgramType;
	import flash.display3D.Context3DVertexBufferFormat;

	public class Sprite2DBatchDynamicMaterial extends Sprite2DBatchMaterial {

		private var idx:uint = 0;
		private const constantsGlobal:uint = 4;
		private const constantsPerMatrix:uint = 4;
		private const constantsPerSprite:uint = 4; // colorMultiplier, colorOffset, uvSheet, uvOffsetAndScale

		private var batchLen:uint = 0;
		private const BATCH_SIZE:uint = (126 - constantsGlobal) / (constantsPerMatrix + constantsPerSprite);

		private var programConstants:Vector.<Number> = new Vector.<Number>(4 * constantsPerSprite * BATCH_SIZE, true);

		private var needInit:Boolean = true;

		private var lastTexture:Texture2D;
		private var currentTexture:Texture2D;

		private var lastBlendMode:NodeBlendMode;
		private var currentBlendMode:NodeBlendMode;

		public function Sprite2DBatchDynamicMaterial() {
			super();
		}

		override protected function prepareForRender(context:Context3D):void {
			super.prepareForRender(context);

			needInit = false;
		}

		override public function renderBatch(context:Context3D, faceList:Vector.<Face>, childList:Node2D):void {
			if(!childList) {
				return;
			}

			batchLen = 0;

			usesUV = childList.usesUV;
			usesColor = usesColor || childList.usesColor;
			usesColorOffset = usesColorOffset || childList.usesColorOffset;

			currentTexture = lastTexture = texture;
			currentBlendMode = lastBlendMode = blendMode;

			generateBufferData(context, faceList);
			prepareForRender(context);

			processAndRenderNodes(context, childList);

			drawCurrentBatch(context);

			clearAfterRender(context);
		}

		override protected function drawCurrentBatch(context:Context3D):void {
			if(batchLen) {
				context.setProgramConstantsFromVector(Context3DProgramType.VERTEX,
					constantsGlobal + BATCH_SIZE * constantsPerMatrix, programConstants, batchLen * constantsPerSprite);

				context.drawTriangles(indexBuffer, 0, batchLen << 1);

				Statistics.drawCalls++;
				Statistics.triangles += (batchLen << 1);
			}

			idx = 0;
			batchLen = 0;
		}

		override protected function processAndRenderNodes(context:Context3D, childList:Node2D):void {
			if(!childList) {
				return;
			}

			var child:Sprite2D;
			var childNode:Node2D;

			for(childNode = childList; childNode; childNode = childNode.next) {
				if(!childNode.visible) {
					continue;
				}

				childNode.step(elapsed);

				if(childNode.invalidateUV) {
					childNode.updateUV();
				}

				if(childNode.invalidateColors) {
					childNode.updateColors();
				}

				if(childNode.invalidateMatrix || childNode.parent.invalidateMatrix) {
					if(childNode.invalidateMatrix) {
						childNode.updateLocalMatrix();
					}

					childNode.updateWorldMatrix();
					childNode.invalidateMatrix = true;
				} else if(childNode.invalidateClipSpace) {
					childNode.updateClipSpace();
				}

				if(childNode.useFrustumCulling && childNode.invalidateCullingCount != camera.invalidateCount) {
					childNode.updateCulling();
				}

				child = childNode as Sprite2D;

				if(child) {
					if(!child.culled) {
						// we can only batch Sprite2DMaterial as we don't know about the changes of derivates
						if(!child.material || Object(child.material).constructor == Sprite2DMaterial) {
							usesUV = child.usesUV;
							usesColor = child.usesColor;
							usesColorOffset = child.usesColorOffset;

							currentTexture = child.texture;
							currentBlendMode = child.blendMode;

							if(needInit) {
								prepareForRender(context);
							} else {
								updateProgram(context);
							}

							context.setProgramConstantsFromMatrix(Context3DProgramType.VERTEX,
								constantsGlobal + batchLen * constantsPerMatrix, child.clipSpaceMatrix, true);

							programConstants[idx++] = child.combinedColorTransform.redMultiplier;
							programConstants[idx++] = child.combinedColorTransform.greenMultiplier;
							programConstants[idx++] = child.combinedColorTransform.blueMultiplier;
							programConstants[idx++] = child.combinedColorTransform.alphaMultiplier;

							programConstants[idx++] = child.combinedColorTransform.redOffset;
							programConstants[idx++] = child.combinedColorTransform.greenOffset;
							programConstants[idx++] = child.combinedColorTransform.blueOffset;
							programConstants[idx++] = child.combinedColorTransform.alphaOffset;

							programConstants[idx++] = child.animation.frameUV.x;
							programConstants[idx++] = child.animation.frameUV.y;
							programConstants[idx++] = child.animation.frameUV.width;
							programConstants[idx++] = child.animation.frameUV.height;

							programConstants[idx++] = child.uvOffsetX;
							programConstants[idx++] = child.uvOffsetY;
							programConstants[idx++] = child.uvScaleX;
							programConstants[idx++] = child.uvScaleY;

							batchLen++;

							Statistics.sprites++;

							if(batchLen == BATCH_SIZE) {
								drawCurrentBatch(context);
							}
						}
						// custom material, mask, blur, etc.
						else {
							drawCurrentBatch(context);

							if(!needInit) {
								clearAfterRender(context);
							}

							child.draw(context, camera);

							needInit = true;
						}
					} else {
						Statistics.spritesCulled++;
					}
				}

				processAndRenderNodes(context, childNode.childFirst);

				childNode.invalidateMatrix = false;
			}
		}

		override protected function updateProgram(context:Context3D):void {
			if(currentTexture != lastTexture || currentBlendMode != lastBlendMode || usesUV != lastUsesUV || usesColor != lastUsesColor || usesColorOffset != lastUsesColorOffset) {
				drawCurrentBatch(context);

				if(usesUV != lastUsesUV || usesColor != lastUsesColor || usesColorOffset != lastUsesColorOffset) {
					shaderData = null;
					initProgram(context);

					if(!needInit) {
						context.setProgram(shaderData.shader);
					}

					lastUsesUV = usesUV;
					lastUsesColor = usesColor;
					lastUsesColorOffset = usesColorOffset;
				}

				if(currentTexture != lastTexture) {
					if(!needInit) {
						context.setTextureAt(0, currentTexture.getTexture(context));
					}

					lastTexture = currentTexture;
				}

				if(currentBlendMode != lastBlendMode) {
					if(!needInit) {
						context.setBlendFactors(currentBlendMode.src, currentBlendMode.dst);
					}

					lastBlendMode = currentBlendMode;
				}
			}
		}

		override public function dispose():void {
			super.dispose();

			programConstants = null;
		}
	}
}
