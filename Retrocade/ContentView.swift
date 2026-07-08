//
//  ContentView.swift
//  Retrocade
//
//  Created by Jeff on 6/30/26.
//

import SwiftUI

// MARK: - MAIN ENTRY VIEW
struct ContentView: View {
    struct Game: Identifiable, Equatable {
        let id = UUID()
        let name: String
    }

    @State private var terminalText: String = ""
    @State private var showMenu = false
    @State private var selectedGame: Game? = nil
    
    let bootLines = [
        "BOOTING RETRO_OS v1.0.7...",
        "LOADING CORE MEMORY....... OK",
        "CONNECTING TO MOONBASE... OK",
        "INSERT QUARTER",
        "LOADING MENU"
    ]
    
    var body: some View {
        ZStack {
            // Background color for areas outside the simulated terminal frame
            Color.black.ignoresSafeArea()
            
            ZStack {
                // TERMINAL DISPLAY BACKGROUND
                Color.black
                
                // TERMINAL CONSOLE LINES
                ScanlineView()
                
                VStack(alignment: .leading, spacing: 10) {
                    if !showMenu {
                        Text(terminalText)
                            .font(.system(.body, design: .monospaced))
                            .foregroundColor(.green)
                            .padding()
                            .onAppear {
                                simulateBootSequence()
                            }
                    } else {
                        TerminalMenuView(selectedGame: $selectedGame)
                    }
                    Spacer()
                }
                .padding()
                .frame(maxWidth: .infinity, alignment: .leading)
            }
            // ✂️ Cleanly locks the boot sequence text, menu list, and scanlines inside a uniform rounded CRT screen box
            .clipShape(RoundedRectangle(cornerRadius: 16, style: .continuous))
            .overlay(
                RoundedRectangle(cornerRadius: 16, style: .continuous)
                    .stroke(Color.green.opacity(0.15), lineWidth: 1)
            )
            .padding() // Adds space around the console monitor edge so it floats on the screen
        }
        .sheet(item: $selectedGame) { game in
            if game.name == "Snake" {
                SnakeGameView(gameName: game.name)
            } else {
                Text("Loading \(game.name)...")
            }
        }
    }
    
    func simulateBootSequence() {
        var currentLine = 0
        Timer.scheduledTimer(withTimeInterval: 0.4, repeats: true) { timer in
            if currentLine < bootLines.count {
                terminalText += bootLines[currentLine] + "\n"
                currentLine += 1
            } else {
                timer.invalidate()
                withAnimation(.easeIn(duration: 0.3)) {
                    showMenu = true
                }
            }
        }
    }
}

// MARK: - MENU VIEW
struct TerminalMenuView: View {
    @Binding var selectedGame: ContentView.Game?
    
    var body: some View {
        VStack(alignment: .leading, spacing: 20) {
            Text("== RETROCADE DIRECTORY ==")
                .font(.system(.title3, design: .monospaced))
                .foregroundColor(.green)
                .bold()
            
            Text("Click a game to play:")
                .font(.system(.body, design: .monospaced))
                .foregroundColor(.green)
            
            Button(action: { selectedGame = ContentView.Game(name: "Snake") }) {
                Text(" > Snake ")
                    .font(.system(.body, design: .monospaced))
                    .foregroundColor(.yellow)
            }
        }
        .padding(.top, 20)
    }
}

// MARK: - CRT SCANLINE EFFECT
struct ScanlineView: View {
    var body: some View {
        GeometryReader { geo in
            Path { path in
                let spacing: CGFloat = 4
                for y in stride(from: 0, to: geo.size.height, by: spacing) {
                    path.move(to: CGPoint(x: 0, y: y))
                    path.addLine(to: CGPoint(x: geo.size.width, y: y))
                }
            }
            .stroke(Color.white.opacity(0.07), lineWidth: 1)
        }
        .allowsHitTesting(false)
    }
}
