import SwiftUI

@MainActor
final class TaskListViewModel: ObservableObject {
    @Published private(set) var tasks: [TaskItem] = []
    @Published var isLoading = false
    @Published var isAddingTask = false
    @Published var updatingTaskIds: Set<Int> = []
    @Published var deletingTaskIds: Set<Int> = []
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
            await refreshTasksFromServer()
        } catch {
            errorMessage = error.localizedDescription
        }

        isAddingTask = false
    }

    func toggleStatus(for task: TaskItem) async {
        guard !updatingTaskIds.contains(task.id) else { return }

        updatingTaskIds.insert(task.id)
        errorMessage = nil
        let previousTasks = tasks

        let toggledStatus = !task.status
        tasks = tasks.map { item in
            guard item.id == task.id else { return item }
            return TaskItem(id: item.id, task: item.task, status: toggledStatus, createdAt: item.createdAt)
        }

        do {
            let updated = try await service.updateTaskStatus(id: task.id, status: toggledStatus)
            tasks = tasks.map { $0.id == updated.id ? updated : $0 }
            await refreshTasksFromServer()
        } catch {
            tasks = previousTasks
            errorMessage = error.localizedDescription
        }

        updatingTaskIds.remove(task.id)
    }

    func deleteTask(id: Int) async {
        guard !deletingTaskIds.contains(id) else { return }

        deletingTaskIds.insert(id)
        errorMessage = nil
        let previousTasks = tasks
        tasks.removeAll { $0.id == id }

        do {
            try await service.deleteTask(id: id)
            await refreshTasksFromServer()
        } catch {
            tasks = previousTasks
            errorMessage = error.localizedDescription
        }

        deletingTaskIds.remove(id)
    }

    private func refreshTasksFromServer() async {
        do {
            tasks = try await service.fetchTasks()
            errorMessage = nil
        } catch {
            errorMessage = error.localizedDescription
        }
    }
}
