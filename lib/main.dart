import 'dart:convert';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:path_provider/path_provider.dart' as path;

void main() {
  runApp(new MaterialApp(title: "lista de tarefas", home: Home()));
}

class Home extends StatefulWidget {
  @override
  _HomeState createState() => _HomeState();
}

class _HomeState extends State<Home> {
  List _todoList = [];
  TextEditingController controladorDeTodo = TextEditingController();
  Map<String, dynamic> lastRemoved = Map();
  int lastRemovedIndex;



  @override
  void initState() {
    super.initState();
    _readData().then(
        (data){
          setState(() {
            _todoList = json.decode(data);
          });
        }); 


  }


  void _addToDo() {

    if(this.controladorDeTodo.text!=""){

    setState(() {
      Map<String, dynamic> newTodo = Map();
      newTodo["title"] = this.controladorDeTodo.text;
      newTodo["ok"] = false;
      this.controladorDeTodo.text = "";
      this._todoList.add(newTodo);
    });

    this._saveData();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Lista de tarefas"),
        centerTitle: true,
      ),
      body: Column(
        children: <Widget>[
          Container(
            padding: EdgeInsets.fromLTRB(17, 1, 7, 1),
            child: Row(
              children: <Widget>[
                Expanded(
                    child: TextField(
                  decoration: InputDecoration(
                      labelText: "nova tarefa",
                      labelStyle: TextStyle(color: Colors.blueAccent)),
                  controller: this.controladorDeTodo,
                )),
                RaisedButton(
                    onPressed: _addToDo,
                    child: Text("ADD"),
                    color: Colors.blueAccent,
                    textColor: Colors.white)
              ],
            ),
          ),
          Expanded(
            child: RefreshIndicator(child: ListView.builder(
              padding: EdgeInsets.only(top: 10.0),
              itemCount: this._todoList.length,
              itemBuilder: buildItem,
              
            
            ),
            
            onRefresh:ordenar,
            ),
          )
        ],
      ),
    );
  }



  Widget buildItem(context, index) {

          return Dismissible(
            onDismissed: (direction){

              setState(() {
                lastRemoved = Map.from(_todoList[index]);
                lastRemovedIndex = index;
                _todoList.removeAt(index);
                _saveData();
              });


            final sn = SnackBar(
                content: Text("Tarefa ${lastRemoved["title"]} removida"),
                action: SnackBarAction(
                    label:"Desfazer",
                    onPressed: (){
                      setState(() {
                      this._todoList.insert(lastRemovedIndex, lastRemoved);
                      _saveData();
                      });
                    },


                ),
            duration: Duration(seconds: 2),
            );
            Scaffold.of(context).removeCurrentSnackBar();    // ADICIONE ESTE COMANDO
            Scaffold.of(context).showSnackBar(sn);
            },
            key: Key(DateTime.now().millisecondsSinceEpoch.toString()),
            background: Container(
              color: Colors.red,
              child: Align(
                  alignment: Alignment(-0.9, 0.0),
                  child: Icon(Icons.delete,color: Colors.white) ,

              ),
              ),
                direction: DismissDirection.startToEnd,
                child: CheckboxListTile(
                  title: Text(this._todoList[index]["title"]),
                  value: this._todoList[index]["ok"],
                  secondary: CircleAvatar(
                    child: Icon(
                        _todoList[index]["ok"] ? Icons.check : Icons.error),
                  ),
                  onChanged: (valor) {
                    setState(() {
                      this._todoList[index]["ok"] = valor;
                    });
                  },
                )
                );
}


Future<Null> ordenar() async{

    await Future.delayed(Duration(seconds: 2));

    setState(() {
      
    this._todoList.sort((a,b){

        if(a["ok"] && !b["ok"])
          return 1;
        if(!a["ok"] && b["ok"])
          return -1;
        return 0;
    });
    _saveData();
    return null;

    });

}


  //processo de abertura de arquivo
  Future<File> _getFile() async {
    final directory = await path.getApplicationDocumentsDirectory();
    return File("${directory.path}/data.json");
  }

  //processo de salvar em arquivo
  Future<File> _saveData() async {
    String data = json.encode(_todoList);
    final file = await _getFile();
    return file.writeAsString(data);
  }

  //processo de ler do arquivo
  Future<String> _readData() async {
    try {
      final file = await this._getFile();
      return file.readAsString();
      this._saveData();
    } catch (e) {
      return null;
    }
  }
}

