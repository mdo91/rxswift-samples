//
//  ViewController.swift
//  GoodList
//
//  Created by Mdo on 07/06/2021.
//

import UIKit
import RxSwift
import RxCocoa
class TaskListViewController: UIViewController {
    
    //MARK: - properties
    
    @IBOutlet weak var segmentedControl:UISegmentedControl!
    @IBOutlet weak var tableView:UITableView!
    let disposeBag = DisposeBag()
    private var tasks = BehaviorRelay<[Task]>(value: [])
    private var filteredTasks = [Task]()
    
    
    //MARK: - viewController life cycle

    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        self.navigationController?.navigationBar.prefersLargeTitles = true
        
    }
    
    //MARK: - segue
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        guard let navigationController = segue.destination as? UINavigationController, let addListVC = navigationController.viewControllers.first as? AddTaskViewController else {
            fatalError("Could not init \(AddTaskViewController.self)")
            
        }
        
        addListVC.taskSubjectObservable.subscribe(onNext: { [unowned self] task in
            print(task)
            let priority = Priority(rawValue: self.segmentedControl.selectedSegmentIndex - 1)
            var existingTasks = self.tasks.value
            existingTasks.append(task)
            self.tasks.accept(existingTasks)
            self.filteredTasks(by: priority)
            
            //self.tasks.value.append(task)
        }).disposed(by: disposeBag)
    }
    
    //MARK: - filter functions
    
    private func filteredTasks(by priority:Priority?){
        if  priority == nil{
            self.filteredTasks = self.tasks.value
            updateTableView()
        }else{
            self.tasks.map { tasks in
                return tasks.filter({$0.priority == priority! })
            }.subscribe(onNext: {[weak self] tasks in
                
                guard let self = self else{ return }
                self.filteredTasks = tasks
                print(tasks)
                self.updateTableView()
                
            }).disposed(by: disposeBag)
        }
    }
    
    @IBAction func priorityValueChanged(segmentedControl:UISegmentedControl){
        
         let selectedPriority = Priority(rawValue: segmentedControl.selectedSegmentIndex - 1)
        print("priorityValueChanged \(selectedPriority)")
        self.filteredTasks(by: selectedPriority)
    }
    
    //MARK: - update tableView
    
    private func updateTableView(){
        
        DispatchQueue.main.async {
            self.tableView.reloadData()
        }
    }


}
extension TaskListViewController:UITableViewDataSource{
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        return self.filteredTasks.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = self.tableView.dequeueReusableCell(withIdentifier: "cellId", for: indexPath)
        cell.textLabel?.text = self.filteredTasks[indexPath.row].title
        return cell
        
    }
    
    
}

