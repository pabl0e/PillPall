// Removed duplicate TaskModel definition

class TodoItem {
  bool isCompleted;
  String description;

  TodoItem({required this.isCompleted, required this.description});

  factory TodoItem.fromMap(Map<String, dynamic> data) {
    return TodoItem(
      isCompleted: data['isCompleted'] ?? false,
      description: data['description'] ?? '',
    );
  }

  Map<String, dynamic> toMap() {
    return {'isCompleted': isCompleted, 'description': description};
  }
}

class TaskModel {
  final String id;
  final String userId;
  final String date;
  final String title;
  final bool isCompleted;
  final List<TodoItem> todos;

  TaskModel({
    required this.id,
    required this.userId,
    required this.date,
    required this.title,
    required this.isCompleted,
    required this.todos,
  });

  factory TaskModel.fromFirestore(Map<String, dynamic> data, String id) {
    var todosData = data['todos'] as List<dynamic>? ?? [];
    List<TodoItem> todosList = todosData
        .map((todo) => TodoItem.fromMap(todo as Map<String, dynamic>))
        .toList();

    return TaskModel(
      id: id,
      userId: data['userId'],
      date: data['date'],
      title: data['title'],
      isCompleted: data['isCompleted'] ?? false,
      todos: todosList,
    );
  }

  Map<String, dynamic> toFirestore() {
    return {
      'userId': userId,
      'date': date,
      'title': title,
      'isCompleted': isCompleted,
      'todos': todos.map((todo) => todo.toMap()).toList(),
    };
  }
}
