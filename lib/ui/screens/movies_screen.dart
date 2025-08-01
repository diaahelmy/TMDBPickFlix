import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart'; // ✅ لازم عشان .w و .h و .sp
import 'package:pick_flix/ui/screens/main_screen.dart';
import '../../view/cubit/movie/movie_bloc.dart';
import '../../view/cubit/movie/movie_state.dart';
import '../../view/data/movie_event.dart';
import '../component/grid_item/movie_grid.dart';
import '../component/no_internet/no_internet_widget.dart';
import '../component/section_title.dart';
import '../component/header_widget.dart';
import '../component/selection_status_widget.dart';
import '../component/loading_grid_widget.dart';
import '../component/error_widget.dart';
import '../component/bottom_button_widget.dart';
import '../component/navigation_helper.dart';

class FavoritesSelectionScreen extends StatelessWidget {
  const FavoritesSelectionScreen({super.key});

  final int minimumSelection = 3;

  void _handleScroll(BuildContext context, ScrollNotification notification) {
    // تأكد من أن state هو MovieCombinedState قبل الوصول إلى خصائصه
    final movieState = context.read<MovieBloc>().state;
    if (movieState is MovieCombinedState) {
      if (notification.metrics.pixels >=
              notification.metrics.maxScrollExtent - 200 &&
          !movieState.topRatedLoaded) {
        // افترض أن topRatedLoaded تشير إلى تحميل قائمة المسلسلات
        context.read<MovieBloc>().add(FetchTopRatedTv());
        context.read<MovieBloc>().add(MarkTopRatedLoaded());
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      body: SafeArea(
        child: Column(
          children: [
            BlocBuilder<MovieBloc, MovieState>(
              builder: (context, state) {
                if (state is! MovieCombinedState) return const SizedBox();
                return HeaderWidget(
                  minimumSelection: minimumSelection,
                  currentSelection: state.selectedMovies.length,
                );
              },
            ),
            Expanded(
              child: NotificationListener<ScrollNotification>(
                onNotification: (notification) {
                  _handleScroll(context, notification);
                  return true;
                },
                child: SingleChildScrollView(
                  padding: EdgeInsets.fromLTRB(16.w, 0, 16.w, 100.h),
                  child: BlocBuilder<MovieBloc, MovieState>(
                    builder: (context, state) {
                      if (state is! MovieCombinedState) {
                        // في حالة لم يتم تهيئة الـ state بعد أو نوعه مختلف
                        return const LoadingGridWidget();
                      }

                      // عرض مؤشر تحميل رئيسي إذا كانت كلتا القائمتين قيد التحميل أو لم يتم تحميلهما بعد
                      // وليس هناك أخطاء
                      if (state.isTopRatedLoading &&
                          state.isTopRatedTvLoading &&
                          state.topRatedMovies == null &&
                          state.topRatedTv == null &&
                          state.topRatedError == null &&
                          state.topRatedTvError == null) {
                        return const LoadingGridWidget();
                      }

                      return Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          SelectionStatusWidget(
                            selectedCount: state.selectedMovies.length,
                            minimumSelection: minimumSelection,
                          ),
                          SizedBox(height: 24.h),

                          // ✅ عرض No Internet مرة واحدة لو الاتنين فاضيين وفيهم Error
                          if ((state.topRatedMovies == null || state.topRatedMovies!.isEmpty) &&
                              (state.topRatedTv == null || state.topRatedTv!.isEmpty) &&
                              (state.topRatedError != null || state.topRatedTvError != null)) ...[
                            NoInternetWidget(
                              onRetry: () {
                                final bloc = context.read<MovieBloc>();
                                bloc.add(FetchTopRatedMovies());
                                bloc.add(FetchTopRatedTv());
                              },
                            ),
                          ] else ...[
                            // ✅ Top Rated Movies Section
                            if (state.topRatedMovies?.isNotEmpty ?? false) ...[
                              const SectionTitle(title: "Top Rated Movies"),
                              SizedBox(height: 8.h),
                              MovieGrid(
                                items: state.topRatedMovies!,
                                itemLimit: 12,
                                selectedItems: state.selectedMovies,
                                onItemTap: (movie) {
                                  context.read<MovieBloc>().add(
                                    ToggleMovieSelection(movie),
                                  );
                                },
                              ),
                            ] else if (state.isTopRatedLoading &&
                                state.topRatedMovies == null) ...[
                              const SectionTitle(title: "Top Rated Movies"),
                              SizedBox(height: 8.h),
                              const LoadingGridWidget(),
                            ],

                            SizedBox(height: 32.h),

                            // ✅ Top Rated TV Section
                            if (state.topRatedTv?.isNotEmpty ?? false) ...[
                              const SectionTitle(title: "Top Rated TV"),
                              SizedBox(height: 8.h),
                              MovieGrid(
                                items: state.topRatedTv!,
                                itemLimit: 12,
                                selectedItems: state.selectedMovies,
                                onItemTap: (movie) {
                                  context.read<MovieBloc>().add(
                                    ToggleMovieSelection(movie),
                                  );
                                },
                              ),
                            ] else if (state.isTopRatedTvLoading &&
                                state.topRatedTv == null) ...[
                              const SectionTitle(title: "Top Rated TV"),
                              SizedBox(height: 8.h),
                              const LoadingGridWidget(),
                            ],
                          ],

                          SizedBox(height: 32.h),
                        ],
                      );

                    },
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
      bottomNavigationBar: BlocBuilder<MovieBloc, MovieState>(
        builder: (context, state) {
          if (state is! MovieCombinedState) return const SizedBox();
          final isEnabled = state.selectedMovies.length >= minimumSelection;

          return BottomButtonWidget(
            isEnabled: isEnabled,
            selectedCount: state.selectedMovies.length,
            minimumSelection: minimumSelection,
            onContinue: () {
              navigateAndFinish(context, const MainScreen());
            },
          );
        },
      ),
    );
  }
}
