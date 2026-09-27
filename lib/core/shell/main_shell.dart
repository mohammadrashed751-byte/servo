import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../feature/account/presentation/screen/profile_screen.dart';
import '../../feature/home/data/datasources/home_local_data_source.dart';
import '../../feature/home/data/repositories/home_repository_impl.dart';
import '../../feature/home/domain/repositories/home_repository.dart';
import '../../feature/home/presentation/cubit/home_cubit.dart';
import '../../feature/home/presentation/state/home_state.dart';
import '../../feature/home/presentation/screen/home_screen.dart';
import '../../feature/booking/presentation/screen/booking_screen.dart';
import '../../feature/messages/presentation/screen/messages_screen.dart';
import '../widgets/app_bottom_navigation_bar.dart';

class MainShell extends StatelessWidget {
  const MainShell({super.key, this.showReviewOnOpen = false});

  final bool showReviewOnOpen;

  @override
  Widget build(BuildContext context) {
    return RepositoryProvider<HomeRepository>(
      create: (_) => const HomeRepositoryImpl(HomeLocalDataSource()),
      child: BlocProvider(
        create: (context) => HomeCubit(context.read<HomeRepository>()),
        child: BlocBuilder<HomeCubit, HomeState>(
          builder: (context, state) {
            return Scaffold(
              body: IndexedStack(
                index: state.currentIndex,
                children: [
                  HomeScreen(showReviewOnOpen: showReviewOnOpen),
                  const BookingScreen(),
                  const MessagesScreen(),
                  const ProfileScreen(),
                ],
              ),
              bottomNavigationBar: AppBottomNavigationBar(
                currentIndex: state.currentIndex,
                onTap: context.read<HomeCubit>().selectTab,
              ),
            );
          },
        ),
      ),
    );
  }
}
