import SwiftUI

struct ContentView: View {
    // Step 1: State to store tasks
    @State private var tasks: [String] = []
    
    // Step 2: State to track the new task input
    @State private var newTask: String = ""
    
    var body: some View {
        NavigationView {
            VStack {
                HStack {
                    TextField("Enter new task", text: $newTask)
                        .textFieldStyle(RoundedBorderTextFieldStyle())
                        .padding()

                    Button(action: {
                        addTask()
                    }) {
                        Text("Add")
                            .padding()
                            .background(Color.blue)
                            .foregroundColor(.white)
                            .cornerRadius(8)
                    }
                }

                List {
                    ForEach(tasks, id: \.self) { task in
                        Text(task)
                    }
                    .onDelete(perform: deleteTask)
                }
            }
            .navigationTitle("To-Do List")
            .onAppear(perform: loadTasks) // Load saved tasks when view appears
        }
    }

    
    // Step 5: Function to add a task
    private func addTask() {
        if !newTask.isEmpty {
            tasks.append(newTask)
            saveTasks()
            newTask = ""
        }
    }
    
    
    // Step 6: Function to delete a task
    private func deleteTask(at offsets: IndexSet) {
        tasks.remove(atOffsets: offsets)
        saveTasks()
    }
    
    private func saveTasks() {
        UserDefaults.standard.set(tasks, forKey: "tasks")
    }
    
    private func loadTasks() {
        if let savedTasks = UserDefaults.standard.array(forKey: "tasks") as? [String] {
            tasks = savedTasks
        }
    }
    
    struct ContentView_Previews: PreviewProvider {
        static var previews: some View {
            ContentView()
        }
    }}
