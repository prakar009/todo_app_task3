import '../models/todo_model.dart';

abstract class TodoEvent {}

class LoadTodos extends TodoEvent {}

class AddOrUpdateTodo extends TodoEvent {
  final Todo todo;
  AddOrUpdateTodo(this.todo);
}

class DeleteTodoEvent extends TodoEvent {
  final int sqlId; 
  DeleteTodoEvent(this.sqlId);
}

class SearchTodos extends TodoEvent {
  final String query;
  SearchTodos(this.query);
}

class Tick extends TodoEvent {}