//
//  MainViewModel.swift
//  ToDoNotes
//
//  Created by Roman Tverdokhleb on 1/4/25.
//

import SwiftUI

final class MainViewModel: ObservableObject {
    
    @Published private(set) var selectedFilter: Filter = .active
    @Published internal var selectedFolder: Folder = .all
    
    @Published internal var showingTaskEditView: Bool = false
    @Published internal var taskManagementHeight: CGFloat = 15
    
    internal var todayDateString: String {
        Date.now.longDayMonthWeekday
    }
    
    internal func toggleShowingTaskEditView() {
        showingTaskEditView.toggle()
    }
    
    internal func setFilter(to new: Filter) {
        withAnimation(.easeInOut(duration: 0.2)) {
            selectedFilter = new
        }
    }
    
    internal func compareFilters(with filter: Filter) -> Bool {
        filter == selectedFilter
    }
    
    internal func setFolder(to new: Folder) {
        withAnimation(.easeInOut(duration: 0.2)) {
            selectedFolder = new
        }
    }
    
    internal func compareFolders(with folder: Folder) -> Bool {
        folder == selectedFolder
    }
}
