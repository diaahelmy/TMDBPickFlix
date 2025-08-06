import 'package:flutter_bloc/flutter_bloc.dart';

enum ContentType { movie, tv }

class TabState {
  final ContentType selectedTab;
  TabState(this.selectedTab);
}

class TabCubit extends Cubit<TabState> {
  TabCubit() : super(TabState(ContentType.movie));

  void selectTab(ContentType type) {
    emit(TabState(type));
  }
}
