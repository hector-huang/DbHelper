//
//  ProfileViewController.swift
//  ADDN
//
//  Created by 黄 康平 on 4/24/17.
//  Copyright © 2017 黄 康平. All rights reserved.
//

import UIKit
import CoreData

class ProfileViewController: UIViewController, UIPickerViewDataSource, UIPickerViewDelegate {
    
    @IBOutlet weak var ageicon: UIImageView!
    @IBOutlet weak var gendericon: UIImageView!
    @IBOutlet weak var durationicon: UIImageView!
    @IBOutlet weak var hba1cicon: UIImageView!
    @IBOutlet weak var heighticon: UIImageView!
    @IBOutlet weak var weighticon: UIImageView!
    @IBOutlet weak var ageinput: UITextField!
    @IBOutlet weak var genderinput: UITextField!
    @IBOutlet weak var durationinput: UITextField!
    @IBOutlet weak var hba1cinput: UITextField!
    @IBOutlet weak var heightinput: UITextField!
    @IBOutlet weak var weightinput: UITextField!
    @IBOutlet weak var backbutton: UIButton!
    @IBOutlet weak var finishbutton: UIButton!
    var people: [NSManagedObject] = []
    
    @IBAction func finishbutton(_ sender: UIButton) {
        if ageinput.text != "" {
            age = Int(ageinput.text!)!
            let fetchRequest: NSFetchRequest<Person> = Person.fetchRequest()
            do{
                let sortDescriptor = NSSortDescriptor(key: "creationDate", ascending: false)
                fetchRequest.sortDescriptors = [sortDescriptor]
                fetchRequest.fetchLimit = 1
                let searchPersonResult = try DatabaseController.getContext().fetch(fetchRequest)
                let personResult = searchPersonResult[0]
                personResult.setValue(age, forKey: "age")
            }
            catch{
                print("Error: \(error)")
            }
        }
        if genderinput.text != "" {
			gender = genderinput.text!
        }
        if durationinput.text != "" {
            duration = Double(durationinput.text!)!
        }
        let health:Health = NSEntityDescription.insertNewObject(forEntityName: "Health", into: DatabaseController.getContext()) as! Health
        if hba1cinput.text != "" {
            health.hba1c = NSDecimalNumber(string: hba1cinput.text)
            DatabaseController.saveContext()
        }
        if heightinput.text != "" {
            health.height = NSDecimalNumber(string: heightinput.text)
            DatabaseController.saveContext()
        }
        if weightinput.text != "" {
            health.weight = NSDecimalNumber(string: weightinput.text)
            DatabaseController.saveContext()
        }
    }
    
    var genderdata = ["Male","Female","Unisex"]
    var genderpicker = UIPickerView()
    
    func numberOfComponents(in pickerView: UIPickerView) -> Int{
        return 1
    }
    
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int{
        return genderdata.count
    }
    
    func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        genderinput.text = genderdata[row]
    }
    
    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        return genderdata[row]
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        
        ageicon.frame = CGRect(x: 0.05*view.frame.width, y: 0.1*view.frame.height, width:0.1*view.frame.width, height:0.1*view.frame.width)
        ageinput.frame = CGRect(x: 0.2*view.frame.width, y: 0.105*view.frame.height, width:0.75*view.frame.width, height:0.1*view.frame.width-0.01*view.frame.height)
        gendericon.frame = CGRect(x: 0.05*view.frame.width, y: 0.1*view.frame.height+0.15*view.frame.width, width:0.1*view.frame.width, height:0.1*view.frame.width)
        genderinput.frame = CGRect(x: 0.2*view.frame.width, y: 0.105*view.frame.height+0.15*view.frame.width, width:0.75*view.frame.width, height:0.1*view.frame.width-0.01*view.frame.height)
        durationicon.frame = CGRect(x: 0.05*view.frame.width, y: 0.1*view.frame.height+0.3*view.frame.width, width:0.1*view.frame.width, height:0.1*view.frame.width)
        durationinput.frame = CGRect(x: 0.2*view.frame.width, y: 0.105*view.frame.height+0.3*view.frame.width, width:0.75*view.frame.width, height:0.1*view.frame.width-0.01*view.frame.height)
        hba1cicon.frame = CGRect(x: 0.05*view.frame.width, y: 0.1*view.frame.height+0.45*view.frame.width, width:0.1*view.frame.width, height:0.1*view.frame.width)
        hba1cinput.frame = CGRect(x: 0.2*view.frame.width, y: 0.105*view.frame.height+0.45*view.frame.width, width:0.75*view.frame.width, height:0.1*view.frame.width-0.01*view.frame.height)
        heighticon.frame = CGRect(x: 0.05*view.frame.width, y: 0.1*view.frame.height+0.6*view.frame.width, width:0.1*view.frame.width, height:0.1*view.frame.width)
        heightinput.frame = CGRect(x: 0.2*view.frame.width, y: 0.105*view.frame.height+0.6*view.frame.width, width:0.75*view.frame.width, height:0.1*view.frame.width-0.01*view.frame.height)
        weighticon.frame = CGRect(x: 0.05*view.frame.width, y: 0.1*view.frame.height+0.75*view.frame.width, width:0.1*view.frame.width, height:0.1*view.frame.width)
        weightinput.frame = CGRect(x: 0.2*view.frame.width, y: 0.105*view.frame.height+0.75*view.frame.width, width:0.75*view.frame.width, height:0.1*view.frame.width-0.01*view.frame.height)
        finishbutton.frame = CGRect(x: 0.05*view.frame.width, y: 0.1*view.frame.height+0.95*view.frame.width, width:0.9*view.frame.width, height:0.1*view.frame.width)
        backbutton.frame = CGRect(x: 0.05*view.frame.width, y: 25, width: 0.1*view.frame.width, height: 30)
        backbutton.layer.cornerRadius = 5
    }
    
    override func viewDidAppear(_ animated: Bool) {
        let fetchPersonRequest: NSFetchRequest<Person> = Person.fetchRequest()
        do{
            let sortDescriptor = NSSortDescriptor(key: "creationDate", ascending: false)
            fetchPersonRequest.sortDescriptors = [sortDescriptor]
            fetchPersonRequest.fetchLimit = 1
            let searchPersonResult = try DatabaseController.getContext().fetch(fetchPersonRequest)
            let personResult = searchPersonResult[0]
            print(personResult)
            if personResult.age != 0 {
                ageinput.text = String(personResult.age)
            }
            if personResult.gender != "" {
                genderinput.text = personResult.gender
            }
        }
        catch{
            print("Error: \(error)")
        }
        
        genderpicker.delegate = self
        genderpicker.dataSource = self
        genderinput.inputView = genderpicker
        genderinput.text = gender
        let toolbar = UIToolbar()
        toolbar.sizeToFit()
        let flexiblespace = UIBarButtonItem(barButtonSystemItem: UIBarButtonSystemItem.flexibleSpace, target: nil, action: nil)
        let doneButton = UIBarButtonItem(barButtonSystemItem: UIBarButtonSystemItem.done, target: self, action: #selector(self.doneClicked))
        toolbar.setItems([flexiblespace, doneButton], animated: false)
        ageinput.inputAccessoryView = toolbar
        genderinput.inputAccessoryView = toolbar
        durationinput.inputAccessoryView = toolbar
        hba1cinput.inputAccessoryView = toolbar
        heightinput.inputAccessoryView = toolbar
        weightinput.inputAccessoryView = toolbar
    }
    
    func doneClicked() {
        view.endEditing(true)
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }

}
