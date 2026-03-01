import '../../models/todo_model.dart';

class TodoState {
  final List<Todo> allTodos;       
  final List<Todo> filteredTodos;  
  final bool isLoading;        

  TodoState({
    required this.allTodos,
    required this.filteredTodos,
    this.isLoading = false,
  });

  TodoState copyWith({
    List<Todo>? allTodos,
    List<Todo>? filteredTodos,
    bool? isLoading,
  }) {
    return TodoState(
      allTodos: allTodos ?? this.allTodos,
      filteredTodos: filteredTodos ?? this.filteredTodos,
      isLoading: isLoading ?? this.isLoading,
    );
  }
}