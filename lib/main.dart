import 'dart:convert';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:path_provider/path_provider.dart' as path;

void main(){

  runApp(new MaterialApp(title: "lista de tarefas",home:  Home()));
}

class Home extends StatefulWidget {
@override
_HomeState createState() => _HomeState();
}
class _HomeState extends State<Home> {

    List _todoList = [];

    @override
    Widget build(BuildContext context) {
      return Container(color: Colors.white,);
      }


    //processo de abertura de arquivo
    Future<File> _getFile() async{
      final directory =  await path.getApplicationDocumentsDirectory();
      return File("${directory.path}/data.json");
    }

    //processo de salvar em arquivo
    Future<File> _saveData() async{
      String data = json.encode(_todoList);
      final file = await _getFile();
      return file.writeAsString(data);
    }

    //processo de ler do arquivo
    Future<String> _readData() async{

        try{
            final file = await this._getFile();
            return file.readAsString();


        }catch(e){
            return null;

        }
    }
 }
