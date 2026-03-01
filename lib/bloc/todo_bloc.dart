import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../data/database_helper.dart';
import '../models/todo_model.dart';
import '../services/notification_service.dart';
import 'todo_event.dart';
import 'todo_state.dart';

class TodoBloc extends Bloc<TodoEvent, TodoState> {
  Timer? _timer;
  final _db = DatabaseHelper.instance;
  final _fire = FirebaseFirestore.instance;
  final _auth = FirebaseAuth.instance;

  TodoBloc() : super(TodoState(allTodos: [], filteredTodos: [], isLoading: false)) {
    on<LoadTodos>(_onLoadTodos);
    on<Tick>(_onTimerTick);
    on<AddOrUpdateTodo>(_onSaveTodo);
    on<DeleteTodoEvent>(_onDeleteTodo);
    on<SearchTodos>(_onSearch);

    _startGlobalTimer();
  }

  User? get user => _auth.currentUser;
  
  DocumentReference _todoDoc(dynamic id) => 
      _fire.collection('users').doc(user?.email).collection('todos').doc(id.toString());

  Future<void> _onLoadTodos(LoadTodos event, Emitter<TodoState> emit) async {
    if (user == null) return;
    emit(state.copyWith(isLoading: true));
    try {
      final data = await _db.fetchByUser(user!.uid);
      emit(state.copyWith(allTodos: data, filteredTodos: data, isLoading: false));
    } catch (e) {
      emit(state.copyWith(isLoading: false));
    }
  }

  void _onTimerTick(Tick event, Emitter<TodoState> emit) {
    if (user == null || state.allTodos.isEmpty) return;

    bool needsUIUpdate = false;
    final updatedList = state.allTodos.map((task) {
      if (task.status == 'In-Progress' && task.remainingSeconds > 0) {
        task.remainingSeconds--;
        needsUIUpdate = true;

        if (task.remainingSeconds == 0) {
          task.status = 'Done';
          _handleTaskCompletion(task);
        }
      }
      return task;
    }).toList();

    if (needsUIUpdate) {
      emit(state.copyWith(allTodos: updatedList, filteredTodos: updatedList));
    }
  }

  Future<void> _onSaveTodo(AddOrUpdateTodo event, Emitter<TodoState> emit) async {
    if (user == null) return;
    
    final task = event.todo..userId = user!.uid;
    try {
      if (task.sqlId == null) {
        task.sqlId = await _db.insert(task);
        await _todoDoc(task.sqlId).set(task.toMap());
      } else {
        await _db.update(task);
        await _todoDoc(task.sqlId).set(task.toMap(), SetOptions(merge: true));
      }
      add(LoadTodos());
    } catch (e) {
      debugPrint("Error: $e");
    }
  }

  Future<void> _onDeleteTodo(DeleteTodoEvent event, Emitter<TodoState> emit) async {
    try {
      await _db.delete(event.sqlId);
      await _todoDoc(event.sqlId).delete();
      add(LoadTodos());
    } catch (e) {
      debugPrint("Error: $e");
    }
  }

  void _onSearch(SearchTodos event, Emitter<TodoState> emit) {
    final query = event.query.toLowerCase();
    final filtered = state.allTodos.where((t) => 
      t.title.toLowerCase().contains(query) || 
      t.description.toLowerCase().contains(query)
    ).toList();
    emit(state.copyWith(filteredTodos: filtered));
  }

  void _handleTaskCompletion(Todo task) {
    NotificationService.notifyStateChange(
      id: task.sqlId!, 
      title: "Task Completed!", 
      body: "'${task.title}' is finished."
    );
    _db.update(task);
    _todoDoc(task.sqlId).update({'status': 'Done', 'remainingSeconds': 0});
  }

  void _startGlobalTimer() {
    _timer?.cancel();
    _timer = Timer.periodic(const Duration(seconds: 1), (_) {
      if (!isClosed) add(Tick());
    });
  }

  @override
  Future<void> close() {
    _timer?.cancel();
    return super.close();
  }
}