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
    private let urlString = "https://swift-task-gateway-743d3a89ff77.herokuapp.com/tasks"

    func fetchTasks() async throws -> [TaskItem] {
        guard let url = URL(string: urlString) else {
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
        guard let url = URL(string: urlString) else {
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
        guard let url = URL(string: "\(urlString)/\(id)/status") else {
            throw NetworkError.invalidURL
        }

        var request = URLRequest(url: url)
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
        guard let url = URL(string: "\(urlString)/\(id)") else {
            throw NetworkError.invalidURL
        }

        var request = URLRequest(url: url)
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
