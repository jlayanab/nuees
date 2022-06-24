import 'package:flutter/material.dart';
import 'package:uees/Controllers/databasehelpers.dart';
import 'package:uees/view/editItems.dart';
import 'package:uees/view/listItems.dart';

class Detail extends StatefulWidget {
  final List list;
  final int index;
  Detail({this.index, this.list});

  @override
  _DetailState createState() => _DetailState();
}

class _DetailState extends State<Detail> {
  DataBaseHelper databasehelper = new DataBaseHelper();

  //create function delete

  void confirm() {
    AlertDialog alertDialog = new AlertDialog(
      content: new Text(
          "Esta seguro de eliminar '${widget.list[widget.index]['name']}'"),
      actions: <Widget>[
        new ElevatedButton(
          child: new Text(
            "Eliminar!",
            style: new TextStyle(color: Colors.black),
          ),
          //color: Colors.red,
          onPressed: () {
            databasehelper
                .removeRegister(widget.list[widget.index]['id'].toString());
            Navigator.of(context).push(new MaterialPageRoute(
              builder: (BuildContext context) => new ListItems(),
            ));
          },
        ),
        new ElevatedButton(
          child: new Text(
            "Cancelar",
            style: new TextStyle(color: Colors.black),
          ),
          //color: Colors.green,
          onPressed: () => Navigator.pop(context),
        )
      ],
    );

    //showDialog(context: context, child: alertDialog);
  }

  @override
  Widget build(BuildContext context) {
    return new Scaffold(
      appBar:
          new AppBar(title: new Text("${widget.list[widget.index]['code']}")),
      body: new Container(
        height: 270.0,
        padding: const EdgeInsets.all(20.0),
        child: new Card(
          child: new Center(
            child: new Column(
              children: <Widget>[
                new Padding(
                  padding: const EdgeInsets.only(top: 30.0),
                ),
                new Text(
                  widget.list[widget.index]['code'],
                  style: new TextStyle(fontSize: 20.0),
                ),
                Divider(),
                new Padding(
                  padding: const EdgeInsets.only(top: 30.0),
                ),
                new Text("Description : ${widget.list[widget.index]['status']}",
                    style: new TextStyle(fontSize: 18.0)),
                new Row(
                  mainAxisSize: MainAxisSize.min,
                  children: <Widget>[
                    new ElevatedButton(
                      child: new Text("Edit"),
                      //color: Colors.blueAccent,
                      //shape: new RoundedRectangleBorder(
                      //borderRadius: new BorderRadius.circular(30.0)),
                      onPressed: () =>
                          Navigator.of(context).push(new MaterialPageRoute(
                        builder: (BuildContext context) => new EditItem(
                          list: widget.list,
                          index: widget.index,
                        ),
                      )),
                    ),
                    VerticalDivider(),
                    new ElevatedButton(
                        child: new Text("Delete"),
                        //color: Colors.redAccent,
                        //shape: new RoundedRectangleBorder(
                        //borderRadius: new BorderRadius.circular(30.0)),
                        onPressed: () => confirm()),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
