import 'package:decimal/decimal.dart';
import 'package:flutter/material.dart';

void main() {
  runApp(const MyApp());
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
      home: const MyHomePage(title: 'Simple Calculator'),
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({Key? key, required this.title}) : super(key: key);

  final String title;

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  var _isRPN = false;
  var _line1 = '';
  var _line2 = '';
  var _line3 = '';
  var _line4 = '0';
  var _enterMode = #replace;
  var _op2 = '';
  var _op3 = '';
  final _keys = [];

  _MyHomePageState() {
    _keys
      ..add([
        ['AC', () => _allClear()],
        ['+/-', () => _changeSign()],
        ['%', () => _percent()],
        ['÷', () => _multiply('÷')],
      ])
      ..add([
        ['7', () => _digit('7')],
        ['8', () => _digit('8')],
        ['9', () => _digit('9')],
        ['×', () => _multiply('×')],
      ])
      ..add([
        ['4', () => _digit('4')],
        ['5', () => _digit('5')],
        ['6', () => _digit('6')],
        ['–', () => _add('-')],
      ])
      ..add([
        ['1', () => _digit('1')],
        ['2', () => _digit('2')],
        ['3', () => _digit('3')],
        ['+', () => _add('+')],
      ])
      ..add([
        ['0', () => _digit('0')],
        ['0', () => _digit('0')],
        ['.', () => _decimal()],
        ['=', () => _equals()],
      ]);
  }

  void _allClear() {
    setState(() {
      if (_isRPN) {
        _line1 = '0';
        _line2 = '0';
        _line3 = '0';
      } else {
        _line1 = '';
        _line2 = '';
        _line3 = '';
      }
      _line4 = '0';
      _op2 = '';
      _op3 = '';
    });
  }

  void _clear() {
    setState(() {
      _line4 = '0';
      _keys[0][0] = ['AC', () => _allClear()];
    });
  }

  void _changeSign() {
    setState(() {
      if (_line4[0] == '-') {
        _line4 = _line4.substring(1);
      } else {
        _line4 = '-' + _line4;
      }
    });
  }

  void _percent() {
    setState(() {
      _line4 = (Decimal.parse(_line4) * Decimal.parse('0.01')).toString();
    });
  }

  void _digit(var aDigit) {
    setState(() {
      if (_enterMode == #push) {
        _line1 = _line2;
        _line2 = _line3;
        _line3 = _line4;
        _line4 = aDigit;
        _enterMode = #append;
      } else {
        if (_line4 == '0' || _enterMode == #replace) {
          _line4 = aDigit.toString();
          _enterMode = #append;
        } else {
          _line4 += aDigit.toString();
        }
      }
      _keys[0][0] = ['C', () => _clear()];
    });
  }

  void _decimal() {
    setState(() {
      if (_enterMode == #push) {
        _line1 = _line2;
        _line2 = _line3;
        _line3 = _line4;
        _line4 = '0.';
        _enterMode = #append;
      } else if (_enterMode == #replace) {
        _line4 = '0.';
        _enterMode = #append;
      } else {
        if (!_line4.contains('.')) {
          _line4 += '.';
        }
      }
    });
  }

  void _add(var op) {
    setState(() {
      if (_isRPN) {
        var x = Decimal.parse(_line3);
        var y = Decimal.parse(_line4);
        if (op == '+') {
          _line4 = (x + y).toString();
        } else {
          _line4 = (x - y).toString();
        }
        _line3 = _line2;
        _line2 = _line1;
        _enterMode = #push;
      } else {
        _equals();
        _line3 = _line4;
        _op3 = op;
        _line4 = '0';
      }
    });
  }

  void _multiply(var op) {
    setState(() {
      if (_isRPN) {
        var x = Decimal.parse(_line3);
        var y = Decimal.parse(_line4);
        if (op == '×') {
          _line4 = (x * y).toString();
        } else {
          _line4 = (x / y).toString();
        }
        _line3 = _line2;
        _line2 = _line1;
        _enterMode = #push;
      } else {
        if (_op3 == '+' || _op3 == '-') {
          _line2 = _line3;
          _op2 = _op3;
          _line3 = _line4;
        } else if (_op3 == '×') {
          var x = Decimal.parse(_line3);
          var y = Decimal.parse(_line4);
          _line3 = (x * y).toString();
        } else if (_op3 == '÷') {
          var x = Decimal.parse(_line3);
          var y = Decimal.parse(_line4);
          _line3 = (x / y).toString();
        } else {
          _line3 = _line4;
        }
        _op3 = op;
        _line4 = '0';
      }
    });
  }

  void _enter() {
    setState(() {
      _line1 = _line2;
      _line2 = _line3;
      _line3 = _line4;
      _enterMode = #replace;
    });
  }

  void _equals() {
    setState(() {
      while (_op3 != '') {
        var x = Decimal.parse(_line3);
        var y = Decimal.parse(_line4);
        var z = Decimal.parse('0');
        switch (_op3) {
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
        _line4 = z.toString();
        _line3 = _line2;
        _line2 = '';
        _op3 = _op2;
        _op2 = '';
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.title),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: <Widget>[
                Radio(
                    value: false,
                    groupValue: _isRPN,
                    onChanged: (var value) {
                      setState(() {
                        _isRPN = false;
                        var rows = _keys.length;
                        var cols = _keys[rows - 1].length;
                        _keys[rows - 1][cols - 1] = ['=', () => _equals()];
                        _allClear();
                      });
                    }),
                const Text('Infix'),
                Radio(
                    value: true,
                    groupValue: _isRPN,
                    onChanged: (var value) {
                      setState(() {
                        _isRPN = true;
                        var rows = _keys.length;
                        var cols = _keys[rows - 1].length;
                        _keys[rows - 1][cols - 1] = ['Enter', () => _enter()];
                        _allClear();
                      });
                    }),
                const Text('RPN'),
              ],
            ),
            Text(_line1 + ' '),
            Text(_line2 + ' ' + _op2),
            Text(_line3 + ' ' + _op3),
            Text(
              _line4,
              style: Theme.of(context).textTheme.headline4,
            ),
            for (var row in _keys)
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
    );
  }
}
