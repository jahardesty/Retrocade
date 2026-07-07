//
//   SnakeGameView.swift
//   Retrocade
//
//   Created by Jeffrey Hardesty on 7/1/26.
//

import SwiftUI
import Combine

struct SnakeGameView: View {
    let gameName: String
    @Environment(\.dismiss) var dismiss
    
    let columns = 15
    let rows = 20
    
    @State private var snake: [CGPoint] = [CGPoint(x: 7, y: 10)]
    @State private var food: CGPoint = CGPoint(x: 3, y: 5)
    @State private var direction: Direction = .up
    @State private var isGameOver = false
    @State private var score = 0
    @State private var hasStarted = false
    
    let timer = Timer.publish(every: 0.2, on: .main, in: .common).autoconnect()
    
    enum Direction {
        case up, down, left, right
    }
    
    // Calculates rotation angle for the snake head indicator arrow
    var headRotation: Angle {
        switch direction {
        case .up:    return .degrees(0)
        case .right: return .degrees(90)
        case .down:  return .degrees(180)
        case .left:  return .degrees(270)
        }
    }
    
    // MARK: DESIGN
    var body: some View {
        ZStack {
            // GLOBAL BACKGROUND (Pure deep black)
            Color.black.ignoresSafeArea()
            
            VStack {
                // TOP HEADER BAR
                HStack {
                    Button(action: { dismiss() }) {
                        Text("EXIT TO TERMINAL")
                            .font(.system(.caption, design: .monospaced))
                            .foregroundColor(.gray)
                            .padding(.bottom, 10)
                    }
                    
                    Text("SCORE: \(score)")
                    Spacer()
                    Text("SNAKE")
                }
                .font(.system(.headline, design: .monospaced))
                .foregroundColor(.green)
                .padding()
                
                // GAME ARENA
                GeometryReader { geometry in
                    let cellSize = min(geometry.size.width / CGFloat(columns), geometry.size.height / CGFloat(rows))
                    
                    ZStack(alignment: .topLeading) {
                        // BACK LAYER: Black Grid Background with uniform rounded corners
                        RoundedRectangle(cornerRadius: 16, style: .continuous)
                            .fill(Color.black)
                            .overlay(
                                RoundedRectangle(cornerRadius: 16, style: .continuous)
                                    .stroke(Color.green.opacity(0.3), lineWidth: 2)
                            )
                        
                        // FOOD ITEM (Crimson Pixel Block)
                        Rectangle()
                            .fill(Color.red)
                            .frame(width: cellSize - 2, height: cellSize - 2)
                            .offset(x: food.x * cellSize + 1, y: food.y * cellSize + 1)
                        
                        // MARK: SNAKE SECTIONS
                        ForEach(0..<snake.count, id: \.self) { index in
                            let isHead = (index == 0)
                            
                            if isHead {
                                // Dynamic Head Block with an Orientation Arrow
                                Rectangle()
                                    .fill(Color.green)
                                    .frame(width: cellSize - 2, height: cellSize - 2)
                                    .overlay(
                                        Image(systemName: "triangle.fill")
                                            .font(.system(size: cellSize * 0.5))
                                            .foregroundColor(.black)
                                            .rotationEffect(headRotation)
                                    )
                                    .offset(x: snake[index].x * cellSize + 1, y: snake[index].y * cellSize + 1)
                            } else {
                                // Body Blocks
                                Rectangle()
                                    .fill(Color.green.opacity(0.85))
                                    .frame(width: cellSize - 2, height: cellSize - 2)
                                    .offset(x: snake[index].x * cellSize + 1, y: snake[index].y * cellSize + 1)
                            }
                        }
                        
                        // FRONT LAYER: The Integrated Start Screen Overlay
                        if !hasStarted {
                            ZStack {
                                Color.black.opacity(0.9)
                                
                                VStack(spacing: 12) {
                                    Text("S N A K E")
                                        .font(.system(.title, design: .monospaced))
                                        .fontWeight(.bold)
                                        .foregroundColor(.yellow)
                                    Text("TAP TO START")
                                        .font(.system(.caption, design: .monospaced))
                                        .foregroundColor(.white)
                                        .opacity(0.8)
                                }
                            }
                            .frame(width: cellSize * CGFloat(columns), height: cellSize * CGFloat(rows))
                        }
                        
                        // 📺 CRT SCANLINE OVERLAY: Locked safely inside the screen bounds stack
                        ScanlineView()
                            .allowsHitTesting(false)
                    }
                    .frame(width: cellSize * CGFloat(columns), height: cellSize * CGFloat(rows))
                    // ✂️ Cleanly clips backgrounds, rectangles, text overlays, and scanlines together!
                    .clipShape(RoundedRectangle(cornerRadius: 16, style: .continuous))
                    .contentShape(RoundedRectangle(cornerRadius: 16, style: .continuous))
                    .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .center)
                    .onTapGesture {
                        if !hasStarted {
                            hasStarted = true
                        }
                    }
                }
                .padding()
                
                Spacer()
                
                // 🎮 RETRO CONSOLE GAME PAD
                HStack(alignment: .center) {
                    // LEFT SIDE: Physical D-Pad Cross Layout
                    VStack(spacing: 2) {
                        Button(action: { if direction != .down { direction = .up } }) {
                            Text("▲")
                                .font(.system(.title3, design: .monospaced))
                                .foregroundColor(.black)
                                .frame(width: 44, height: 44)
                                .background(Color.yellow)
                                .cornerRadius(6)
                        }
                        
                        HStack(spacing: 46) {
                            Button(action: { if direction != .right { direction = .left } }) {
                                Text("◀")
                                    .font(.system(.title3, design: .monospaced))
                                    .foregroundColor(.black)
                                    .frame(width: 44, height: 44)
                                    .background(Color.yellow)
                                    .cornerRadius(6)
                            }
                            
                            Button(action: { if direction != .left { direction = .right } }) {
                                Text("▶")
                                    .font(.system(.title3, design: .monospaced))
                                    .foregroundColor(.black)
                                    .frame(width: 44, height: 44)
                                    .background(Color.yellow)
                                    .cornerRadius(6)
                            }
                        }
                        
                        Button(action: { if direction != .up { direction = .down } }) {
                            Text("▼")
                                .font(.system(.title3, design: .monospaced))
                                .foregroundColor(.black)
                                .frame(width: 44, height: 44)
                                .background(Color.yellow)
                                .cornerRadius(6)
                        }
                    }
                    .background(
                        RoundedRectangle(cornerRadius: 4)
                            .fill(Color.yellow.opacity(0.2))
                            .frame(width: 46, height: 46)
                    )
                    
                    Spacer()
                    
                    // RIGHT SIDE: Angled Action Buttons
                    HStack(spacing: 24) {
                        Button(action: { /* Future Turbo Action */ }) {
                            Circle()
                                .fill(Color.red)
                                .frame(width: 50, height: 50)
                                .shadow(color: .black.opacity(0.6), radius: 2, x: 2, y: 3)
                                .overlay(
                                    Text("B")
                                        .font(.system(.body, design: .monospaced))
                                        .fontWeight(.bold)
                                        .foregroundColor(.white)
                                )
                        }
                        .offset(y: 12)
                        
                        Button(action: { /* Future Primary Action */ }) {
                            Circle()
                                .fill(Color.red)
                                .frame(width: 50, height: 50)
                                .shadow(color: .black.opacity(0.6), radius: 2, x: 2, y: 3)
                                .overlay(
                                    Text("A")
                                        .font(.system(.body, design: .monospaced))
                                        .fontWeight(.bold)
                                        .foregroundColor(.white)
                                )
                        }
                    }
                    .padding(.trailing, 15)
                }
                .padding(.horizontal, 25)
                .padding(.bottom, 25)
            }
        }
        .onReceive(timer) { _ in
            if hasStarted && !isGameOver {
                moveSnake()
            }
        }
        .alert("GAME OVER", isPresented: $isGameOver) {
            Button("Retry") { resetGame() }
            Button("Exit", role: .cancel) { dismiss() }
        } message: {
            Text("Final Score: \(score)")
        }
    }
    
    // MARK: - GAME MECHS
    func moveSnake() {
        guard let head = snake.first else { return }
        var newHead = head
        
        switch direction {
        case .up: newHead.y -= 1
        case .down: newHead.y += 1
        case .left: newHead.x -= 1
        case .right: newHead.x += 1
        }
        
        if newHead.x < 0 || newHead.x >= CGFloat(columns) || newHead.y < 0 || newHead.y >= CGFloat(rows) {
            isGameOver = true
            return
        }
        
        if snake.contains(newHead) {
            isGameOver = true
            return
        }
        
        snake.insert(newHead, at: 0)
        
        if newHead == food {
            score += 10
            generateNewFood()
        } else {
            snake.removeLast()
        }
    }
    
    func generateNewFood() {
        while true {
            let randomX = CGFloat(Int.random(in: 0..<columns))
            let randomY = CGFloat(Int.random(in: 0..<rows))
            let newFoodLocation = CGPoint(x: randomX, y: randomY)
            
            if !snake.contains(newFoodLocation) {
                food = newFoodLocation
                break
            }
        }
    }
    
    func resetGame() {
        snake = [CGPoint(x: 7, y: 10)]
        direction = .up
        score = 0
        generateNewFood()
        isGameOver = false
        hasStarted = false
    }
}
