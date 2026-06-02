//
//  AnimatedBackgroundView.swift
//  ClimaSwift
//
//  Created by JETSMobileLabMini6 on 01/06/2026.
//

import SwiftUI

struct AnimatedBackgroundView: View {
    let theme: ThemeType
    
    @State private var animateGradient = false
    
    var body: some View {
        ZStack {
            // Base Gradient Animation
            LinearGradient(
                gradient: Gradient(colors: theme == .morning ? [Color.blue.opacity(0.7), Color.cyan.opacity(0.7)] : [Color.purple.opacity(0.7), Color.indigo.opacity(0.7)]),
                startPoint: animateGradient ? .topLeading : .bottomLeading,
                endPoint: animateGradient ? .bottomTrailing : .topTrailing
            )
            .ignoresSafeArea()
            .onAppear {
                withAnimation(.linear(duration: 10).repeatForever(autoreverses: true)) {
                    animateGradient = true
                }
            }
            
            if theme == .morning {
                ZStack {
                    SunView()
                    LottieView(name: "birds_morning")
                        .frame(maxWidth: .infinity, maxHeight: .infinity)
                        .opacity(0.6)
                }
                .transition(.opacity)
            } else {
                ZStack {
                    StarsView()
                    MoonView()
                    LottieView(name: "fireflies_evening")
                        .frame(maxWidth: .infinity, maxHeight: .infinity)
                        .opacity(0.8)
                }
                .transition(.opacity)
            }
        }
        .animation(.easeInOut(duration: 1.0), value: theme)
    }
}

struct SunView: View {
    @State private var scale: CGFloat = 1.0
    @State private var rotation: Double = 0.0
    
    var body: some View {
        Circle()
            .fill(Color.yellow)
            .frame(width: 150, height: 150)
            .shadow(color: .yellow.opacity(0.6), radius: 30, x: 0, y: 0)
            .scaleEffect(scale)
            .rotationEffect(.degrees(rotation))
            .onAppear {
                withAnimation(.easeInOut(duration: 2.5).repeatForever(autoreverses: true)) {
                    scale = 1.1
                }
                withAnimation(.linear(duration: 20).repeatForever(autoreverses: false)) {
                    rotation = 360
                }
            }
            .offset(x: UIScreen.main.bounds.width / 3, y: -UIScreen.main.bounds.height / 4)
    }
}

struct MoonView: View {
    @State private var scale: CGFloat = 1.0
    
    var body: some View {
        Circle()
            .fill(Color.white.opacity(0.8))
            .frame(width: 120, height: 120)
            .shadow(color: .white.opacity(0.4), radius: 25, x: 0, y: 0)
            .scaleEffect(scale)
            .onAppear {
                withAnimation(.easeInOut(duration: 3.0).repeatForever(autoreverses: true)) {
                    scale = 1.05
                }
            }
            .offset(x: UIScreen.main.bounds.width / 3, y: -UIScreen.main.bounds.height / 4)
    }
}

struct StarsView: View {
    @State private var starOpacity: Double = 0.0
    
    var body: some View {
        ZStack {
            ForEach(0..<50) { _ in
                Circle()
                    .fill(Color.white.opacity(Double.random(in: 0.3...0.8)))
                    .frame(width: CGFloat.random(in: 2...5), height: CGFloat.random(in: 2...5))
                    .position(x: CGFloat.random(in: 0...UIScreen.main.bounds.width), y: CGFloat.random(in: 0...UIScreen.main.bounds.height / 2))
                    .opacity(starOpacity)
                    .animation(.easeInOut(duration: Double.random(in: 1.0...3.0)).repeatForever(autoreverses: true), value: starOpacity)
            }
        }
        .onAppear {
            starOpacity = 1.0
        }
    }
}
