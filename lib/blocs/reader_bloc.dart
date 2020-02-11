import 'package:rxdart/rxdart.dart';
import 'bloc_base.dart';

class ReaderBloc extends BlocBase {
  final _qrReadList = BehaviorSubject<List<String>>();

  ///  Observable
  ValueObservable<List<String>> get qrList => _qrReadList.stream;

  /// Functions
  Function(List<String>) get addQrList => _qrReadList.sink.add;

  addQrToList(String newQr) {
    List<String> currentList = _qrReadList.value;
    if (currentList == null) {
      currentList = new List<String>();
    }
    currentList.add(newQr);
    _qrReadList.sink.add(currentList);
  }

  void removeQr(int index) {
    List<String> currentList = _qrReadList.value;
    if (currentList.length != 0) {
      currentList.removeAt(index);
      _qrReadList.sink.add(currentList);
    }
  }

  void dropList() {
    _qrReadList.sink.add(new List<String>());
  }

  @override
  void dispose() {
    _qrReadList.close();
  }
}
