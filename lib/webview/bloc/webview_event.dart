part of 'webview_bloc.dart';

sealed class WebviewEvent extends Equatable {
  const WebviewEvent();
}

class PageStarted extends WebviewEvent {
  final String url;

  const PageStarted(this.url);

  @override
  List<Object?> get props => [url];
}

class PageFinished extends WebviewEvent {
  final String url;

  const PageFinished(this.url);

  @override
  List<Object?> get props => [url];
}

class PageProgress extends WebviewEvent {
  final int progress;

  const PageProgress(this.progress);

  @override
  List<Object?> get props => [progress];
}

class DataReceived extends WebviewEvent {
  final Penumpang data;

  const DataReceived(this.data);

  @override
  List<Object?> get props => [data];
}
