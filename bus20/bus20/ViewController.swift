//
//  ViewController.swift
//  bus20
//
//  Created by SATOSHI NAKAJIMA on 8/27/18.
//  Copyright © 2018 SATOSHI NAKAJIMA. All rights reserved.
//

import UIKit

class ViewController: UIViewController {
    @IBOutlet var viewMain:UIView!
    let graph = Graph(w: 10, h: 10, unit: 1.0)
    var routeView:UIImageView!
    var scale = CGFloat(1.0)
    var shuttles = [Shuttle]()
    let start = Date()
    var riders = [Rider]()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        let frame = view.frame
        let mapView = UIImageView(frame: frame)
        scale = min(frame.size.width / 11.0,
                        frame.size.height / 11.0)
        UIGraphicsBeginImageContextWithOptions(frame.size, true, 0.0)
        defer { UIGraphicsEndImageContext() }
        
        let ctx = UIGraphicsGetCurrentContext()!
        graph.render(ctx:ctx, frame: frame, scale:scale)
        mapView.image = UIGraphicsGetImageFromCurrentImageContext()

        viewMain.addSubview(mapView)

        routeView = UIImageView(frame:frame)
        viewMain.addSubview(routeView)
        
        for i in 0..<8 {
            shuttles.append(Shuttle(hue: 0.125 * CGFloat(i), index:i*10+i, nodes:graph.nodes))
        }

        update()
    }
    
    func update() {
        let time = CGFloat(Date().timeIntervalSince(start)) * 1.0
        UIGraphicsBeginImageContextWithOptions(view.frame.size, false, 0.0)
        defer { UIGraphicsEndImageContext() }
        
        let ctx = UIGraphicsGetCurrentContext()!
        ctx.setLineWidth(10.0)
        ctx.setLineCap(.round)
        ctx.setLineJoin(.round)
        
        UIColor(hue: 1.0, saturation: 1.0, brightness: 1.0, alpha: 0.2).setStroke()
        var route = Graph.shortest(nodes:graph.nodes, start: 0, end: 37)
        route.render(ctx: ctx, nodes: graph.nodes, scale: scale)
        
        UIColor(hue: 0.25, saturation: 1.0, brightness: 1.0, alpha: 0.2).setStroke()
        route = Graph.shortest(nodes:graph.nodes,start: 18, end: 84)
        route.render(ctx: ctx, nodes: graph.nodes, scale: scale)
        
        UIColor(hue: 0.50, saturation: 1.0, brightness: 1.0, alpha: 0.2).setStroke()
        route = Graph.shortest(nodes:graph.nodes, start: 78, end: 33)
        route.render(ctx: ctx, nodes: graph.nodes, scale: scale)

        for shuttle in shuttles {
            shuttle.render(ctx: ctx, nodes: graph.nodes, scale: scale, time:time)
        }
        
        ctx.setLineWidth(1.0)
        for rider in riders {
            rider.render(ctx: ctx, nodes: graph.nodes, scale: scale)
        }
        
        routeView.image = UIGraphicsGetImageFromCurrentImageContext()!

        DispatchQueue.main.async {
            self.update()
        }
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    @IBAction func add(_ sender:UIBarButtonItem) {
        print("add")
        riders.append(Rider(graph:graph))
    }
}

