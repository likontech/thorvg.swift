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

import CoreGraphics
import Foundation

/// Object used to load and query SVG images.
///
/// `SVG` wraps a ThorVG `Picture` for loading SVG content from various sources.
/// Unlike `Lottie`, SVG is a static image format and does not require an `Animation` object.
///
/// ## Basic Usage
///
/// ```swift
/// // Load from a file path
/// let svg = try SVG(path: Bundle.main.path(forResource: "tiger", ofType: "svg")!)
///
/// // Load from an SVG string
/// let svg = try SVG(string: "<svg>...</svg>")
///
/// // Load from Data
/// let svg = try SVG(data: svgData)
/// ```
public class SVG {
    /// The internal picture object used for rendering.
    let picture: Picture

    /// The intrinsic size of the SVG content (from viewBox/width/height).
    public var size: CGSize {
        picture.getSize()
    }

    /// Creates an `SVG` instance from a file path.
    ///
    /// - Parameter path: The file path of the SVG file to load.
    /// - Throws: `SVGRenderingError.failedToLoadFromPath` if loading fails.
    public convenience init(path: String) throws {
        let picture = Picture()
        do {
            try picture.load(fromPath: path)
        } catch {
            throw SVGRenderingError.failedToLoadFromPath
        }
        self.init(picture: picture)
    }

    /// Creates an `SVG` instance from an SVG XML string.
    ///
    /// - Parameter string: The SVG XML string to render.
    /// - Throws: `SVGRenderingError.failedToLoadFromDataString` if loading fails.
    public convenience init(string: String) throws {
        let picture = Picture()
        do {
            try picture.load(fromString: string, mimeType: .svgXml)
        } catch {
            throw SVGRenderingError.failedToLoadFromDataString
        }
        self.init(picture: picture)
    }

    /// Creates an `SVG` instance from raw SVG data.
    ///
    /// - Parameter data: The raw SVG data to render.
    /// - Throws: `SVGRenderingError.failedToLoadFromDataString` if loading fails.
    public convenience init(data: Data) throws {
        let picture = Picture()
        let string = String(data: data, encoding: .utf8) ?? ""
        guard !string.isEmpty else {
            throw SVGRenderingError.failedToLoadFromDataString
        }
        do {
            try picture.load(fromString: string, mimeType: .svg)
        } catch {
            throw SVGRenderingError.failedToLoadFromDataString
        }
        self.init(picture: picture)
    }

    /// Internal initializer with a pre-loaded picture.
    init(picture: Picture) {
        self.picture = picture
    }
}
