import 'package:flutter/material.dart';

import '../../../dao/task_dao_impl.dart';
import '../../../models/task.dart';
import '../../../utils.dart';
import 'my_container.dart';
import 'task_editor.dart';

class TaskDetailsContainer extends StatefulWidget {
  final Task task;
  final bool editor;
  final bool isListedAsChild;
  final TaskDaoImpl taskDao;
  final Function updateCurrentTask;

  TaskDetailsContainer({
    this.task,
    @required this.editor,
    this.isListedAsChild,
    @required this.taskDao,
    @required this.updateCurrentTask,
  });

  @override
  State<StatefulWidget> createState() => _TaskDetailsContainer();
}

class _TaskDetailsContainer extends State<TaskDetailsContainer> {
  double width, height;
  bool editMode;
  List<Task> treeSubTasks = [];
  List<TaskEditor> taskEditors = [];

  @override
  void initState() {
    super.initState();

    editMode = widget.task == null ? true : widget.editor;

    treeSubTasks.clear();
    treeSubTasks.add(widget.task);
  }

  @override
  Widget build(BuildContext context) {
    this.width = MediaQuery.of(context).size.width;
    this.height = MediaQuery.of(context).size.height;

    taskEditors.clear();

    return WillPopScope(
      onWillPop: () async => _showConfirmQuit(),
      child: SingleChildScrollView(
        child: MyContainer(
          radius: 10,
          padding: EdgeInsets.all(20),
          margin: EdgeInsets.all(10),
          color: Colors.white,
          width: width < 800 ? (width - 20) * 0.8 : width * .3,
          child: Column(
            children: [
              // Stack Task details (title, shortDesc, desc etc) and Edit Button
              Stack(
                children: [
                  //Preview UI: show current task details
                  ListView.builder(
                    shrinkWrap: true,
                    itemCount: treeSubTasks.length,
                    itemBuilder: (BuildContext context, int index) {
                      var te = TaskEditor(
                        task: treeSubTasks[index],
                        buildAddSubtask: index == 0 &&
                            editMode &&
                            (treeSubTasks[index]?.canHaveChildren ?? true) &&
                            widget.isListedAsChild,
                        isEditing: editMode,
                        addNewTask: () => _addTaskDetails(Task.empty(parentId: widget.task.id)),
                      );
                      taskEditors.add(te);
                      return te;
                    },
                  ),
                  Positioned(
                    top: 0,
                    right: 0,
                    child: GestureDetector(
                      onTap: () => setState(() => editMode = !editMode),
                      child: Container(
                        height: 30,
                        padding: EdgeInsets.all(5),
                        child: FittedBox(child: Icon(editMode ? Icons.cancel : Icons.edit)),
                        decoration:
                            BoxDecoration(color: Colors.black.withOpacity(0.3), borderRadius: BorderRadius.circular(5)),
                      ),
                    ),
                  ),
                ],
              ),
              // Delete Button (always visible on !isPredefined tasks) and Save Button (visible on edit)
              Row(
                children: [
                  Visibility(
                    visible: !widget.task.isPredefined,
                    child: Expanded(
                      child: GestureDetector(
                        onTap: () {
                          // Show confirm Dialog
                          showDialog(
                            context: context,
                            builder: (BuildContext context) {
                              return AlertDialog(
                                title: Text("Are you sure?"),
                                content: Text("Task with title '${widget.task.title}' will be deleted."),
                                actions: [
                                  FlatButton(
                                    child: Text("Cancel"),
                                    onPressed: () => Navigator.of(context).pop(false),
                                  ),
                                  FlatButton(
                                    child: Text("Delete"),
                                    onPressed: () async {
                                      await widget.taskDao.deleteTask(widget.task);
                                      widget.updateCurrentTask(widget.taskDao.findTask(widget.task.parentId));
                                      // Pop dialog box
                                      Navigator.of(context).pop(true);
                                      // Pop task details
                                      Navigator.of(context).pop(true);
                                      Utils.showToast(context, "'${widget.task.title}' task deleted.");
                                    },
                                  )
                                ],
                              );
                            },
                          );
                        },
                        child: MyContainer(
                          height: 35,
                          child: Icon(Icons.delete),
                          color: Colors.red,
                          colorEffect: true,
                          radius: 5,
                        ),
                      ),
                    ),
                  ),
                  Visibility(
                    visible: editMode && !widget.task.isPredefined,
                    child: SizedBox(width: 10),
                  ),
                  Visibility(
                    visible: editMode,
                    child: Expanded(
                      child: GestureDetector(
                        onTap: () => _saveTaskTree(),
                        child: MyContainer(
                          height: 35,
                          child: Icon(Icons.save),
                          color: Colors.green,
                          colorEffect: true,
                          radius: 5,
                        ),
                      ),
                    ),
                  ),
                ],
              )
            ],
          ),
        ),
      ),
    );
  }

  // (title, shortDesc, desc etc) add to 'listedTasks' list of widgets
  void _addTaskDetails(Task task) {
    setState(() => treeSubTasks.add(task));
  }

  void _saveTaskTree() async {
    for (var te in taskEditors) {
      Task toSave = te.getEditedTask();
      await widget.taskDao.insertOrUpdate(toSave);
    }

    widget.updateCurrentTask();
    editMode = false;

    // Close Popup Task Details
    Navigator.of(context).pop();

    Utils.showToast(context, "${taskEditors.length} task(s) saved/updated.");
  }

  Future<bool> _showConfirmQuit() async {
    if (!editMode) return true;
    return await showDialog<bool>(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text('Are you sure you want to exit?'),
          content: Text("You will lose all the modifications."),
          actions: <Widget>[
            FlatButton(
              child: Text('No'),
              onPressed: () {
                Navigator.of(context).pop(false);
              },
            ),
            FlatButton(
              child: Text('Exit'),
              onPressed: () {
                Navigator.of(context).pop(true);
              },
            ),
          ],
        );
      },
    );
  }
}
