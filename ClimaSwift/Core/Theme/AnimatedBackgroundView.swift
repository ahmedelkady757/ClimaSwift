//
//  AnimatedBackgroundView.swift
//  ClimaSwift
//
//  Refactored: full pure-SwiftUI animated sky.
//  Morning → layered dawn/day sky gradient, animated sun with corona rays,
//             procedural clouds drifting L→R, birds flapping across the screen.
//  Evening → deep indigo/navy gradient, crescent moon with glow,
//             twinkling stars (warm amber/gold tones), shooting stars.
//  Text contrast: morning uses deep navy text; evening uses warm white text.
//  No Lottie dependency required.
//

import SwiftUI

// MARK: - Main View

struct AnimatedBackgroundView: View {
    let theme: ThemeType
    @State private var appeared = false

    var body: some View {
        ZStack {
            if theme == .morning {
                MorningSkyView(appeared: appeared)
                    .transition(.opacity)
            } else {
                EveningSkyView(appeared: appeared)
                    .transition(.opacity)
            }
        }
        .ignoresSafeArea()
        .animation(.easeInOut(duration: 1.4), value: theme)
        .onAppear { appeared = true }
    }
}

// MARK: - Morning Sky

struct MorningSkyView: View {
    let appeared: Bool

    // Sky gradient animates between warm sunrise and bright midday
    @State private var skyShift: CGFloat = 0

    var body: some View {
        ZStack {
            // ── Sky gradient ──────────────────────────────────────
            LinearGradient(
                stops: [
                    .init(color: Color(hex: "FFD580"), location: 0.0 + skyShift * 0.05),
                    .init(color: Color(hex: "FFA04A"), location: 0.15 + skyShift * 0.03),
                    .init(color: Color(hex: "6EC6F5"), location: 0.4),
                    .init(color: Color(hex: "2196F3"), location: 1.0),
                ],
                startPoint: .top,
                endPoint: .bottom
            )
            .ignoresSafeArea()
            .onAppear {
                withAnimation(.easeInOut(duration: 12).repeatForever(autoreverses: true)) {
                    skyShift = 1
                }
            }

            // ── Sun ───────────────────────────────────────────────
            SunView()

            // ── Clouds ────────────────────────────────────────────
            ForEach(0..<4, id: \.self) { i in
                CloudView(index: i)
            }

            // ── Birds ─────────────────────────────────────────────
            ForEach(0..<5, id: \.self) { i in
                BirdView(index: i)
            }
        }
    }
}

// MARK: - Evening Sky

struct EveningSkyView: View {
    let appeared: Bool
    @State private var glowPulse: CGFloat = 0.6

    var body: some View {
        ZStack {
            // ── Sky gradient ──────────────────────────────────────
            LinearGradient(
                stops: [
                    .init(color: Color(hex: "0A0E1A"), location: 0.0),
                    .init(color: Color(hex: "0D1B3E"), location: 0.35),
                    .init(color: Color(hex: "1A1060"), location: 0.65),
                    .init(color: Color(hex: "2D1B4E"), location: 1.0),
                ],
                startPoint: .top,
                endPoint: .bottom
            )
            .ignoresSafeArea()

            // ── Stars ─────────────────────────────────────────────
            StarsView()

            // ── Shooting stars ────────────────────────────────────
            ForEach(0..<3, id: \.self) { i in
                ShootingStarView(index: i)
            }

            // ── Moon ──────────────────────────────────────────────
            MoonView()
        }
    }
}

// MARK: - Sun

private struct SunView: View {
    @State private var scale: CGFloat = 1.0
    @State private var rayRotation: Double = 0

    private let screenW = UIScreen.main.bounds.width
    private let screenH = UIScreen.main.bounds.height

    var body: some View {
        ZStack {
            // Outer glow
            Circle()
                .fill(
                    RadialGradient(
                        colors: [Color(hex: "FFE066").opacity(0.55), .clear],
                        center: .center,
                        startRadius: 60,
                        endRadius: 130
                    )
                )
                .frame(width: 260, height: 260)
                .scaleEffect(scale)

            // Corona rays
            ForEach(0..<12, id: \.self) { i in
                Capsule()
                    .fill(Color(hex: "FFE066").opacity(0.3))
                    .frame(width: 3, height: 55)
                    .offset(y: -90)
                    .rotationEffect(.degrees(Double(i) * 30 + rayRotation))
            }

            // Sun body
            Circle()
                .fill(
                    RadialGradient(
                        colors: [Color(hex: "FFF8A0"), Color(hex: "FFD700"), Color(hex: "FFA500")],
                        center: .center,
                        startRadius: 5,
                        endRadius: 55
                    )
                )
                .frame(width: 110, height: 110)
                .shadow(color: Color(hex: "FFD700").opacity(0.8), radius: 30)
                .scaleEffect(scale)
        }
        .offset(x: screenW * 0.28, y: -screenH * 0.28)
        .onAppear {
            withAnimation(.easeInOut(duration: 3.5).repeatForever(autoreverses: true)) { scale = 1.08 }
            withAnimation(.linear(duration: 40).repeatForever(autoreverses: false)) { rayRotation = 360 }
        }
    }
}

// MARK: - Cloud

private struct CloudView: View {
    let index: Int
    @State private var offsetX: CGFloat = 0

    private let screenW = UIScreen.main.bounds.width
    private let screenH = UIScreen.main.bounds.height

    private var startX: CGFloat { -screenW * 0.6 - CGFloat(index) * 80 }
    private var yFrac: CGFloat { [0.08, 0.16, 0.22, 0.30][index % 4] }
    private var scale: CGFloat { [0.9, 1.15, 0.75, 1.0][index % 4] }
    private var speed: Double { [28.0, 38.0, 22.0, 45.0][index % 4] }
    private var opacity: Double { [0.88, 0.72, 0.80, 0.65][index % 4] }

    var body: some View {
        CloudShape()
            .fill(Color.white.opacity(opacity))
            .frame(width: 160, height: 60)
            .scaleEffect(scale)
            .offset(x: startX + offsetX, y: screenH * yFrac - screenH * 0.5)
            .onAppear {
                offsetX = 0
                let total = screenW * 1.6 + 200
                withAnimation(.linear(duration: speed).repeatForever(autoreverses: false)) {
                    offsetX = total
                }
            }
    }
}

private struct CloudShape: Shape {
    func path(in rect: CGRect) -> Path {
        var path = Path()
        let w = rect.width, h = rect.height
        // Main body
        path.addEllipse(in: CGRect(x: w * 0.1, y: h * 0.3, width: w * 0.65, height: h * 0.65))
        // Left puff
        path.addEllipse(in: CGRect(x: 0, y: h * 0.45, width: w * 0.35, height: h * 0.50))
        // Right puff
        path.addEllipse(in: CGRect(x: w * 0.6, y: h * 0.45, width: w * 0.40, height: h * 0.50))
        // Top center puff
        path.addEllipse(in: CGRect(x: w * 0.28, y: 0, width: w * 0.42, height: h * 0.62))
        return path
    }
}

// MARK: - Bird

private struct BirdView: View {
    let index: Int

    @State private var offsetX: CGFloat = 0
    @State private var wingPhase: Double = 0   // drives flap

    private let screenW = UIScreen.main.bounds.width
    private let screenH = UIScreen.main.bounds.height

    private var startY: CGFloat { screenH * [-0.30, -0.20, -0.35, -0.25, -0.18][index % 5] }
    private var yOffset: CGFloat { CGFloat([-30, 20, -50, 10, -15][index % 5]) }
    private var scale: CGFloat { [0.7, 1.0, 0.55, 0.85, 0.65][index % 5] }
    private var speed: Double { [14.0, 18.0, 12.0, 20.0, 16.0][index % 5] }
    private var delay: Double { Double(index) * 3.2 }

    var body: some View {
        BirdShape(wingPhase: wingPhase)
            .stroke(Color(hex: "1A2A4A").opacity(0.75), style: StrokeStyle(lineWidth: 1.8, lineCap: .round))
            .frame(width: 44, height: 24)
            .scaleEffect(scale)
            .offset(x: -screenW * 0.65 + offsetX, y: startY + yOffset)
            .onAppear {
                // Flap wings continuously
                withAnimation(.easeInOut(duration: 0.55).repeatForever(autoreverses: true)) {
                    wingPhase = 1
                }
                // Fly across
                DispatchQueue.main.asyncAfter(deadline: .now() + delay) {
                    withAnimation(.linear(duration: speed).repeatForever(autoreverses: false)) {
                        offsetX = screenW * 1.6
                    }
                }
            }
    }
}

private struct BirdShape: Shape {
    var wingPhase: Double   // 0 = wings level, 1 = wings dipped

    var animatableData: Double { get { wingPhase } set { wingPhase = newValue } }

    func path(in rect: CGRect) -> Path {
        var path = Path()
        let cx = rect.midX, cy = rect.midY
        let dip = CGFloat(wingPhase) * 6   // wing-tip dip in points

        // Left wing arc
        path.move(to: CGPoint(x: cx, y: cy))
        path.addQuadCurve(
            to: CGPoint(x: cx - 18, y: cy - 4 + dip),
            control: CGPoint(x: cx - 9, y: cy - 8 + dip * 0.5)
        )
        // Right wing arc
        path.move(to: CGPoint(x: cx, y: cy))
        path.addQuadCurve(
            to: CGPoint(x: cx + 18, y: cy - 4 + dip),
            control: CGPoint(x: cx + 9, y: cy - 8 + dip * 0.5)
        )
        return path
    }
}

// MARK: - Moon

private struct MoonView: View {
    @State private var glowScale: CGFloat = 1.0

    private let screenW = UIScreen.main.bounds.width
    private let screenH = UIScreen.main.bounds.height

    var body: some View {
        ZStack {
            // Outer glow
            Circle()
                .fill(
                    RadialGradient(
                        colors: [Color(hex: "FFF4C2").opacity(0.22), .clear],
                        center: .center,
                        startRadius: 50,
                        endRadius: 110
                    )
                )
                .frame(width: 220, height: 220)
                .scaleEffect(glowScale)

            // Moon base circle
            Circle()
                .fill(Color(hex: "FFF8DC"))
                .frame(width: 105, height: 105)
                .shadow(color: Color(hex: "FFE88A").opacity(0.5), radius: 22)

            // Crescent mask — offset circle cuts the moon
            Circle()
                .fill(Color(hex: "0D1B3E"))   // matches sky background
                .frame(width: 88, height: 88)
                .offset(x: 28, y: -10)

            // Subtle crater dots
            Group {
                Circle().fill(Color(hex: "EEE4B0").opacity(0.6)).frame(width: 9, height: 9).offset(x: -20, y: -18)
                Circle().fill(Color(hex: "EEE4B0").opacity(0.4)).frame(width: 6, height: 6).offset(x: -32, y: 8)
                Circle().fill(Color(hex: "EEE4B0").opacity(0.3)).frame(width: 5, height: 5).offset(x: -14, y: 28)
            }
        }
        .offset(x: screenW * 0.26, y: -screenH * 0.30)
        .onAppear {
            withAnimation(.easeInOut(duration: 4.0).repeatForever(autoreverses: true)) {
                glowScale = 1.12
            }
        }
    }
}

// MARK: - Stars

private struct StarsView: View {
    // Fixed seed-based star data so positions are stable (no random on each redraw)
    private let stars: [StarData] = (0..<70).map { i -> StarData in
        let seed = UInt64(i &* 6364136223846793005 &+ 1442695040888963407)
        func rng(_ s: UInt64) -> Double { Double(s >> 33) / Double(1 << 31) }
        let x = rng(seed) * UIScreen.main.bounds.width
        let y = rng(seed &* 2) * UIScreen.main.bounds.height * 0.72
        let r = rng(seed &* 3) * 2.2 + 0.8
        // Warm amber/gold/white tones for stars
        let colorIdx = Int(seed % 3)
        let dur = rng(seed &* 4) * 2.5 + 1.0
        return StarData(x: x, y: y, radius: r, colorIndex: colorIdx, duration: dur)
    }

    var body: some View {
        ZStack {
            ForEach(stars.indices, id: \.self) { i in
                TwinklingStar(data: stars[i])
            }
        }
        .ignoresSafeArea()
    }
}

private struct StarData {
    let x: CGFloat
    let y: CGFloat
    let radius: CGFloat
    let colorIndex: Int   // 0=warm white, 1=gold, 2=amber
    let duration: Double
}

private struct TwinklingStar: View {
    let data: StarData
    @State private var opacity: Double = 0.2

    private let colors: [Color] = [
        Color(hex: "FFF9F0"),   // warm white
        Color(hex: "FFD966"),   // gold
        Color(hex: "FFB347"),   // amber/orange
    ]

    var body: some View {
        Circle()
            .fill(colors[data.colorIndex])
            .frame(width: data.radius * 2, height: data.radius * 2)
            .opacity(opacity)
            .position(x: data.x, y: data.y)
            .onAppear {
                withAnimation(
                    .easeInOut(duration: data.duration)
                    .repeatForever(autoreverses: true)
                    .delay(data.duration * 0.4)
                ) {
                    opacity = 0.95
                }
            }
    }
}

// MARK: - Shooting Star

private struct ShootingStarView: View {
    let index: Int
    @State private var active = false
    @State private var progress: CGFloat = 0

    private let screenW = UIScreen.main.bounds.width
    private let screenH = UIScreen.main.bounds.height

    private var startX: CGFloat { [screenW * 0.7, screenW * 0.4, screenW * 0.85][index % 3] }
    private var startY: CGFloat { [screenH * 0.05, screenH * 0.12, screenH * 0.02][index % 3] }
    private var angle: Double { [-35.0, -40.0, -30.0][index % 3] }
    private var interval: Double { [9.0, 14.0, 20.0][index % 3] }
    private var delay: Double { Double(index) * 5.0 + 2.0 }

    private let trailLength: CGFloat = 90

    var body: some View {
        Canvas { ctx, size in
            guard active else { return }
            let dx = cos((angle - 90) * .pi / 180) * trailLength * progress
            let dy = sin((angle - 90) * .pi / 180) * trailLength * progress
            var path = Path()
            path.move(to: CGPoint(x: startX, y: startY))
            path.addLine(to: CGPoint(x: startX + dx, y: startY + dy))

            let grad = LinearGradient(
                colors: [Color(hex: "FFE088").opacity(0.0), Color(hex: "FFE088").opacity(0.9)],
                startPoint: .leading,
                endPoint: .trailing
            )
            ctx.stroke(path, with: .linearGradient(
                Gradient(colors: [.clear, Color(hex: "FFE088")]),
                startPoint: CGPoint(x: startX, y: startY),
                endPoint: CGPoint(x: startX + dx, y: startY + dy)
            ), lineWidth: 2.2)
        }
        .ignoresSafeArea()
        .onAppear { scheduleShoot() }
    }

    private func scheduleShoot() {
        DispatchQueue.main.asyncAfter(deadline: .now() + delay) {
            shoot()
        }
    }

    private func shoot() {
        active = true
        progress = 0
        withAnimation(.easeIn(duration: 0.6)) { progress = 1 }
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.65) {
            withAnimation(.easeOut(duration: 0.3)) { progress = 0 }
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.4) {
                active = false
                DispatchQueue.main.asyncAfter(deadline: .now() + interval) {
                    shoot()
                }
            }
        }
    }
}

// MARK: - Color hex helper (shared, defined once here)

extension Color {
    init(hex: String) {
        let hex = hex.trimmingCharacters(in: CharacterSet.alphanumerics.inverted)
        var int: UInt64 = 0
        Scanner(string: hex).scanHexInt64(&int)
        let a, r, g, b: UInt64
        switch hex.count {
        case 3:
            (a, r, g, b) = (255, (int >> 8) * 17, (int >> 4 & 0xF) * 17, (int & 0xF) * 17)
        case 6:
            (a, r, g, b) = (255, int >> 16, int >> 8 & 0xFF, int & 0xFF)
        case 8:
            (a, r, g, b) = (int >> 24, int >> 16 & 0xFF, int >> 8 & 0xFF, int & 0xFF)
        default:
            (a, r, g, b) = (255, 200, 200, 200)
        }
        self.init(.sRGB,
                  red: Double(r) / 255,
                  green: Double(g) / 255,
                  blue: Double(b) / 255,
                  opacity: Double(a) / 255)
    }
}
