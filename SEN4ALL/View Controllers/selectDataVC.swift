//
//  selectDataVC.swift
//  SEN4ALL
//
//  Created by ERASMICOIN on 02/10/23.
//

import UIKit
import FSCalendar

protocol selectDataVCDelegate {
    func applyDate(date: Date)
}

class selectDataVC: UIViewController, FSCalendarDataSource, FSCalendarDelegate {

    @IBOutlet weak var calendarView: UIView!
    @IBOutlet weak var calendar: FSCalendar!
    @IBOutlet weak var monthLabel: UILabel!
    @IBOutlet weak var dateLabel: UILabel!
    
    var delegate: selectDataVCDelegate?
    var selectedDate: Date?
    
    @IBAction func applyAction(_ sender: UIButton) {
        delegate?.applyDate(date: selectedDate!)
        self.dismiss(animated: true)
    }
    
    @IBAction func exitAction(_ sender: UIButton) {
        self.dismiss(animated: true)
    }
    
    @IBAction func nextMonth(_ sender: UIButton) {
        let month = Calendar.current.date(byAdding: .month, value: 1, to: calendar.currentPage)
        calendar.setCurrentPage(month!, animated: true)
        
    }
    
    
    @IBAction func prevMonth(_ sender: UIButton) {
        let month = Calendar.current.date(byAdding: .month, value: -1, to: calendar.currentPage)
        calendar.setCurrentPage(month!, animated: true)
       
    }
    
    
    // MARK: - FSCalendar Delegate
    
    func calendar(_ calendar: FSCalendar, didSelect date: Date, at monthPosition: FSCalendarMonthPosition) {
       
        let dataEstratta = getFormattedDate(date: date, format: "E d MMM yyyy")
        
        dateLabel.text = dataEstratta
        
        selectedDate = date
       
        
    }
    
    func calendarCurrentPageDidChange(_ calendar: FSCalendar) {
        let dataAttuale = getFormattedDate(date: calendar.currentPage, format: "MMMM yyyy")
        monthLabel.text = dataAttuale
    }
    
    func maximumDate(for calendar: FSCalendar) -> Date {
        return Date()
    }
    
    // MARK: - Helpers
    
    
    func getFormattedDate(date: Date, format: String) -> String {
            let dateformat = DateFormatter()
            dateformat.dateFormat = format
            return dateformat.string(from: date)
    }
    
    
    // MARK: - Overrides
    
    override var prefersStatusBarHidden: Bool {
        return true
    }
    
    override func viewDidLoad() {
        calendarView.layer.cornerRadius = 12
        calendarView.layer.masksToBounds = true
       
        
        calendar.select(selectedDate)
        
        let dataEstratta = getFormattedDate(date: selectedDate!, format: "E d MMM yyyy")
        dateLabel.text = dataEstratta
        let dataAttuale = getFormattedDate(date: selectedDate!, format: "MMMM yyyy")
      
        
        monthLabel.text = dataAttuale
        super.viewDidLoad()

        // Do any additional setup after loading the view.
    }
    

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */

}
