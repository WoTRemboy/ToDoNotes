//
//  OnboardingScreenView.swift
//  ToDoNotes
//
//  Created by Roman Tverdokhleb on 1/1/25.
//

import SwiftUI
import SwiftUIPager
import AuthenticationServices

/// View displaying the onboarding process or the main `RootView` if onboarding is complete.
struct OnboardingScreenView: View {
    
    @Environment(\.colorScheme) var colorScheme
    
    /// View model controlling the onboarding state.
    @EnvironmentObject private var viewModel: OnboardingViewModel
    
    /// Current page tracker for the pager.
    @StateObject private var page: Page = .first()
    
    // MARK: - Body
    
    internal var body: some View {
        if viewModel.skipOnboarding {
            RootView()
                .environmentObject(TabRouter())
        } else {
            VStack(spacing: 0) {
                content
                progressCircles
                selectPageButtons
                skipButton
            }
            .padding(.vertical)
        }
    }
    
    // MARK: - Content
    
    /// Displays the onboarding steps using a Pager.
    private var content: some View {
        Pager(page: page,
              data: viewModel.pages,
              id: \.self) { index in
                VStack(spacing: 0) {
                    viewModel.steps[index].image
                        .resizable()
                        .scaledToFit()
                        .frame(width: 300, height: 300)
                        .clipShape(.rect(cornerRadius: 16))
                    
                    Text(viewModel.steps[index].name)
                        .font(.system(size: 18))
                        .fontWeight(.regular)
                        .multilineTextAlignment(.center)
                        .padding(.top)
                    
                    Text(viewModel.steps[index].description)
                        .font(.system(size: 14))
                        .fontWeight(.light)
                        .multilineTextAlignment(.center)
                        .padding(.top, 3)
                        .frame(width: 238)
                }
                .frame(maxWidth: .infinity, maxHeight: .infinity)
                .tag(index)
        }
              .interactive(scale: 0.8)
              .itemSpacing(10)
              .itemAspectRatio(1.0)
        
              .swipeInteractionArea(.allAvailable)
              .multiplePagination()
              .horizontal()
    }
    
    // MARK: - Progress Circles
    
    /// Displays the progress indicator for the onboarding steps.
    private var progressCircles: some View {
        HStack {
            ForEach(viewModel.pages, id: \.self) { step in
                if step == page.index {
                    Circle()
                        .frame(width: 15, height: 15)
                        .foregroundStyle(Color.gray)
                        .transition(.scale)
                } else {
                    Circle()
                        .frame(width: 10, height: 10)
                        .foregroundStyle(Color.labelDisable)
                        .transition(.scale)
                }
            }
        }
    }
    
    // MARK: - Page Buttons
    
    private var selectPageButtons: some View {
        VStack(spacing: 16) {
            if !viewModel.isLastPage(current: page.index) {
                nextPageButton
                    .transition(.move(edge: .leading).combined(with: .opacity))
            } else {
                signWithAppleButton
                    .transition(.move(edge: .trailing).combined(with: .opacity))
                    .padding(.top, 30)
                signWithAppleButton
                    .transition(.move(edge: .trailing).combined(with: .opacity))
            }
        }
    }
    
    // MARK: - Action Button
    
    /// Button for advancing to the next step or completing onboarding.
    private var nextPageButton: some View {
        Button {
            withAnimation {
                page.update(.next)
            }
        } label: {
            Text(Texts.OnboardingPage.next)
                .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .center)
        }
        .frame(height: 50)
        .frame(maxWidth: .infinity)
        .minimumScaleFactor(0.4)
        
        .foregroundStyle(Color.white)
        .tint(Color.LabelColors.labelPrimary)
        .buttonStyle(.bordered)
        
        .padding(.horizontal)
        .padding(.top, 30)
    }
    
    // MARK: - Sign with Apple Button
    
    private var signWithAppleButton: some View {
        SignInWithAppleButton(.continue) { request in
            request.requestedScopes = [.fullName, .email]
        } onCompletion: { result in
            viewModel.authorization(result: result)
        }
        .signInWithAppleButtonStyle(
            colorScheme == .light ? .black : .white
        )
        .clipShape(.rect(cornerRadius: 10))
        .frame(height: 50)
        .padding(.horizontal)
    }
    
    // MARK: - Skip Button
    
    /// Button allowing users to skip to the last onboarding step.
    private var skipButton: some View {
        Text(!viewModel.isLastPage(current: page.index) ? Texts.OnboardingPage.skip : Texts.OnboardingPage.withoutAuth)
            .font(.system(size: 14))
            .fontWeight(.light)
            .foregroundStyle(Color.labelSecondary)
        
            .padding(.top)
            .padding(.bottom, hasNotch() ? 20 : 16)
        
            .onTapGesture {
                if !viewModel.isLastPage(current: page.index) {
                    withAnimation {
                        page.update(.moveToLast)
                    }
                } else {
                    viewModel.skipSteps()
                }
            }
            .animation(.easeInOut, value: page.index)
    }
}

// MARK: - Preview

#Preview {
    OnboardingScreenView()
        .environmentObject(OnboardingViewModel())
}
