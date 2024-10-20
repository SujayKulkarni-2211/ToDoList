import SwiftUI

struct Task: Identifiable, Codable {
    var id = UUID() // Unique identifier for each task
    var title: String
    var dueDate: Date // Due date for the task
    var isCompleted: Bool = false // Status of the task
}

struct ContentView: View {
    @State private var tasks: [Task] = []
    @State private var newTaskTitle: String = ""
    @State private var newTaskDueDate: Date = Date() // Default to the current date
    @State private var isEditing: Bool = false
    @State private var editingTaskIndex: Int? = nil

    var body: some View {
        NavigationView {
            VStack {
                HStack {
                    TextField("Enter new task", text: $newTaskTitle)
                        .textFieldStyle(RoundedBorderTextFieldStyle())
                        .padding()

                    Button(action: {
                        if isEditing, let index = editingTaskIndex {
                            updateTask(at: index)
                        } else {
                            addTask()
                        }
                    }) {
                        Text(isEditing ? "Update" : "Add")
                            .padding(.horizontal, 10)
                            .padding(.vertical, 10)
                            .background(Color.blue)
                            .foregroundColor(.white)
                            .cornerRadius(8)
                    }
                }

                DatePicker("Due Date", selection: $newTaskDueDate, displayedComponents: .date)
                    .padding()

                List {
                    Section(header: Text("Tasks")) {
                        ForEach(tasks.indices, id: \.self) { index in
                            HStack {
                                VStack(alignment: .leading) {
                                    Text(tasks[index].title)
                                    Text("Due: \(formattedDate(tasks[index].dueDate))") // Display due date
                                        .font(.subheadline)
                                        .foregroundColor(.gray)
                                }
                                Spacer()
                                Button(action: {
                                    completeTask(at: index)
                                }) {
                                    Text("Complete")
                                        .foregroundColor(.green)
                                }
                                Button(action: {
                                    startEditingTask(at: index)
                                }) {
                                    Text("Edit")
                                        .foregroundColor(.blue)
                                }
                            }
                        }
                        .onDelete(perform: deleteTask)
                    }

                    Section(header: Text("Completed Tasks")) {
                        ForEach(tasks.filter { $0.isCompleted }) { task in
                            Text(task.title) // Display completed tasks
                        }
                    }
                }
            }
            .navigationTitle("To-Do List")
            .onAppear(perform: loadTasks)
        }
    }

    private func addTask() {
        if !newTaskTitle.isEmpty {
            let newTask = Task(title: newTaskTitle, dueDate: newTaskDueDate)
            tasks.append(newTask)
            saveTasks()
            newTaskTitle = ""
            newTaskDueDate = Date() // Reset due date
        }
    }

    private func updateTask(at index: Int) {
        if let index = editingTaskIndex {
            tasks[index].title = newTaskTitle
            tasks[index].dueDate = newTaskDueDate // Update due date
            saveTasks()
            newTaskTitle = ""
            newTaskDueDate = Date() // Reset due date
            isEditing = false
            editingTaskIndex = nil
        }
    }

    private func completeTask(at index: Int) {
        // Ensure the index is valid
        guard index < tasks.count else { return }
        
        tasks[index].isCompleted = true // Mark task as completed
        saveTasks()
    }

    private func startEditingTask(at index: Int) {
        newTaskTitle = tasks[index].title
        newTaskDueDate = tasks[index].dueDate // Load the due date for editing
        isEditing = true
        editingTaskIndex = index
    }

    private func deleteTask(at offsets: IndexSet) {
        tasks.remove(atOffsets: offsets)
        saveTasks()
    }

    private func saveTasks() {
        if let encoded = try? JSONEncoder().encode(tasks) {
            UserDefaults.standard.set(encoded, forKey: "tasks")
        }
    }

    private func loadTasks() {
        if let data = UserDefaults.standard.data(forKey: "tasks"),
           let decodedTasks = try? JSONDecoder().decode([Task].self, from: data) {
            tasks = decodedTasks
        }
    }

    private func formattedDate(_ date: Date) -> String {
        let formatter = DateFormatter()
        formatter.dateStyle = .short
        return formatter.string(from: date)
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
