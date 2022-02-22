//
//  NotesView.swift
//  Holes
//
//  Created by Dylan Elliott on 19/2/2022.
//

import SwiftUI

struct NotesView: View {

    @State var text: String
    
    init() {
        text = UserDefaults.standard.string(forKey: Constants.notesUserDefaultsKey) ?? ""
    }
    
    var body: some View {
        TextEditor(text: $text.onChange({ newValue in
            UserDefaults.standard.set(newValue, forKey: Constants.notesUserDefaultsKey)
            UserDefaults.standard.synchronize()
            print(newValue)
        }))
//        .resignKeyboardOnDragGesture()
        .navigationTitle("Notes")
    }
    
    enum Constants {
        static let notesUserDefaultsKey = "NOTES"
    }
}

extension Binding {
    func onChange(_ handler: @escaping (Value) -> Void) -> Binding<Value> {
        Binding(
            get: { self.wrappedValue },
            set: { newValue in
                self.wrappedValue = newValue
                handler(newValue)
            }
        )
    }
}

extension UIApplication {
    func endEditing(_ force: Bool) {
        self.windows
            .filter{$0.isKeyWindow}
            .first?
            .endEditing(force)
    }
}

struct ResignKeyboardOnDragGesture: ViewModifier {
    var gesture = DragGesture().onChanged{_ in
        UIApplication.shared.endEditing(true)
    }
    func body(content: Content) -> some View {
        content.gesture(gesture)
    }
}

extension View {
    func resignKeyboardOnDragGesture() -> some View {
        return modifier(ResignKeyboardOnDragGesture())
    }
}
