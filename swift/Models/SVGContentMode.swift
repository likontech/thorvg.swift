/*
 * Copyright (c) 2025 - 2026 ThorVG project. All rights reserved.

 * Permission is hereby granted, free of charge, to any person obtaining a copy
 * of this software and associated documentation files (the "Software"), to deal
 * in the Software without restriction, including without limitation the rights
 * to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
 * copies of the Software, and to permit persons to whom the Software is
 * furnished to do so, subject to the following conditions:

 * The above copyright notice and this permission notice shall be included in all
 * copies or substantial portions of the Software.

 * THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
 * IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
 * FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
 * AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
 * LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
 * OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
 * SOFTWARE.
 */

/// Defines how SVG content should be displayed within the view bounds.
public enum SVGContentMode {
    /// Scale to fit within the view while maintaining aspect ratio.
    ///
    /// The SVG will scale to fit entirely within the rendering size, maintaining its
    /// original aspect ratio. This may result in letterboxing (empty space on sides/top/bottom).
    case scaleAspectFit

    /// Scale to fill the view while maintaining aspect ratio (may crop).
    ///
    /// The SVG will scale to completely fill the rendering size while maintaining its
    /// aspect ratio. Parts of the SVG may be cropped if the aspect ratios don't match.
    case scaleAspectFill

    /// Stretch to fill the view without maintaining aspect ratio.
    ///
    /// The SVG will be stretched to exactly fill the rendering size. The aspect ratio
    /// will not be preserved, which may cause distortion.
    case stretch
}
