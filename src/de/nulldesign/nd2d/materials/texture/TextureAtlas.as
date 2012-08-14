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

package de.nulldesign.nd2d.materials.texture {

	import de.nulldesign.nd2d.materials.texture.parser.ParserBase;
	import de.nulldesign.nd2d.materials.texture.parser.ParserTexturePacker;

	public class TextureAtlas extends TextureSheetBase {

		/**
		 * Parses and holds information of multiple sprites packed into one
		 * texture.
		 *
		 * @param texture
		 * @param parser		ParserTexturePacker(), ParserZwopTex(), ParserSparrow(),
		 * ...
		 * @param distribute	If true, applies this atlas to the texture
		 */
		public function TextureAtlas(texture:Texture2D, parser:ParserBase, distribute:Boolean = true) {
			if(texture) {
				parser.parse(texture);

				frames = parser.frames;
				offsets = parser.offsets;
				uvRects = parser.uvRects;
				customData = parser.customData;

				frameNames = parser.frameNames;
				frameNameToIndex = parser.frameNameToIndex;

				parser.dispose();

				// distribute to texture
				if(distribute) {
					texture.setSheet(this);
				}
			}
		}

		/**
		 * Adds a new animation to this atlas.
		 *
		 * <p>Frame names support wildcards with <code>~~</code> (asterisk) and
		 * <code>?</code> (question mark) to match multiple frames. If more
		 * complexity is required, pass a RegExp() object instead of the
		 * String. Frame order is as defined by XML, no sort is applied.</p>
		 *
		 * <listing>
		 * // integer
		 * atlas.addAnimation("shoot", [4, 5, 6, 5, 6, 7]);
		 *
		 * // string with and without wildcards
		 * atlas.addAnimation("run", ["run*", "walk_end", "walk_stand"]);
		 *
		 * // integer, regexp and string mix
		 * atlas.addAnimation("run", [12, /^run.*$/, "walk_stand"]);
		 * </listing>
		 *
		 * @param name			Animation name
		 * @param keyFrames		Integer, String or RegExp() array - can be mixed
		 * @param loop			If true, the animation will start over when finished
		 * @param fps			Frames per second
		 */
		override public function addAnimation(name:String, keyFrames:Array, loop:Boolean = true, fps:int = 1):void {
			var pattern:RegExp
			var frameName:String;
			var keyFrameIndices:Array = [];

			for each(var keyFrame:* in keyFrames) {
				// String
				if(keyFrame is String) {
					frameName = keyFrame;

					// wildcard match
					if(frameName.indexOf("?") >= 0 || frameName.indexOf("*") >= 0) {
						pattern = new RegExp("^" + frameName.replace(/\^|\$|\\|\.|\+|\(|\)|\[|\]|\||\{|\}/g, "\\$1").replace(/\?/g, ".").replace(/\*/g, ".*") + "$");

						for each(frameName in frameNames) {
							if(frameName.search(pattern) >= 0 && hasFrame(frameName)) {
								keyFrameIndices.push(frameNameToIndex[frameName]);
							}
						}
					} else if(hasFrame(frameName)) {
						keyFrameIndices.push(frameNameToIndex[frameName]);
					}
				}
				// RegExp
				else if(keyFrame is RegExp) {
					pattern = keyFrame;

					for each(frameName in frameNames) {
						if(frameName.search(pattern) >= 0 && hasFrame(frameName)) {
							keyFrameIndices.push(frameNameToIndex[frameName]);
						}
					}
				}
				// anything else, assume Integer
				else {
					keyFrameIndices.push(uint(keyFrame));
				}
			}

			if(keyFrameIndices.length) {
				animationMap[name] = new TextureAnimation(keyFrameIndices, loop, fps);
			}
		}
	}
}
