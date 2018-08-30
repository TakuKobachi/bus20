//
//  Shuttle.swift
//  bus20
//
//  Created by SATOSHI NAKAJIMA on 8/27/18.
//  Copyright © 2018 SATOSHI NAKAJIMA. All rights reserved.
//

import UIKit

class Shuttle {
    struct RoutePlan {
        let score:CGFloat
        let routes:[Route]
    }
    
    private let hue:CGFloat
    private var edge:Edge
    private var routes:[Route]
    private var baseTime = CGFloat(0)
    private var assigned = [Rider]()
    private var riders = [Rider]()
    private var location = CGPoint.zero
    
    init(hue:CGFloat, index:Int, graph:Graph) {
        self.hue = hue
        let index1 = (index + 1 + Int(arc4random()) % (graph.nodes.count - 1)) % graph.nodes.count
        self.routes = [graph.route(from: index, to: index1)]
        self.edge = self.routes[0].edges[0]
    }

    func update(graph:Graph, time:CGFloat) {
        while (time - baseTime) > edge.length {
            baseTime += edge.length
            var edges = routes[0].edges
            edges.removeFirst()
            if edges.isEmpty {
                // We are picking up a rider
                for (index, rider) in assigned.enumerated() {
                    if rider.from == edge.to {
                        rider.state = .riding
                        assigned.remove(at:index)
                        riders.append(rider)
                    }
                }
                // We are dropping a rider
                for (index, rider) in riders.enumerated() {
                    if rider.to == edge.to {
                        rider.state = .done
                        riders.remove(at:index)
                    }
                }
                
                self.routes.remove(at:0)
                if self.routes.isEmpty {
                    let index1 = (edge.to + 1 + Int(arc4random()) % (graph.nodes.count - 1)) % graph.nodes.count
                    self.routes = [graph.route(from: edge.to, to: index1)]
                }
            } else {
                self.routes[0] = Route(edges: edges, length: routes[0].length - edge.length)
            }
            self.edge = self.routes[0].edges[0]
        }
    }
    
    func render(ctx:CGContext, graph:Graph, scale:CGFloat, time:CGFloat) {
        let node0 = graph.nodes[edge.from]
        let node1 = graph.nodes[edge.to]
        let ratio = (time - baseTime) / edge.length
        location.x = node0.x + (node1.x - node0.x) * ratio
        location.y = node0.y + (node1.y - node0.y) * ratio
        riders.forEach { $0.location = location }
        
        let rc = CGRect(x: location.x * scale - Metrics.shuttleRadius, y: location.y * scale - Metrics.shuttleRadius, width: Metrics.shuttleRadius * 2, height: Metrics.shuttleRadius * 2)
        UIColor(hue: hue, saturation: 1.0, brightness: 1.0, alpha: Metrics.shuttleAlpha).setFill()
        UIColor(hue: hue, saturation: 1.0, brightness: 1.0, alpha: Metrics.routeAlpha).setStroke()
        ctx.fillEllipse(in: rc)

        ctx.setLineWidth(Metrics.routeWidth)
        ctx.setLineCap(.round)
        ctx.setLineJoin(.round)
        
        if assigned.count + riders.count > 0 {
            for route in routes {
                route.render(ctx: ctx, nodes: graph.nodes, scale: scale)
            }
        }
    }
    
    func evaluate(rider:Rider, graph:Graph) -> RoutePlan {
        // Only one rider is allowed (like a Taxi)
        let routeEdge = Route(edges:[self.edge], length:self.edge.length)
        let routeRider = graph.route(from:rider.from, to:rider.to)
        if assigned.count + riders.count > 0 {
            return RoutePlan(score:0, routes:[routeRider])
        }
        let routeToRider = graph.route(from: edge.to, to: rider.from)
        let routes = [routeEdge, routeToRider, routeRider]
        return RoutePlan(score:1/routeToRider.length, routes:routes)
    }
    
    func adapt(plan:RoutePlan, rider:Rider, graph:Graph) {
        self.routes = plan.routes
        self.assigned.append(rider)
        rider.state = .assigned
        rider.hue = self.hue
    }
}


