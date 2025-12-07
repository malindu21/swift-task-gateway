import Foundation

enum NetworkError: LocalizedError {
    case invalidURL
    case invalidResponse
    case decodingError
    case serverError(String)

    var errorDescription: String? {
        switch self {
        case .invalidURL:
            return "Invalid URL"
        case .invalidResponse:
            return "Invalid response from server"
        case .decodingError:
            return "Failed to decode response"
        case .serverError(let message):
            return message
        }
    }
}

actor TaskService {
    private var baseTasksURL: URL? {
        let trimmed = AppConfig.baseURL.trimmingCharacters(in: CharacterSet(charactersIn: "/"))
        return URL(string: "\(trimmed)/tasks")
    }

    func fetchTasks() async throws -> [TaskItem] {
        guard let url = baseTasksURL else {
            throw NetworkError.invalidURL
        }

        let (data, response) = try await URLSession.shared.data(from: url)

        guard let httpResponse = response as? HTTPURLResponse else {
            throw NetworkError.invalidResponse
        }

        guard (200...299).contains(httpResponse.statusCode) else {
            throw NetworkError.serverError("Server returned status code \(httpResponse.statusCode)")
        }

        do {
            let decoder = JSONDecoder()

            if let taskResponse = try? decoder.decode(TaskResponse.self, from: data) {
                return taskResponse.data
            }

            return try decoder.decode([TaskItem].self, from: data)
        } catch {
            throw NetworkError.decodingError
        }
    }

    func addTask(task: String, status: Bool = false) async throws -> TaskItem {
        guard let url = baseTasksURL else {
            throw NetworkError.invalidURL
        }

        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")

        let body: [String: Any] = [
            "task": task,
            "status": status
        ]

        request.httpBody = try JSONSerialization.data(withJSONObject: body)

        let (data, response) = try await URLSession.shared.data(for: request)

        guard let httpResponse = response as? HTTPURLResponse else {
            throw NetworkError.invalidResponse
        }

        guard (200...299).contains(httpResponse.statusCode) else {
            throw NetworkError.serverError("Server returned status code \(httpResponse.statusCode)")
        }

        let decoder = JSONDecoder()

        if let taskResponse = try? decoder.decode(TaskResponse.self, from: data),
           let createdTask = taskResponse.data.first {
            return createdTask
        }

        if let envelope = try? decoder.decode(TaskDataResponse.self, from: data) {
            return envelope.data
        }

        return try decoder.decode(TaskItem.self, from: data)
    }

    func updateTaskStatus(id: Int, status: Bool) async throws -> TaskItem {
        guard let base = baseTasksURL else {
            throw NetworkError.invalidURL
        }

        var request = URLRequest(url: base.appendingPathComponent("\(id)/status"))
        request.httpMethod = "PATCH"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        request.httpBody = try JSONSerialization.data(withJSONObject: ["status": status])

        let (data, response) = try await URLSession.shared.data(for: request)

        guard let httpResponse = response as? HTTPURLResponse else {
            throw NetworkError.invalidResponse
        }

        guard (200...299).contains(httpResponse.statusCode) else {
            throw NetworkError.serverError("Server returned status code \(httpResponse.statusCode)")
        }

        let decoder = JSONDecoder()

        if let taskResponse = try? decoder.decode(TaskResponse.self, from: data),
           let updatedTask = taskResponse.data.first {
            return updatedTask
        }

        if let envelope = try? decoder.decode(TaskDataResponse.self, from: data) {
            return envelope.data
        }

        return try decoder.decode(TaskItem.self, from: data)
    }

    func deleteTask(id: Int) async throws {
        guard let base = baseTasksURL else {
            throw NetworkError.invalidURL
        }

        var request = URLRequest(url: base.appendingPathComponent("\(id)"))
        request.httpMethod = "DELETE"

        let (_, response) = try await URLSession.shared.data(for: request)

        guard let httpResponse = response as? HTTPURLResponse else {
            throw NetworkError.invalidResponse
        }

        guard (200...299).contains(httpResponse.statusCode) else {
            throw NetworkError.serverError("Server returned status code \(httpResponse.statusCode)")
        }
    }
}
