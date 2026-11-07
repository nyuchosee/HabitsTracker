import SwiftUI

struct Habit: Identifiable, Codable {
    let id: UUID
    var titles: String
    var isCompleted: Bool
}

struct ContentView: View {
    
    @State private var selectedHabit: Habit?
    @State private var newHabit = ""
    
    @State private var habits: [Habit] = [
        Habit(id: UUID(), titles: "Читать 20 минут", isCompleted: false),
        Habit(id: UUID(), titles: "Выпить воду", isCompleted: false),
        Habit(id: UUID(), titles: "Сделать зарядку", isCompleted: false)
    ]
    
    private var completedCount: Int {
        var count = 0
        
        for habit in habits {
            if habit.isCompleted {
                count += 1
            }
        }
        return count
    }
    
    private var progress: Double {
        
        if habits.isEmpty {
            return 0.0
        }
        
        return Double(completedCount) / Double(habits.count)
    }
    
    private func saveHabits() {
        
        let jsonEncoder = JSONEncoder()
        
        guard let data = try? jsonEncoder.encode(habits) else {
            print("Ошибка сохранения")
            return
        }
        
        UserDefaults.standard.set(data, forKey: "savedHabits")
    }
    
    private func loadHabits() {
        let jsonDecoder = JSONDecoder()
        
        guard let data = UserDefaults.standard.data(forKey: "savedHabits") else {
            print("Нет сохранённых привычек")
            return
        }
        
        guard let restoredHabits = try? jsonDecoder.decode([Habit].self, from: data) else {
            print("Ошибка загрузки")
            return
        }
        
        habits = restoredHabits
    }
    
    var body: some View {
        VStack {
            Text("Мои привычки")
                .font(.title)
            
            TextField("Новая привычка", text: $newHabit)
                .padding(.horizontal, 20)
            
            Text(newHabit)
            
            Button("Добавить") {
                newHabit = newHabit.trimmingCharacters(in: .whitespacesAndNewlines)
                
                guard !newHabit.isEmpty else {
                    print("Вы ничего не ввели")
                    return
                }
                
                habits.append(
                    Habit(
                        id: UUID(),
                        titles: newHabit,
                        isCompleted: false
                    )
                )
                
                newHabit = ""
                
                saveHabits()
                
            }
            
            Text("Выполнено \(completedCount) из \(habits.count)")
                .padding(.vertical, 10)
            
            ProgressView(value: progress)
                .padding(.horizontal, 20)
            
            ForEach($habits) { $habit in
                HStack{
                    Text(habit.titles)
                    
                    Spacer()
                    
                    Button {
                        habit.isCompleted.toggle()
                        saveHabits()
                    } label: {
                        Text(habit.isCompleted ? "Выполнено" : "Выполнить")
                    }
                    .padding()
                    .background(habit.isCompleted ? .green : .gray)
                    .cornerRadius(16)
                    .foregroundStyle(.white)
                    
                    Button {
                        selectedHabit = habit
                    } label: {
                        Image(systemName: "pencil")
                    }
                    
                    Button {
                        habits.removeAll { item in
                            item.id == habit.id
                        }
                        
                        saveHabits()
                    } label: {
                        Image(systemName: "trash")
                    }
                    
                }
                .padding(10)
                .background(.regularMaterial)
                .clipShape(RoundedRectangle(cornerRadius: 15))
                .padding(.horizontal, 20)
            }
        } .onAppear {
            loadHabits()
        }
        .sheet(item: $selectedHabit) { habit in
            EditHabitView(habit: habit, onSave: { newTitle in
                guard let index = habits.firstIndex(where: { item in
                    item.id == habit.id
                }) else {
                    return
                }
                
                habits[index].titles = newTitle
                saveHabits()
                selectedHabit = nil
            })
        }
    }
}

#Preview {
    ContentView()
}

