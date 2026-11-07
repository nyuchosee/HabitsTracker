//
//  EditHabitView.swift
//  Task
//
//  Created by Ru Niu on 11/5/26.
//
import SwiftUI

struct EditHabitView: View {
    
    let habit: Habit
    
    let onSave: (String) -> Void
        
    @State private var editedTitle = ""
    
    var body: some View {
        VStack {
            TextField("Название привычки", text: $editedTitle)
                .padding()
                .onAppear {
                    editedTitle = habit.titles
                }
            
            Button("Сохранить") {
                let cleanTitle = editedTitle.trimmingCharacters(in: .whitespacesAndNewlines)
                guard !cleanTitle.isEmpty else {
                    return
                }
                onSave(cleanTitle)
            }
        }
        
    }
}
