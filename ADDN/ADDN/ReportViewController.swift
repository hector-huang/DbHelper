//
//  ReportViewController.swift
//  ADDN
//
//  Created by 黄 康平 on 4/23/17.
//  Copyright © 2017 黄 康平. All rights reserved.
//

import UIKit
import Alamofire

class ReportViewController: UIViewController {
    
    @IBOutlet weak var groupContainerView: UIView!
    @IBOutlet weak var myBMIlabel: CircleLabel!
    @IBOutlet weak var avgBMIlabel: CircleLabel!
    @IBOutlet weak var percentlabel: UILabel!
    @IBOutlet weak var yoursexceedslabel: UILabel!
    @IBOutlet weak var ofpeoplelabel: UILabel!
    @IBOutlet weak var BMIperclabel: countingLabel!
    @IBOutlet weak var progressGroup: MKRingProgressGroupView!
    @IBOutlet weak var okbutton: UIButton!
    @IBOutlet weak var medBMIlabel: CircleLabel!
    // 130.56.248.85
    var BMIpercent = 0
    var BMIavg = 0.00
    var BMImedian = 0.0
    var BMI = 0.00
    var delay: UIActivityIndicatorView = UIActivityIndicatorView(activityIndicatorStyle: UIActivityIndicatorViewStyle.whiteLarge)
    
    override func viewDidLoad() {
        super.viewDidLoad()
        delay.center = CGPoint(x: view.center.x, y: 0.6*view.center.y)
        delay.hidesWhenStopped = true
        view.addSubview(delay)
        delay.startAnimating()
        let bmipostparameters: Parameters = [ "bmi": BMI ]
        let emptyparameters: Parameters = [:]
        Alamofire.request("http://130.56.248.85:3000/rpc/getbmipercent", method: .post, parameters: bmipostparameters).responseJSON { response in
            if let bmipercentJSON = response.result.value {
                print("bmipercent JSON: \(bmipercentJSON)")
                self.BMIpercent = bmipercentJSON as! Int
                if self.BMIpercent < 30 {
                    self.myBMIlabel.textColor = UIColor.gray
                }
                print(self.BMIpercent)
            }
        }
        Alamofire.request("http://130.56.248.85:3000/rpc/getbmimean", method: .post, parameters: emptyparameters).responseJSON { response in
            if let bmiavgJSON = response.result.value {
                print("bmiavg JSON: \(bmiavgJSON)")
                self.BMIavg = bmiavgJSON as! Double
                print(self.BMIavg)
                self.avgBMIlabel.text = "National average is "+String(self.BMIavg)
            }
        }
        Alamofire.request("http://130.56.248.85:3000/rpc/getbmimedian", method: .post, parameters: emptyparameters).responseJSON { response in
            if let bmimedianJSON = response.result.value {
                print("bmimedian JSON: \(bmimedianJSON)")
                self.BMImedian = bmimedianJSON as! Double
                print(self.BMImedian)
                self.medBMIlabel.text = "National median is "+String(self.BMImedian)
            }
        }
        let twodecimalbmi = Double(round(100*BMI)/100)
        myBMIlabel.text = "Your BMI is "+String(twodecimalbmi)
        groupContainerView.center = CGPoint(x: view.center.x, y: 0.6*view.center.y)
        okbutton.frame = CGRect(x: 0.05*view.frame.width, y: 0.1*view.frame.height+0.95*view.frame.width, width:0.9*view.frame.width, height:0.1*view.frame.width)
        myBMIlabel.frame = CGRect(x:groupContainerView.center.x-85, y:groupContainerView.center.y-85, width:170, height:170)
        myBMIlabel.angle = 0.6
        avgBMIlabel.frame = CGRect(x:groupContainerView.center.x-112, y:groupContainerView.center.y-112, width:224, height:224)
        avgBMIlabel.angle = 0.6
        medBMIlabel.frame = CGRect(x:groupContainerView.center.x-139, y:groupContainerView.center.y-139, width:278, height:278)
        medBMIlabel.angle = 0.6
        BMIperclabel.center = CGPoint(x: groupContainerView.center.x-10, y:groupContainerView.center.y)
        percentlabel.center = CGPoint(x: BMIperclabel.center.x+29, y: BMIperclabel.center.y)
        yoursexceedslabel.center = CGPoint(x: groupContainerView.center.x, y:BMIperclabel.center.y-20)
        ofpeoplelabel.center = CGPoint(x: groupContainerView.center.x, y:BMIperclabel.center.y+20)
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
    
    func buttonClicked(_ sender: AnyObject?) {
        if sender === okbutton {
            performSegue(withIdentifier: "nextreportseque", sender: self)
        }
    }
    
    private func updateMainGroupProgress() {
        CATransaction.begin()
        CATransaction.setAnimationDuration(1.0)
        self.progressGroup.ring1.progress = BMImedian/bmi*Double(BMIpercent)/Double(100)
        if self.progressGroup.ring1.progress < 0.25 {
            self.medBMIlabel.textColor = UIColor.gray
        }
        self.medBMIlabel.isHidden = false
        self.progressGroup.ring2.progress = BMIavg/bmi*Double(BMIpercent)/Double(100)
        if self.progressGroup.ring2.progress < 0.30 {
            self.avgBMIlabel.textColor = UIColor.gray
        }
        self.avgBMIlabel.isHidden = false
        self.progressGroup.ring3.progress = Double(BMIpercent)/Double(100)
        delay.stopAnimating()
        BMIperclabel.countFromZero(to: Float(BMIpercent))
        if self.progressGroup.ring3.progress < 0.25 {
            self.myBMIlabel.textColor = UIColor.gray
        }
        self.myBMIlabel.isHidden = false
        CATransaction.commit()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }

}
