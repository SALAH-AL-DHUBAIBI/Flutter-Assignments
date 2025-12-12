class Task {
  int? id;
  String? title;
  String? description;
  String? priority;
  String? dueDate;
  int? isCompleted;
  String? category;
  String? createdAt;

  Task({
    this.id,
    this.title,
    this.description,
    this.priority,
    this.dueDate,
    this.isCompleted,
    this.category,
    this.createdAt,
  });

  Task.fromJson(Map<String, dynamic> json) {
    id = json['id'];
    title = json['title'];
    description = json['description'];
    priority = json['priority'];
    dueDate = json['dueDate'];
    isCompleted = json['isCompleted'];
    category = json['category'];
    createdAt = json['createdAt'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['id'] = id;
    data['title'] = title;
    data['description'] = description;
    data['priority'] = priority;
    data['dueDate'] = dueDate;
    data['isCompleted'] = isCompleted;
    data['category'] = category;
    data['createdAt'] = createdAt;
    return data;
  }
}
