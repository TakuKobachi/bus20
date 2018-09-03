//
//  Route.swift
//  bus20
//
//  Created by SATOSHI NAKAJIMA on 8/27/18.
//  Copyright © 2018 SATOSHI NAKAJIMA. All rights reserved.
//

import CoreGraphics

// A Route represents a section of trip from one node to another consisting of connected edges.
struct Route {
    let edges:[Edge]
    let length:CGFloat
    let extra:CGFloat // used only when finding a shortest route

    init() {
        edges = [Edge]()
        length = 1.0e99
        extra = 0
    }
    init(edges:[Edge], length:CGFloat) {
        self.edges = edges
        self.length = length
        self.extra = 0
    }

    init(edge:Edge, extra:CGFloat) {
        self.edges = [edge]
        self.length = edge.length
        self.extra = extra
    }
    
    init(route:Route, edge:Edge, extra:CGFloat) {
        var edges = route.edges
        edges.append(edge)
        self.edges = edges
        self.length = route.length + edge.length
        self.extra = extra
    }
    
    func render(ctx:CGContext, nodes:[Node], scale:CGFloat) {
        guard let first = edges.first else {
            return
        }
        let node0 = nodes[first.from]
        ctx.move(to: CGPoint(x: node0.location.x * scale, y: node0.location.y * scale))
        for edge in edges {
            let node = nodes[edge.to]
            ctx.addLine(to: CGPoint(x: node.location.x * scale, y: node.location.y * scale))
        }
        ctx.drawPath(using: .stroke)
    }

    var from:Int {
        return edges.first!.from
    }

    var to:Int {
        return edges.last!.to
    }
}

extension Route: CustomStringConvertible {
    var description: String {
        var array = edges.map { (edge) -> Int in
            return edge.from
        }
        array.append(self.to)
        return array.description
    }
}
