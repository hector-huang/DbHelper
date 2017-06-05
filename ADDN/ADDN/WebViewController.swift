//
//  WebViewController.swift
//  ADDN
//
//  Created by 黄 康平 on 5/22/17.
//  Copyright © 2017 黄 康平. All rights reserved.
//

import UIKit

class WebViewController: UIViewController {

    @IBOutlet weak var webview: UIWebView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        let url = NSURL (string:"https://diabeteshelpersite.wordpress.com");
        let requestObj = NSURLRequest(url: url! as URL);
        self.webview.loadRequest(requestObj as URLRequest)
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}
