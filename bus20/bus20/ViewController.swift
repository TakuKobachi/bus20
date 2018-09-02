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
    var start = Date()
    var riders = [Rider]()
    var stopped = false
    var speedMultiple = Metrics.speedMultiple
    
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
        
        Random.seed(0)
        start(count: Metrics.numberOfShuttles)
    }
    
    func start(count:Int) {
        stopped = false
        shuttles = [Shuttle]()
        start = Date()
        riders = [Rider]()
        for i in 0..<count {
            shuttles.append(Shuttle(hue: 1.0/CGFloat(count) * CGFloat(i), index:i*10+i, graph:graph))
        }
        update()
    }
    
    func update() {
        let time = CGFloat(Date().timeIntervalSince(start)) * speedMultiple
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
            if !self.stopped {
                self.update()
            }
        }
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    @IBAction func add(_ sender:UIBarButtonItem) {
        addRider()
    }
    
    func addRider() {
        let rider = Rider(nodes:graph.nodes)
        riders.append(rider)
        assign(rider: rider)
    }
    
    @IBAction func test(_ sender:UIBarButtonItem) {
        //speedMultiple = 30.0
        Random.seed(110) // 4, 40, 110
        print("Seed=", Random.seed)
        
        start(count: 1)
        addRider()
        addRider()
        addRider()
        addRider()
        addRider()
        addRider()
    }
    
    @IBAction func stop(_ sender:UIBarButtonItem) {
        stopped = true
    }
    
    func assign(rider:Rider) {
        let plans = shuttles
            .flatMap({ $0.plans(rider:rider, graph:graph) })
            .sorted { $0.cost < $1.cost }
        let bestPlan = plans[0]
        bestPlan.shuttle.adapt(plan:bestPlan, rider:rider, graph:graph)
    }
}

