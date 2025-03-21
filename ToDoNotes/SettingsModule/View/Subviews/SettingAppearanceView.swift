//
//  SettingAppearanceView.swift
//  ToDoNotes
//
//  Created by Roman Tverdokhleb on 3/3/25.
//

import SwiftUI

struct SettingAppearanceView: View {
    
    @Environment(\.colorScheme) private var scheme
    @EnvironmentObject private var viewModel: SettingsViewModel
    
    @State private var selectedTheme: Theme = .systemDefault
        
    internal var body: some View {
        VStack(spacing: 20) {
            title
            themeSelector
            buttons
        }
        .frame(width: 320)
        
        .background(Color.BackColors.backSecondary)
        .cornerRadius(12)
        .shadow(radius: 10)
        
        .overlay(
            RoundedRectangle(cornerRadius: 12)
                .stroke(Color.gray.opacity(0.2), lineWidth: 1)
        )
        .onAppear {
            selectedTheme = viewModel.userTheme
        }
    }
    
    private var title: some View {
        Text(Texts.Settings.Appearance.title)
            .font(.system(size: 17, weight: .semibold))
            .padding(.top, 12)
    }
    
    private var themeSelector: some View {
        VStack(spacing: 16) {
            ForEach(Theme.allCases, id: \.self) { theme in
                Button {
                    withAnimation(.easeInOut(duration: 0.1)) {
                        selectedTheme = theme
                    }
                } label: {
                    selectorRow(title: theme.name,
                                isSelected: theme == selectedTheme)
                }
                .buttonStyle(.plain)
            }
        }
    }
    
    @ViewBuilder
    private func selectorRow(title: String, isSelected: Bool) -> some View {
        HStack {
            Text(title)
                .font(.system(size: 17, weight: .regular))
            Spacer()
            
            (isSelected ? Image.Selector.selected :
               Image.Selector.unselected)
               .resizable()
               .frame(width: 20, height: 20)
        }
        .contentShape(Rectangle())
        .padding(.horizontal, 16)
    }
    
    private var buttons: some View {
        HStack(spacing: 4) {
            cancelButton
            acceptButton
        }
        .padding([.horizontal, .bottom], 6)
    }
    
    private var acceptButton: some View {
        Button {
            viewModel.toggleShowingAppearance()
            viewModel.changeTheme(theme: selectedTheme)
        } label: {
            ZStack {
                Color.LabelColors.labelPrimary
                
                Text(Texts.Settings.Appearance.accept)
                    .font(.system(size: 17, weight: .regular))
                    .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .center)
                    .foregroundColor(Color.LabelColors.labelReversed)
            }
            .clipShape(.rect(cornerRadius: 10))
        }
        .frame(height: 50)
        .frame(maxWidth: .infinity)
    }
    
    private var cancelButton: some View {
        Button {
            viewModel.toggleShowingAppearance()
        } label: {
            ZStack {
                Color.clear
                
                Text(Texts.Settings.Appearance.cancel)
                    .font(.system(size: 17, weight: .regular))
                    .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .center)
                    .foregroundColor(Color.LabelColors.labelPrimary)
            }
            .clipShape(.rect(cornerRadius: 10))
            .overlay(
                RoundedRectangle(cornerRadius: 10)
                    .stroke(Color.LabelColors.labelDetails, lineWidth: 1)
            )
        }
        .frame(height: 50)
        .frame(maxWidth: .infinity)
    }
}

#Preview {
    SettingAppearanceView()
        .environmentObject(SettingsViewModel(notificationsEnabled: false))
}
