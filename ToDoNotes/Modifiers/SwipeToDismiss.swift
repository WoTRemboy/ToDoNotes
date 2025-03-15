//
//  SwipeToDismiss.swift
//  ToDoNotes
//
//  Created by Roman Tverdokhleb on 3/15/25.
//

import SwiftUI

struct SwipeToDismiss: ViewModifier {
    @Binding var isAtTop: Bool
    @State var verticalDragAmount = 0.0
    @State var opacityAmount = 1.0
    
    private let onDismiss: () -> Void
    
    init(isAtTop: Binding<Bool>, onDismiss: @escaping () -> Void) {
        self._isAtTop = isAtTop
        self.onDismiss = onDismiss
    }
    
    func body(content: Content) -> some View {
        content
            .offset(y: verticalDragAmount)
            .opacity(opacityAmount)
            .gesture(
                DragGesture()
                    .onChanged { drag in
                        guard isAtTop else { return }
                        withAnimation {
                            verticalDragAmount = drag.translation.height
                            if drag.translation.height < 100 {
                                opacityAmount = (100 - verticalDragAmount) / 100
                            } else {
                                opacityAmount = 0
                            }
                        }
                    }
                    .onEnded { drag in
                        withAnimation {
                            if drag.translation.height > 100, isAtTop {
                                onDismiss()
                                opacityAmount = 0
                            } else {
                                verticalDragAmount = 0
                                opacityAmount = 1
                            }
                        }
                    }
            )
    }
}

extension View {
    func swipeToDismiss(isAtTop: Binding<Bool>, onDismiss: @escaping () -> Void) -> some View {
        modifier(SwipeToDismiss(isAtTop: isAtTop, onDismiss: onDismiss))
    }
}
