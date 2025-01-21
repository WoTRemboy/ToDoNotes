//
//  TaskListRow.swift
//  ToDoNotes
//
//  Created by Roman Tverdokhleb on 1/13/25.
//

import SwiftUI
import CoreData

struct TaskListRow: View {
    
    @EnvironmentObject private var coreDataManager: CoreDataViewModel
    private var entity: TaskEntity
    
    init(entity: TaskEntity) {
        self.entity = entity
    }
    
    internal var body: some View {
        HStack {
            if entity.completed != 0 {
                checkBoxButton
            }
            nameLabel
            
            Spacer()
            detailsBox
        }
    }
    
    private var checkBoxButton: some View {
        (coreDataManager.checkCompletedStatus(for: entity) ?
        Image.TaskManagement.TaskRow.uncheckedBox :
        Image.TaskManagement.TaskRow.checkedBox)
            .resizable()
            .frame(width: 15, height: 15)
        
            .onTapGesture {
                withAnimation(.easeInOut(duration: 0.2)) {
                    coreDataManager.toggleCompleteChecking(for: entity)
                }
            }
    }
    
    private var nameLabel: some View {
        Text(entity.name ?? String())
            .font(.system(size: 15, weight: .medium))
            .foregroundStyle(entity.completed == 2 ?
                             Color.LabelColors.labelDetails :
                             Color.LabelColors.labelPrimary)
            .strikethrough(entity.completed == 2,
                           color: Color.LabelColors.labelDetails)
    }
    
    private var detailsBox: some View {
        VStack(alignment: .trailing, spacing: 2) {
            if entity.target != nil {
                dateLabel
            }
            if entity.notify {
                remainderImage
            }
        }
    }
    
    private var dateLabel: some View {
        Text(entity.target?.fullHourMinutes ?? String())
            .font(.system(size: 12, weight: .medium))
            .foregroundStyle(Color.LabelColors.labelPrimary)
    }
    
    private var remainderImage: some View {
        Image.TaskManagement.TaskRow.remainder
            .frame(width: 12, height: 12)
    }
}

#Preview {
    let coreDataManager = CoreDataViewModel()
    
    return TaskListRow(entity: coreDataManager.savedEnities.last!)
        .environmentObject(coreDataManager)
}
