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
        
        for i in 0..<Metrics.numberOfShuttles {
            shuttles.append(Shuttle(hue: 1.0/CGFloat(Metrics.numberOfShuttles) * CGFloat(i), index:i*10+i, graph:graph))
        }

        update()
    }
    
    func update() {
        let time = CGFloat(Date().timeIntervalSince(start)) * 3.0
        UIGraphicsBeginImageContextWithOptions(view.frame.size, false, 0.0)
        defer { UIGraphicsEndImageContext() }
        
        let ctx = UIGraphicsGetCurrentContext()!

        shuttles.forEach() {
            $0.update(graph:graph, time:time)
            $0.render(ctx: ctx, graph: graph, scale: scale, time:time)
        }
        
        riders.forEach() {
            $0.render(ctx: ctx, nodes: graph.nodes, scale: scale)
        }
        
        routeView.image = UIGraphicsGetImageFromCurrentImageContext()!
        
        riders = riders.filter {
            $0.state != .done
        }

        DispatchQueue.main.async {
            self.update()
        }
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    @IBAction func add(_ sender:UIBarButtonItem) {
        let rider = Rider(nodes:graph.nodes)
        riders.append(rider)
        assign(rider: rider)
    }
    
    func assign(rider:Rider) {
        let plans = shuttles.map { $0.evaluate(rider:rider, graph:graph) }
        let sorted = (0..<shuttles.count).sorted {
            plans[$0].cost < plans[$1].cost
        }
        let first = sorted[0]

        shuttles[first].adapt(plan:plans[first], rider:rider, graph:graph)
    }
}

