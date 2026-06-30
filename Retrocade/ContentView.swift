//
//  ContentView.swift
//  Retrocade
//
//  Created by Jeff on 6/30/26.
//

import SwiftUI

// MARK: - MAIN ENTRY VIEW
struct ContentView: View {
    @State private var terminalText: String = ""
    @State private var showMenu = false
    @State private var selectedGame: String? = nil
    
    let bootLines = [
        "BOOTING RETRO_OS v1.0.7...",
        "LOADING CORE MEMORY....... OK",
        "CONNECTING TO DIAL-UP [56K]... OK",
        "READY.",
        "\n--- SELECT A GAME ---"
    ]
    
    var body: some View {
        ZStack {
            Color.black.ignoresSafeArea()
            
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
        .sheet(item: $selectedGame) { game in
            GameRunnerView(gameName: game)
        }
    }
    
    func simulateBootSequence() {
        var currentLine = 0
        Timer.scheduledTimer(withTimeInterval: 0.6, repeats: true) { timer in
            if currentLine < bootLines.count {
                terminalText += bootLines[currentLine] + "\n"
                currentLine += 1
            } else {
                timer.invalidate()
                withAnimation(.easeIn(duration: 0.5)) {
                    showMenu = true
                }
            }
        }
    }
}

// MARK: - MENU VIEW
struct TerminalMenuView: View {
    @Binding var selectedGame: String?
    
    var body: some View {
        VStack(alignment: .leading, spacing: 20) {
            Text("== RETROCADE DIRECTORY ==")
                .font(.system(.title3, design: .monospaced))
                .foregroundColor(.green)
                .bold()
            
            Text("Click a game to play:")
                .font(.system(.body, design: .monospaced))
                .foregroundColor(.green)
            
            Button(action: { selectedGame = "Snake" }) {
                Text(" Snake ")
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
            .stroke(Color.white.opacity(0.04), lineWidth: 1)
        }
        .allowsHitTesting(false)
    }
}

// MARK: - GAME RUNNER CONTAINER
struct GameRunnerView: View {
    let gameName: String
    @Environment(\.dismiss) var dismiss
    
    var body: some View {
        ZStack {
            Color.blue.ignoresSafeArea()
            
            VStack(spacing: 20) {
                Text("RUNNING: \(gameName.uppercased())")
                    .font(.system(.headline, design: .monospaced))
                    .foregroundColor(.white)
                
                Text("[ Insert Game Logic Here ]")
                    .font(.system(.body, design: .monospaced))
                    .foregroundColor(.yellow)
                
                Button(action: { dismiss() }) {
                    Text("ALT+F4: EXIT TO TERMINAL")
                        .font(.system(.caption, design: .monospaced))
                        .padding()
                        .background(Color.white.opacity(0.2))
                        .foregroundColor(.white)
                        .cornerRadius(5)
                }
            }
        }
    }
}

// MARK: - EXTENSIONS
extension String: Identifiable {
    public var id: String { self }
}
