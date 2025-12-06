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

    func fetchTasks() async throws -> [Task] {
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

            return try decoder.decode([Task].self, from: data)
        } catch {
            throw NetworkError.decodingError
        }
    }

    func addTask(task: String, status: Bool = false) async throws -> Task {
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

        return try decoder.decode(Task.self, from: data)
    }
}
