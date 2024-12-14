// ignore_for_file: public_member_api_docs, sort_constructors_first
part of 'webview_bloc.dart';

sealed class WebviewState extends Equatable {
  const WebviewState();
}

final class WebviewInitial extends WebviewState {
  @override
  List<Object?> get props => [];
}

class PageLoading extends WebviewState {
  final int progress;

  const PageLoading(this.progress);

  @override
  List<Object?> get props => [progress];
}

class PageLoaded extends WebviewState {
  final String url;
  final List<dynamic> data;

  const PageLoaded(this.url, this.data);

  @override
  List<Object> get props => [url, data];
}

class DataLoaded extends WebviewState {
  final List<dynamic>? data;

  const DataLoaded(this.data);

  @override
  List<Object?> get props => [data];
}

class PrintingInProgress extends WebviewState {
  @override
  List<Object?> get props => [];
}

class PrintSuccess extends WebviewState {
  final String url;

  const PrintSuccess(this.url);

  @override
  List<Object?> get props => [url];
}

class PrintFailure extends WebviewState {
  final String error;

  const PrintFailure(this.error);

  @override
  List<Object> get props => [error];
}
