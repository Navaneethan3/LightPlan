//#region License Information (GPL v3)

/*   
*    LightPlan is an open source app created with the intent of helping users keep track of tasks.
*    Copyright (C) 2020-2021 LightPlan Team
*
*    This program is free software: you can redistribute it and/or modify
*    it under the terms of the GNU General Public License as published by
*    the Free Software Foundation, either version 3 of the License, or
*    (at your option) any later version.
*
*    This program is distributed in the hope that it will be useful,
*    but WITHOUT ANY WARRANTY; without even the implied warranty of
*    MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
*    GNU General Public License for more details.
*
*    You should have received a copy of the GNU General Public License
*    along with this program. If not, see https://www.gnu.org/licenses/.
*
*    Contact the authors at: contact@lightplanx.com
*/

//#endregion License Information (GPL v3)

import 'package:flutter/material.dart';
import 'package:hive/hive.dart';
import 'package:provider/provider.dart';

import '../../dao/preferences.dart';
import '../../dao/task_dao_impl.dart';
import '../../models/task.dart';
import '../../task_list_handler.dart';
import '../../theme_handler.dart';
import '../widgets/bottom_bar.dart';
import '../widgets/tasktree/tasks_listview.dart';

class TasksPage extends StatefulWidget {
  @override
  State<StatefulWidget> createState() => _TasksPage();
}

class _TasksPage extends State<TasksPage> {
  TaskDaoImpl taskDaoImpl;

  @override
  Widget build(BuildContext context) {
    int searchedTaskId, searchedTaskYear;

    searchedTaskYear = Preferences.getInstance().getLastViewedYear();
    searchedTaskId = Preferences.getInstance().getLastViewedTask();
    // Routing arguments
    /*Map routeArgs = ModalRoute.of(context).settings.arguments;
    if (routeArgs != null) {
      print('task year=${routeArgs['year']}, id=${routeArgs['id']}');
      searchedTaskYear = routeArgs['year'];
      searchedTaskId = routeArgs['id'];
    }
    if (searchedTaskYear == null) searchedTaskYear = DateTime.now().year;*/

    var controller = PageController(
      initialPage: 0,
      viewportFraction: MediaQuery.of(context).size.width > 950 ? 0.3 : 1.0,
    );

    return WillPopScope(
      onWillPop: () async => _showConfirmQuit(context),
      child: SafeArea(
        child: Scaffold(
          resizeToAvoidBottomInset: false,
          body: FutureBuilder<Box<Task>>(
            future: Hive.openBox<Task>('tasks'),
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.done) {
                return FutureProvider(
                  create: (_) => TaskDaoImpl().insertDefaults(),
                  child: ChangeNotifierProvider(
                    create: (context) => TaskListHandler(),
                    child: Column(
                      children: [
                        TasksListView(
                          controller: controller,
                          searchedTask: {
                            searchedTaskYear: searchedTaskId,
                          },
                        ),
                        MyBottomBar(treeController: controller),
                      ],
                    ),
                  ),
                );
              } else {
                return Center(child: CircularProgressIndicator());
              }
            },
          ),
        ),
      ),
    );
  }

  @override
  void dispose() {
    Hive.close();
    super.dispose();
  }

  Future<bool> _showConfirmQuit(BuildContext context) async {
    return await showDialog<bool>(
      context: context,
      builder: (context) {
        return AlertDialog(
          content: Text('Are you sure you want to quit?'),
          actions: <Widget>[
            FlatButton(
              child: Text('No'),
              onPressed: () {
                Navigator.of(context).pop(false);
              },
            ),
            FlatButton(
              child: Text('Yes'),
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
