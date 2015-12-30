//
//  ViewController.swift
//  Earthquakes At a Glance
//
//  Created by jeff cohen on 9/21/15.
//  Copyright (c) 2015 JBC. All rights reserved.
//

import UIKit

class ViewController: UIViewController {
    
    var timer = NSTimer()
    
    @IBOutlet weak var today: UILabel!
    
    @IBOutlet weak var biggest: UILabel!
    
    @IBAction func refresh(sender: AnyObject) {
        
        scrape()
        
    }
    
    @IBOutlet weak var web: UIBarButtonItem!
    
    func showError() {
        
        print("Was not able to locate the website")
        
    }
    
    var previous:String = ""
    
    var new:String = ""
    
    func scrape() {
        
        let url = NSURL(string: "http://earthquaketrack.com/recent")
        
        if url != nil {

            let task = NSURLSession.sharedSession().dataTaskWithURL(url!, completionHandler: { (data, response, error) -> Void in

                var urlError = false
                
                var biggestString = ""
                
                var todayString = ""

                if error == nil {

                    let urlContent = NSString(data: data!, encoding: NSUTF8StringEncoding) as NSString!
                    
                    var urlContentArray = urlContent.componentsSeparatedByString("<ul class=\"list-unstyled\">")
                    
                    var urlContentArray2 = urlContentArray[2].componentsSeparatedByString("Earthquake Alerts via Twitter")
                    
                    if urlContentArray.count > 1 {

                        var textArray = urlContentArray[1].componentsSeparatedByString("</ul>")
                        
                        todayString = textArray[0] 
                        
                        todayString = todayString.stringByReplacingOccurrencesOfString("<li>", withString: "")
                        todayString = todayString.stringByReplacingOccurrencesOfString("</li>", withString: "")
                        
                        if urlContentArray.count > 2 {
                            
                            var biggestArray = urlContentArray2[0].componentsSeparatedByString("</a>")
                            
                            for (var i = 0; i < biggestArray.count; i++) {
                                
                                let big = biggestArray[i] 
                                
                                biggestString += big.stringByReplacingOccurrencesOfString("</a>", withString: "")

                            }
                            
                            biggestString = biggestString.stringByReplacingOccurrencesOfString("<[^>]+>", withString: "", options: .RegularExpressionSearch, range: nil)
                            
                            biggestString = biggestString.stringByReplacingOccurrencesOfString(" ", withString: "", options: .RegularExpressionSearch, range: nil)
                            
                            biggestString = biggestString.stringByReplacingOccurrencesOfString("\n", withString: "", options: .RegularExpressionSearch, range: nil)
                            
                            biggestString = biggestString.stringByReplacingOccurrencesOfString("in", withString: " ", options: .RegularExpressionSearch, range: nil)
                            
                            biggestString = biggestString.stringByReplacingOccurrencesOfString("this", withString: "\nThis ", options: .RegularExpressionSearch, range: nil)
                            
                            biggestString = biggestString.stringByReplacingOccurrencesOfString("today", withString: "Today", options: .RegularExpressionSearch, range: nil)
                            
                            biggestString = biggestString.stringByReplacingOccurrencesOfString(":", withString: ": ", options: .RegularExpressionSearch, range: nil)
                            
                            self.previous = self.new as String
                            
                            self.new = todayString + biggestString
                            
                        }
                        
                    } else {
                        
                        urlError = true
                        
                    }
                    
                
                } else {
                    
                    urlError = true
                    
                }
                
                dispatch_async(dispatch_get_main_queue()) {
                    
                    if urlError == true {
                        
                        self.showError()
                        
                    } else {
                        
                        if self.new.isEqual(self.previous) {
                            
                            self.web.title = ""
                            
                        } else {
                            
                            self.web.title = "Updated"
                            
                        }
                        
                        self.today.text = "There have been: (M1.5 or greater)\n" + todayString
                        
                        self.biggest.text = "The biggest earthquake:\n\n" + biggestString
                        
                    }
                }
                
            })
            
            task.resume()
            
            
        } else {
            
            showError()
            
        }
        
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        
        timer = NSTimer.scheduledTimerWithTimeInterval(5, target: self, selector: Selector("scrape"), userInfo: nil, repeats: true)

        scrape()
        
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }


}

