//
//  ToastViewModifier.swift
//  HabitSetter
//
//  Created by Mattias Axelsson on 2024-05-03.
//

import SwiftUI


struct Toast: ViewModifier {
    @Binding var isShowing: Bool
    var message: String?

    func body(content: Content) -> some View {
        ZStack {
            content
            if isShowing && message != nil {
                Text(message!)
                    .padding()
                    .background(Color.green.opacity(0.6))
                    .foregroundColor(Color.white)
                    .cornerRadius(10)
                    .padding(.top, 5)
                    .transition(.slide)
                    .onAppear {
                        DispatchQueue.main.asyncAfter(deadline: .now() + 2) {
                            withAnimation {
                                self.isShowing = false
                            }
                        }
                    }
            }
        }
    }
}

extension View {
    func toast(isShowing: Binding<Bool>, message: String?) -> some View {
        self.modifier(Toast(isShowing: isShowing, message: message))
    }
}





