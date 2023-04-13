//
//  GameScene.swift
//  Flower Collector
//
//  Created by Zeeshan Suleman on 09/04/2023.
//

import SpriteKit
import AVFoundation

class GameScene: SKScene, SKPhysicsContactDelegate {
    
    /// Audio player for collision sound
    var player: AVAudioPlayer?
    
    private var lastUpdateTime : TimeInterval = 0
    private var currentFlowerSpawnTime : TimeInterval = 0
    private var flowerSpawnRate : TimeInterval = 0.8
    
    /// Flower Texture
    let flowerTexture = SKTexture(imageNamed: "flower")
    
    /// Vase Node
    private let vaseNode = VaseSprite.newInstance()
    
    
    /// Label for showing score
    private let scoreLabel = SKLabelNode(text: "Score: 0")
    /// Score
    private var score: Int = 0
    
    
    /// Time Label
    private var timeLabel = SKLabelNode(text: "60 sec")
    /// Active timer indicator
    private var isTimerActive = true
    /// Total timer seconds
    private var totalTimerSeconds = 60
    /// Timer
    private var timer: Timer?
    
    // Game Over View
    let gameOverNode = SKNode()
    let finalScoreLabel = SKLabelNode(text: "Final Score: 0")
    
    
    override func sceneDidLoad() {
        self.lastUpdateTime = 0
        
        vaseNode.updatePosition(point: CGPoint(x: frame.midX, y: frame.minY + 30))
        vaseNode.zPosition = 4
        addChild(vaseNode)
        
        var worldFrame = frame
        worldFrame.origin.x -= 100
        worldFrame.origin.y -= 100
        worldFrame.size.height += 200
        worldFrame.size.width += 200
        
        self.physicsBody = SKPhysicsBody(edgeLoopFrom: worldFrame)
        self.physicsBody?.categoryBitMask = WorldCategory
        self.physicsWorld.contactDelegate = self
        
        configureSound()
        setupScoreLabel()
        setupTimeLabel()
        activateTimer()
        gameOverView()
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        let touchPoint = touches.first?.location(in: self)
        
        if let point = touchPoint {
            vaseNode.setDestination(destination: point)
        }
        
        for touch in touches {
            let location = touch.location(in: self)
            let node = self.atPoint(location)
            
            if node.name == "restart" {
                timeLabel.text = "60 Sec"
                activateTimer()
                gameOverNode.isHidden = true
            }
        }
    }
    
    override func touchesMoved(_ touches: Set<UITouch>, with event: UIEvent?) {
        let touchPoint = touches.first?.location(in: self)
        
        if let point = touchPoint {
            vaseNode.setDestination(destination: point)
        }
    }
    
    override func update(_ currentTime: TimeInterval) {
        // Called before each frame is rendered
        
        // Initialize _lastUpdateTime if it has not already been
        if (self.lastUpdateTime == 0) {
            self.lastUpdateTime = currentTime
        }
        
        // Calculate time since last update
        let dt = currentTime - self.lastUpdateTime
        
        vaseNode.update(deltaTime: dt)
        
        // Update the Spawn Timer
        currentFlowerSpawnTime += dt
        
        if currentFlowerSpawnTime > flowerSpawnRate {
            currentFlowerSpawnTime = 0
            if isTimerActive{
                spawnFlower()
            }
        }
        
        self.lastUpdateTime = currentTime
    }
    
    private func spawnFlower() {
        let flower = SKSpriteNode(texture: flowerTexture)
        flower.physicsBody = SKPhysicsBody(texture: flowerTexture, size: flower.size)
        flower.physicsBody?.categoryBitMask = FlowerCategory
        
        let xPosition = CGFloat(arc4random()).truncatingRemainder(dividingBy: size.width)
        let yPosition = size.height + flower.size.height
        flower.position = CGPoint(x: xPosition, y: yPosition)
        flower.zPosition = 2
        
        addChild(flower)
    }
    
    /// Configuring Sound to Play when Collision happend
    private func configureSound(){
        let soundURL = Bundle.main.url(forResource: "sound", withExtension: "mp3")!
        let session = AVAudioSession.sharedInstance()
        do {
            try session.setCategory(AVAudioSession.Category.playAndRecord)
            player = try AVAudioPlayer(contentsOf: soundURL)
            player?.prepareToPlay()
        } catch let error {
            print("Error loading sound: \(error.localizedDescription)")
        }
    }
    
    /// Setup Score Label
    private func setupScoreLabel(){
        scoreLabel.position = CGPoint(x: 100, y: size.height - 100)
        scoreLabel.fontSize = 32
        scoreLabel.fontColor = SKColor.white
        addChild(scoreLabel)
    }
    
    /// Setup Time Label
    private func setupTimeLabel(){
        timeLabel.position = CGPoint(x: size.width - 80, y: size.height - 100)
        timeLabel.fontSize = 24
        timeLabel.fontColor = SKColor.gray
        addChild(timeLabel)
    }
    
    /// Update Score with Sound
    private func updateScoreWithSound(){
        player?.play()
        score += 1
        scoreLabel.text = "Score: \(score)"
    }
    
    /// Activate Timer
    private func activateTimer(){
        totalTimerSeconds = 60
        isTimerActive = true
        scoreLabel.text = "Score: 0"
        score = 0
        timer = Timer.scheduledTimer(timeInterval: 1.0, target: self, selector: #selector(timerAction), userInfo: nil, repeats: true)
    }
    
    /// Timer Action
    @objc func timerAction() {
        totalTimerSeconds -= 1
        timeLabel.text = "\(totalTimerSeconds) sec"
        
        // When timer finished
        if totalTimerSeconds == 0{
            isTimerActive = false
            timer?.invalidate()
            DispatchQueue.main.asyncAfter(deadline: .now() + 1){ [unowned self] in
                gameOverNode.isHidden = false
                finalScoreLabel.text = "Final Score: \(score)"
            }
        }
    }
    
    /// Game Over View
    func gameOverView(){
        
        gameOverNode.position = CGPoint(x: self.frame.midX, y: self.frame.midY)
        gameOverNode.scene?.backgroundColor = .red
        self.addChild(gameOverNode)
        gameOverNode.isHidden = true
        
        finalScoreLabel.fontSize = 24
        finalScoreLabel.fontName = "HelveticaNeue-Bold"
        finalScoreLabel.position = CGPoint(x: 0, y: 50)
        gameOverNode.addChild(finalScoreLabel)
        
        // Size for restart button and background path with cornor radius
        let spriteSize = CGSize(width: 150, height: 50)
        let cornerRadius: CGFloat = 15
        let roundedRect = CGRect(x: -spriteSize.width/2, y: -spriteSize.height/2, width: spriteSize.width, height: spriteSize.height)
        let path = UIBezierPath(roundedRect: roundedRect, cornerRadius: cornerRadius)
        let shape = SKShapeNode(path: path.cgPath)
        shape.fillColor = .gray.withAlphaComponent(0.5)
        shape.strokeColor = .clear
        
        
        // Restart Button
        let restartButton = SKSpriteNode(color: .clear, size: spriteSize)
        restartButton.position = CGPoint(x: 0, y: -50)
        restartButton.name = "restart"
        restartButton.addChild(shape)
        gameOverNode.addChild(restartButton)
        
        // Restart Button Label
        let buttonLabel = SKLabelNode(text: "Restart")
        buttonLabel.name = "restart"
        buttonLabel.verticalAlignmentMode = .center
        buttonLabel.horizontalAlignmentMode = .center
        buttonLabel.fontSize = 20
        buttonLabel.fontName = "HelveticaNeue-Bold"
        buttonLabel.fontColor = .white
        restartButton.addChild(buttonLabel)
    }
    
    func didBegin(_ contact: SKPhysicsContact) {
        
        if (contact.bodyA.categoryBitMask == VaseCategory) {
            updateScoreWithSound()
        } else if (contact.bodyB.categoryBitMask == VaseCategory) {
            updateScoreWithSound()
        }
        
        if (contact.bodyA.categoryBitMask == FlowerCategory) {
            contact.bodyA.node?.physicsBody?.collisionBitMask = 0
            contact.bodyA.node?.physicsBody?.categoryBitMask = 0
        } else if (contact.bodyB.categoryBitMask == FlowerCategory) {
            contact.bodyB.node?.physicsBody?.collisionBitMask = 0
            contact.bodyB.node?.physicsBody?.categoryBitMask = 0
        }
        
        if contact.bodyA.categoryBitMask == WorldCategory {
            contact.bodyB.node?.removeFromParent()
            contact.bodyB.node?.physicsBody = nil
            contact.bodyB.node?.removeAllActions()
        } else if contact.bodyB.categoryBitMask == WorldCategory {
            contact.bodyA.node?.removeFromParent()
            contact.bodyA.node?.physicsBody = nil
            contact.bodyA.node?.removeAllActions()
        }
    }
}
