//
//  History1ViewController.swift
//  ADDN
//
//  Created by 黄 康平 on 5/8/17.
//  Copyright © 2017 黄 康平. All rights reserved.
//

import UIKit
import CoreData
import JTAppleCalendar
import Charts
import Alamofire

class History1ViewController: UIViewController, ChartViewDelegate {
    @IBOutlet weak var rangeText: UILabel!
    @IBOutlet weak var calendarView: JTAppleCalendarView!
    @IBOutlet weak var year: UILabel!
    @IBOutlet weak var month: UILabel!
    @IBOutlet weak var lineChartView: BarChartView!
    
    let outsideMonthColor = UIColor(colorWithHexValue: 0x5B5163)
    let monthColor = UIColor.white
    let selectedMonthColor = UIColor(colorWithHexValue: 0x3a294b)
    let currentDateSelectedViewColor = UIColor(colorWithHexValue: 0x8A7F95)
    let todayColor = UIColor(colorWithHexValue: 0xfbc94d)

    let formatter = DateFormatter()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        getMedian() {value, error in
            let hba1cMedian = value?.doubleValue
            let hba1cThreshold = hba1cMedian!*1.1
            self.rangeText.text?.append(String(hba1cThreshold))
        }
        
        lineChartView.delegate = self
        setupCalendarView()
        let fetchRequest: NSFetchRequest<Health> = Health.fetchRequest()
        do{
            let searchHealthResult = try DatabaseController.getContext().fetch(fetchRequest)
            for result in searchHealthResult as [Health]{
                print("\(result.creationDate) 's hba2c is \(result.hba1c!)")
            }
        }
        catch{
            print("Error: \(error)")
        }
    }
    
    func setChartData(healthvalues: [Health]){
        self.formatter.dateFormat = "MMMM dd"
        var days = [String]()
        var value = [NSDecimalNumber]()
        for healthvalue in healthvalues {
            days.append(self.formatter.string(from: healthvalue.creationDate as! Date))
            value.append(healthvalue.hba1c!)
        }
        lineChartView.noDataTextColor = monthColor
        lineChartView.noDataText = "No data provided"
        lineChartView.xAxis.labelTextColor = currentDateSelectedViewColor
        lineChartView.leftAxis.labelTextColor = currentDateSelectedViewColor
        lineChartView.rightAxis.labelTextColor = currentDateSelectedViewColor
        lineChartView.legend.textColor = monthColor
        lineChartView.backgroundColor = selectedMonthColor
        lineChartView.chartDescription?.text = ""
        lineChartView.animate(xAxisDuration: 2.0, yAxisDuration: 2.0)
        lineChartView.leftAxis.axisMinimum = 3.5
        lineChartView.rightAxis.axisMinimum = 3.5
        

        lineChartView.setBarChartData(xValues:days, yValues: value as [Double], label: "hba1c Daily Records")
    }
    
    func chartValueSelected(_ chartView: ChartViewBase, entry: ChartDataEntry, highlight: Highlight) {
        let hba1c = Double(entry.y)
        let next = self.storyboard?.instantiateViewController(withIdentifier: "hba1cAnalysis") as! Report1ViewController
        next.hba1c = hba1c
        self.present(next, animated: false, completion: nil)
    }
    
    func getCoredataInCurrentmonth(from visibleDates: DateSegmentInfo) -> [Health]{
        self.formatter.dateFormat = "MM dd"
        var currentMonthHealth = [Health]()
        let monthdates = visibleDates.monthDates
        for date in monthdates {
            let monthdate = self.formatter.string(from: date.date)
            let fetchRequest: NSFetchRequest<Health> = Health.fetchRequest()
            let sortDescriptor = NSSortDescriptor(key: "creationDate", ascending: false)
            fetchRequest.sortDescriptors = [sortDescriptor]

            do{
                let searchHealthResult = try DatabaseController.getContext().fetch(fetchRequest)
                for result in searchHealthResult as [Health]{
                    let resultdate = self.formatter.string(from: result.creationDate as! Date)
                    if (monthdate == resultdate){
                        currentMonthHealth.append(result)
                        break
                    }
                }
            }
            catch{
                print("Error: \(error)")
            }
        }
        print(currentMonthHealth)
        return currentMonthHealth
    }
    
    func setupCalendarView() {
        calendarView.scrollToDate(NSDate() as Date, triggerScrollToDateDelegate: true, animateScroll: false, preferredScrollPosition: nil, extraAddedOffset: 0, completionHandler: nil)
        calendarView.selectDates([NSDate() as Date])
        
        //Setup calendar spacing
        calendarView.minimumLineSpacing = 0
        calendarView.minimumInteritemSpacing = 0
        
        //Setup labels
        calendarView.visibleDates{ (visibleDates) in
            self.setupViewOfCalendar(from: visibleDates)
        }
    }
    
    func handleCelltick(view: JTAppleCell?, cellState: CellState){
        guard let validCell = view as? CustomCell else {
            return
        }
        if ifAmongCreationdate(cellState: cellState){
            getMedian() {value, error in
                let hba1cMedian = value?.doubleValue
                let hba1cThreshold = hba1cMedian!*1.1
                print("Threshold of hba1c \(hba1cThreshold)")
                if self.ifNormal(cellState: cellState, threshold: hba1cThreshold){
                    validCell.tickImage.image = #imageLiteral(resourceName: "tick")
                }
                else{
                    let initialwidth = validCell.tickImage.frame.width
                    let initialheight = validCell.tickImage.frame.height
                    validCell.tickImage.frame = CGRect(x: 0, y: 0, width: 0.6*initialwidth, height: 0.6*initialheight)
                    validCell.tickImage.center = CGPoint(x: validCell.dataLabel.center.x, y: validCell.dataLabel.center.y+13)
                    validCell.tickImage.image = #imageLiteral(resourceName: "wrong")
                }
            }
                validCell.tickImage.isHidden = false
        }
        else{
            validCell.tickImage.isHidden = true
        }
    }
    
    func ifAmongCreationdate(cellState: CellState) -> Bool{
        self.formatter.dateFormat = "yyyy MM dd"
        formatter.timeZone = Calendar.current.timeZone
        let calendarDate = self.formatter.string(from: cellState.date)
        let fetchRequest: NSFetchRequest<Health> = Health.fetchRequest()
        do{
            let searchHealthResult = try DatabaseController.getContext().fetch(fetchRequest)
            for result in searchHealthResult as [Health]{
                let creationDate = self.formatter.string(from: result.creationDate as! Date)
                if creationDate == calendarDate{
                    return true
                }
            }
            return false
        }
        catch{
            print("Error: \(error)")
            return false
        }
    }
    
    func getMedian(completionHandler: @escaping (AnyObject?, NSError?) -> ()){
        let emptyparameters: Parameters = [:]
        Alamofire.request("http://130.56.248.85:3000/rpc/gethba1cmedian", method: .post, parameters: emptyparameters).responseJSON { response in
            switch response.result {
            case .success(let value):
                completionHandler(value as AnyObject?, nil)
            case .failure(let error):
                completionHandler(nil, error as NSError?)
            }
        }
    }
    
    func ifNormal(cellState: CellState, threshold: Double) -> Bool{
        
        self.formatter.dateFormat = "yyyy MM dd"
        formatter.timeZone = Calendar.current.timeZone
        let calendarDate = self.formatter.string(from: cellState.date)
        let fetchRequest: NSFetchRequest<Health> = Health.fetchRequest()
        
        do{
            let searchHealthResult = try DatabaseController.getContext().fetch(fetchRequest)
            
            var latestResult = 0.0
            for result in searchHealthResult as [Health]{
                let creationDate = self.formatter.string(from: result.creationDate as! Date)
                if creationDate == calendarDate{
                    latestResult = Double(result.hba1c!)
                }
            }
            if latestResult < threshold{
                return true
            }
            return false
        }
        catch{
            print("Error: \(error)")
            return false
        }
    }
    
    func handleCelltextColor(view: JTAppleCell?, cellState: CellState){
        guard let validCell = view as? CustomCell else {
            return
        }
        if validCell.isSelected {
            validCell.dataLabel.textColor = selectedMonthColor
        }
        else {
            self.formatter.dateFormat = "yyyy MM dd"
            let calendarDate = self.formatter.string(from: cellState.date)
            let today = self.formatter.string(from: NSDate() as Date)
            if calendarDate == today {
                validCell.dataLabel.textColor = todayColor
                validCell.dataLabel.font = UIFont(name: "HelveticaNeue-Bold", size: 20)
            }
            else {
                validCell.dataLabel.font = UIFont(name: "System", size: 17)
                if cellState.dateBelongsTo != .thisMonth {
                    validCell.dataLabel.textColor = outsideMonthColor
                }
                else {
                    if calendarDate > today {
                        validCell.dataLabel.textColor = currentDateSelectedViewColor
                    }
                    else {
                        validCell.dataLabel.textColor = monthColor
                    }
                }
            }
        }
    }
    
    func handleCellSelected(view: JTAppleCell?, cellState: CellState){
        guard let validCell = view as? CustomCell else {
            return
        }
        if validCell.isSelected {
            validCell.selectedView.isHidden = false
        }
        else {
            validCell.selectedView.isHidden = true
        }
    }
    
    func setupViewOfCalendar(from visibleDates: DateSegmentInfo){
        let date = visibleDates.monthDates.first!.date
        
        self.formatter.dateFormat = "yyyy"
        self.year.text = self.formatter.string(from: date)
        
        self.formatter.dateFormat = "MMMM"
        self.month.text = self.formatter.string(from: date)
        
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
}

extension History1ViewController: JTAppleCalendarViewDataSource {
    func configureCalendar(_ calendar: JTAppleCalendarView) -> ConfigurationParameters{
        formatter.dateFormat = "yyyy MM dd"
        formatter.timeZone = Calendar.current.timeZone
        formatter.locale = Calendar.current.locale
        
        let startDate = formatter.date(from: "2017 01 01")!
        let endDate = formatter.date(from: "2017 12 31")!
        
        let parameters = ConfigurationParameters(startDate: startDate, endDate: endDate, numberOfRows: 5, calendar: Calendar.current, generateInDates: .forAllMonths, generateOutDates: .tillEndOfRow, firstDayOfWeek: .sunday, hasStrictBoundaries: true)
        return parameters
    }
}

extension History1ViewController: JTAppleCalendarViewDelegate {
    // Display the cell
    func calendar(_ calendar: JTAppleCalendarView, cellForItemAt date: Date, cellState: CellState, indexPath: IndexPath) -> JTAppleCell {
        let cell = calendar.dequeueReusableJTAppleCell(withReuseIdentifier: "CustomCell", for: indexPath) as! CustomCell
        cell.dataLabel.text = cellState.text
        handleCellSelected(view: cell, cellState: cellState)
        handleCelltextColor(view: cell, cellState: cellState)
        handleCelltick(view: cell, cellState: cellState)
        return cell
    }
    
    func calendar(_ calendar: JTAppleCalendarView, didSelectDate date: Date, cell: JTAppleCell?, cellState: CellState) {
        handleCellSelected(view: cell, cellState: cellState)
        handleCelltextColor(view: cell, cellState: cellState)
    }
    
    func calendar(_ calendar: JTAppleCalendarView, didDeselectDate date: Date, cell: JTAppleCell?, cellState: CellState) {
        handleCellSelected(view: cell, cellState: cellState)
        handleCelltextColor(view: cell, cellState: cellState)
    }
    func calendar(_ calendar: JTAppleCalendarView, didScrollToDateSegmentWith visibleDates: DateSegmentInfo) {
        setupViewOfCalendar(from: visibleDates)
        setChartData(healthvalues: getCoredataInCurrentmonth(from: visibleDates))
    }
}

extension BarChartView {
    
    private class BarChartFormatter: NSObject, IAxisValueFormatter {
        
        var labels: [String] = []
        
        func stringForValue(_ value: Double, axis: AxisBase?) -> String {
            return labels[Int(value)]
        }
        
        init(labels: [String]) {
            super.init()
            self.labels = labels
        }
    }
    
    func setBarChartData(xValues: [String], yValues: [Double], label: String) {
        
        var dataEntries: [BarChartDataEntry] = []
        
        for i in 0..<yValues.count {
            let dataEntry = BarChartDataEntry(x: Double(i), y: yValues[i])
            dataEntries.append(dataEntry)
        }
        
        let chartDataSet = BarChartDataSet(values: dataEntries, label: label)
        chartDataSet.valueColors = [UIColor.white]
        chartDataSet.valueFont = UIFont(name: "HelveticaNeue", size: 12)!

        let chartData = BarChartData(dataSet: chartDataSet)
        chartData.barWidth = 0.618
        
        let chartFormatter = BarChartFormatter(labels: xValues)
        let xAxis = XAxis()
        xAxis.valueFormatter = chartFormatter
        self.xAxis.valueFormatter = xAxis.valueFormatter
        
        self.data = chartData
    }
}

extension UIColor {
    convenience init(colorWithHexValue value: Int, alpha:CGFloat = 1.0) {
        self.init(
            red: CGFloat((value & 0xFF0000) >> 16) / 255.0,
            green: CGFloat((value & 0x00FF00) >> 8) / 255.0,
            blue: CGFloat((value & 0x0000FF)) / 255.0,
            alpha: alpha
        )
    }
}

