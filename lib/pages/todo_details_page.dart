import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../bloc/todo/todo_bloc.dart';
import '../bloc/todo/todo_event.dart';
import '../bloc/todo/todo_state.dart';
import '../models/todo_model.dart';

class TodoDetailsPage extends StatelessWidget {
  final int todoId;
  const TodoDetailsPage({super.key, required this.todoId});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0F0F0F),
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(icon: const Icon(Icons.arrow_back_ios_new_rounded, color: Colors.white, size: 20), onPressed: () => Navigator.pop(context)),
        title: const Text("TASK CONTROL", style: TextStyle(letterSpacing: 2, fontWeight: FontWeight.w900, color: Colors.white70, fontSize: 16)),
        actions: [
          BlocBuilder<TodoBloc, TodoState>(
            builder: (context, state) {
              final idx = state.allTodos.indexWhere((t) => t.sqlId == todoId);
              if (idx == -1) return const SizedBox();
              return IconButton(
                icon: const Icon(Icons.edit_note_rounded, color: Colors.blueAccent, size: 28),
                onPressed: () => _editSheet(context, state.allTodos[idx]),
              );
            },
          ),
          const SizedBox(width: 10),
        ],
      ),
      body: BlocBuilder<TodoBloc, TodoState>(
        builder: (context, state) {
          final idx = state.allTodos.indexWhere((t) => t.sqlId == todoId);
          if (idx == -1) return const Center(child: Text("Task Deleted", style: TextStyle(color: Colors.white24)));
          
          final data = state.allTodos[idx];
          double pct = data.totalSeconds > 0 ? data.remainingSeconds / data.totalSeconds : 0;
          Color col = data.status == 'In-Progress' ? Colors.blueAccent : (data.status == 'Done' ? Colors.greenAccent : Colors.orangeAccent);

          return Padding(
            padding: const EdgeInsets.symmetric(horizontal: 30),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(data.title.toUpperCase(), textAlign: TextAlign.center, style: const TextStyle(color: Colors.white, fontSize: 28, fontWeight: FontWeight.w900, letterSpacing: 1)),
                const SizedBox(height: 12),
                _statusChip(data.status, col),
                const SizedBox(height: 50),
                _timerCircle(data.remainingSeconds.toString(), pct, col),
                const SizedBox(height: 50),
                if (data.description.isNotEmpty) _descBox(data.description),
                const SizedBox(height: 60),
                _controls(context, data),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _statusChip(String status, Color col) => Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 4),
        decoration: BoxDecoration(color: col.withOpacity(0.1), borderRadius: BorderRadius.circular(20), border: Border.all(color: col.withOpacity(0.2))),
        child: Text(status.toUpperCase(), style: TextStyle(color: col, fontWeight: FontWeight.bold, fontSize: 10, letterSpacing: 1)),
      );

  Widget _timerCircle(String val, double pct, Color col) => Stack(
        alignment: Alignment.center,
        children: [
          SizedBox(
            width: 220, height: 220,
            child: CircularProgressIndicator(value: pct, strokeWidth: 10, backgroundColor: Colors.white.withOpacity(0.03), color: col),
          ),
          Column(
            children: [
              Text(val, style: const TextStyle(color: Colors.white, fontSize: 60, fontWeight: FontWeight.w900)),
              const Text("SECONDS", style: TextStyle(color: Colors.white24, fontSize: 10, fontWeight: FontWeight.bold, letterSpacing: 2)),
            ],
          ),
        ],
      );

  Widget _descBox(String txt) => Container(
        width: double.infinity, padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(color: Colors.white.withOpacity(0.02), borderRadius: BorderRadius.circular(15), border: Border.all(color: Colors.white.withOpacity(0.05))),
        child: Text(txt, textAlign: TextAlign.center, style: const TextStyle(color: Colors.white60, fontSize: 14, height: 1.4)),
      );
Widget _controls(BuildContext context, Todo data) {
 
    final bool isTimeUp = data.remainingSeconds <= 0;

    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
    
        _btn(
          Icons.pause_rounded, 
          isTimeUp ? Colors.grey : Colors.orangeAccent, 
          "PAUSE", 
          isTimeUp ? null : () { 
            data.status = 'TODO';
            context.read<TodoBloc>().add(AddOrUpdateTodo(data));
          }
        ),
        const SizedBox(width: 40),
    
        _btn(
          Icons.play_arrow_rounded, 
          isTimeUp ? Colors.grey : Colors.greenAccent, 
          "START", 
          isTimeUp ? null : () {
            data.status = 'In-Progress';
            context.read<TodoBloc>().add(AddOrUpdateTodo(data));
          }
        ),
      ],
    );
  }


  Widget _btn(IconData icon, Color col, String label, VoidCallback? tap) => GestureDetector(
        onTap: tap,
        child: Opacity(
          opacity: tap == null ? 0.3 : 1.0,
          child: Column(
            children: [
              Container(
                padding: const EdgeInsets.all(18),
                decoration: BoxDecoration(
                  color: col.withOpacity(0.05), 
                  shape: BoxShape.circle, 
                  border: Border.all(color: col.withOpacity(0.2), width: 1.5)
                ),
                child: Icon(icon, color: col, size: 35),
              ),
              const SizedBox(height: 8),
              Text(label, style: TextStyle(color: col, fontSize: 10, fontWeight: FontWeight.bold, letterSpacing: 1)),
            ],
          ),
        ),
      );

void _editSheet(BuildContext context, Todo model) {
  final tC = TextEditingController(text: model.title);
  final dC = TextEditingController(text: model.description);
  int sec = model.totalSeconds;

  showModalBottomSheet(
    context: context,
    isScrollControlled: true,
    backgroundColor: Colors.transparent,
    builder: (ctx) => Container(
      decoration: const BoxDecoration(
        color: Color(0xFF1A1A1B),
        borderRadius: BorderRadius.vertical(top: Radius.circular(30)),
      ),
      padding: EdgeInsets.only(
        bottom: MediaQuery.of(ctx).viewInsets.bottom + 20,
        left: 25, right: 25, top: 15,
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(width: 40, height: 4, decoration: BoxDecoration(color: Colors.white10, borderRadius: BorderRadius.circular(10))),
          const SizedBox(height: 25),
          const Text("MODIFY TASK", style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, letterSpacing: 1.5)),
          const SizedBox(height: 20),
          _input(tC, "Title"),
          const SizedBox(height: 12),
          _input(dC, "Notes"),
          const SizedBox(height: 20),
          SizedBox(
            height: 120,
            child: CupertinoTheme(
              data: const CupertinoThemeData(brightness: Brightness.dark),
              child: CupertinoTimerPicker(
                mode: CupertinoTimerPickerMode.ms,
                initialTimerDuration: Duration(seconds: sec),
                onTimerDurationChanged: (v) => sec = v.inSeconds,
              ),
            ),
          ),
          const SizedBox(height: 25),
          MaterialButton(
            minWidth: double.infinity,
            height: 55,
            color: const Color(0xFF222223),
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
            onPressed: () {
       
              if (sec > 300) {
               ScaffoldMessenger.of(context).showSnackBar(
  SnackBar(
    content: const Text("MAX 5 MINUTES ALLOWED!", textAlign: TextAlign.center),
    backgroundColor: Colors.redAccent,
    behavior: SnackBarBehavior.floating,
    duration: const Duration(milliseconds: 800), 
    width: 250,
    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30)),
  ),
);
                return; 
              }

              if (tC.text.trim().isNotEmpty) {
                final out = Todo(
                  sqlId: model.sqlId,
                  firebaseId: model.firebaseId,
                  userId: model.userId,
                  title: tC.text.trim(),
                  description: dC.text.trim(),
                  totalSeconds: sec > 0 ? sec : 60,
                  remainingSeconds: sec > 0 ? sec : 60,
                  status: model.status,
                );
                context.read<TodoBloc>().add(AddOrUpdateTodo(out));
                Navigator.pop(ctx);
              } else {
                ScaffoldMessenger.of(context).showSnackBar(
  SnackBar(
    content: const Text("Text can not be empty", textAlign: TextAlign.center),
    backgroundColor: Colors.redAccent,
    behavior: SnackBarBehavior.floating,
    duration: const Duration(milliseconds: 800), 
    width: 250, 
    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30)),
  ),
);
              }
            },
            child: const Text("UPDATE TASK", style: TextStyle(color: Colors.blueAccent, fontWeight: FontWeight.bold)),
          ),
        ],
      ),
    ),
  );
}
Widget _input(TextEditingController c, String h) => Container(
        decoration: BoxDecoration(color: const Color(0xFF151516), borderRadius: BorderRadius.circular(12)),
        child: TextField(
          controller: c,
          style: const TextStyle(color: Colors.white, fontSize: 14),
          decoration: InputDecoration(
            hintText: h,
            hintStyle: const TextStyle(color: Colors.white10),
            border: InputBorder.none,
            contentPadding: const EdgeInsets.all(15),
          ),
        ),
      );
}