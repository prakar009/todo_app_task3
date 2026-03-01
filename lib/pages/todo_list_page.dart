import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../bloc/todo/todo_bloc.dart';
import '../bloc/todo/todo_event.dart';
import '../bloc/todo/todo_state.dart';
import '../models/todo_model.dart';
import '../services/auth_service.dart';
import 'login_page.dart';
import 'todo_details_page.dart';

class TodoListPage extends StatefulWidget {
  const TodoListPage({super.key});

  @override
  State<TodoListPage> createState() => _TodoListPageState();
}

class _TodoListPageState extends State<TodoListPage> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<TodoBloc>().add(LoadTodos());
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF1A1A1B),
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        title: const Text("LMG TODO  APP",
            style: TextStyle(letterSpacing: 2, fontWeight: FontWeight.w900, color: Colors.white70, fontSize: 18)),
        actions: [
          Center(child: Text(FirebaseAuth.instance.currentUser?.email ?? "", style: const TextStyle(color: Colors.white24, fontSize: 11))),
          IconButton(
            icon: const Icon(Icons.logout_rounded, color: Colors.redAccent, size: 20),
            onPressed: () async {
              await AuthService().logout();
              if (mounted) Navigator.pushAndRemoveUntil(context, MaterialPageRoute(builder: (c) => const LoginPage()), (r) => false);
            },
          )
        ],
      ),
      body: Column(
        children: [
          _taskSearchBar(),
          Expanded(
            child: BlocBuilder<TodoBloc, TodoState>(
              builder: (context, state) {
                if (state.isLoading) return const Center(child: CupertinoActivityIndicator(color: Colors.blueAccent));
                final list = state.filteredTodos;

                if (list.isEmpty) {
                  return const Center(child: Text("NO TASKS PENDING", style: TextStyle(color: Colors.white10, fontSize: 18, fontWeight: FontWeight.bold, letterSpacing: 2)));
                }

                return ListView.builder(
                  padding: const EdgeInsets.only(bottom: 120, top: 10),
                  itemCount: list.length,
                  itemBuilder: (context, index) {
                    final item = list[index];
                    final accent = item.status == 'In-Progress' ? Colors.blueAccent : (item.status == 'Done' ? Colors.greenAccent : Colors.orangeAccent);
                    return _taskTile(context, item, accent);
                  },
                );
              },
            ),
          ),
        ],
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
      floatingActionButton: _addTaskFab(),
    );
  }

  Widget _taskSearchBar() {
    return Padding(
      padding: const EdgeInsets.all(20),
      child: Container(
        decoration: BoxDecoration(
          color: const Color(0xFF1A1A1B),
          borderRadius: BorderRadius.circular(15),
          boxShadow: [
            BoxShadow(color: Colors.black.withOpacity(0.4), offset: const Offset(4, 4), blurRadius: 8),
            BoxShadow(color: Colors.white.withOpacity(0.02), offset: const Offset(-4, -4), blurRadius: 8),
          ],
        ),
        child: TextField(
          style: const TextStyle(color: Colors.white, fontSize: 14),
          onChanged: (v) => context.read<TodoBloc>().add(SearchTodos(v)),
          decoration: const InputDecoration(
            hintText: "Find task...",
            hintStyle: TextStyle(color: Colors.white10, fontSize: 13),
            prefixIcon: Icon(Icons.search_rounded, color: Colors.blueAccent, size: 18),
            border: InputBorder.none,
            contentPadding: EdgeInsets.symmetric(vertical: 15),
          ),
        ),
      ),
    );
  }

  Widget _taskTile(BuildContext context, Todo data, Color accent) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
      child: GestureDetector(
        onTap: () => Navigator.push(context, MaterialPageRoute(builder: (c) => TodoDetailsPage(todoId: data.sqlId!))),
        child: Container(
          decoration: BoxDecoration(
            color: const Color(0xFF1A1A1B),
            borderRadius: BorderRadius.circular(20),
            boxShadow: [
              BoxShadow(color: Colors.black.withOpacity(0.5), offset: const Offset(6, 6), blurRadius: 12),
              BoxShadow(color: Colors.white.withOpacity(0.03), offset: const Offset(-4, -4), blurRadius: 10),
            ],
            gradient: const LinearGradient(colors: [Color(0xFF222223), Color(0xFF141415)]),
          ),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(20),
            child: Stack(
              children: [
                Positioned(left: 0, top: 0, bottom: 0, child: Container(width: 4, color: accent)),
                Padding(
                  padding: const EdgeInsets.all(20),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Expanded(child: Text(data.title.toUpperCase(), style: const TextStyle(color: Colors.white, fontSize: 15, fontWeight: FontWeight.bold))),
                          GestureDetector(
                            onTap: () => context.read<TodoBloc>().add(DeleteTodoEvent(data.sqlId!)),
                            child: Icon(Icons.delete_outline_rounded, color: Colors.redAccent.withOpacity(0.7), size: 18),
                          ),
                        ],
                      ),
                      if (data.description.isNotEmpty) ...[
                        const SizedBox(height: 6),
                        Text(data.description, maxLines: 1, style: const TextStyle(color: Colors.white38, fontSize: 12)),
                      ],
                      const SizedBox(height: 15),
                      Row(
                        children: [
                          _badge(Icons.access_time_rounded, "${data.remainingSeconds}s", accent),
                          const SizedBox(width: 10),
                          _badge(Icons.label_important_outline, data.status, accent),
                        ],
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _badge(IconData icon, String txt, Color col) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(color: Colors.black26, borderRadius: BorderRadius.circular(6)),
      child: Row(
        children: [
          Icon(icon, color: col, size: 10),
          const SizedBox(width: 5),
          Text(txt.toUpperCase(), style: TextStyle(color: col, fontSize: 9, fontWeight: FontWeight.bold)),
        ],
      ),
    );
  }

  Widget _addTaskFab() {
    return FloatingActionButton.extended(
      backgroundColor: const Color(0xFF1A1A1B),
      elevation: 10,
      onPressed: () => _showTaskSheet(context, null),
      label: const Text("ADD TASK", style: TextStyle(color: Colors.white, letterSpacing: 1, fontWeight: FontWeight.bold)),
      icon: const Icon(Icons.add_rounded, color: Colors.blueAccent),
    );
  }

  void _showTaskSheet(BuildContext context, Todo? model) {
    final isEdit = model != null;
    final tCtrl = TextEditingController(text: isEdit ? model.title : "");
    final dCtrl = TextEditingController(text: isEdit ? model.description : "");
    int dur = isEdit ? model.totalSeconds : 60;

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) => Container(
        decoration: const BoxDecoration(color: Color(0xFF1A1A1B), borderRadius: BorderRadius.vertical(top: Radius.circular(30))),
        padding: EdgeInsets.only(bottom: MediaQuery.of(ctx).viewInsets.bottom + 20, left: 25, right: 25, top: 15),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(width: 40, height: 4, decoration: BoxDecoration(color: Colors.white10, borderRadius: BorderRadius.circular(10))),
            const SizedBox(height: 20),
            Text(isEdit ? "EDIT TASK" : "CREATE TASK", style: const TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold, letterSpacing: 1)),
            const SizedBox(height: 20),
            _input(tCtrl, "Task Title"),
            const SizedBox(height: 12),
            _input(dCtrl, "Notes / Description"),
            const SizedBox(height: 20),
            SizedBox(
              height: 120,
              child: CupertinoTheme(
                data: const CupertinoThemeData(brightness: Brightness.dark),
                child: CupertinoTimerPicker(
                  mode: CupertinoTimerPickerMode.ms,
                  initialTimerDuration: Duration(seconds: dur),
                  onTimerDurationChanged: (v) => dur = v.inSeconds,
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
  String title = tCtrl.text.trim();
  String desc = dCtrl.text.trim();

  // 1. Instant Snackbar Setup
  void showError(String msg) {
    ScaffoldMessenger.of(context).removeCurrentSnackBar();
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(msg, textAlign: TextAlign.center, style: const TextStyle(fontWeight: FontWeight.bold)),
        backgroundColor: Colors.redAccent,
        behavior: SnackBarBehavior.floating,
        duration: const Duration(milliseconds: 1000),
        margin: EdgeInsets.only(bottom: MediaQuery.of(context).size.height / 2.2, left: 60, right: 60),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      ),
    );
  }

  // 2. Validations
  if (title.isEmpty) {
    showError("TITLE IS REQUIRED!");
    return;
  }
  
  if (desc.isEmpty) {
    showError("DESCRIPTION IS REQUIRED!");
    return;
  }

  if (dur == 0) {
    showError("PLEASE SELECT TIME!");
    return;
  }

  if (dur > 300) {
    showError("MAX 5 MINUTES ALLOWED!");
    return;
  }

  // 3. Success Logic
  final out = Todo(
    sqlId: isEdit ? model.sqlId : null,
    firebaseId: isEdit ? model.firebaseId : null,
    userId: FirebaseAuth.instance.currentUser?.uid ?? "",
    title: title,
    description: desc,
    totalSeconds: dur,
    remainingSeconds: dur,
    status: isEdit ? model.status : 'TODO',
  );

  context.read<TodoBloc>().add(AddOrUpdateTodo(out));
  Navigator.pop(ctx);
},
              child: Text(isEdit ? "SAVE CHANGES" : "START TASK", style: const TextStyle(color: Colors.blueAccent, fontWeight: FontWeight.bold)),
            ),
          ],
        ),
      ),
    );
  }

  Widget _input(TextEditingController c, String h) {
    return Container(
      decoration: BoxDecoration(color: const Color(0xFF151516), borderRadius: BorderRadius.circular(12)),
      child: TextField(
        controller: c,
        style: const TextStyle(color: Colors.white, fontSize: 14),
        decoration: InputDecoration(
          hintText: h,
          hintStyle: const TextStyle(color: Colors.white10, fontSize: 13),
          border: InputBorder.none,
          contentPadding: const EdgeInsets.symmetric(horizontal: 15, vertical: 15),
        ),
      ),
    );
  }
}