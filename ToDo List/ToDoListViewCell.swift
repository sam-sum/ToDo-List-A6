//
//  MAPD714 F2022
//  Assignment 6
//  ToDo List App
//  Part 2 - Code the app functions
//  Group 9
//  Member: Suen, Chun Fung (Alan) 301277969
//          Sum, Chi Hung (Samuel) 300858503
//          Wong, Po Lam (Lizolet) 301258847
//
//  ToDoListViewCell.swift
//  ToDo List
//  Date: Dec 4, 2022
//  Version: 1.0
//

import UIKit

protocol ToDoListViewCellDelegate: AnyObject {
    func didChangeSwitchValue(with tag: Int, value: Bool)
    func didClickedEditButton(with tag: Int)
}

class ToDoListViewCell: UITableViewCell {
/*
    @IBOutlet weak var switchIsCompleted: UISwitch!{
        didSet {
            switchIsCompleted.thumbTintColor = .white
            switchIsCompleted.tintColor = .systemGray6
            switchIsCompleted.onTintColor = .systemGray2
            switchIsCompleted.backgroundColor = .white
            switchIsCompleted.layer.cornerRadius = 16.0
        }
    }
*/
    @IBOutlet weak var lblTitle: UILabel!
    @IBOutlet weak var lblDesc: UILabel!
    @IBOutlet weak var viewCell: UIView!
    
    private var tagSwitch: Int = 0
    private var tagEditButton: Int = 0
    
    weak var delegate: ToDoListViewCellDelegate?
    
    static let identifier = "ToDoListViewCell"
    
    static func nib() -> UINib {
        return UINib(nibName: "ToDoListViewCell", bundle: nil)
    }

    // *****
    // Notify the parent view controller about the switch value changes
    // *****
    @IBAction func didChangeSwitchValue(_ sender: UISwitch) {
        delegate?.didChangeSwitchValue(with: tagSwitch, value: sender.isOn)
    }
    
    // *****
    // Notify the parent view controller about the button click event
    // *****
    @IBAction func didClickedEditButton(_ sender: UIButton) {
        delegate?.didClickedEditButton(with: tagEditButton)
    }
    
    // *****
    // Config the content of a table cell
    // *****
    func configure(with item: ToDoItem, row: Int) {
        self.tagSwitch = row
        self.tagEditButton = row
        //switchIsCompleted.tag = row
        //switchIsCompleted.setOn(item.isCompleted, animated: false)
        lblTitle.text = item.name
        lblDesc.text = getDescription(item)
        if item.isCompleted {
            viewCell.backgroundColor = Utility.getUIColor("#AAAAAA")
            lblDesc.textColor = UIColor.white
            lblDesc.backgroundColor = UIColor.clear
        } else {
            viewCell.backgroundColor = Utility.getUIColor("#FF9292")
        }
    }
    
    // *****
    // Determine the decription according to the item content
    // *****
    func getDescription(_ item: ToDoItem) -> String {
        var desc = "No due date"
        lblDesc.textColor = UIColor.white
        lblDesc.backgroundColor = UIColor.clear
        
        if item.hasDueDate {
            let dateFormatter = DateFormatter()
            dateFormatter.dateFormat = "MMM d, yyyy @h:mm a"
            dateFormatter.locale = Locale(identifier: "ca")
            if let theDate = item.dueDate {

                //check for due date has passed
                let now = Date.now
                if theDate < now {
                    lblDesc.textColor = UIColor.red
                    lblDesc.backgroundColor = Utility.getUIColor("#F6F6F6")
                    desc = "Late: \(dateFormatter.string(from: theDate))"
                } else {
                    desc = "Due date: \(dateFormatter.string(from: theDate))"
                }
            }
        }
        
        return desc
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }
}
