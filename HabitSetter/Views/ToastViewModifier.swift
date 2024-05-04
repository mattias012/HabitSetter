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
        ZStack(alignment: .top) {  //align in to the top
            content
            if isShowing && message != nil {
                VStack {
                    Text(message!)
                        .padding()
                        .bold()
                        .background(Color.green.opacity(0.6))
                        .foregroundColor(Color.white)
                        .cornerRadius(5)
                        .padding(.top, 60)
                        .transition(.slide)
                        .onAppear {
                            DispatchQueue.main.asyncAfter(deadline: .now() + 2) {
                                withAnimation {
                                    self.isShowing = false
                                }
                            }
                        }
                        .onTapGesture {
                            withAnimation {
                                self.isShowing = false
                            }
                        }
                    Spacer()
                }
                .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .top)  //secure towards the top with this frame?
                .edgesIgnoringSafeArea(.top)  //ignore safe area
            }
        }
    }
}

extension View {
    func toast(isShowing: Binding<Bool>, message: String?) -> some View {
        self.modifier(Toast(isShowing: isShowing, message: message))
    }
}





