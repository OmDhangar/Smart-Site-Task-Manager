
enum Priority { low, medium, high }

enum Status { pending, inProgress, completed }

class Task {
  final String id;
  final String title;
  final String? description;
  final String category;
  final Priority priority;
  final Status status;
  final String? assignedTo;
  final DateTime? dueDate;
  final Map<String, dynamic>? extractedEntities; // read-only AI output
  final List<String>? suggestedActions;
  final DateTime? createdAt;
  final DateTime? updatedAt;

  Task({
    required this.id,
    required this.title,
    this.description,
    required this.category,
    required this.priority,
    required this.status,
    this.assignedTo,
    this.dueDate,
    this.extractedEntities,
    this.suggestedActions,
    this.createdAt,
    this.updatedAt,
  });

  factory Task.fromJson(Map<String, dynamic> json) {
    Priority parsePriority(String? p) {
      switch (p) {
        case 'low':
          return Priority.low;
        case 'medium':
          return Priority.medium;
        case 'high':
          return Priority.high;
        default:
          return Priority.low;
      }
    }

    Status parseStatus(String? s) {
      switch (s) {
        case 'pending':
          return Status.pending;
        case 'in_progress':
        case 'inProgress':
          return Status.inProgress;
        case 'completed':
          return Status.completed;
        default:
          return Status.pending;
      }
    }

    return Task(
      id: json['id'] as String,
      title: json['title'] as String,
      description: json['description'] as String?,
      category: json['category'] as String? ?? '',
      priority: parsePriority(json['priority'] as String?),
      status: parseStatus(json['status'] as String?),
      assignedTo: json['assigned_to'] as String?,
      dueDate: json['due_date'] != null ? DateTime.parse(json['due_date'] as String) : null,
      extractedEntities: json['extracted_entities'] as Map<String, dynamic>?,
      suggestedActions: (json['suggested_actions'] as List?)?.map((e) => e as String).toList(),
      createdAt: json['created_at'] != null ? DateTime.parse(json['created_at'] as String) : null,
      updatedAt: json['updated_at'] != null ? DateTime.parse(json['updated_at'] as String) : null,
    );
  }

  Map<String, dynamic> toJson() {
    String priorityToString(Priority p) {
      switch (p) {
        case Priority.low:
          return 'low';
        case Priority.medium:
          return 'medium';
        case Priority.high:
          return 'high';
      }
    }

    String statusToString(Status s) {
      switch (s) {
        case Status.pending:
          return 'pending';
        case Status.inProgress:
          return 'in_progress';
        case Status.completed:
          return 'completed';
      }
    }

    return {
      'id': id,
      'title': title,
      if (description != null) 'description': description,
      'category': category,
      'priority': priorityToString(priority),
      'status': statusToString(status),
      if (assignedTo != null) 'assigned_to': assignedTo,
      if (dueDate != null) 'due_date': dueDate!.toIso8601String(),
    };
  }
}
