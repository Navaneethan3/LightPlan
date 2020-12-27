import 'package:hive/hive.dart';
import 'package:lighthouse_planner/dao/task_dao.dart';
import 'package:lighthouse_planner/models/task.dart';

class TaskDaoImpl extends TaskDao {
  final Box<Task> tasksBox = Hive.box("tasks");

  Future<TaskDaoImpl> init() async {
    if (tasksBox.isNotEmpty) return this;
    print("db init");
    Task year = Task(
        title: "2k2k",
        shortDesc: "This year was fun",
        desc: "this year was not fun...");
    int yearId = await insertTask(year);
    Task spring = Task(
        title: "Spring",
        parentId: yearId,
        shortDesc: "Stuff we do in spring",
        desc: "blah blah");
    Task summer = Task(
        title: "Summer",
        parentId: yearId,
        shortDesc: "Stuff we do in summer",
        desc: "blah blah");
    Task autumn = Task(
        title: "Autumn",
        parentId: yearId,
        shortDesc: "Stuff we do in autumn",
        desc: "blah blah");
    Task winter = Task(
        title: "Winter",
        parentId: yearId,
        shortDesc: "Stuff we do in winter",
        desc: "blah blah");

    var q1id = await insertTask(spring);
    var q2id = await insertTask(summer);
    var q3id = await insertTask(autumn);
    var q4id = await insertTask(winter);

    Task monthQ1 = Task(title: "Month Spring", parentId: q1id, shortDesc: "Month during spring");
    Task monthQ2 = Task(title: "Month Summer", parentId: q2id, shortDesc: "Month during summer");
    Task monthQ3 = Task(title: "Month Autumn", parentId: q3id, shortDesc: "Month during autumn");
    Task monthQ4 = Task(title: "Month Winter", parentId: q4id, shortDesc: "Month during winter");

    insertTask(monthQ1);
    insertTask(monthQ2);
    insertTask(monthQ3);
    insertTask(monthQ4);

    print("end db init");
    return this;
  }

  @override
  Future<void> deleteTask(Task treeTask) {
    return tasksBox.delete(treeTask);
  }

  @override
  Future<void> deleteTasks(List<Task> treeTask) {
    return tasksBox.deleteAll(treeTask);
  }

  @override
  List<Task> findAllTasks() {
    List<Task> tasksList = [];
    for (int i = 0; i < tasksBox.length; i++) {
      tasksList.add(tasksBox.getAt(i));
    }
    return tasksList;
  }

  @override
  Task findTask(int id) {
    print("finding task #$id");
    return tasksBox.get(id);
  }

  @override
  List<Task> findTaskChildren(int id) {
    return tasksBox.values.where((e) {
      return e.parentId == id;
    }).toList();
  }

  @override
  Future<int> insertTask(Task treeTask) async {
    int idTask = await tasksBox.add(treeTask);
    updateTask(idTask, treeTask.setId(idTask));
    return idTask;
  }

  @override
  Future<void> updateTask(int id, Task treeTask) async {
    return await tasksBox.put(id, treeTask);
  }
}