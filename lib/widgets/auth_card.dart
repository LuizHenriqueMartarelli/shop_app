import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:shop_app/exceptions/auth_exception.dart';
import 'package:shop_app/providers/auth.dart';

enum AuthMode { Singup, Login }

class AuthCard extends StatefulWidget {
  const AuthCard({Key? key}) : super(key: key);

  @override
  _AuthCardState createState() => _AuthCardState();
}

class _AuthCardState extends State<AuthCard> {
  GlobalKey<FormState> _form = GlobalKey();
  bool _isLoading = false;
  AuthMode _authMode = AuthMode.Login;
  final _passwordController = TextEditingController();
  Map<String, String?> _authData = {'email': '', 'password': ''};

  void _showErrorDialog(String msg) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text('Ocorreu um erro!'),
        content: Text(msg),
        actions: [
          TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: Text('Fechar!'))
        ],
      ),
    );
  }

  Future<void> _submit() async {
    if (!_form.currentState!.validate()) return;

    setState(() {
      _isLoading = true;
    });
    _form.currentState!.save();

    Auth auth = Provider.of(context, listen: false);
    try {
      if (_authMode == AuthMode.Login) {
        await auth.login(_authData['email']!, _authData['password']!);
      } else {
        await auth.singup(_authData['email']!, _authData['password']!);
      }
    } on AuthException catch (error) {
      _showErrorDialog(error.toString());
    } catch (error) {
      _showErrorDialog("Ocorreu um erro inesperado!");
    }

    setState(() {
      _isLoading = false;
    });
  }

  void _switchAuthMode() {
    if (_authMode == AuthMode.Login) {
      setState(() {
        _authMode = AuthMode.Singup;
      });
    } else {
      setState(() {
        _authMode = AuthMode.Login;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final deviceSize = MediaQuery.of(context).size;

    return Card(
      elevation: 8.0,
      child: Container(
        height: _authMode == AuthMode.Login ? 290 : 371,
        width: deviceSize.width * .75,
        padding: const EdgeInsets.all(16),
        child: Form(
          key: _form,
          child: Column(
            children: [
              TextFormField(
                decoration: InputDecoration(labelText: 'Email'),
                keyboardType: TextInputType.emailAddress,
                validator: (value) {
                  if (value == null ||
                      value.trim().isEmpty ||
                      !value.trim().contains('@')) {
                    return 'Informe um Email válido';
                  }

                  return null;
                },
                onSaved: (value) => _authData['email'] = value,
              ),
              TextFormField(
                decoration: InputDecoration(labelText: 'Senha'),
                keyboardType: TextInputType.visiblePassword,
                obscureText: true,
                controller: _passwordController,
                validator: (value) {
                  if (value == null ||
                      value.trim().isEmpty ||
                      value.trim().length < 6) {
                    return 'Informe uma Senha válida';
                  }

                  return null;
                },
                onSaved: (value) => _authData['password'] = value,
              ),
              if (_authMode == AuthMode.Singup)
                TextFormField(
                  decoration: InputDecoration(labelText: 'Confirmar Senha'),
                  keyboardType: TextInputType.visiblePassword,
                  obscureText: true,
                  validator: _authMode == AuthMode.Singup
                      ? (value) {
                          if (value == null ||
                              value.trim().isEmpty ||
                              value.trim().length < 6) {
                            return 'Informe uma Senha válida';
                          }

                          if (value != _passwordController.text) {
                            return "As senhas são diferentes!";
                          }

                          return null;
                        }
                      : null,
                ),
              Spacer(),
              _isLoading
                  ? CircularProgressIndicator()
                  : ElevatedButton(
                      style: ElevatedButton.styleFrom(
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(30),
                          ),
                          textStyle: TextStyle(
                              color: Theme.of(context)
                                  .primaryTextTheme
                                  .button
                                  ?.color),
                          padding: const EdgeInsets.symmetric(
                              horizontal: 30, vertical: 8),
                          primary: Theme.of(context).primaryColor),
                      child: Text(
                          _authMode == AuthMode.Login ? 'ENTRAR' : 'REGISTRAR'),
                      onPressed: () => _submit(),
                    ),
              TextButton(
                onPressed: _switchAuthMode,
                child: Text(
                    "ALTERAR P/ ${_authMode == AuthMode.Login ? 'REGISTRAR' : 'LOGIN'}"),
              )
            ],
          ),
        ),
      ),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
    );
  }
}
