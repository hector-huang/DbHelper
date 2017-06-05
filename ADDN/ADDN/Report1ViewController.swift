//
//  Report1ViewController.swift
//  ADDN
//
//  Created by 黄 康平 on 5/2/17.
//  Copyright © 2017 黄 康平. All rights reserved.
//

import UIKit
import Alamofire

class Report1ViewController: UIViewController {

    @IBOutlet weak var groupContainerView: UIView!
    @IBOutlet weak var yoursexceedslabel: UILabel!
    @IBOutlet weak var Percentlabel: UILabel!
    @IBOutlet weak var MyBMIlabel: CircleLabel!
    @IBOutlet weak var BMIperclabel: countingLabel!
    @IBOutlet weak var Ofpeoplelabel: UILabel!
    @IBOutlet weak var AvgBMIlabel: CircleLabel!
    @IBOutlet weak var MedBMIlabel: CircleLabel!
    @IBOutlet weak var Okbutton: UIButton!
    @IBOutlet weak var progressGroup: MKRingProgressGroupView!
    var delay: UIActivityIndicatorView = UIActivityIndicatorView(activityIndicatorStyle: UIActivityIndicatorViewStyle.whiteLarge)
    
    var hba1cpercent = 0
    var hba1cavg = 0.00
    var hba1cmedian = 0.0
    var hba1c = 0.0
    
    override func viewDidLoad() {
        super.viewDidLoad()
        delay.center = CGPoint(x: view.center.x, y: 0.6*view.center.y)
        delay.hidesWhenStopped = true
        view.addSubview(delay)
        delay.startAnimating()
        let bmipostparameters: Parameters = [ "hba1c": hba1c ]
        let emptyparameters: Parameters = [:]
        
        Alamofire.request("http://130.56.248.85:3000/rpc/gethba1cpercent", method: .post, parameters: bmipostparameters).responseJSON { response in
            if let bmipercentJSON = response.result.value {
                print("bmipercent JSON: \(bmipercentJSON)")
                self.hba1cpercent = bmipercentJSON as! Int
                if self.hba1cpercent < 30 {
                    self.MyBMIlabel.textColor = UIColor.gray
                }
                print(self.hba1cpercent)
            }
        }
        Alamofire.request("http://130.56.248.85:3000/rpc/gethba1cmean", method: .post, parameters: emptyparameters).responseJSON { response in
            if let bmiavgJSON = response.result.value {
                print("bmiavg JSON: \(bmiavgJSON)")
                self.hba1cavg = bmiavgJSON as! Double
                print(self.hba1cavg)
                self.AvgBMIlabel.text = "National average is "+String(self.hba1cavg)
            }
        }
        Alamofire.request("http://130.56.248.85:3000/rpc/gethba1cmedian", method: .post, parameters: emptyparameters).responseJSON { response in
            if let bmimedianJSON = response.result.value {
                print("bmimedian JSON: \(bmimedianJSON)")
                self.hba1cmedian = bmimedianJSON as! Double
                print(self.hba1cmedian)
                self.MedBMIlabel.text = "National median is "+String(self.hba1cmedian)
            }
        }
        let twodecimalbmi = Double(round(100*hba1c)/100)
        MyBMIlabel.text = "Your hba1c is "+String(twodecimalbmi)
        groupContainerView.center = CGPoint(x: view.center.x, y: 0.6*view.center.y)
        // Do any additional setup after loading the view.
        Okbutton.frame = CGRect(x: 0.05*view.frame.width, y: 0.1*view.frame.height+0.95*view.frame.width, width:0.9*view.frame.width, height:0.1*view.frame.width)
        MyBMIlabel.frame = CGRect(x:groupContainerView.center.x-85, y:groupContainerView.center.y-85, width:170, height:170)
        MyBMIlabel.angle = 0.6
        AvgBMIlabel.frame = CGRect(x:groupContainerView.center.x-112, y:groupContainerView.center.y-112, width:224, height:224)
        AvgBMIlabel.angle = 0.6
        MedBMIlabel.frame = CGRect(x:groupContainerView.center.x-139, y:groupContainerView.center.y-139, width:278, height:278)
        MedBMIlabel.angle = 0.6
        BMIperclabel.center = CGPoint(x: groupContainerView.center.x-10, y:groupContainerView.center.y)
        Percentlabel.center = CGPoint(x: BMIperclabel.center.x+29, y: BMIperclabel.center.y)
        yoursexceedslabel.center = CGPoint(x: groupContainerView.center.x, y:BMIperclabel.center.y-20)
        Ofpeoplelabel.center = CGPoint(x: groupContainerView.center.x, y:BMIperclabel.center.y+20)
    }
    
    override func viewDidAppear(_ animated: Bool) {
        progressGroup.ringWidth = view.bounds.width * 0.08
        CATransaction.begin()
        CATransaction.setAnimationDuration(0.0)
        self.progressGroup.ring1.progress = 0.0
        self.progressGroup.ring2.progress = 0.0
        self.progressGroup.ring3.progress = 0.0
        CATransaction.commit()
        UIView.animate(withDuration: 0.3, delay: 0.0, usingSpringWithDamping: 0.9, initialSpringVelocity: 0.0, options: [], animations: { () -> Void in
            self.groupContainerView.transform = CGAffineTransform.identity
            }, completion: { (_) -> Void in
                
                self.updateMainGroupProgress()
        })
        
    }
    
    private func updateMainGroupProgress() {
        CATransaction.begin()
        CATransaction.setAnimationDuration(1.0)
        self.progressGroup.ring1.progress = hba1cmedian/hba1c*Double(hba1cpercent)/Double(100)
        if self.progressGroup.ring1.progress < 0.25 {
            self.MedBMIlabel.textColor = UIColor.gray
        }
        self.MedBMIlabel.isHidden = false
        self.progressGroup.ring2.progress = hba1cavg/hba1c*Double(hba1cpercent)/Double(100)
        if self.progressGroup.ring2.progress < 0.30 {
            self.AvgBMIlabel.textColor = UIColor.gray
        }
        self.AvgBMIlabel.isHidden = false
        self.progressGroup.ring3.progress = Double(hba1cpercent)/Double(100)
        delay.stopAnimating()
        BMIperclabel.countFromZero(to: Float(hba1cpercent))
        if self.progressGroup.ring3.progress < 0.25 {
            self.MyBMIlabel.textColor = UIColor.gray
            
        }
        self.MyBMIlabel.isHidden = false
        CATransaction.commit()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
}
