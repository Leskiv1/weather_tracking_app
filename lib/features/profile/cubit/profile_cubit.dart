// lib/features/profile/cubit/profile_cubit.dart
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../core/data/auth_repository.dart';
import '../../../core/models/user_model.dart';

// 1. СТАН
class ProfileState {
  final bool isLoading;
  final UserModel? user;

  ProfileState({this.isLoading = true, this.user});
}

// 2. CUBIT
class ProfileCubit extends Cubit<ProfileState> {
  final AuthRepositoryImpl authRepository;

  // Одразу при створенні йдемо за даними юзера
  ProfileCubit({required this.authRepository}) : super(ProfileState()) {
    loadUserData();
  }

  Future<void> loadUserData() async {
    emit(ProfileState(isLoading: true)); // Показуємо лоадер
    final currentUser = await authRepository.getCurrentUser();
    emit(ProfileState(isLoading: false, user: currentUser)); // Віддаємо дані
  }
}
