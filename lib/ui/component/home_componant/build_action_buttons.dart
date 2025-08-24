import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../models/search_result.dart';
import '../../../view/cubit/home/popular/popular_movies_cubit.dart';
import '../../../view/cubit/home/top_rate/home_toprated_cubit.dart';
import '../../../view/cubit/home/upcoming/home_upcoming_cubit.dart';
import '../../../view/cubit/tab_change/TabState.dart';
import '../../screens/item/favorites_screen.dart';
import '../../screens/item/watchlist_screen.dart';
import '../../screens/move_pages/detail/movie_detail_screen.dart';
import '../navigation_helper.dart';
import 'build_quick_action_card.dart';

Widget buildActionButtons(BuildContext context) {
  final theme = Theme.of(context);
  final isDark = theme.brightness == Brightness.dark;
  final selectedTab = context.read<TabCubit>().state.selectedTab;
  final source = selectedTab == ContentType.movie
      ? MediaType.movie.name
      : MediaType.tv.name;
  final mediaType = selectedTab == ContentType.movie
      ? MediaType.movie
      : MediaType.tv;

  return Column(
    children: [
      // Movie Deal Button
      Container(
        width: double.infinity,
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              const Color(0xFF1976D2), // Cinema blue from theme
              const Color(0xFF1565C0),
            ],
          ),
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: const Color(0xFF1976D2).withOpacity(0.3),
              blurRadius: 8,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Material(
          color: Colors.transparent,
          child: InkWell(
            borderRadius: BorderRadius.circular(16),
            onTap: () {
              // Movie deal action
            },
            child: Padding(
              padding: const EdgeInsets.symmetric(vertical: 18, horizontal: 24),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.2),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: const Icon(
                      Icons.local_movies,
                      color: Colors.white,
                      size: 24,
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          selectedTab == ContentType.movie?
                          'Movie Deal':'TV Show Deal',
                          style: theme.textTheme.titleLarge?.copyWith(
                            color: Colors.white,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          'Special offers & discounts',
                          style: theme.textTheme.bodySmall?.copyWith(
                            color: Colors.white.withOpacity(0.9),
                            fontSize: 12,
                          ),
                        ),
                      ],
                    ),
                  ),
                  Icon(
                    Icons.arrow_forward_ios,
                    color: Colors.white.withOpacity(0.8),
                    size: 18,
                  ),
                ],
              ),
            ),
          ),
        ),
      ),

      const SizedBox(height: 20),

      // Random Movie Pick Button
    Container(

          width: double.infinity,
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [
                const Color(0xFFFF6B35),
                const Color(0xFFE55A2B),
              ],
            ),
            borderRadius: BorderRadius.circular(16),
            boxShadow: [
              BoxShadow(
                color: const Color(0xFFFF6B35).withOpacity(0.3),
                blurRadius: 8,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: Material(

            color: Colors.transparent,
            child: InkWell(
              onTap: () {
                final popularMovies = context.read<HomePopularCubit>().cachedPopularMovies;
                final topRatedMovies = context.read<HomeTopRatedCubit>().cachedTopRatedMovies;
                final upcomingMovies = context.read<HomeUpcomingCubit>().cachedUpcomingMovies;


                final allMovies = [
                  ...popularMovies,
                  ...topRatedMovies,
                  ...upcomingMovies,
                ];

                if (allMovies.isNotEmpty) {
                  allMovies.shuffle();
                  final randomMovie = allMovies.first;

                  navigateTo(
                    context,
                    MovieDetailScreen(
                      id: randomMovie.id,
                      source: source,
                    ),
                  );
                } else {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Loading movies... please try again')),
                  );

                  context.read<HomePopularCubit>().fetchPopularMovies(
                    ContentType.movie,
                  );
                  context.read<HomeTopRatedCubit>().fetchTopRatedMovies(
                    ContentType.movie,

                  );
                  context.read<HomeUpcomingCubit>().fetchUpcomingMovies(
                    ContentType.movie,

                  );
                }
              },
              child: Padding(
                padding: const EdgeInsets.symmetric(vertical: 18, horizontal: 24),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.2),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: const Icon(
                        Icons.shuffle,
                        color: Colors.white,
                        size: 24,
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Column(

                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [


                          Text(
                            selectedTab == ContentType.movie?
                            'Random Movie Pick!':'Random TV Show Pick!',
                            style: theme.textTheme.titleLarge?.copyWith(
                              color: Colors.white,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                          const SizedBox(height: 2),
                          Text(
                            'Let us surprise you',
                            style: theme.textTheme.bodySmall?.copyWith(
                              color: Colors.white.withOpacity(0.9),
                              fontSize: 12,
                            ),
                          ),
                        ],
                      ),
                    ),
                    Icon(
                      Icons.arrow_forward_ios,
                      color: Colors.white.withOpacity(0.8),
                      size: 18,
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),

      const SizedBox(height: 16),

      // Optional: Additional Quick Actions Row
      Row(
        children: [
          Expanded(
            child: buildQuickActionCard(
              context,
              icon: Icons.bookmark_outline,
              label: 'Watchlist',
              color: isDark ? const Color(0xFF161B22) : Colors.grey[100]!,
              onTap: () {
                navigateTo(context,WatchlistScreen(
                  mediaType: mediaType,
                ));
                // Watchlist action
              },
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: buildQuickActionCard(
              context,
              icon: Icons.history,
              label: 'History',
              color: isDark ? const Color(0xFF161B22) : Colors.grey[100]!,
              onTap: () {
                // History action
              },
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: buildQuickActionCard(
              context,
              icon: Icons.star_outline,
              label: 'Favorites',
              color: isDark ? const Color(0xFF161B22) : Colors.grey[100]!,
              onTap: () {
                navigateTo(context,FavoritesScreen(

                  mediaType: mediaType,
                ));
                // Favorites action
              },
            ),
          ),
        ],
      ),
    ],
  );
}
