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

package de.nulldesign.nd2d.materials.texture.parser {

	import de.nulldesign.nd2d.materials.texture.Texture2D;

	import flash.geom.Point;
	import flash.geom.Rectangle;

	public class ParserTexturePacker extends ParserBase {

		public var xmlData:XML;

		public function ParserTexturePacker(xmlData:XML) {
			this.xmlData = xmlData;
		}

		override public function parse(texture:Texture2D):void {
			var metadata:XML = getDict("metadata", xmlData);

			if(!metadata) {
				throw new Error("Unrecognised XML Format");
			}

			var format:String = getValueFromDict("format", metadata);

			switch(format) {
				case "0":  {
					throw new Error("cocos2d-original Format is not supported. Try cocos2d or cocos2d-0.99.4 instead");
					break;
				}
				case "1":
				case "2":  {
					parseCocos2DDefault(texture, xmlData);
					break;
				}
				default:  {
					throw new Error("Unrecognised XML Format");
					break;
				}
			}
		}

		protected function parseCocos2DDefault(texture:Texture2D, cocos2DXML:XML):void {
			var type:String;
			var data:String;
			var array:Array;

			var topKeys:XMLList = cocos2DXML.dict.key;
			var topDicts:XMLList = cocos2DXML.dict.dict;

			for(var k:uint = 0; k < topKeys.length(); k++) {
				switch(topKeys[k].toString()) {
					case "frames":  {
						var frameKeys:XMLList = topDicts[k].key;
						var frameDicts:XMLList = topDicts[k].dict;

						for(var l:uint = 0; l < frameKeys.length(); l++) {
							var keyName:String = frameKeys[l];
							var propKeys:XMLList = frameDicts[l].key;
							var propAll:XMLList = frameDicts[l].*;

							frameNames.push(keyName);
							frameNameToIndex[keyName] = l;

							for(var m:uint = 0; m < propKeys.length(); m++) {
								var i:uint = propKeys[m].childIndex() + 1;

								data = propAll[i];
								type = propAll[i].name();

								switch(propKeys[m].toString()) {
									case "frame":  {
										if(type == "string") {
											array = data.split(/[^0-9-]+/);
											frames.push(new Rectangle(array[1], array[2], array[3], array[4]));

											uvRects.push(new Rectangle(
												array[1] / texture.textureWidth,
												array[2] / texture.textureHeight,
												array[3] / texture.textureWidth,
												array[4] / texture.textureHeight));
										} else {
											throw new Error("Error parsing descriptor format");
										}

										break;
									}
									case "offset":  {
										if(type == "string") {
											array = data.split(/[^0-9-]+/);
											// our coordinate system is different than the cocos one
											offsets.push(new Point(array[1], -array[2]));
										} else {
											throw new Error("Error parsing descriptor format");
										}

										break;
									}
									case "rotated":  {
										if(type != "false") {
											throw new Error("Rotated elements not supported (yet)");
										}

										break;
									}
								}
							}
						}

						break;
					}
				}
			}
		}

		override public function dispose():void {
			xmlData = null;

			super.dispose();
		}
	}
}
