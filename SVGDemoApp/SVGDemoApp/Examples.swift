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
import ThorVGSwift
import UIKit

// MARK: - SVG File Example

struct SVGFileExample: View {
    var body: some View {
        VStack(spacing: 20) {
            SVGFileView()

            Text("From Bundle File")
                .font(.headline)
            Text("Loads tiger.svg from the app bundle using SVG(path:)")
                .font(.caption)
                .foregroundColor(.secondary)
                .multilineTextAlignment(.center)
        }
        .padding()
        .navigationTitle("Bundle File")
    }
}

private struct SVGFileView: View {
    @State private var svg: SVG?

    var body: some View {
        Group {
            if let svg = svg {
                SVGView(svg: svg, contentMode: .scaleAspectFit)
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
            } else {
                Text("Failed to load SVG")
                    .foregroundColor(.red)
            }
        }
        .onAppear {
            loadSVG()
        }
    }

    private func loadSVG() {
        guard let path = Bundle.main.path(forResource: "tiger", ofType: "svg") else {
            return
        }
        svg = try? SVG(path: path)
    }
}

// MARK: - SVG String Example

struct SVGStringExample: View {
    var body: some View {
        VStack(spacing: 20) {
            SVGStringView()

            Text("From SVG String")
                .font(.headline)
            Text("Renders an inline SVG XML string using SVG(string:)")
                .font(.caption)
                .foregroundColor(.secondary)
                .multilineTextAlignment(.center)
        }
        .padding()
        .navigationTitle("SVG String")
    }
}

private struct SVGStringView: View {
    @State private var svg: SVG?

    private let svgString = """
    <svg xmlns="http://www.w3.org/2000/svg" viewBox="0 0 200 200">
      <defs>
        <linearGradient id="grad" x1="0%" y1="0%" x2="100%" y2="100%">
          <stop offset="0%" style="stop-color:#FF6B6B;stop-opacity:1" />
          <stop offset="50%" style="stop-color:#4ECDC4;stop-opacity:1" />
          <stop offset="100%" style="stop-color:#45B7D1;stop-opacity:1" />
        </linearGradient>
      </defs>
      <rect x="10" y="10" width="180" height="180" rx="20" fill="url(#grad)" />
      <circle cx="70" cy="80" r="15" fill="white" opacity="0.9" />
      <circle cx="130" cy="80" r="15" fill="white" opacity="0.9" />
      <path d="M 60 130 Q 100 170 140 130" stroke="white" stroke-width="4" fill="none" stroke-linecap="round" />
      <text x="100" y="185" text-anchor="middle" font-size="12" fill="#666">ThorVG SVG Demo</text>
    </svg>
    """

    var body: some View {
        Group {
            if let svg = svg {
                SVGView(svg: svg, contentMode: .scaleAspectFit)
                    .frame(width: 300, height: 300)
            } else {
                Text("Failed to render SVG string")
                    .foregroundColor(.red)
            }
        }
        .onAppear {
            svg = try? SVG(string: svgString)
        }
    }
}

// MARK: - Content Modes Example

struct SVGContentModesExample: View {
    var body: some View {
        ScrollView {
            VStack(spacing: 32) {
                SVGContentModeView(
                    title: "Scale Aspect Fit",
                    description: "Shows full SVG, maintains aspect ratio",
                    contentMode: .scaleAspectFit,
                    frameWidth: 300,
                    frameHeight: 150,
                    borderColor: .green
                )

                SVGContentModeView(
                    title: "Scale Aspect Fill",
                    description: "Fills the frame, may crop edges",
                    contentMode: .scaleAspectFill,
                    frameWidth: 300,
                    frameHeight: 150,
                    borderColor: .blue
                )

                SVGContentModeView(
                    title: "Stretch",
                    description: "Stretches to fill, distorts aspect ratio",
                    contentMode: .stretch,
                    frameWidth: 300,
                    frameHeight: 150,
                    borderColor: .orange
                )
            }
            .padding()
        }
        .navigationTitle("Content Modes")
    }
}

private struct SVGContentModeView: View {
    let title: String
    let description: String
    let contentMode: SVGContentMode
    let frameWidth: CGFloat
    let frameHeight: CGFloat
    let borderColor: Color

    @State private var svg: SVG?

    var body: some View {
        VStack(spacing: 8) {
            Text(title)
                .font(.headline)
            Text(description)
                .font(.caption)
                .foregroundColor(.secondary)

            if let svg = svg {
                SVGView(
                    svg: svg,
                    contentMode: contentMode,
                    size: CGSize(width: frameWidth, height: frameHeight)
                )
                .frame(width: frameWidth, height: frameHeight)
                .background(borderColor.opacity(0.1))
                .border(borderColor, width: 2)
            } else {
                Rectangle()
                    .fill(Color.gray.opacity(0.2))
                    .frame(width: frameWidth, height: frameHeight)
                    .overlay(Text("Loading...").foregroundColor(.secondary))
            }
        }
        .onAppear {
            guard let path = Bundle.main.path(forResource: "tiger", ofType: "svg") else { return }
            svg = try? SVG(path: path)
        }
    }
}

// MARK: - UIKit Integration Example

struct SVGUIKitExample: View {
    @State private var svg: SVG?

    var body: some View {
        VStack(spacing: 20) {
            Text("SVGUIKitView in SwiftUI")
                .font(.headline)

            Text("Demonstrates UIKit integration using UIViewRepresentable")
                .font(.caption)
                .foregroundColor(.secondary)
                .multilineTextAlignment(.center)

            if let svg = svg {
                SVGUIKitViewWrapper(svg: svg)
                    .frame(maxWidth: .infinity)
                    .frame(height: 300)
                    .background(Color.gray.opacity(0.1))
                    .cornerRadius(12)
            } else {
                Text("Failed to load SVG")
                    .foregroundColor(.red)
            }

            VStack(alignment: .leading, spacing: 8) {
                if let svg = svg {
                    HStack {
                        Text("Intrinsic Size:")
                            .fontWeight(.medium)
                        Text("\(Int(svg.size.width)) x \(Int(svg.size.height))")
                            .foregroundColor(.secondary)
                        Spacer()
                    }
                }
            }
            .padding()
            .background(Color.secondary.opacity(0.1))
            .cornerRadius(8)

            Spacer()
        }
        .padding()
        .navigationTitle("UIKit View")
        .onAppear {
            guard let path = Bundle.main.path(forResource: "tiger", ofType: "svg") else { return }
            svg = try? SVG(path: path)
        }
    }
}

// MARK: - UIViewRepresentable Wrapper

struct SVGUIKitViewWrapper: UIViewRepresentable {
    let svg: SVG

    func makeUIView(context: Context) -> SVGUIKitView {
        let view = SVGUIKitView(svg: svg, contentMode: .scaleAspectFit)
        return view
    }

    func updateUIView(_ uiView: SVGUIKitView, context: Context) {
        // Static content — no updates needed
    }
}
