import SwiftUI

struct TodoTask: Identifiable, Codable {
    var id = UUID() // Unique identifier for each task
    var title: String
    var dueDate: Date // Due date for the task
    var isCompleted: Bool = false // Track completion status
}

struct ContentView: View {
    // Step 1: State to store tasks
    @State private var tasks: [TodoTask] = [] // Changed to TodoTask
    // Step 2: State to track the new task input
    @State private var newTask: String = ""
    @State private var newTaskDueDate: Date = Date() // State for the due date
    @State private var editingTask: TodoTask? // State to track the task being edited

    var body: some View {
        NavigationView {
            VStack {
                HStack {
                    TextField("Enter new task", text: $newTask)
                        .textFieldStyle(RoundedBorderTextFieldStyle())
                        .padding(5)

                    Button(action: {
                        if let task = editingTask {
                            editTask(task)
                        } else {
                            addTask()
                        }
                    }) {
                        Text(editingTask == nil ? "Add" : "Edit") // Change button text based on state
                            .padding(.horizontal, 8)
                            .padding(.vertical, 8)
                            .background(Color.blue)
                            .foregroundColor(.white)
                            .cornerRadius(8)
                    }
                    .padding(.trailing, 10)
                }

                // Added DatePicker for due date
                DatePicker("Due Date", selection: $newTaskDueDate, displayedComponents: .date)
                    .padding(.horizontal)

                List {
                    ForEach(tasks) { task in
                        HStack {
                            // Mark task as completed or edit task
                            Button(action: {
                                if !task.isCompleted {
                                    markTaskAsCompleted(task)
                                } else {
                                    editTask(task)
                                }
                            }) {
                                HStack {
                                    if task.isCompleted {
                                        Image(systemName: "checkmark.circle.fill")
                                            .foregroundColor(.green)
                                    } else {
                                        Image(systemName: "circle")
                                            .foregroundColor(.gray)
                                    }
                                    
                                    Text(task.title)
                                        .strikethrough(task.isCompleted, color: .black) // Strike through if completed
                                        .foregroundColor(task.isCompleted ? .gray : .primary) // Change color if completed
                                }
                            }
                        }
                    }
                    .onDelete(perform: deleteTask)
                }
            }
            .navigationTitle("To-Do List")
            .onAppear(perform: loadTasks) // Load saved tasks when view appears
        }
    }

    // Function to add a task
    private func addTask() {
        if !newTask.isEmpty {
            let newTaskItem = TodoTask(title: newTask, dueDate: newTaskDueDate)
            tasks.append(newTaskItem)
            saveTasks()
            newTask = ""
            newTaskDueDate = Date() // Reset the due date to now after adding a task
        }
    }

    // Function to edit a task
    private func editTask(_ task: TodoTask) {
        if let index = tasks.firstIndex(where: { $0.id == task.id }) {
            tasks[index].title = newTask // Update the title with new input
            tasks[index].dueDate = newTaskDueDate // Update due date
            saveTasks()
            newTask = "" // Clear the input field
            newTaskDueDate = Date() // Reset the due date to now after editing
            editingTask = nil // Clear the editing task
        }
    }

    // Function to mark task as completed
    private func markTaskAsCompleted(_ task: TodoTask) {
        if let index = tasks.firstIndex(where: { $0.id == task.id }) {
            tasks[index].isCompleted = true // Mark the task as completed
            saveTasks()

            // Schedule deletion after 2 seconds
            DispatchQueue.main.asyncAfter(deadline: .now() + 2) {
                tasks.remove(at: index) // Remove task after 2 seconds
                saveTasks()
            }
        }
    }

    // Function to delete a task
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
           let decodedTasks = try? JSONDecoder().decode([TodoTask].self, from: data) {
            tasks = decodedTasks
        }
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}

