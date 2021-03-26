import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:table_calendar/table_calendar.dart';
import 'package:todo_app/database_helper.dart';
import 'package:todo_app/models/task.dart';

class HomePage extends StatefulWidget {
  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {

  Color _themeColor=Color(0xff30384c);
  CalendarController calController;
  TextEditingController tfTitleController=TextEditingController();
  TextEditingController tfDecController=TextEditingController();
  GlobalKey<FormState> key=GlobalKey();
  List taskList=List();
  final dateFormat=new DateFormat("d EEE, MMM ''yyyy");
  DateTime _selectedDate=DateTime.now();

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    calController=CalendarController();
    getAllTasks();

  }
  // Returning all tasks on selected date
  Future<void> getAllTasks()async {
    List<Map<String,dynamic>> queryRows=await DataBaseHelper.instance.onDateTasks(dateFormat.format(_selectedDate));
    queryRows.forEach((taskMap) {

      Task toBeAdd=new Task();
      toBeAdd.id=taskMap[DataBaseHelper.columnId];
      toBeAdd.title=taskMap[DataBaseHelper.columnTitle];
      toBeAdd.description=taskMap[DataBaseHelper.columnDescription];
      toBeAdd.completed=taskMap[DataBaseHelper.columnCompleted]==1;
      toBeAdd.date=dateFormat.parse(taskMap[DataBaseHelper.columnDate]);
      taskList.add(toBeAdd);
    });
    setState(() {

    });

  }
  //Returning date
  getDiff() {

    var now=DateTime.now();
    if(dateFormat.format(_selectedDate)==dateFormat.format(now)) return "Today";
    return dateFormat.format(_selectedDate).toString();

  }
  //Background for edit task (when user swipe start to end)
  getEditBg() {
    return Container(
      padding: EdgeInsets.only(left: 10),
      alignment: Alignment.centerLeft,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
      ),

      child: Icon(
        Icons.edit,
        color: _themeColor,
        size:25,
      ),
    );
  }

  //Background for delete task (when user swipe end to start)
  getDeleteBg() {
    return Container(
      alignment: Alignment.centerRight,

      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
      ),
      padding: EdgeInsets.only(right: 10),
      child: Icon(
        Icons.delete,
        color: _themeColor,
        size: 25,
      ),
    );
  }
  //Removing task from database and list
  removeTask(index) async{
    Task tobeRemoved=taskList.removeAt(index);
    int i=await DataBaseHelper.instance.deleteTask({
      DataBaseHelper.columnId:tobeRemoved.id
    });
    setState(() {

      print('row deleted $i');
    });
  }
  //Removing task from list
  removeTaskFromList(index) async {
    taskList.removeAt(index);
    setState(() {});
  }
  //Showing snack bar when user delete any task
  showSnackBar(context,task,index) {
    Scaffold.of(context).showSnackBar(SnackBar(
      duration: Duration(seconds: 1),
      content: Text(
        '${task.title} task deleted',
        style: TextStyle(
          fontSize: 14,
        ),
      ),
    ));
  }


  // Opening dialog box for new task or edit task

   Future<void> showTaskDialog(BuildContext context,Task task,int taskIndex) async {


     bool isCompleted=task!=null?task.completed:false;
     tfTitleController.text=task!=null?task.title:tfTitleController.text;
     tfDecController.text=task!=null?task.description:tfDecController.text;

    return showDialog(context: context,
        barrierDismissible: task==null,
    builder: (context){
      return StatefulBuilder(

        builder: (context,setState){
          return AlertDialog(

            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(20),
            ),
            elevation: 0,
            content: Container(
              child: Form(
                key: key,
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    TextFormField(
                      controller: tfTitleController,
                      validator: (value){
                        return value.isEmpty?"Required *":null;
                      },
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold
                      ),
                      decoration: InputDecoration(
                          hintText: "title",
                          hintStyle: TextStyle(
                            color: Colors.grey,
                            fontSize: 20,
                          ),
                          focusedBorder: UnderlineInputBorder(
                              borderSide: BorderSide(
                                color: _themeColor,
                              )
                          )
                      ),
                    ),
                    SizedBox(height: 10,),
                    Container(
                      constraints: BoxConstraints(
                        maxHeight: 50,
                      ),
                      child: TextFormField(
                        controller: tfDecController,
                        maxLines: null,
                        style: TextStyle(
                          fontSize: 18,
                        ),
                        decoration: InputDecoration(
                            hintText: "Description",
                            hintStyle: TextStyle(
                              color: Colors.grey,
                              fontSize: 18,
                            ),
                            focusedBorder: UnderlineInputBorder(
                                borderSide: BorderSide(
                                  color: _themeColor,
                                )
                            )
                        ),
                      ),
                    ),
                    SizedBox(height: 10,),
                    task==null?SizedBox():Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          "Completed",
                          style: TextStyle(
                            color: _themeColor,
                            fontSize: 18,
                          ),
                        ),
                        Checkbox(
                          value: isCompleted ,
                          onChanged: (value){
                            setState((){
                            isCompleted=value;
                            });
                          },
                          activeColor: _themeColor,
                          checkColor: Colors.white,
                        )
                      ],
                    )

                  ],
                ),
              ),
            ) ,
            actions: [
              Container(
                padding: EdgeInsets.only(right: 10),
                child: FlatButton(
                  color: _themeColor,
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(5)
                  ),
                  textColor: Colors.white,
                  child: Text('Save'),
                  onPressed: () async {
                    if(key.currentState.validate()) {
                      Task newTask=Task(

                        title: tfTitleController.text,
                        description: tfDecController.text,
                        completed: isCompleted,
                        date: _selectedDate,);
                      tfTitleController.text='';
                      tfDecController.text='';
                      if(task==null) {

                        newTask.id=await DataBaseHelper.instance.insertTask(
                          {
                            DataBaseHelper.columnTitle:newTask.title,
                            DataBaseHelper.columnDescription:newTask.description,
                            DataBaseHelper.columnCompleted:newTask.completed?1:0,
                            DataBaseHelper.columnDate:dateFormat.format(newTask.date).toString(),

                          }
                        );
                        print(' the id of new task ${newTask.id}');
                        taskList.add(newTask);
                      } else {

                        newTask.id=task.id;
                        int result=await DataBaseHelper.instance.updateTask(
                            {
                              DataBaseHelper.columnId:newTask.id,
                              DataBaseHelper.columnTitle:newTask.title,
                              DataBaseHelper.columnDescription:newTask.description,
                              DataBaseHelper.columnCompleted:newTask.completed?1:0,
                              DataBaseHelper.columnDate:dateFormat.format(newTask.date).toString(),

                            }
                        );
                        print('row updated $result');

                        taskList.insert(taskIndex,newTask);
                      }
                      Navigator.of(context).pop();
                    }
                  },

                ),
              )
            ],
          );
        }
      );

    });
   }


//Returning list of all tasks on selected date

  Container getTaskList() {
   return Container(
     child: Expanded(
       child: ListView.builder(
         itemCount: taskList.length,

         itemBuilder: (context,index)=>

             Dismissible(
               key: Key(taskList[index].id.toString()),
               onDismissed: (direction) async {
                 if(direction==DismissDirection.endToStart) {
                   Task task=taskList[index];
                   removeTask(index);
                   showSnackBar(context, task, index);
                 }
                 else  {

                   Task task=taskList[index];
                   int taskIndex=taskList.indexOf(task);
                   removeTaskFromList(index);
                   await showTaskDialog(context,task,taskIndex);
                   setState(() {
                   });
                 }
               },
               secondaryBackground: getDeleteBg(),
               background: getEditBg(),
               child: Card(
                 color: _themeColor,
                 elevation: 0,
                 shadowColor: Colors.white,
                 child: Row(

                   children: [
                   taskList[index].completed?
                   Icon(
                     CupertinoIcons.check_mark_circled_solid,
                     color: Color(0xff00cf8d),
                     size: 30,):
                   Icon(
                     CupertinoIcons.clock_solid,
                     color: Color(0xffff9e00),
                     size: 30,
                   ),
                     SizedBox(width: 10,),
                     Container(
                       padding: EdgeInsets.only(left: 0,right: 0,top: 10),
                       width: MediaQuery.of(context).size.width*0.75,
                       child: Column(
                         crossAxisAlignment: CrossAxisAlignment.start,
                         children: [
                           Text(
                             '${taskList[index].title}',
                             style: TextStyle(
                                 fontSize: 20,
                                 fontWeight: FontWeight.bold,
                                 color: Colors.white
                             ),
                           ),
                           SizedBox(height: 10),
                           Text(
                             taskList[index].description,
                             style: TextStyle(
                                 fontSize: 15,
                                 fontWeight: FontWeight.normal,
                                 color: Colors.white
                             ),
                           ),
                           SizedBox(height: 10),
                         ],
                       ),
                     )
                   ],
                 ),
               ),
             ),
       ),
     ),
   );
  }
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SingleChildScrollView(
        physics: ScrollPhysics(),
        child: Container(
          padding: EdgeInsets.only(top: 50),
          child: Column(
            children: [

              TableCalendar(
                startingDayOfWeek: StartingDayOfWeek.monday,
                calendarStyle: CalendarStyle(
                  weekdayStyle: TextStyle(color: _themeColor,fontWeight: FontWeight.normal,fontSize: 14),
                  weekendStyle: TextStyle(color: _themeColor,fontWeight: FontWeight.normal,fontSize: 14),
                  selectedColor: _themeColor,
                  todayColor: _themeColor,
                  todayStyle: TextStyle(
                    fontSize: 14,
                    color: Colors.white
                  )
                ),
                onDaySelected: (date,events,holiday)=>{

                setState(() {
                  _selectedDate=date;
                  taskList=List();
                  getAllTasks();
                }),

                },


                builders: CalendarBuilders(
                  selectedDayBuilder: (context,date,events)=>
                  Container(
                    margin: EdgeInsets.all(5.0),
                    alignment: Alignment.center,
                    decoration: BoxDecoration(
                      color: _themeColor,

                      borderRadius: BorderRadius.circular(15),
                    ),
                    child: Text(
                        date.day.toString(),
                    style: TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold
                    ),),
                  )
                ),
                daysOfWeekStyle: DaysOfWeekStyle(
                  weekendStyle: TextStyle(
                    color: _themeColor,
                      fontWeight: FontWeight.bold
                  ),
                  weekdayStyle: TextStyle(
                    color: _themeColor,
                    fontWeight: FontWeight.bold
                  )

                ),
                headerStyle: HeaderStyle(
                  formatButtonVisible: false,
                  centerHeaderTitle: true,
                  titleTextStyle: TextStyle(
                    color: _themeColor,
                    fontWeight: FontWeight.bold,
                    fontSize: 20,
                  ),
                  leftChevronIcon: Icon(
                    Icons.chevron_left,
                    color: _themeColor,
                  ),
                  rightChevronIcon: Icon(
                    Icons.chevron_right,
                    color: _themeColor,
                  )
                ),
                calendarController: calController,
              ),
              SizedBox(height: 30,),
              Container(
                padding: EdgeInsets.only(left: 15,right: 10),
                height: MediaQuery.of(context).size.height,
                width: MediaQuery.of(context).size.width,
                decoration: BoxDecoration(
                    color: _themeColor,
                    borderRadius: BorderRadius.only(topRight: Radius.circular(50),topLeft: Radius.circular(30))
                ),
                child: Container(
                child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  SizedBox(height: 50,),
                  Text(

                        getDiff(),
                        style: TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                        fontSize: 30
                    ),
                  ),
                  getTaskList(),

                  ],
                 ),
                )
              )
            ],
          ),
        ),
      ),

      floatingActionButton: Container(
        padding: EdgeInsets.all(0),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.all(Radius.circular(20)),
          boxShadow: [

            BoxShadow(
            color: Colors.white12,
            blurRadius:30,

          ),
          ],
        ),
        child: RawMaterialButton(

          splashColor: Colors.transparent,
          highlightColor: Colors.transparent,
          onPressed: () async{
            await showTaskDialog(context,null,null);
            setState(() {
            });
          },

          child: Icon(
            CupertinoIcons.add,
            color: _themeColor,

          ),
        ),
      )
    );
  }
}
