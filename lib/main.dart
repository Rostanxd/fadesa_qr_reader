import 'package:flutter/material.dart';
import 'package:barcode_scan/barcode_scan.dart';
import 'package:flutter/services.dart';

import 'blocs/reader_bloc.dart';

void main() => runApp(MyApp());

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Fadesa QR Reader',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: MyHomePage(title: 'QR Reader'),
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
  final _scaffoldKey = GlobalKey<ScaffoldState>();
  ReaderBloc _readerBloc = new ReaderBloc();

  Future _barcodeScanning() async {
    try {
      var _barcodeRead = await BarcodeScanner.scan();
      _readerBloc.addQrToList(_barcodeRead);
    } on PlatformException catch (e) {
      _scaffoldKey.currentState.showSnackBar(
          new SnackBar(content: Text('Error acceso a cámara denegado.')));
    } on FormatException {} catch (e) {
      _scaffoldKey.currentState
          .showSnackBar(new SnackBar(content: Text('Error ${e.toString()}')));
    }
  }

  @override
  void initState() {
    _readerBloc.addQrList([]);
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: _scaffoldKey,
      appBar: AppBar(
        title: Text(widget.title),
        actions: <Widget>[
          IconButton(
            icon: Icon(Icons.content_copy),
            onPressed: () {
              copyToClipboard();
            },
          ),
          IconButton(
            icon: Icon(Icons.delete),
            onPressed: () {
              _readerBloc.dropList();
            },
          ),
          IconButton(
            icon: Icon(Icons.add_to_queue),
            onPressed: () {
              _barcodeScanning();
            },
          ),
        ],
      ),
      body: Center(
        child: StreamBuilder(
          stream: _readerBloc.qrList,
          builder:
              (BuildContext context, AsyncSnapshot<List<String>> snapshot) {
            return snapshot.data != null && snapshot.data.length != 0
                ? ListView.separated(
                    itemBuilder: (BuildContext context, int index) {
                      return Dismissible(
                        key: Key(UniqueKey().toString()),
                        child: ListTile(
                          title: Text(snapshot.data[index]),
                        ),
                        onDismissed: (direction) {
                          _readerBloc.removeQr(index);
                        },
                        background: Container(
                            alignment: AlignmentDirectional.centerEnd,
                            color: Colors.red,
                            child: Padding(
                              padding: EdgeInsets.fromLTRB(0.0, 0.0, 10.0, 0.0),
                              child: Icon(Icons.delete, color: Colors.white),
                            )),
                      );
                    },
                    separatorBuilder: (BuildContext context, int index) {
                      return Divider();
                    },
                    itemCount: snapshot.data.length)
                : Center(
                    child: Container(
                      child: Text('Por favor comience a realizar capturas.'),
                    ),
                  );
          },
        ),
      ),
    );
  }

  void copyToClipboard() {
    String data = "";
    int count =
        _readerBloc.qrList.value != null ? _readerBloc.qrList.value.length : 0;

    _readerBloc.qrList.value.forEach((qr) => data += qr.toString() + '\n');

    Clipboard.setData(ClipboardData(text: data));

    _scaffoldKey.currentState.showSnackBar(new SnackBar(
        content: Text('Se han Copiado ${count.toString()} elementos.')));
  }
}
