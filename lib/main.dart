import 'package:decimal/decimal.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class Calculator with ChangeNotifier {
  var isRPN = false;
  var line1 = '';
  var line2 = '';
  var line3 = '';
  var line4 = '0';
  var _enterMode = #replace;
  var op2 = '';
  var op3 = '';
  final keys = [];

  Calculator() {
    keys
      ..add([
        ['AC', () => allClear()],
        ['+/-', () => changeSign()],
        ['%', () => percent()],
        ['÷', () => multiply('÷')],
      ])
      ..add([
        ['7', () => digit('7')],
        ['8', () => digit('8')],
        ['9', () => digit('9')],
        ['×', () => multiply('×')],
      ])
      ..add([
        ['4', () => digit('4')],
        ['5', () => digit('5')],
        ['6', () => digit('6')],
        ['–', () => add('-')],
      ])
      ..add([
        ['1', () => digit('1')],
        ['2', () => digit('2')],
        ['3', () => digit('3')],
        ['+', () => add('+')],
      ])
      ..add([
        ['0', () => digit('0')],
        ['0', () => digit('0')],
        ['.', () => decimal()],
        ['=', () => equals()],
      ]);
  }

  void allClear() {
    if (isRPN) {
      line1 = '0';
      line2 = '0';
      line3 = '0';
    } else {
      line1 = '';
      line2 = '';
      line3 = '';
    }
    line4 = '0';
    op2 = '';
    op3 = '';
    notifyListeners();
  }

  void clear() {
    line4 = '0';
    keys[0][0] = ['AC', () => allClear()];
    notifyListeners();
  }

  void changeSign() {
    if (line4[0] == '-') {
      line4 = line4.substring(1);
    } else {
      line4 = '-' + line4;
    }
    notifyListeners();
  }

  void percent() {
    line4 = (Decimal.parse(line4) * Decimal.parse('0.01')).toString();
    notifyListeners();
  }

  void digit(var aDigit) {
    if (_enterMode == #push) {
      line1 = line2;
      line2 = line3;
      line3 = line4;
      line4 = aDigit;
      _enterMode = #append;
    } else {
      if (line4 == '0' || _enterMode == #replace) {
        line4 = aDigit.toString();
        _enterMode = #append;
      } else {
        line4 += aDigit.toString();
      }
    }
    keys[0][0] = ['C', () => clear()];
    notifyListeners();
  }

  void decimal() {
    if (_enterMode == #push) {
      line1 = line2;
      line2 = line3;
      line3 = line4;
      line4 = '0.';
      _enterMode = #append;
    } else if (_enterMode == #replace) {
      line4 = '0.';
      _enterMode = #append;
    } else {
      if (!line4.contains('.')) {
        line4 += '.';
      }
    }
    notifyListeners();
  }

  void add(var op) {
    if (isRPN) {
      var x = Decimal.parse(line3);
      var y = Decimal.parse(line4);
      if (op == '+') {
        line4 = (x + y).toString();
      } else {
        line4 = (x - y).toString();
      }
      line3 = line2;
      line2 = line1;
      _enterMode = #push;
    } else {
      equals();
      line3 = line4;
      op3 = op;
      line4 = '0';
    }
    notifyListeners();
  }

  void multiply(var op) {
    if (isRPN) {
      var x = Decimal.parse(line3);
      var y = Decimal.parse(line4);
      if (op == '×') {
        line4 = (x * y).toString();
      } else {
        line4 = (x / y).toString();
      }
      line3 = line2;
      line2 = line1;
      _enterMode = #push;
    } else {
      if (op3 == '+' || op3 == '-') {
        line2 = line3;
        op2 = op3;
        line3 = line4;
      } else if (op3 == '×') {
        var x = Decimal.parse(line3);
        var y = Decimal.parse(line4);
        line3 = (x * y).toString();
      } else if (op3 == '÷') {
        var x = Decimal.parse(line3);
        var y = Decimal.parse(line4);
        line3 = (x / y).toString();
      } else {
        line3 = line4;
      }
      op3 = op;
      line4 = '0';
    }
    notifyListeners();
  }

  void enter() {
    line1 = line2;
    line2 = line3;
    line3 = line4;
    _enterMode = #replace;
    notifyListeners();
  }

  void equals() {
    while (op3 != '') {
      var x = Decimal.parse(line3);
      var y = Decimal.parse(line4);
      var z = Decimal.parse('0');
      switch (op3) {
        case '+':
          z = x + y;
          break;
        case '-':
          z = x - y;
          break;
        case '×':
          z = x * y;
          break;
        case '÷':
          z = x / y;
          break;
      }
      line4 = z.toString();
      line3 = line2;
      line2 = '';
      op3 = op2;
      op2 = '';
    }
    notifyListeners();
  }
}

void main() {
  runApp(
    ChangeNotifierProvider(
      create: (_) => Calculator(),
      child: const MyApp(),
    ),
  );
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Calculator',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: const CalculatorPage(title: 'Simple Calculator'),
    );
  }
}

class CalculatorPage extends StatelessWidget {
  const CalculatorPage({Key? key, required this.title}) : super(key: key);

  final String title;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(title),
      ),
      body: Consumer<Calculator>(
        builder: (context, calculator, child) => Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: <Widget>[
                  Radio(
                      value: false,
                      groupValue: calculator.isRPN,
                      onChanged: (var value) {
                        calculator.isRPN = false;
                        var rows = calculator.keys.length;
                        var cols = calculator.keys[rows - 1].length;
                        calculator.keys[rows - 1]
                            [cols - 1] = ['=', () => calculator.equals()];
                        calculator.allClear();
                      }),
                  const Text('Infix'),
                  Radio(
                      value: true,
                      groupValue: calculator.isRPN,
                      onChanged: (var value) {
                        calculator.isRPN = true;
                        var rows = calculator.keys.length;
                        var cols = calculator.keys[rows - 1].length;
                        calculator.keys[rows - 1]
                            [cols - 1] = ['Enter', () => calculator.enter()];
                        calculator.allClear();
                      }),
                  const Text('RPN'),
                ],
              ),
              Text(calculator.line1 + ' '),
              Text(calculator.line2 + ' ' + calculator.op2),
              Text(calculator.line3 + ' ' + calculator.op3),
              Text(
                calculator.line4,
                style: Theme.of(context).textTheme.headline4,
              ),
              for (var row in calculator.keys)
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: <Widget>[
                    for (var pair in row)
                      OutlinedButton(
                        onPressed: pair[1],
                        child: Text(pair[0]),
                      )
                  ],
                ),
            ],
          ),
        ),
      ),
    );
  }
}
