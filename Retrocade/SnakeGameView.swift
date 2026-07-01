//
//  SnakeGameView.swift
//  Retrocade
//
//  Created by Jeffrey Hardesty on 7/1/26.
//

import SwiftUI
internal import Combine

struct SnakeGameView: View {
    let gameName: String
    @Environment(\.dismiss) var dismiss
    
    let columns = 15
    let rows = 20
    
    @State private var snake: [CGPoint] = [CGPoint(x: 7, y: 10)]
    @State private var food: CGPoint = CGPoint(x:3, y: 5)
    @State private var direction: Direction = .up
    @State private var isGameOver = false
    @State private var score = 0
    
    let timer = Timer.publish(every: 0.2, on: .main, in: .common).autoconnect()
    
    enum Direction {
        case up, down, left, right
    }
    
    var body: some View {
        ZStack {
            Color.black.ignoresSafeArea()
            ScanlineView()
            
            VStack {
                HStack {
                    Text("SCORE: \(score)")
                    Spacer()
                    Text("SNAKE")
                }
                .font(.system(.headline, design: .monospaced))
                .foregroundColor(.green)
                .padding()
                
                GeometryReader { geometry in
                    let cellSize = min(geometry.size.width / CGFloat(columns), geometry.size.height / CGFloat(rows))
                    ZStack(alignment: .topLeading) {
                        Rectangle()
                            .fill(Color.black)
                            .border(Color.green.opacity(0.3), width: 2)
                        Rectangle()
                                .fill(Color.red)
                                .frame(width: cellSize - 2, height: cellSize - 2)
                                .offset(x: food.x * cellSize + 1, y: food.y * cellSize + 1)
                        
                        ForEach(0..<snake.count, id: \.self) { index in
                             Rectangle()
                                .fill(Color.green)
                                .frame(width: cellSize - 2, height: cellSize - 2)
                                .offset(x: snake[index].x * cellSize + 1, y: snake[index].y * cellSize + 1)
                            }
                    }
                    .frame(width: cellSize * CGFloat(columns), height: cellSize * CGFloat(rows))
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
                }
                .padding()
                
                VStack(spacing: 10) {
                    Button(action: { if direction != .down { direction = .up}}) {
                        Text("[ ↑ ]")
                    }
                    
                    HStack(spacing: 10) {
                        Button(action: { if direction != .right { direction = .left}}) {
                            Text ("[ ← ]")
                        }
                        Button(action: { if direction != .left { direction = .right}}) {
                            Text("[ → ]")
                        }
                    }
                    Button(action: { if direction != .up { direction = .down}}) {
                        Text("[ ↓ ]")
                    }
                }
                .font(.system(.title2, design: .monospaced))
                .foregroundColor(.yellow)
                .padding(.bottom, 10)
                
                Button(action: { dismiss() }) {
                    Text("EXIT TO TERMINAL")
                        .font(.system(.caption, design: .monospaced))
                        .foregroundColor(.gray)
                        .padding(.bottom, 10)
                }
            }
        }
        
        .onReceive(timer) { _ in
            if !isGameOver {
                moveSnake()
            }
        }
        .alert(isPresented: $isGameOver) {
            Alert(
                title: Text("GAME OVER"),
                message: Text("Final Score: \(score)"),
                primaryButton: .default(Text("RETRY"), action: resetGame),
                secondaryButton: .cancel(Text("EXIT"), action: { dismiss() })
            )
        }
    }
    
    //MARK: GAME MECHS
    func moveSnake() {
        var head = snake.first!
        // calc head position based on current direction
        switch direction {
        case .up: head.y -= 1
        case .down: head.y += 1
        case .left: head.x -= 1
        case .right: head.x += 1
        }
            // wall collision check
        if head.x < 0 || head.x >= CGFloat(columns) || head.y >= CGFloat(rows) {
            isGameOver = true
            return
        }
        
        snake.insert(head, at: 0)
        
        if head == food {
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
    }
    
    
}

