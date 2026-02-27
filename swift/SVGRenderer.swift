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

/// Object responsible for rendering an SVG image using ThorVG.
///
/// `SVGRenderer` manages the rendering pipeline: it holds a pixel buffer, a ThorVG canvas,
/// and produces a `CGImage` from the rendered SVG content. Unlike `LottieRenderer`, SVG
/// rendering is a single-shot operation — no frame loop is needed.
///
/// ## Basic Usage
///
/// ```swift
/// let svg = try SVG(path: "tiger.svg")
/// var buffer = [UInt32](repeating: 0, count: 512 * 512)
/// let renderer = SVGRenderer(svg, size: CGSize(width: 512, height: 512), buffer: &buffer)
/// let image = try renderer.render(contentMode: .scaleAspectFit)
/// ```
public class SVGRenderer {
    private let svg: SVG
    private let canvas: Canvas
    private let size: CGSize
    private let pixelFormat: PixelFormat
    private var buffer: [UInt32]
    private var cgContext: CGContext?

    /// Initializes the SVGRenderer with an SVG object, rendering size, and configuration.
    ///
    /// - Parameters:
    ///   - svg: The `SVG` object containing the image to render.
    ///   - engine: An optional `Engine` object to use. Defaults to `.main`.
    ///   - size: The size of the rendering canvas.
    ///   - pixelFormat: The pixel format for rendering. Defaults to `.argb`.
    public init(
        _ svg: SVG,
        engine: Engine = .main,
        size: CGSize,
        pixelFormat: PixelFormat = .argb
    ) {
        self.svg = svg
        self.size = size
        self.pixelFormat = pixelFormat

        self.buffer = [UInt32](repeating: 0, count: Int(size.width * size.height))
        self.canvas = Canvas(
            size: size,
            buffer: &self.buffer,
            stride: Int(size.width),
            pixelFormat: pixelFormat
        )

        svg.picture.resize(size)
        canvas.push(picture: svg.picture)
    }

    /// Renders the SVG with the specified content rect and returns the resulting image.
    ///
    /// The content rect defines which portion of the SVG to render and how it maps
    /// to the canvas. Use `render(contentMode:)` for automatic content rect calculation.
    ///
    /// - Parameter contentRect: The area of the SVG content to render.
    /// - Returns: The rendered image, or `nil` if image creation fails.
    /// - Throws: `SVGRenderingError` if rendering fails.
    public func render(contentRect: CGRect) throws -> CGImage? {
        let svgSize = svg.size

        // Build the transform: translate to content rect origin, then scale
        let transform =
            CGAffineTransform(
                translationX: -contentRect.minX,
                y: -contentRect.minY
            )
            .concatenating(
                CGAffineTransform(
                    scaleX: svgSize.width / contentRect.width,
                    y: svgSize.height / contentRect.height
                )
            )

        svg.picture.setTransform(transform)

        // Clear buffer before rendering
        buffer.withUnsafeMutableBufferPointer { ptr in
            ptr.baseAddress?.initialize(repeating: 0, count: ptr.count)
        }

        canvas.update()

        do {
            try canvas.draw()
        } catch {
            throw SVGRenderingError.failedToDrawFrame
        }

        // Lazy initialize CGContext on first render
        if cgContext == nil {
            guard let context = CGContext.create(
                buffer: &self.buffer,
                size: self.size,
                pixelFormat: pixelFormat
            ) else {
                throw SVGRenderingError.contextCreationFailed
            }
            self.cgContext = context
        }

        guard let cgImage = cgContext?.makeImage() else {
            throw SVGRenderingError.imageCreationFailed
        }

        return cgImage
    }

    /// Renders the SVG with the specified content mode and returns the resulting image.
    ///
    /// This convenience method automatically calculates the content rect based on the
    /// SVG's intrinsic size and the requested content mode.
    ///
    /// - Parameter contentMode: How the SVG should be scaled within the canvas.
    /// - Returns: The rendered image, or `nil` if image creation fails.
    /// - Throws: `SVGRenderingError` if rendering fails.
    public func render(contentMode: SVGContentMode) throws -> CGImage? {
        let contentRect = calculateContentRect(contentMode: contentMode)
        return try render(contentRect: contentRect)
    }

    /// Calculates the content rect for the given content mode.
    private func calculateContentRect(contentMode: SVGContentMode) -> CGRect {
        let svgSize = svg.size

        switch contentMode {
        case .scaleAspectFit:
            return CGRect(origin: .zero, size: svgSize)

        case .scaleAspectFill:
            let viewAspect = size.width / size.height
            let svgAspect = svgSize.width / svgSize.height

            if svgAspect > viewAspect {
                // SVG is wider — crop sides
                let newWidth = svgSize.height * viewAspect
                let x = (svgSize.width - newWidth) / 2
                return CGRect(x: x, y: 0, width: newWidth, height: svgSize.height)
            } else {
                // SVG is taller — crop top/bottom
                let newHeight = svgSize.width / viewAspect
                let y = (svgSize.height - newHeight) / 2
                return CGRect(x: 0, y: y, width: svgSize.width, height: newHeight)
            }

        case .stretch:
            return CGRect(origin: .zero, size: svgSize)
        }
    }
}
