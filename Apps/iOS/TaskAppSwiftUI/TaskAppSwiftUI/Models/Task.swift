import Foundation

struct TaskResponse: Codable {
    let data: [TaskItem]
}

struct TaskDataResponse: Codable {
    let data: TaskItem
}

struct TaskItem: Codable, Identifiable {
    let id: Int
    let task: String
    let status: Bool
    let createdAt: String

    var formattedDate: String {
        let isoFormatter = ISO8601DateFormatter()
        isoFormatter.formatOptions = [.withInternetDateTime, .withFractionalSeconds]

        var parsedDate = isoFormatter.date(from: createdAt)

        if parsedDate == nil {
            isoFormatter.formatOptions = [.withInternetDateTime]
            parsedDate = isoFormatter.date(from: createdAt)
        }

        guard let date = parsedDate else { return createdAt }

        let formatter = DateFormatter()
        formatter.dateStyle = .medium
        formatter.timeStyle = .short
        return formatter.string(from: date)
    }
}
