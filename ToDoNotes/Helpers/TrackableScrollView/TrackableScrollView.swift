//
//  TrackableScrollView.swift
//  ToDoNotes
//
//  Created by Roman Tverdokhleb on 3/15/25.
//

import SwiftUI

struct TrackableScrollView<Content: View>: View {
    private let content: Content
    @Binding private var isAtTop: Bool

    init(isAtTop: Binding<Bool>, @ViewBuilder content: () -> Content) {
        self._isAtTop = isAtTop
        self.content = content()
    }

    internal var body: some View {
        ScrollView {
            content
                .background(
                    GeometryReader { geo in
                        Color.clear
                            .preference(key: ScrollOffsetPreferenceKey.self, value: geo.frame(in: .named("scroll")).minY)
                    }
                )
        }
        .coordinateSpace(.named("scroll"))
        .onPreferenceChange(ScrollOffsetPreferenceKey.self) { value in
            isAtTop = (value >= 0)
        }
    }
}

struct ScrollOffsetPreferenceKey: PreferenceKey {
    static var defaultValue: CGFloat = 0

    static func reduce(value: inout CGFloat, nextValue: () -> CGFloat) {
        value = nextValue()
    }
}
