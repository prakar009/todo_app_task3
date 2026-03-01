class Todo {
  int? sqlId; 
  String? firebaseId;
  String userId;
  String title;
  String description;
  int totalSeconds;
  int remainingSeconds;
  String status;

  Todo({
    this.sqlId,
    this.firebaseId,
    required this.userId,
    required this.title,
    this.description = '',
    required this.totalSeconds,
    required this.remainingSeconds,
    this.status = 'TODO',
  });

  Map<String, dynamic> toMap() {
    return {
      'sqlId': sqlId, 
      'firebaseId': firebaseId,
      'userId': userId,
      'title': title,
      'description': description,
      'totalSeconds': totalSeconds,
      'remainingSeconds': remainingSeconds,
      'status': status,
    };
  }


  factory Todo.fromMap(Map<String, dynamic> map) {
    return Todo(
      sqlId: map['sqlId'] is int ? map['sqlId'] : int.tryParse(map['sqlId']?.toString() ?? ''),
      firebaseId: map['firebaseId']?.toString(),
      userId: map['userId']?.toString() ?? '',
      title: map['title']?.toString() ?? '',
      description: map['description']?.toString() ?? '',
      totalSeconds: map['totalSeconds'] is int ? map['totalSeconds'] : (int.tryParse(map['totalSeconds']?.toString() ?? '0') ?? 0),
      remainingSeconds: map['remainingSeconds'] is int ? map['remainingSeconds'] : (int.tryParse(map['remainingSeconds']?.toString() ?? '0') ?? 0),
      status: map['status']?.toString() ?? 'TODO',
    );
  }

  Todo copyWith({
    int? sqlId,
    String? firebaseId,
    String? userId,
    String? title,
    String? description,
    int? totalSeconds,
    int? remainingSeconds,
    String? status,
  }) {
    return Todo(
      sqlId: sqlId ?? this.sqlId,
      firebaseId: firebaseId ?? this.firebaseId,
      userId: userId ?? this.userId,
      title: title ?? this.title,
      description: description ?? this.description,
      totalSeconds: totalSeconds ?? this.totalSeconds,
      remainingSeconds: remainingSeconds ?? this.remainingSeconds,
      status: status ?? this.status,
    );
  }
}