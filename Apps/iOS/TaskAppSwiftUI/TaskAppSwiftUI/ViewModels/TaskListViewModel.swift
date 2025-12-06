import SwiftUI

@MainActor
final class TaskListViewModel: ObservableObject {
    @Published private(set) var tasks: [Task] = []
    @Published var isLoading = false
    @Published var isAddingTask = false
    @Published var errorMessage: String?
    @Published var isShowingNewTaskSheet = false

    private let service: TaskService

    init(service: TaskService = TaskService()) {
        self.service = service
    }

    func loadTasks() async {
        guard !isLoading else { return }

        isLoading = true
        errorMessage = nil

        do {
            tasks = try await service.fetchTasks()
        } catch {
            errorMessage = error.localizedDescription
        }

        isLoading = false
    }

    func addTask(description: String) async {
        let trimmed = description.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !trimmed.isEmpty else { return }
        guard !isAddingTask else { return }

        isAddingTask = true
        errorMessage = nil

        do {
            let createdTask = try await service.addTask(task: trimmed)
            tasks.insert(createdTask, at: 0)
        } catch {
            errorMessage = error.localizedDescription
        }

        isAddingTask = false
    }
}
