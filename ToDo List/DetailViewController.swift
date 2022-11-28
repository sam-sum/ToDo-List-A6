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
//  DetailViewController.swift
//  ToDo List
//  Date: Dec 4, 2022
//  Version: 1.0
//

import UIKit

class DetailViewController: UIViewController, UITextViewDelegate, UITextFieldDelegate {
    
    private var toDoList: ToDoList!
    
    @IBOutlet weak var nameLabel: UILabel!
    @IBOutlet weak var notesLabel: UILabel!
    @IBOutlet weak var dateLabel: UILabel!
    @IBOutlet weak var statusLabel: UILabel!
    
    @IBOutlet weak var nameTextField: UITextField!
    @IBOutlet weak var notesTextView: UITextView!
    @IBOutlet weak var dateSwitch: UISwitch!
    @IBOutlet weak var statusSwitch: UISwitch!
    @IBOutlet weak var dueDatePicker: UIDatePicker!
    
    @IBOutlet weak var updateBtn: UIButton!
    @IBOutlet weak var cancelBtn: UIButton!
    @IBOutlet weak var deleteBtn: UIButton!
    
    var originalItem: ToDoItem?
    var editingItem: ToDoItem?
    let placeHolderText = "Description"

    override func viewDidLoad() {
        super.viewDidLoad()
        toDoList = ToDoList.sharedToDoList
        
        //Style of task name text field
        nameTextField.delegate = self
        nameTextField.layer.cornerRadius = 10
        nameTextField.layer.borderColor = UIColor.systemGray5.cgColor
        
        //Style of notes text view
        notesTextView.delegate = self
        notesTextView.textColor = UIColor.black
        notesTextView.layer.borderWidth = 1
        notesTextView.layer.borderColor = UIColor.systemGray5.cgColor
        notesTextView.layer.cornerRadius = 10
        
        dueDatePicker.addTarget(self, action: #selector(self.handler(sender:)), for: UIControl.Event.valueChanged)
        
        // keep the unmodified values of the todo item
        originalItem = ToDoItem(id: editingItem!.id,
                                seq: editingItem!.seq,
                                name: editingItem!.name,
                                notes: editingItem!.notes,
                                isCompleted: editingItem!.isCompleted,
                                hasDueDate: editingItem!.hasDueDate,
                                dueDate: editingItem!.dueDate)
        
        //prepare initial values passed from the selected cell
        if let currentItem = editingItem {
            let todayDate = Date()
            nameTextField.text = currentItem.name
            notesTextView.text = (currentItem.notes == "") ? placeHolderText : currentItem.notes
            if currentItem.notes == "" || currentItem.notes == placeHolderText {
                notesTextView.textColor = UIColor.lightGray
            }
            dateSwitch.setOn(currentItem.hasDueDate, animated: true)
            statusSwitch.setOn(currentItem.isCompleted, animated: true)
            if currentItem.hasDueDate {
                dueDatePicker.date = currentItem.dueDate ?? todayDate
                dueDatePicker.isEnabled = true
            } else {
                dueDatePicker.isEnabled = false
            }
        }
        
        //Dismiss the keyboard if the user tap outside the text field
        let tapGesture = UITapGestureRecognizer(target: view, action: #selector(UIView.endEditing))
        tapGesture.cancelsTouchesInView = false
        view.addGestureRecognizer(tapGesture)
        
        //Hide the back button on the upper left
        self.navigationItem.setHidesBackButton(true, animated: true)
    }
    
    // *****
    // Setting placeholder inside the text view
    // *****
    func textViewDidBeginEditing(_ textView: UITextView) {
        textView.textColor = UIColor.black
        if textView == notesTextView {
            if textView.text == placeHolderText {
                textView.text = ""
            }
        }
    }
    
    // *****
    // Incoperate defaults settings for the notes text view
    // *****
    func textViewDidEndEditing(_ textView: UITextView) {
        if textView == notesTextView {
            if textView.text == "" {
                textView.text = placeHolderText
                textView.textColor = UIColor.lightGray
            }
        }
    }

    // *****
    // A handler function to get the date value upon the datepicker selection
    // *****
    @objc func handler(sender: UIDatePicker) {
        editingItem?.dueDate = dueDatePicker.date
    }

    // *****
    // Action function to toggle the hasDueDate switch
    // *****
    @IBAction func DidChangedValueDueDateSwitch(_ sender: UISwitch) {
        if sender.isOn {
            dueDatePicker.isEnabled = true
        } else {
            dueDatePicker.isEnabled = false
        }
        editingItem?.hasDueDate = sender.isOn
    }
    
    // *****
    // Action function to toggle the isCompleted switch
    // *****
    @IBAction func DidChangedValueStatusSwitch(_ sender: UISwitch) {
        editingItem?.isCompleted = sender.isOn
    }
    
    // *****
    // Action function to update the ToDo item with an alert dialog
    // *****
    @IBAction func DidPressedSaveButton(_ sender: UIButton) {
        let updateAlert = UIAlertController(title: "Update", message: "Confirm to update the Todo?", preferredStyle: UIAlertController.Style.alert)

        updateAlert.addAction(UIAlertAction(title: "Ok", style: .default, handler: { (action: UIAlertAction!) in
            print("Update alert OK pressed")
            self.editingItem?.name = self.nameTextField.text == nil ? "" : self.nameTextField.text!
            self.editingItem?.notes = self.notesTextView.text == nil ? "" : self.notesTextView.text!
            // even do not have due date, save a default due date for it as the requirement stated
            self.editingItem?.dueDate = self.dueDatePicker.date
            self.toDoList.replaceItem(self.editingItem!)
            self.navigationController?.popToRootViewController(animated: true)
        }))

        updateAlert.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: { (action: UIAlertAction!) in
            print("Update alert CANCEL pressed")
        }))

        present(updateAlert, animated: true, completion: nil)
    }
    
    // *****
    // Action function to cancel the update of the ToDo item with an alert dialog
    // *****
    @IBAction func DidPressedCancelButton(_ sender: UIButton) {
        if (isTodoItemModified()) {
            let cancelAlert = UIAlertController(title: "Cancel",
                                                message: "Confirm to cancel the update of the Todo?",
                                                preferredStyle: UIAlertController.Style.alert)
            
            cancelAlert.addAction(UIAlertAction(
                title: "OK",
                style: .default,
                handler: { (action: UIAlertAction!) in
                    print("Cancel alert OK pressed")
                    self.navigationController?.popToRootViewController(animated: true)
                }
            ))
            
            cancelAlert.addAction(UIAlertAction(
                title: "Cancel",
                style: .cancel,
                handler: { (action: UIAlertAction!) in
                    print("Cancel alert CANCEL pressed")
                }
            ))
            
            present(cancelAlert, animated: true, completion: nil)
        }
        else {
            self.navigationController?.popToRootViewController(animated: true)
        }
    }
    
    // *****
    // return if the todo item has been modified
    // *****
    private func isTodoItemModified() -> Bool {
        if (originalItem!.name != (nameTextField.text == nil ? "" : nameTextField.text!)
            || originalItem!.notes != (notesTextView.text == nil ? "" : notesTextView.text!)
            || originalItem!.isCompleted != statusSwitch.isOn
            || originalItem!.hasDueDate != dateSwitch.isOn
            || originalItem!.dueDate != dueDatePicker.date
        ) {
            return true
        }
        else {
            return false
        }
    }
    
    // *****
    // Action function to delete the ToDo item with an alert dialog
    // *****
    @IBAction func DidPressedDeleteButton(_ sender: UIButton) {
        let deleteAlert = UIAlertController(title: "Delete",
                                            message: "Confirm to delete the Todo?",
                                            preferredStyle: UIAlertController.Style.alert)
        
        deleteAlert.addAction(UIAlertAction(
            title: "OK",
            style: .default,
            handler: { (action: UIAlertAction!) in
                print("Delete alert OK pressed")
                self.toDoList.removeItem(self.editingItem!)
                self.navigationController?.popToRootViewController(animated: true)
            }
        ))
        
        deleteAlert.addAction(UIAlertAction(
            title: "Cancel",
            style: .cancel,
            handler: { (action: UIAlertAction!) in
                print("Delete alert CANCEL pressed")
            }
        ))
        
        present(deleteAlert, animated: true, completion: nil)
    }
    
    // *****
    // Dismiss the keyboard when return key is clicked
    // *****
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        //self.view.endEditing(true)
        return true
    }
}
