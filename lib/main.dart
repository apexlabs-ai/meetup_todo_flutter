import 'dart:math';

import 'package:bloc/bloc.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:meetup_todo_flutter/bloc/todo.dart';
import 'package:openapi/api.dart';

void main() {
  BlocSupervisor.delegate = SimpleBlocDelegate();
  runApp(MyApp());
}

class SimpleBlocDelegate extends BlocDelegate {
  @override
  void onTransition(Bloc bloc, Transition transition) {
    super.onTransition(bloc, transition);
    print(transition.toString());
  }
  @override
  void onError(Bloc bloc, Object error, StackTrace stacktrace) {
    super.onError(bloc, error, stacktrace);
    print('$error, $stacktrace');
  }
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Meetup Todo',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: BlocProvider(
        builder: (BuildContext context) => TodoBloc(),
        child: MyHomePage(title: 'Meetup Todo Home Page')
      )
    );
  }
}

class MyHomePage extends StatefulWidget {
  MyHomePage({Key key, this.title}) : super(key: key);

  final String title;

  @override
  _MyHomePageState createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  @override
  void initState() {
    BlocProvider.of<TodoBloc>(context).dispatch(TodoRequested());
    super.initState();
  }
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.title),
      ),
      body: Center(
        child: BlocBuilder <TodoBloc, TodoState>(
          builder: (context, state) {
            if (state is TodoLoaded) {
              var rows = <Widget>[
                Text('Your ${state.todos.length} Todos:')
              ];

              for (var todo in state.todos) {
                rows.add(
                    GestureDetector(onLongPress: () => BlocProvider.of<TodoBloc>(context).dispatch(TodoDelete(todo: todo)),
                      child: Text(todo.description,
                          style: Theme
                              .of(context)
                              .textTheme
                              .display1),
                    )
                );
              }
              return Column(
                  children: rows
              );
            } else if (state is TodoLoading) {
              if (state.error != null) return Text(state.error);
            }
            return CircularProgressIndicator();
          },
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          BlocProvider.of<TodoBloc>(context).dispatch(TodoNew(todo: Todo()..description='random todo ${Random().nextInt(100).toString()}'));
        },
        tooltip: 'Increment',
        child: Icon(Icons.add),
      ), // This trailing comma makes auto-formatting nicer for build methods.
    );
  }
}
