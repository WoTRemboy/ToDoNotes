//
//  TaskListRow.swift
//  ToDoNotes
//
//  Created by Roman Tverdokhleb on 1/13/25.
//

import SwiftUI
import CoreData

struct TaskListRow: View {
    
    @ObservedObject private var entity: TaskEntity
    private let status: TaskStatus
    private let isLast: Bool
    
    init(entity: TaskEntity, isLast: Bool) {
        self._entity = ObservedObject(wrappedValue: entity)
        self.status = .setupStatus(for: entity)
        self.isLast = isLast
    }
    
    internal var body: some View {
        CustomContextMenu {
            content
                .background(Color.SupportColors.supportListRow)
        } preview: {
            TaskManagementPreview(
                entity: entity)
        } actions: {
            uiContextMenu
        } onEnd: {
            
        }
    }
    
    private var content: some View {
        HStack(spacing: 0) {
            folderIndicatior
            pinnedIndicator
            if entity.completed != 0 {
                checkBoxButton
            }
            nameLabel
            
            Spacer()
            detailsBox
        }
        .frame(height: 62)
        
        .overlay(alignment: .bottom) {
            if !isLast {
                Rectangle()
                    .frame(height: 0.5)
                    .foregroundStyle(Color.LabelColors.labelDetails)
                    .padding(.horizontal, 16)
            }
        }
    }
    
    private var folderIndicatior: some View {
        let folder = Folder(rawValue: entity.folder ?? String())
        let color = folder?.color ?? .clear
        return Rectangle()
            .foregroundStyle(color)
            .frame(maxWidth: 6, maxHeight: .infinity)
    }
    
    private var pinnedIndicator: some View {
        ZStack(alignment: .topTrailing) {
            Color.clear
            
            if entity.pinned {
                Image.TaskManagement.TaskRow.pinned
                    .resizable()
                    .frame(width: 5, height: 5)
                    .padding(.top, 5)
            }
        }
        .frame(maxWidth: 10, maxHeight: .infinity)
    }
    
    private var checkBoxButton: some View {
        (TaskService.taskCheckStatus(for: entity) ?
         Image.TaskManagement.TaskRow.checkedBox :
            Image.TaskManagement.TaskRow.uncheckedBox)
        .resizable()
        .renderingMode(.template)
        .frame(width: 18, height: 18)
        
        .foregroundStyle(
            status == .outdated || TaskService.taskCheckStatus(for: entity) ?
            Color.LabelColors.labelDetails :
                Color.LabelColors.labelPrimary
        )
        
        .onTapGesture {
            guard !entity.removed else { return }
            withAnimation(.easeInOut(duration: 0.2)) {
                do {
                    try TaskService.toggleCompleteChecking(for: entity)
                    let impactMed = UIImpactFeedbackGenerator(style: .medium)
                    impactMed.impactOccurred()
                    
                    if entity.completed == 2 {
                        Toast.shared.present(
                            title: Texts.Toasts.completedOn)
                    }
                } catch {
                    print("Task checkbox toggle error: \(error.localizedDescription)")
                    Toast.shared.present(
                        title: Texts.Toasts.completedError)
                }
            }
        }
        .padding(.trailing, 8)
    }
    
    private var nameLabel: some View {
        let name = entity.name ?? String()
        return Text(!name.isEmpty ? name : Texts.TaskManagement.TaskRow.placeholder)
            .font(.system(size: 18, weight: .medium))
            .lineLimit(1)
            .foregroundStyle(
                (TaskService.taskCheckStatus(for: entity)
                 || status == .outdated || name.isEmpty) ?
                Color.LabelColors.labelDetails :
                    Color.LabelColors.labelPrimary)
            .strikethrough(TaskService.taskCheckStatus(for: entity),
                           color: Color.LabelColors.labelDetails)
    }
    
    private var detailsBox: some View {
        let hasDateLabel = entity.target != nil && entity.hasTargetTime
        let context = TaskService.haveTextContent(for: entity)
        let notifications = entity.notifications?.count ?? 0 > 0
        let spacingValue: CGFloat = (hasDateLabel && (context || notifications)) ? 6 : 0
        
        return VStack(alignment: .trailing, spacing: spacingValue) {
            if entity.target != nil, entity.hasTargetTime {
                dateLabel
            }
            
            HStack(spacing: 2) {
                if context {
                    textContentImage
                }
                if notifications {
                    reminderImage
                }
                if context || notifications || !hasDateLabel {
                    additionalStatus
                        .frame(width: 15, height: 15)
                }
            }
        }
        .padding(.trailing, 4)
    }
    
    private var dateLabel: some View {
        HStack(spacing: 2) {
            Text(entity.target?.fullHourMinutes ?? String())
                .font(.system(size: 15, weight: .regular))
                .foregroundStyle(
                    TaskService.taskCheckStatus(for: entity)
                    || status == .outdated ?
                    Color.LabelColors.labelDetails :
                        Color.LabelColors.labelPrimary)
            
            dateLabelAdditionalIcon
                .frame(width: 15, height: 15)
        }
    }
    
    private var reminderImage: some View {
        (TaskService.taskCheckStatus(for: entity) ?
         Image.TaskManagement.TaskRow.reminderOff :
            Image.TaskManagement.TaskRow.reminderOn)
        .resizable()
        .frame(width: 18, height: 18)
    }
    
    private var textContentImage: some View {
        Image.TaskManagement.TaskRow.contentOn
            .resizable()
            .frame(width: 18, height: 18)
    }
    
    private var dateLabelAdditionalIcon: some View {
        Group {
            switch status {
            case .none:
                emptyRectangle
            case .outdated:
                Image.TaskManagement.TaskRow.expired
            case .important:
                Image.TaskManagement.TaskRow.important
            case .outdatedImportant:
                Image.TaskManagement.TaskRow.important
            }
        }
    }
    
    private var additionalStatus: some View {
        Group {
            switch status {
            case .none:
                emptyRectangle
            case .outdated:
                emptyRectangle
            case .important:
                if entity.hasTargetTime {
                    emptyRectangle
                } else {
                    Image.TaskManagement.TaskRow.important
                }
            case .outdatedImportant:
                Image.TaskManagement.TaskRow.expired
            }
        }
    }
    
    private var emptyRectangle: some View {
        Rectangle()
            .foregroundStyle(.clear)
    }
    
    private var uiContextMenu: UIMenu {
        let _/*toggleImportantAction*/ = UIAction(
            title:
                (entity.important ?
                Texts.TaskManagement.ContextMenu.importantDeselect :
                Texts.TaskManagement.ContextMenu.important),
            image:
                (entity.important ?
                 UIImage.TaskManagement.importantDeselect :
                    UIImage.TaskManagement.importantSelect)
        ) { _ in
            withAnimation(.easeInOut(duration: 0.2)) {
                try? TaskService.toggleImportant(for: entity)
            }
            Toast.shared.present(
                title: entity.important ? Texts.Toasts.importantOn : Texts.Toasts.importantOff)
        }
        
        let _/*togglePinnedAction*/ = UIAction(
            title: (entity.pinned ?
                    Texts.TaskManagement.ContextMenu.unpin :
                        Texts.TaskManagement.ContextMenu.pin),
            
            image: (entity.pinned ?
                    UIImage.TaskManagement.pinnedDeselect :
                        UIImage.TaskManagement.pinnedSelect)
        ) { _ in
            withAnimation(.easeInOut(duration: 0.2)) {
                try? TaskService.togglePinned(for: entity)
            }
            Toast.shared.present(
                title: entity.pinned ? Texts.Toasts.pinnedOn : Texts.Toasts.pinnedOff)
        }
        
        let _/*duplicateAction*/ = UIAction(
            title: Texts.TaskManagement.ContextMenu.dublicate,
            image: UIImage.TaskManagement.copy
        ) { _ in
//            withAnimation(.easeInOut(duration: 0.2)) {
//                do {
//                    try TaskService.toggleRemoved(for: entity)
//                    Toast.shared.present(
//                        title: Texts.Toasts.removed)
//                } catch {
//                    print("Task could not be removed with error: \(error.localizedDescription).")
//                }
//            }
        }
        
        let removeAction = UIAction(
            title: Texts.TaskManagement.ContextMenu.delete,
            image: UIImage.TaskManagement.trash,
            attributes: .destructive
        ) { _ in
            withAnimation(.easeInOut(duration: 0.2)) {
                do {
                    try TaskService.toggleRemoved(for: entity)
                    Toast.shared.present(
                        title: Texts.Toasts.removed)
                } catch {
                    print("Task could not be removed with error: \(error.localizedDescription).")
                }
            }
        }
        
        return UIMenu(title: String(), children: [
//            toggleImportantAction,
//            togglePinnedAction,
//            duplicateAction,
            removeAction
        ])
    }
    
}

#Preview {
    TaskListRow(entity: PreviewData.taskItem, isLast: false)
}
