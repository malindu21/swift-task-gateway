import SwiftUI

struct ContentView: View {
    @StateObject private var viewModel = TaskListViewModel()

    var body: some View {
        TaskListScreen(viewModel: viewModel)
    }
}

struct TaskListScreen: View {
    @ObservedObject var viewModel: TaskListViewModel
    @State private var newTaskText = ""

    var body: some View {
        NavigationStack {
            ZStack {
                content

                if viewModel.isLoading && viewModel.tasks.isEmpty {
                    ProgressView("Loading tasks...")
                        .padding(24)
                        .background(.thinMaterial, in: RoundedRectangle(cornerRadius: 14))
                }
            }
            .navigationTitle("Tasks")
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button {
                        viewModel.isShowingNewTaskSheet = true
                        newTaskText = ""
                    } label: {
                        Image(systemName: "plus.circle.fill")
                            .font(.title2)
                    }
                    .disabled(viewModel.isLoading)
                    .accessibilityLabel("Add task")
                }
            }
            .task {
                await viewModel.loadTasks()
            }
            .refreshable {
                await viewModel.loadTasks()
            }
            .alert("Something went wrong", isPresented: errorBinding) {
                Button("Retry") {
                    Task { await viewModel.loadTasks() }
                }
                Button("Dismiss", role: .cancel) {
                    viewModel.errorMessage = nil
                }
            } message: {
                if let message = viewModel.errorMessage {
                    Text(message)
                }
            }
            .sheet(isPresented: $viewModel.isShowingNewTaskSheet) {
                NewTaskSheet(
                    text: $newTaskText,
                    isSubmitting: viewModel.isAddingTask,
                    onAdd: { text in
                        Task {
                            await viewModel.addTask(description: text)

                            if viewModel.errorMessage == nil {
                                viewModel.isShowingNewTaskSheet = false
                            }
                        }
                    }
                )
                .presentationDetents([.medium])
            }
        }
    }

    private var content: some View {
        Group {
            if let error = viewModel.errorMessage, viewModel.tasks.isEmpty {
                ErrorStateView(message: error) {
                    Task { await viewModel.loadTasks() }
                }
            } else if viewModel.tasks.isEmpty {
                EmptyStateView()
            } else {
                TaskListView(tasks: viewModel.tasks)
            }
        }
        .animation(.easeInOut, value: viewModel.tasks.count)
    }

    private var errorBinding: Binding<Bool> {
        Binding(
            get: { viewModel.errorMessage != nil },
            set: { isPresented in
                if !isPresented {
                    viewModel.errorMessage = nil
                }
            }
        )
    }
}

struct TaskListView: View {
    let tasks: [TaskItem]

    var body: some View {
        List(tasks) { task in
            TaskRowView(task: task)
                .listRowInsets(.init(top: 12, leading: 16, bottom: 12, trailing: 16))
                .listRowSeparator(.hidden)
                .listRowBackground(Color.clear)
        }
        .listStyle(.plain)
        .background(Color(.systemGroupedBackground))
    }
}

struct TaskRowView: View {
    let task: TaskItem

    var body: some View {
        HStack(spacing: 12) {
            ZStack {
                Circle()
                    .fill(task.status ? Color.green.opacity(0.15) : Color.gray.opacity(0.12))
                    .frame(width: 32, height: 32)
                Image(systemName: task.status ? "checkmark.circle.fill" : "circle")
                    .foregroundStyle(task.status ? .green : .secondary)
                    .font(.title3)
            }

            VStack(alignment: .leading, spacing: 6) {
                Text(task.task)
                    .font(.headline)
                    .foregroundStyle(.primary)
                    .lineLimit(2)

                Text(task.formattedDate)
                    .font(.caption)
                    .foregroundStyle(.secondary)
            }

            Spacer()

            Text(task.status ? "Done" : "Open")
                .font(.caption.weight(.semibold))
                .padding(.horizontal, 10)
                .padding(.vertical, 6)
                .foregroundStyle(task.status ? .green : .orange)
                .background((task.status ? Color.green.opacity(0.12) : Color.orange.opacity(0.12)))
                .clipShape(Capsule())
        }
        .padding(12)
        .background(Color(.secondarySystemBackground), in: RoundedRectangle(cornerRadius: 14))
    }
}

struct EmptyStateView: View {
    var body: some View {
        ContentUnavailableView(
            "No Tasks",
            systemImage: "checklist",
            description: Text("Create a new task to get started.")
        )
        .symbolVariant(.circle.fill)
    }
}

struct ErrorStateView: View {
    let message: String
    let retry: () -> Void

    var body: some View {
        VStack(spacing: 16) {
            Image(systemName: "exclamationmark.triangle.fill")
                .font(.system(size: 48))
                .foregroundStyle(.orange)

            Text("Something went wrong")
                .font(.title3)
                .fontWeight(.semibold)

            Text(message)
                .font(.body)
                .foregroundStyle(.secondary)
                .multilineTextAlignment(.center)
                .padding(.horizontal)

            Button("Retry", action: retry)
                .buttonStyle(.borderedProminent)
        }
        .padding()
    }
}

struct NewTaskSheet: View {
    @Environment(\.dismiss) private var dismiss
    @Binding var text: String
    let isSubmitting: Bool
    let onAdd: (String) -> Void
    @FocusState private var isFocused: Bool

    private var isAddButtonDisabled: Bool {
        text.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty || isSubmitting
    }

    var body: some View {
        NavigationStack {
            Form {
                Section(header: Text("What needs to be done?")) {
                    TextField("Enter task description", text: $text, axis: .vertical)
                        .lineLimit(2...4)
                        .focused($isFocused)
                }

                if isSubmitting {
                    Section {
                        HStack {
                            Spacer()
                            ProgressView("Adding task...")
                            Spacer()
                        }
                    }
                }
            }
            .navigationTitle("New Task")
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("Cancel") {
                        text = ""
                        isFocused = false
                        dismiss()
                    }
                }

                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Add") {
                        onAdd(text)
                    }
                    .disabled(isAddButtonDisabled)
                }
            }
            .onAppear {
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.4) {
                    isFocused = true
                }
            }
        }
    }
}
