import 'package:flutter/cupertino.dart';

/**
 * Exemplo de Widget herdado
 */
class CounterState {
  int _value = 1;

  int get value => _value;

  void inc() => _value++;
  void dec() => _value--;

  bool diff(CounterState old) {
    return old._value != _value;
  }
}

class CounterProvider extends InheritedWidget {
  final CounterState state = CounterState();

  CounterProvider({required Widget child}) : super(child: child);

  static CounterProvider of(BuildContext context) {
    return context.dependOnInheritedWidgetOfExactType<CounterProvider>()
        as CounterProvider;
  }

  @override
  bool updateShouldNotify(covariant InheritedWidget oldWidget) => true;
}
