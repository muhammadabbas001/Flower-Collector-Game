//
//  VaseSprite.swift
//  Flower Collector
//
//  Created by Zeeshan Suleman on 09/04/2023.
//

import SpriteKit

public class VaseSprite : SKSpriteNode {
    private var destination : CGPoint!
    private let easing : CGFloat = 0.1
    
    public static func newInstance() -> VaseSprite {
        let vase = VaseSprite(imageNamed: "vase")
        vase.physicsBody = SKPhysicsBody(rectangleOf: CGSize(width: vase.size.width - 30, height: vase.size.height - 30))
        vase.physicsBody?.isDynamic = false
        vase.physicsBody?.categoryBitMask = VaseCategory
        vase.physicsBody?.contactTestBitMask = FlowerCategory
        return vase
    }
    
    public func updatePosition(point : CGPoint) {
        position = point
        destination = point
    }
    
    public func setDestination(destination : CGPoint) {
        self.destination = destination
    }
    
    public func update(deltaTime : TimeInterval) {
        let distance = sqrt(pow((destination.x - position.x), 2) + pow((destination.y - position.y), 2))
        
        if(distance > 1) {
            let directionX = (destination.x - position.x)
            
            position.x += directionX * easing
        } else {
            position = destination;
        }
    }
}
