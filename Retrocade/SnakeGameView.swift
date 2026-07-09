//
//   SnakeGameView.swift
//   Retrocade
//
//   Created by Jeffrey Hardesty on 7/1/26.
//

import SwiftUI
import Combine
import UIKit

struct SnakeSegment: Identifiable {
    let id = UUID()
    var position: CGPoint
}

struct SnakeGameView: View {
    let gameName: String
    @Environment(\.dismiss) var dismiss
    
    let columns = 15
    let rows = 20
    
    @State private var snake: [SnakeSegment] = [SnakeSegment(position: CGPoint(x: 7, y: 10))]
    @State private var food: CGPoint = CGPoint(x: 3, y: 5)
    @State private var superFood: CGPoint? = nil
    @State private var direction: Direction = .up
    @State private var lastMovedDirection: Direction = .up
    
    @State private var isGameOver = false
    @State private var hasStarted = false
    @State private var score: Int = 0
    @State private var highScore: Int = UserDefaults.standard.integer(forKey: "SnakeHighScore")
    @State private var isTurboMode = false
    @State private var isSlowMode = false
    @State private var moveInterval: Double = 0.2
    @State private var speedTimer = Timer.publish(every: 0.2, on: .main, in: .common).autoconnect()
    
    let timer = Timer.publish(every: 0.2, on: .main, in: .common).autoconnect()
    
    
    private let dpadFeedback = UIImpactFeedbackGenerator(style: .rigid)
    private let actionFeedback = UIImpactFeedbackGenerator(style: .medium)
    
    enum Direction {
        case up, down, left, right
    }
    
    var headRotation: Angle {
        switch direction {
        case .up:    return .degrees(0)
        case .right: return .degrees(90)
        case .down:  return .degrees(180)
        case .left:  return .degrees(270)
        }
    }
    
    var body: some View {
        ZStack {
            Color.black.ignoresSafeArea()
            
            VStack(spacing: 0) {
                // MARK: - TERMINAL HUD DISPLAY
                HStack(alignment: .center) {
                    HStack(spacing: 16) {
                        HStack(spacing: 4) {
                            Text("SCORE:")
                                .foregroundColor(.green.opacity(0.6))
                            Text(String(format: "%04d", score))
                                .foregroundColor(.green)
                                .bold()
                        }
                        
                        HStack(spacing: 4) {
                            Text("HI:")
                                .foregroundColor(.green.opacity(0.6))
                            Text(String(format: "%04d", highScore))
                                .foregroundColor(.yellow)
                                .bold()
                        }
                    }
                    .font(.system(.subheadline, design: .monospaced))
                    
                    Spacer()
                    
                    Button(action: {
                        actionFeedback.impactOccurred()
                        dismiss()
                    }) {
                        Text("[ESC_EXIT]")
                            .font(.system(.caption, design: .monospaced))
                            .foregroundColor(.red.opacity(0.85))
                            .padding(.horizontal, 8)
                            .padding(.vertical, 4)
                            .background(
                                RoundedRectangle(cornerRadius: 4)
                                    .stroke(Color.red.opacity(0.4), lineWidth: 1)
                            )
                    }
                }
                .padding(.horizontal, 12)
                .padding(.vertical, 8)
                .background(Color.green.opacity(0.04))
                
                // MARK: - GAME ARENA BOX
                ZStack {
                    GeometryReader { geometry in
                        let cellSize = min(geometry.size.width / CGFloat(columns), geometry.size.height / CGFloat(rows))
                        
                        ZStack(alignment: .topLeading) {
                            RoundedRectangle(cornerRadius: 16, style: .continuous)
                                .fill(Color.black)
                                .overlay(
                                    RoundedRectangle(cornerRadius: 16, style: .continuous)
                                        .stroke(Color.green.opacity(0.3), lineWidth: 2)
                                )
                            
                            // FOOD ITEM
                            Rectangle()
                                .fill(Color.red)
                                .frame(width: cellSize - 2, height: cellSize - 2)
                                .offset(x: food.x * cellSize + 1, y: food.y * cellSize + 1)
                            
                            if let superFoodLocation = superFood {
                                Rectangle()
                                    .fill(Color.blue)
                                    .frame(width: cellSize - 2, height: cellSize - 2)
                                    .offset(x: superFoodLocation.x * cellSize + 1, y: superFoodLocation.y * cellSize + 1)
                            }
                            
                            //MARK: SNAKE SECTIONS
                            ForEach(snake) { segment in
                                let isHead = (segment.id == snake.first?.id)
                                let isTail = (segment.id == snake.last?.id) && (snake.count > 1)
                                
                                if isHead {
                                    Rectangle()
                                        .fill(Color.green)
                                        .frame(width: cellSize - 2, height: cellSize - 2)
                                        .overlay(
                                            Image(systemName: "triangle.fill")
                                                .font(.system(size: cellSize * 0.5))
                                                .foregroundColor(.black)
                                                .rotationEffect(headRotation)
                                        )
                                        .offset(x: segment.position.x * cellSize + 1, y: segment.position.y * cellSize + 1)
                                } else if isTail {
                                    Rectangle()
                                        .fill(Color.yellow.opacity(0.85))
                                        .frame(width: cellSize - 2, height: cellSize - 2)
                                        .offset(x: segment.position.x * cellSize + 1, y: segment.position.y * cellSize + 1)
                                } else {
                                    Rectangle()
                                        .fill(Color.green.opacity(0.85))
                                        .frame(width: cellSize - 2, height: cellSize - 2)
                                        .offset(x: segment.position.x * cellSize + 1, y: segment.position.y * cellSize + 1)
                                }
                            }
                            
                            if !hasStarted {
                                ZStack {
                                    Color.black.opacity(0.9)
                                    
                                    VStack(spacing: 12) {
                                        Text("S N A K E")
                                            .font(.system(.title, design: .monospaced))
                                            .fontWeight(.bold)
                                            .foregroundColor(.yellow)
                                        Text("""
                                            TAP SCREEN OR [A] TO START
                                            USE ARROW KEYS TO MOVE 
                                            PRESS [A] TO SPEED UP
                                            PRESS [B] TO SLOW DOWN")
                                            """)
                                        .multilineTextAlignment(.center)
                                            .font(.system(.caption, design: .monospaced))
                                            .foregroundColor(.white)
                                            .opacity(0.8)
                                    }
                                }
                                .frame(width: cellSize * CGFloat(columns), height: cellSize * CGFloat(rows))
                            }
                            
                            // Visual Placeholder or implementation for your Scanlines
                            Color.clear // Replace with ScanlineView() if it exists in your project
                                .allowsHitTesting(false)
                        }
                        .frame(width: cellSize * CGFloat(columns), height: cellSize * CGFloat(rows))
                        .clipShape(RoundedRectangle(cornerRadius: 16, style: .continuous))
                        .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .center)
                    }
                }
                .padding()
                .onTapGesture {
                    triggerGameStart()
                }
                
                Spacer()
                
                // MARK: - CONTROLLER CONTROLS
                HStack(alignment: .center) {
                    // D-PAD
                    VStack(spacing: 2) {
                        Button(action: { if lastMovedDirection != .down { direction = .up; dpadFeedback.impactOccurred() } }) {
                            Text("▲")
                                .font(.system(.title3, design: .monospaced))
                                .foregroundColor(.black)
                                .frame(width: 44, height: 44)
                                .background(Color.yellow)
                                .cornerRadius(6)
                        }
                        
                        HStack(spacing: 46) {
                            Button(action: { if lastMovedDirection != .right { direction = .left; dpadFeedback.impactOccurred() } }) {
                                Text("◀")
                                    .font(.system(.title3, design: .monospaced))
                                    .foregroundColor(.black)
                                    .frame(width: 44, height: 44)
                                    .background(Color.yellow)
                                    .cornerRadius(6)
                            }
                            
                            Button(action: { if lastMovedDirection != .left { direction = .right; dpadFeedback.impactOccurred() } }) {
                                Text("▶")
                                    .font(.system(.title3, design: .monospaced))
                                    .foregroundColor(.black)
                                    .frame(width: 44, height: 44)
                                    .background(Color.yellow)
                                    .cornerRadius(6)
                            }
                        }
                        
                        Button(action: { if lastMovedDirection != .up { direction = .down; dpadFeedback.impactOccurred() } }) {
                            Text("▼")
                                .font(.system(.title3, design: .monospaced))
                                .foregroundColor(.black)
                                .frame(width: 44, height: 44)
                                .background(Color.yellow)
                                .cornerRadius(6)
                        }
                    }
                    
                    Spacer()
                    
                    // ACTION BUTTONS
                    HStack(spacing: 24) {
                        Button(action: { actionFeedback.impactOccurred()
                            toggleSlowSpeed()
                        }) {
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
                        
                        Button(action: {
                            actionFeedback.impactOccurred()
                            if !hasStarted {
                                triggerGameStart()
                            } else {
                                toggleTurboSpeed()
                            }
                        }) {
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
                .padding(.bottom, 35)
            }
            .onReceive(speedTimer) { _ in
                if hasStarted && !isGameOver {
                    moveSnake()
                }
            }
            if isGameOver {
                ZStack {
                    // Dimmed retro background overlay
                    Color.black.opacity(0.85)
                        .ignoresSafeArea()
                    
                    // Custom Pleasing Terminal Card
                    VStack(spacing: 20) {
                        Text("GAME OVER")
                            .font(.system(.title, design: .monospaced))
                            .fontWeight(.black)
                            .foregroundColor(.red)
                            .shadow(color: .yellow.opacity(0.4), radius: 4)
                        
                        VStack(spacing: 4) {
                            Text("FINAL SCORE")
                                .font(.system(.caption2, design: .monospaced))
                                .foregroundColor(.green.opacity(0.6))
                            Text(String(format: "%04d", score))
                                .font(.system(.title2, design: .monospaced))
                                .bold()
                                .foregroundColor(.green)
                        }
                        .padding(.vertical, 8)
                        
                        // Retro Styled Buttons
                        HStack(spacing: 16) {
                            Button(action: {
                                resetGame()
                            }) {
                                Text("RETRY")
                                    .font(.system(.body, design: .monospaced))
                                    .bold()
                                    .foregroundColor(.black)
                                    .padding(.horizontal, 20)
                                    .padding(.vertical, 10)
                                    .background(Color.yellow)
                                    .cornerRadius(8)
                            }
                            
                            Button(action: {
                                dismiss()
                            }) {
                                Text("EXIT")
                                    .font(.system(.body, design: .monospaced))
                                    .foregroundColor(.red)
                                    .padding(.horizontal, 20)
                                    .padding(.vertical, 10)
                                    .background(
                                        RoundedRectangle(cornerRadius: 8)
                                            .stroke(Color.red.opacity(0.6), lineWidth: 1)
                                    )
                            }
                        }
                    }
                    .padding(30)
                    .background(
                        RoundedRectangle(cornerRadius: 16)
                            .fill(Color(white: 0.08)) // Dark charcoal gray card
                    )
                    .overlay(
                        RoundedRectangle(cornerRadius: 16)
                            .stroke(Color.green.opacity(0.2), lineWidth: 2)
                    )
                    .padding(.horizontal, 40)
                }
                // Smooth fade-in animation
                .transition(.opacity.combined(with: .scale(scale: 0.95)))
            }
            
        }
    }
    
    // MARK: - GAME MECHS
    func triggerGameStart() {
        if !hasStarted {
            dpadFeedback.prepare()
            actionFeedback.prepare()
            hasStarted = true
        }
    }
    
    func moveSnake() {
        guard let head = snake.first else { return }
        var newHeadPosition = head.position
        
        lastMovedDirection = direction
        
        switch direction {
        case .up: newHeadPosition.y -= 1
        case .down: newHeadPosition.y += 1
        case .left: newHeadPosition.x -= 1
        case .right: newHeadPosition.x += 1
        }
        
        // Arena wall check
        if newHeadPosition.x < 0 || newHeadPosition.x >= CGFloat(columns) || newHeadPosition.y < 0 || newHeadPosition.y >= CGFloat(rows) {
            updateHighScore()
            isGameOver = true
            return
        }
        
        // Self collision check
        if snake.contains(where: { $0.position == newHeadPosition }) {
            updateHighScore()
            isGameOver = true
            return
        }
        
        // Insert new segment
        snake.insert(SnakeSegment(position: newHeadPosition), at: 0)
        
        // Check Food Consumption
        if newHeadPosition == food {
            score += 10
            generateNewFood()
            if [100, 300, 600, 1000].contains(score) {
                generateSuperFood()
            }
        } else if let superFoodLocation = superFood, newHeadPosition == superFoodLocation {
            switch score {
            case 100: score += 20
            case 300: score += 40
            case 600: score += 60
            case 1000: score += 100
            default: score += 20
            }
            
            superFood = nil
            if snake.count > 2 {
                let tail = snake.last!
                snake = [snake[0], tail]
            }
        } else {
            // Keep length consistent if food wasn't eaten
            snake.removeLast()
        }
    }

    //MARK: HELPER METHODS
    
    func toggleTurboSpeed() {
        isTurboMode.toggle()
        moveInterval = isTurboMode ? 0.1 : 0.2
        speedTimer = Timer.publish(every: moveInterval, on: .main, in: .common).autoconnect()
    }
    
    func toggleSlowSpeed() {
        isSlowMode.toggle()
        moveInterval = isSlowMode ? 0.3 : 0.2
        speedTimer = Timer.publish(every: moveInterval, on: .main, in: .common).autoconnect()
    }
    
    func updateHighScore() {
        if score > highScore {
            highScore = score
            UserDefaults.standard.set(highScore, forKey: "SnakeHighScore")
        }
    }
    
    func generateNewFood() {
        while true {
            let randomX = CGFloat(Int.random(in: 0..<columns))
            let randomY = CGFloat(Int.random(in: 0..<rows))
            let newFoodLocation = CGPoint(x: randomX, y: randomY)
            
            if !snake.contains(where: { $0.position == newFoodLocation }) {
                food = newFoodLocation
                break
            }
        }
    }
    
    func generateSuperFood() {
        while true {
            let randomX = CGFloat(Int.random(in: 0..<columns))
            let randomY = CGFloat(Int.random(in: 0..<rows))
            let newSuperFoodLocation = CGPoint(x: randomX, y: randomY)
            
            if !snake.contains(where: { $0.position == newSuperFoodLocation }) && superFood == nil {
                superFood = newSuperFoodLocation
                break
            }
        }
    }
    
    func resetGame() {
        snake = [SnakeSegment(position: CGPoint(x: 7, y: 10))]
        direction = .up
        lastMovedDirection = .up
        score = 0
        generateNewFood()
        isGameOver = false
        hasStarted = false
        superFood = nil
        isTurboMode = false
        moveInterval = 0.2
        speedTimer = Timer.publish(every: moveInterval, on: .main, in: .common).autoconnect()
    }
}
