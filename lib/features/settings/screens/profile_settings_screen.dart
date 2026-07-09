import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:team_manager/features/home/cubit/get_user_profile_cubit/get_user_profile_cubit.dart';
import 'package:team_manager/features/home/cubit/get_user_profile_cubit/get_user_profile_state.dart';
import 'package:team_manager/features/settings/widgets/profile_settings_view.dart';

class ProfileSettingsScreen extends StatefulWidget {
  const ProfileSettingsScreen({super.key});

  @override
  State<ProfileSettingsScreen> createState() => _ProfileSettingsScreenState();
}

class _ProfileSettingsScreenState extends State<ProfileSettingsScreen> {
  int selectedTab = 0;

  @override
  void initState() {
    super.initState();
    GetUserProfileCubit.get(context).getUserProfile();
  }

  void changeTab(int index) {
    setState(() => selectedTab = index);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      body: BlocBuilder<GetUserProfileCubit, GetUserProfileState>(
        builder: (context, state) {
          if (state is GetUserProfileLoading) {
            return const Center(child: CircularProgressIndicator());
          }

          if (state is GetUserProfileError) {
            return const Center(child: Text('Something went wrong'));
          }

          if (state is GetUserProfileSuccess) {
            return SafeArea(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(16, 16, 16, 0),
                child: ProfileSettingsView(
                  profile: state.profileModel,
                  selectedTab: selectedTab,
                  onTabChanged: changeTab,
                ),
              ),
            );
          }

          return const SizedBox();
        },
      ),
    );
  }
}
