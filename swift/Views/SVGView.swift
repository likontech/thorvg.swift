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

import SwiftUI

/// A SwiftUI view for displaying SVG images rendered by ThorVG.
///
/// `SVGView` provides a declarative interface for rendering SVG content in SwiftUI.
/// Unlike `LottieView`, SVG is a static format — the image is rendered once and cached.
/// No ViewModel or animation timer is needed.
///
/// ## Basic Usage
///
/// ```swift
/// let svg = try SVG(path: Bundle.main.path(forResource: "tiger", ofType: "svg")!)
/// SVGView(svg: svg)
/// ```
///
/// ## Content Modes
///
/// ```swift
/// SVGView(svg: svg, contentMode: .scaleAspectFill)
///     .frame(width: 200, height: 300)
/// ```
///
/// ## Fixed Render Size
///
/// ```swift
/// SVGView(svg: svg, size: CGSize(width: 512, height: 512))
/// ```
@available(iOS 13.0, macOS 10.15, *)
public struct SVGView: View {

    // MARK: - Properties

    private let svg: SVG
    private let contentMode: SVGContentMode
    private let fixedSize: CGSize?
    private let pixelFormat: PixelFormat

    @State private var renderedImage: CGImage?
    @State private var lastRenderedSize: CGSize = .zero

    // MARK: - Initialization

    /// Creates a new SVG view.
    ///
    /// - Parameters:
    ///   - svg: The SVG object to render.
    ///   - contentMode: How the SVG should be scaled within the view. Defaults to `.scaleAspectFit`.
    ///   - size: An optional fixed rendering size. If `nil`, the view uses its layout size from
    ///           `GeometryReader`. Set this for predictable rendering without layout dependency.
    ///   - pixelFormat: The pixel format for rendering. Defaults to `.argb`.
    public init(
        svg: SVG,
        contentMode: SVGContentMode = .scaleAspectFit,
        size: CGSize? = nil,
        pixelFormat: PixelFormat = .argb
    ) {
        self.svg = svg
        self.contentMode = contentMode
        self.fixedSize = size
        self.pixelFormat = pixelFormat
    }

    // MARK: - Body

    public var body: some View {
        if let fixedSize = fixedSize {
            // Fixed size mode — render immediately
            content(for: fixedSize)
                .frame(width: fixedSize.width, height: fixedSize.height)
        } else {
            // Dynamic size mode — use GeometryReader
            GeometryReader { geometry in
                content(for: geometry.size)
            }
        }
    }

    // MARK: - Content

    @ViewBuilder
    private func content(for size: CGSize) -> some View {
        if let cgImage = renderedImage {
            createImage(from: cgImage)
                .resizable()
                .scaledToFit()
                .onAppear {
                    renderIfNeeded(size: size)
                }
        } else {
            Color.clear
                .onAppear {
                    renderIfNeeded(size: size)
                }
        }
    }

    // MARK: - Rendering

    private func renderIfNeeded(size: CGSize) {
        guard size.width > 0 && size.height > 0 else { return }
        guard size != lastRenderedSize else { return }

        let renderer = SVGRenderer(
            svg,
            size: size,
            pixelFormat: pixelFormat
        )

        do {
            renderedImage = try renderer.render(contentMode: contentMode)
            lastRenderedSize = size
        } catch {
            // Silently fail — renderedImage remains nil, showing Color.clear
        }
    }

    // MARK: - Helper Methods

    /// Creates a SwiftUI Image from a CGImage, handling platform differences.
    private func createImage(from cgImage: CGImage) -> Image {
        #if canImport(UIKit)
        let uiImage = UIImage(
            cgImage: cgImage,
            scale: UIScreen.main.scale,
            orientation: .up
        )
        return Image(uiImage: uiImage)
        #elseif canImport(AppKit)
        let size = NSSize(width: cgImage.width, height: cgImage.height)
        let nsImage = NSImage(cgImage: cgImage, size: size)
        return Image(nsImage: nsImage)
        #endif
    }
}

// MARK: - UIKit View

#if canImport(UIKit)
import UIKit

/// A UIKit view for displaying SVG images rendered by ThorVG.
///
/// `SVGUIKitView` provides a UIKit interface for rendering SVG content.
/// The SVG is rendered once when the view's layout is determined.
///
/// ## Basic Usage
///
/// ```swift
/// let svg = try SVG(path: "tiger.svg")
/// let svgView = SVGUIKitView(svg: svg)
/// view.addSubview(svgView)
/// ```
@available(iOS 13.0, *)
public class SVGUIKitView: UIView {

    // MARK: - Properties

    private let svg: SVG
    private let svgContentMode: SVGContentMode
    private let pixelFormat: PixelFormat
    private let imageView: UIImageView
    private var hasRendered = false

    /// Callback invoked if an error occurs during rendering.
    public var onError: ((SVGRenderingError) -> Void)?

    // MARK: - Initialization

    /// Creates a new SVG UIKit view.
    ///
    /// - Parameters:
    ///   - svg: The SVG object to render.
    ///   - contentMode: How the SVG should be scaled within the view. Defaults to `.scaleAspectFit`.
    ///   - pixelFormat: The pixel format for rendering. Defaults to `.argb`.
    public init(
        svg: SVG,
        contentMode: SVGContentMode = .scaleAspectFit,
        pixelFormat: PixelFormat = .argb
    ) {
        self.svg = svg
        self.svgContentMode = contentMode
        self.pixelFormat = pixelFormat
        self.imageView = UIImageView()

        super.init(frame: .zero)

        setupView()
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented. Use init(svg:contentMode:) instead.")
    }

    // MARK: - Setup

    private func setupView() {
        imageView.contentMode = .scaleAspectFit
        addSubview(imageView)
        imageView.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            imageView.topAnchor.constraint(equalTo: topAnchor),
            imageView.bottomAnchor.constraint(equalTo: bottomAnchor),
            imageView.leadingAnchor.constraint(equalTo: leadingAnchor),
            imageView.trailingAnchor.constraint(equalTo: trailingAnchor)
        ])
    }

    // MARK: - Layout

    public override func layoutSubviews() {
        super.layoutSubviews()

        let size = bounds.size
        guard size.width > 0 && size.height > 0 else { return }
        guard !hasRendered else { return }

        let renderer = SVGRenderer(
            svg,
            size: size,
            pixelFormat: pixelFormat
        )

        do {
            if let cgImage = try renderer.render(contentMode: svgContentMode) {
                let uiImage = UIImage(
                    cgImage: cgImage,
                    scale: UIScreen.main.scale,
                    orientation: .up
                )
                imageView.image = uiImage
                hasRendered = true
            }
        } catch {
            if let svgError = error as? SVGRenderingError {
                onError?(svgError)
            }
        }
    }
}
#endif
