//
//  CoreDataViewModel.swift
//  ToDoNotes
//
//  Created by Roman Tverdokhleb on 1/12/25.
//

import Foundation
import Combine
import CoreData

final class CoreDataViewModel: ObservableObject {
    
    @Published internal var savedEnities: [TaskEntity] = []
    private let container: NSPersistentContainer
    
    internal var isEmpty : Bool {
        savedEnities.isEmpty
    }
    
    init() {
        container = NSPersistentContainer(name: Texts.CoreData.container)
        container.loadPersistentStores { (description, error) in
            if let error {
                print("Error loading core data: \(error.localizedDescription)")
            } else {
                print("Successfully loaded core data")
            }
        }
        fetchTasks()
    }
    
    internal func addTask(name: String,
                          description: String,
                          completeCheck: Bool) {
        let newTask = TaskEntity(context: container.viewContext)
        
        newTask.id = UUID()
        newTask.name = name
        newTask.details = description
        newTask.completed = completeCheck ? 1 : 0
        saveData()
    }
    
    internal func updateTask(entity: TaskEntity,
                             name: String,
                             description: String,
                             completeCheck: Bool) {
        entity.name = name
        entity.details = description
        entity.completed = completeCheck ? 1 : 0
        saveData()
    }
    
    internal func deleteTask(indexSet: IndexSet) {
        guard let index = indexSet.first else { return }
        
        let entity = savedEnities[index]
        container.viewContext.delete(entity)
        saveData()
    }
    
    private func saveData() {
        do {
            try container.viewContext.save()
            fetchTasks()
        } catch let error {
            print("Error saving data: \(error.localizedDescription)")
        }
    }
    
    private func fetchTasks() {
        let request = NSFetchRequest<TaskEntity>(entityName: Texts.CoreData.entity)
        
        do {
            savedEnities = try container.viewContext.fetch(request)
        } catch let error {
            print("Error fetching tasks: \(error.localizedDescription)")
        }
    }
    
#warning("Needed to be completed")
    
    @Published internal var checklistItems: [ChecklistItem] = []
    @Published internal var checkListItemText: String = String()
    @Published internal var lastAddedItemID: UUID?
    @Published internal var newItemText: String = String()
    
    internal func addItem() {
        guard !newItemText.isEmpty else { return }
        
        let newItem = ChecklistItem(title: newItemText)
        checklistItems.append(newItem)
        lastAddedItemID = newItem.id
        
        newItemText = ""
    }
    
    internal func removeItem(item: ChecklistItem) {
        guard let removeItemIndex = checklistItems.firstIndex(of: item) else { return }
        checklistItems.remove(at: removeItemIndex)
    }
    
}


extension CoreDataViewModel {
    
    internal func setupChecking(for entity: TaskEntity) {
        if entity.completed == 0 {
            entity.completed = 1
        } else {
            entity.completed = 0
        }
        saveData()
    }
    
    internal func checkCompletedStatus(for entity: TaskEntity) -> Bool {
        entity.completed == 1
    }
    
    internal func toggleCompleteChecking(for entity: TaskEntity) {
        entity.completed = entity.completed == 1 ? 2 : 1
        saveData()
    }
}
