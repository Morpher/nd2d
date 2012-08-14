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

	import flash.events.EventDispatcher;
	import flash.geom.Point;
	import flash.geom.Rectangle;
	import flash.utils.Dictionary;

	public class TextureSheetBase extends EventDispatcher {

		protected var texture:Texture2D;

		public var frames:Vector.<Rectangle>;
		public var offsets:Vector.<Point>;
		public var uvRects:Vector.<Rectangle>;

		public var customData:*;

		public var animationMap:Dictionary = new Dictionary();

		public var frameNames:Array;
		public var frameNameToIndex:Dictionary;

		public function TextureSheetBase() {
		}

		public function get totalFrames():uint {
			return frames.length;
		}

		public function getDimensionForFrame(frameIdx:uint):Rectangle {
			return frames[frameIdx];
		}

		public function getIndexForFrame(name:String):uint {
			return frameNameToIndex[name];
		}

		public function hasFrame(name:String):Boolean {
			return frameNameToIndex[name] != null;
		}

		public function addAnimation(name:String, keyFrames:Array, loop:Boolean = true, fps:int = 1):void {
			// override this
		}

		public function dispose():void {
			texture = null;

			frames = null;
			offsets = null;
			uvRects = null;
			customData = null;

			frameNames = null;
			animationMap = null;
			frameNameToIndex = null;
		}
	}
}
