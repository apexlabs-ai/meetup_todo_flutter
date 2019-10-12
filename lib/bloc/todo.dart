import 'package:meta/meta.dart';
import 'package:equatable/equatable.dart';
import 'package:openapi/api.dart';
import 'package:bloc/bloc.dart';

abstract class EmptyEquatable extends Equatable {
  @override
  List<Object> get props => null;

  @override
  String toString() => "${runtimeType.toString()}";
}
/*
 *
 * States
 *
 */
abstract class TodoState extends EmptyEquatable {}

class TodoLoading extends TodoState {
  final String error;

  TodoLoading({this.error = null});

  @override
  List<Object> get props => [error];

  @override
  String toString() => 'TodoLoading';
}

class TodoLoaded extends TodoState {
  final List <Todo> todos;

  TodoLoaded({@required this.todos});

  @override
  List<Object> get props => [todos];

  @override
  String toString() =>
      'TodoLoaded { loaded ${todos.length} todos }';
}

/*
 *
 * Events
 *
 */
abstract class TodoEvent extends EmptyEquatable {}

class TodoRequested extends TodoEvent {}

class TodoNew extends TodoEvent {
  final Todo todo;

  @override
  List<Object> get props => [todo];

  TodoNew({@required this.todo});

  @override
  String toString() =>
      'TodoNew { todo: ${todo.toString()} }';
}

class TodoDelete extends TodoEvent {
  final Todo todo;

  TodoDelete({@required this.todo});

  @override
  List<Object> get props => [todo];

  @override
  String toString() =>
      'TodoDelete { todo: ${todo.toString()} }';
}

/*
 *
 * Bloc
 *
 */
class TodoBloc extends Bloc<TodoEvent, TodoState> {
  final TodoApi _api = TodoApi();

  @override
  TodoState get initialState => TodoLoading();

  @override
  Stream<TodoState> mapEventToState(TodoEvent event) async* {
    try {
      if (event is TodoNew) {
        yield TodoLoading();
        await _api.todoCreate(event.todo);
        dispatch(TodoRequested());
      } else if (event is TodoRequested) {
        yield TodoLoading();
        yield TodoLoaded(todos: await _api.todoList());
      } else if (event is TodoDelete) {
        yield TodoLoading();
        await _api.todoDelete(event.todo.id);
        dispatch(TodoRequested());
      }
    } catch(e) {
      yield TodoLoading(error: e.toString());
    }
  }
}
