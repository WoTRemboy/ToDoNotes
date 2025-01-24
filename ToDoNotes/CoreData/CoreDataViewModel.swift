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
    @Published internal var segmentedAndSortedTasksArray: [(Date?, [TaskEntity])] = []
    @Published internal var segmentedAndSortedTasksDict: [Date?: [TaskEntity]] = [:]
    private let container: NSPersistentContainer
    
    internal var isEmpty : Bool {
        savedEnities.isEmpty
    }
    
    internal var daysWithTasks: Set<Date> {
        var result = Set<Date>()
        
        for date in segmentedAndSortedTasksDict {
            let day = date.0 ?? Date()
            result.insert(day)
        }
        return result
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
                          completeCheck: Bool,
                          target: Date?,
                          notify: Bool) {
        let newTask = TaskEntity(context: container.viewContext)
        
        newTask.id = UUID()
        newTask.name = name
        newTask.details = description
        newTask.completed = completeCheck ? 1 : 0
        newTask.created = .now
        newTask.target = target
        newTask.notify = notify
        saveData()
    }
    
    internal func updateTask(entity: TaskEntity,
                             name: String,
                             description: String,
                             completeCheck: Bool,
                             target: Date?,
                             notify: Bool,
                             checklist: [ChecklistItem] = []) {
        entity.name = name
        entity.details = description
        entity.completed = completeCheck ? showCheckStatus(for: entity) : 0
        entity.target = target
        entity.notify = target != nil ? notify : false
        
        var checklistEnities = [ChecklistEntity]()
        for item in checklist {
            let entityItem = ChecklistEntity(context: container.viewContext)
            entityItem.name = item.name
            entityItem.completed = item.completed
            checklistEnities.append(entityItem)
        }
        
        let orderedChecklist = NSOrderedSet(array: checklistEnities)
        entity.checklist = orderedChecklist
        
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
            setupSegmentedAndSortedTasks()
        } catch let error {
            print("Error fetching tasks: \(error.localizedDescription)")
        }
    }
    
    private func setupSegmentedAndSortedTasks() {
        var groupedTasks: [Date: [TaskEntity]] = [:]
        
        for task in savedEnities {
            let referenceDate = task.target ?? task.created ?? Date.distantPast
            let day = Calendar.current.startOfDay(for: referenceDate)
            groupedTasks[day, default: []].append(task)
        }
        
        segmentedAndSortedTasksDict = groupedTasks
        sortSegmentedAndSortedTasksDict()
        
        segmentedAndSortedTasksArray = groupedTasks
            .map { (day, tasks) in
                (day, tasks.sorted {
                    ($0.target ?? Date.distantFuture < $1.target ?? Date.distantFuture)
                })
            }
            .sorted { $0.0 > $1.0 }
    }


    
    internal func deleteTasks(with ids: [NSManagedObjectID]) {
        ids.forEach { id in
            if let object = try? container.viewContext.existingObject(with: id) {
                container.viewContext.delete(object)
            }
        }
        saveData()
    }
}


extension CoreDataViewModel {
    
    internal func dayTasks(for date: Date) -> [TaskEntity] {
        let day = Calendar.current.startOfDay(for: date)
        return segmentedAndSortedTasksDict[day] ?? []
    }
    
    internal func haveTextContent(for entity: TaskEntity) -> Bool {
        let details = entity.details ?? String()
        
        let firstChecklistElement = entity.checklist?.compactMap({ $0 as? ChecklistEntity }).first
        let firstChecklistName = firstChecklistElement?.name ?? String()
        let checklistCount = entity.checklist?.count ?? 0

        return !details.isEmpty || (!firstChecklistName.isEmpty || checklistCount > 1)
    }
    
    private func sortSegmentedAndSortedTasksDict() {
        for (day, tasks) in segmentedAndSortedTasksDict {
            let sortedTasks = tasks.sorted { t1, t2 in
                let d1 = t1.target ?? t1.created ?? Date.distantFuture
                let d2 = t2.target ?? t2.created ?? Date.distantFuture
                return d1 < d2
            }
            segmentedAndSortedTasksDict[day] = sortedTasks
        }
    }
    
    internal func setupChecking(for entity: TaskEntity) {
        if entity.completed == 0 {
            entity.completed = 1
        } else {
            entity.completed = 0
        }
        saveData()
    }
    
    private func showCheckStatus(for entity: TaskEntity) -> Int16 {
        entity.completed == 2 ? 2 : 1
    }
    
    internal func checkCompletedStatus(for entity: TaskEntity) -> Bool {
        entity.completed == 1
    }
    
    internal func taskCheckStatus(for entity: TaskEntity) -> Bool {
        entity.completed == 2
    }
    
    internal func toggleCompleteChecking(for entity: TaskEntity) {
        entity.completed = entity.completed == 1 ? 2 : 1
        saveData()
    }
}
