//
//  Node.swift
//  bus20
//
//  Created by SATOSHI NAKAJIMA on 8/27/18.
//  Copyright © 2018 SATOSHI NAKAJIMA. All rights reserved.
//

import CoreGraphics

// A Node represents a location where shuttles can pick up or drop riders
struct Node {
    enum NodeType {
        case empty
        case start
        case end
        case used
    }
    
    let location:CGPoint // The location
    let edges:[Edge]     // Edges started from this node (one direction)
    let type:NodeType    // Node type. Used only when we are searching a shortest route
    var shortestRoutes = [Int:Route]() // shortest route to other nodes (Int is the index of the other node)
    var snodes = [Int]() // indeces to significant nodes. The size is 0 (significant) or 2
    var connections = Set<Int>() // all connected nodes (in and out)
    
    init(location:CGPoint, edges:[Edge]) {
        self.location = location
        self.edges = edges
        self.type = .empty
    }
    
    init(node:Node, type:NodeType) {
        self.location = node.location
        self.edges = node.edges
        self.type = type
    }
    
    // Insigifincant node on two way road
    var isNodeOnTwoWayRoad:Bool {
        return edges.count == 2 && connections.count==2
    }
    
    // Insigifincant node on one way road
    var isNodeOnOneWayRoad:Bool {
        return edges.count == 1 && connections.count==2
    }
    
    var isSignificant:Bool {
        return !(isNodeOnOneWayRoad || isNodeOnTwoWayRoad)
    }
    
    func distance(to:Node) -> CGFloat {
        let dx = to.location.x - self.location.x
        let dy = to.location.y - self.location.y
        return sqrt(dx * dx + dy * dy)
    }
    
    func render(ctx:CGContext, graph:Graph, scale:CGSize) {
        if isSignificant {
            let r:CGFloat = 2
            let rc = CGRect(x: location.x * scale.width - r, y: location.y * scale.height - r, width: r*2, height: r*2)
            ctx.fillEllipse(in: rc)
        }
        
        ctx.beginPath()
        for edge in edges {
            edge.addPath(ctx: ctx, graph: graph, scale: scale)
        }
        ctx.closePath()
        ctx.drawPath(using: .stroke)
    }

    var dictionary:[String:Any] {
        return [
          "location": [
            "x": self.location.x,
            "y": self.location.y,
          ],
          "edges": edges.map { $0.dictionary }
        ];
    }
}

