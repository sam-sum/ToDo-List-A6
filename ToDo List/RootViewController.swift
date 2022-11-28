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
//  RootViewController.swift
//  ToDo List
//  Date: Dec 4, 2022
//  Version: 1.0
//

import UIKit

class RootViewController: UITableViewController {

    private var cellPointSize: CGFloat!
    private var toDoList: ToDoList!
    //private var selectedItem: ToDoItem?
    private static let toDoItemCell = "Items"
    
    override func viewDidLoad() {
        super.viewDidLoad()
        toDoList = ToDoList.sharedToDoList

        tableView.register(ToDoListViewCell.nib(), forCellReuseIdentifier: ToDoListViewCell.identifier)
        tableView.dataSource = self
        tableView.rowHeight = 70
        
        self.navigationItem.rightBarButtonItem = self.editButtonItem
        self.navigationItem.rightBarButtonItem!.tintColor = Utility.getUIColor("#FF9292")
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        tableView.reloadData()
    }
    
    // *****
    // define number of sections in the table view
    // *****
    override func numberOfSections(in tableView: UITableView) -> Int {
        // #warning Incomplete implementation, return the number of sections
        return 1
    }

    // *****
    // define number of total cells (row) in the table view
    // *****
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // #warning Incomplete implementation, return the number of rows
       return toDoList.count()
    }

    // *****
    // Called by iOS to reuse / create a table cell for display
    // *****
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let data = toDoList.getAllItems()
        let cell = tableView.dequeueReusableCell(withIdentifier: ToDoListViewCell.identifier, for: indexPath) as! ToDoListViewCell
        cell.configure(with: data[indexPath.row], row: indexPath.row)
        cell.delegate = self
        return cell
    }
    
    // *****
    // Additional function sets the table view cell be editable
    // *****
    override func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        // Return false if you do not want the specified item to be editable.
        return true
    }
     
    // *****
    // Additional function supports rearranging the table view
    // *****
    override func tableView(_ tableView: UITableView, moveRowAt fromIndexPath: IndexPath, to: IndexPath) {
        let data = toDoList.getAllItems()
        let movedItem = data[fromIndexPath.row]
        toDoList.removeItemAt(fromIndexPath.row)
        toDoList.insertItemAt(index: to.row, item: movedItem)
        tableView.reloadData()
    }
    
    // *****
    // Additional function sets the table view cell be rearrangable
    // *****
    override func tableView(_ tableView: UITableView, canMoveRowAt indexPath: IndexPath) -> Bool {
        // Return false if you do not want the item to be re-orderable.
        return true
    }

    // *****
    // Additional function handles left-to-right swipe
    // *****
    override func tableView(_ tableView: UITableView, leadingSwipeActionsConfigurationForRowAt indexPath: IndexPath) -> UISwipeActionsConfiguration? {
        let editAction = UIContextualAction(style: .normal, title:  "Edit", handler: { (ac:UIContextualAction, view:UIView, success:(Bool) -> Void) in
                print("edit item requested")
                self.didClickedEditButton(with: indexPath.row)
                success(true)
            })
        editAction.backgroundColor = .systemBlue
        return UISwipeActionsConfiguration(actions: [editAction])
    }
    
    // *****
    // Additional function handles right-to-left swipe
    // *****
    override func tableView(_ tableView: UITableView, trailingSwipeActionsConfigurationForRowAt indexPath: IndexPath) -> UISwipeActionsConfiguration? {
        let data = self.toDoList.getAllItems()
        
        let completeTitle = (data[indexPath.row].isCompleted) ? "Undo" : "Done"
        let completeAction = UIContextualAction(style: .normal, title:  completeTitle, handler: { (ac:UIContextualAction, view:UIView, success:(Bool) -> Void) in
                print("toggle item completed")
                let isDone: Bool = !data[indexPath.row].isCompleted
                self.didChangeSwitchValue(with: indexPath.row, value: isDone )
                success(true)
            })
        completeAction.backgroundColor = .systemYellow
        
        let deleteAction = UIContextualAction(style: .destructive, title:  "Delete", handler: { (ac:UIContextualAction, view:UIView, success:(Bool) -> Void) in
                print("delete item requested")
                // Delete the row from the data source
                let deleteItem = data[indexPath.row]
                self.toDoList.removeItem(deleteItem)
                self.tableView.reloadData()
                success(true)
            })
        deleteAction.backgroundColor = .systemRed

        return UISwipeActionsConfiguration(actions: [deleteAction, completeAction])
    }
    
    // *****
    // Action function to handle adding a new task entry
    // *****
    @IBAction func didPressedAddButton(_ sender: UIBarButtonItem) {
        print("didPressedAddButton.")
        
        let alert = UIAlertController(title: "New ToDo Task", message: "Enter a title", preferredStyle: .alert)
        alert.addTextField {
            (textField) in textField.text = ""
        }
        alert.addAction(UIAlertAction(title: "OK", style: .default, handler: { [weak alert] (_) in
            let textField = alert?.textFields![0] // Force unwrapping because it won't be nil.
            print("Alert text field: \(textField?.text ?? "no value")")
            self.toDoList.addBlankItem(textField?.text ?? "New title")
            self.tableView.reloadData()
        }))
        alert.addAction(UIAlertAction(title: "Cancel", style: .cancel))
        self.present(alert, animated: true, completion: nil)
    }

}

// *****
// Extent the class to add action functions required by the protocol
// *****
extension RootViewController: ToDoListViewCellDelegate {
    
    func didChangeSwitchValue(with tag: Int, value: Bool) {
        print ("didChangeSwitchValue: \(tag), \(value)")
        var toDoItem: ToDoItem?
        let fullList = toDoList.getAllItems()
        for item in fullList {
            //seq has to be divided by 10 as it is in the multipe of 10
            if (item.seq / 10) == tag {
                toDoItem = item
            }
        }
        print ("Current toDoList item: \(toDoItem?.id ?? "" )")
        if var theItem = toDoItem {
            theItem.isCompleted = !theItem.isCompleted
            toDoList.replaceItem(theItem)
            print ("toDoList updated")
            tableView.reloadData()
        }
    }
    
    func didClickedEditButton(with tag: Int) {
        print ("Button: \(tag)")
        let data = toDoList.getAllItems()
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        let vc = storyboard.instantiateViewController(withIdentifier: "DetailScreen") as! DetailViewController
        vc.editingItem = data[tag]
        //change the animation direction
        let transition = CATransition()
        transition.duration = 0.5
        transition.timingFunction = CAMediaTimingFunction(name: CAMediaTimingFunctionName.easeInEaseOut)
        transition.type = CATransitionType.push
        transition.subtype = CATransitionSubtype.fromLeft
        self.navigationController?.view.layer.add(transition, forKey: kCATransition)
        self.navigationController?.pushViewController(vc,animated:true)
    }
    
}
