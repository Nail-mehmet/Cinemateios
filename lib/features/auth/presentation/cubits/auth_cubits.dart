/*,
 Auth Cuibt: State Mangement 

*/


import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:Cinemate/features/auth/domain/entities/app_user.dart';
import 'package:Cinemate/features/auth/domain/repos/auth_repo.dart';
import 'package:Cinemate/features/auth/presentation/cubits/auth_states.dart';

class AuthCubit extends Cubit<AuthState>{
  final AuthRepo authRepo;
  AppUser? _currentUser;

  AuthCubit({required this.authRepo}): super(AuthInitial());

  // check if user is already authenticate
  void checkAuth() async{
    final AppUser? user = await authRepo.getCurrentUser();

    if(user!=null){
      _currentUser = user;
      emit(Authenticated(user));
    }else{
      emit(Unauthenticated());
    }
  }

  // AuthCubit içinde
  // get current user
  AppUser? get currentUser => _currentUser;

  // login with email and pw
  Future<void> login(String email, String pw)async{
    try{
      emit(AuthLoading());
      final user = await authRepo.loginWithEmailPassword(email, pw);

      if(user != null){
        _currentUser = user;
        emit(Authenticated(user));
      }else{
        emit(Unauthenticated());
      }
    }catch(e) {
      emit(AuthError(e.toString()));
      emit(Unauthenticated());
    }
  }

  // register with email and pw
  Future<void> register(String name, String email, String pw) async {
    try {
      emit(AuthLoading());
      final user = await authRepo.registerWithEmailPassword(name, email, pw);

      if (user != null) {
        _currentUser = user;
        emit(Authenticated(user));
        // Add any post-registration logic here if needed
      } else {
        emit(Unauthenticated());
        emit(AuthError("Registration failed - no user returned"));
      }
    } catch (e) {
      emit(AuthError(e.toString()));
      emit(Unauthenticated());
    }
  }

  Future<void> deleteAccount() async {
  emit(DeleteAccountLoading());
  try {
    await authRepo.deleteAccount();
    emit(DeleteAccountSuccess());
    emit(Unauthenticated());
  } catch (e) {
    emit(DeleteAccountError('Hesap silinemedi: $e'));
  }
}


  // logout
  Future<void> logout() async {
    authRepo.logout();
    emit(Unauthenticated());
  }
}