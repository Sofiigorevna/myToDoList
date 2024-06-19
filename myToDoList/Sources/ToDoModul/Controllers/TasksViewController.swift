//
//  TasksViewController.swift
//  myToDoList
//
//  Created by 1234 on 17.06.2024.
//

import UIKit
import Firebase

class TasksViewController: UITableViewController {
    
    // MARK: - Outlets
    
    let cellId = "Cell"
    
    var taskStore: TaskStore! {
        didSet {
            taskStore.tasks = TasksUtility.fetch() ?? [[Task](), [Task]()]

            tableView.reloadData()
        }
    }
    
    // MARK: - Lifecycle
    
    override init(style: UITableView.Style) {
        super.init(style: style)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .systemIndigo
        tableView.register(UITableViewCell.self, forCellReuseIdentifier: cellId)
        setupNavigationBar()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        tableView.reloadData()
    }
    
    // MARK: - Setup
    
    func setupNavigationBar() {
        navigationController?.navigationBar.tintColor = .white
        title = "myToDoList"
        
        navigationItem.leftBarButtonItem = UIBarButtonItem(
            title: "Exit profile",
            style: .plain,
            target: self,
            action: #selector(signOut))
        
        navigationItem.rightBarButtonItem = UIBarButtonItem(
            title: "Add task",
            style: .plain,
            target: self,
            action: #selector(addTask))
    }
    
    // MARK: - Actions
    
    @objc func signOut() {
        do{
            try Auth.auth().signOut()
            let viewController = AuthViewController()
            let navigationController = UINavigationController(rootViewController: viewController)
            present(navigationController, animated: true)
            
        } catch let signOutError as NSError{
            print(signOutError)
        }
    }
    
    @objc func addTask() {
        let alertController = UIAlertController(title: "Add Task", message: nil, preferredStyle: .alert)
        
        let addAction = UIAlertAction(title: "Add", style: .default) {_ in
            
            guard let name = alertController.textFields?.first?.text else { return }
            
            let newTask = Task(name: name, image: nil)
            
            self.taskStore.add(newTask, at: 0)
            
            let indexPath = IndexPath(row: 0, section: 0)
            self.tableView.insertRows(at: [indexPath], with: .automatic)
            self.saveTasksToUserDefaults()
        }
        
        addAction.isEnabled = false
        
        let cancelAction = UIAlertAction(title: "Cancel", style: .cancel, handler: nil)
        
        alertController.addTextField { textField in
            textField.placeholder = "Enter task name..."
            textField.addTarget(self, action: #selector(self.handleTextChanged), for: .editingChanged)
        }
        
        alertController.addAction(addAction);
        alertController.addAction(cancelAction);
        
        present(alertController, animated: true, completion: nil)
    }
    
    @objc private func handleTextChanged(_ sender: UITextField) {
        
        guard let alertController = presentedViewController as? UIAlertController,
              let addAction = alertController.actions.first,
              let text = sender.text
        else { return }
        
        addAction.isEnabled = !text.trimmingCharacters(in: .whitespaces).isEmpty
    }
    
    func saveTasksToUserDefaults() {
        let encoder = JSONEncoder()
        if let encodedTasks = try? encoder.encode(taskStore.tasks) {
            UserDefaults.standard.set(encodedTasks, forKey: "tasks")
        }
    }
}

// MARK: - DataSource
extension TasksViewController {
    
    override func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        return section == 0 ? "To-do" : "Done"
    }
    
    override func numberOfSections(in tableView: UITableView) -> Int {
        return taskStore.tasks.count
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return taskStore.tasks[section].count
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: cellId, for: indexPath)
        cell.textLabel?.text = taskStore.tasks[indexPath.section][indexPath.row].name
        
        return cell
    }
    
}

// MARK: - Delegate
extension TasksViewController {
    
    override func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 45
    }
    
    override func tableView(_ tableView: UITableView, trailingSwipeActionsConfigurationForRowAt indexPath: IndexPath) -> UISwipeActionsConfiguration? {
        
        let deleteAction = UIContextualAction(style: .destructive, title: nil) {(action, sourceView, completionHandler) in
            
            guard let isDone = self.taskStore.tasks[indexPath.section][indexPath.row].isDone else { return }
            
            self.taskStore.removeTask(at: indexPath.row, isDone: isDone)
            
            tableView.deleteRows(at: [indexPath], with: .automatic)
            
            completionHandler(true)
        }
        
        deleteAction.image = #imageLiteral(resourceName: "delete")
        deleteAction.backgroundColor = #colorLiteral(red: 0.8784313725, green: 0.4901960784, blue: 0.4823529412, alpha: 1)
        
        return UISwipeActionsConfiguration(actions: [deleteAction])
    }
    
    override func tableView(_ tableView: UITableView, leadingSwipeActionsConfigurationForRowAt indexPath: IndexPath) -> UISwipeActionsConfiguration? {
        
        let doneAction = UIContextualAction(style: .normal, title: nil) {(action, sourceView, completionHandler) in
            
            self.taskStore.tasks[0][indexPath.row].isDone = true
            
            let doneTask = self.taskStore.removeTask(at: indexPath.row)
            
            tableView.deleteRows(at: [indexPath], with: .automatic)
            
            self.taskStore.add(doneTask, at: 0, isDone: true)
            
            let indexPath = IndexPath(row: 0, section: 1)
            tableView.insertRows(at: [indexPath], with: .automatic)
            
            completionHandler(true)
        }
        
        doneAction.image = #imageLiteral(resourceName: "done")
        doneAction.backgroundColor = #colorLiteral(red: 0.231372549, green: 0.7411764706, blue: 0.6509803922, alpha: 1)
        
        return indexPath.section == 0 ? UISwipeActionsConfiguration(actions: [doneAction]) : nil
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        let viewController = DetailViewController()
        viewController.task = taskStore.tasks[indexPath.section][indexPath.row]
        viewController.delegate = self
        navigationController?.pushViewController(viewController, animated: true)
    }
}

extension TasksViewController: TaskUpdateDelegate {
    func didUpdateTask(_ task: Task) {
        if let selectedIndexPath = tableView.indexPathForSelectedRow {
            taskStore.tasks[selectedIndexPath.section][selectedIndexPath.row] = task
            tableView.reloadRows(at: [selectedIndexPath], with: .automatic)
            saveTasksToUserDefaults()
        }
    }
}

