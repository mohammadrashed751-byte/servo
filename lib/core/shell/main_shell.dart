import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../feature/user_account/account/presentation/screen/profile_screen.dart';
import '../../feature/user_account/home/data/datasources/home_local_data_source.dart';
import '../../feature/user_account/home/data/repositories/home_repository_impl.dart';
import '../../feature/user_account/home/domain/repositories/home_repository.dart';
import '../../feature/user_account/home/presentation/cubit/home_cubit.dart';
import '../../feature/user_account/home/presentation/state/home_state.dart';
import '../../feature/user_account/home/presentation/screen/home_screen.dart';
import '../../feature/user_account/booking/presentation/screen/booking_screen.dart';
import '../../feature/user_account/messages/presentation/screen/messages_screen.dart';
import '../widgets/app_bottom_navigation_bar.dart';

class MainShell extends StatelessWidget {
  const MainShell({super.key});

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
                  const HomeScreen(),
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
