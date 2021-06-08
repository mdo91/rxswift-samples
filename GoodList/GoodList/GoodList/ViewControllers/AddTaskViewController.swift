//
//  AddTaskViewController.swift
//  GoodList
//
//  Created by Mdo on 07/06/2021.
//

import Foundation
import UIKit
import RxSwift

class AddTaskViewController:UIViewController{
    
    
    //MARK: - properties
    
    @IBOutlet weak var segmentedControl:UISegmentedControl!
    @IBOutlet weak var textField:UITextField!
    
    // an object to be observed
    private let taskSubject = PublishSubject<Task>()
    
    var taskSubjectObservable:Observable<Task>{
        return taskSubject.asObserver()
    }
    
    
    
    
    //MARK: - viewController lifecycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    
    //MARK: - actions
    
    @IBAction func save(){
        
        guard let priority = Priority(rawValue: segmentedControl.selectedSegmentIndex), let title = textField.text else{
            return
        }
        
        let task = Task(title: title, priority: priority)
        taskSubject.onNext(task)
        self.dismiss(animated: true)
        
        
    }
    
    
}
