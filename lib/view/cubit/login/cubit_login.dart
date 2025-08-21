import 'package:flutter/cupertino.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:pick_flix/view/cubit/login/status_login.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../../models/user_model.dart';
import '../../api_service/ApiService.dart';



class AuthCubit extends Cubit<AuthState> {
  final ApiService apiService;
  AuthCubit(this.apiService) : super(AuthInitial());

  UserModel? userModel;
  static AuthCubit get(BuildContext context) => BlocProvider.of<AuthCubit>(context);

  Future<void> login({
    required String username,
    required String password,
  }) async {
    emit(AuthLoginLoading());
    try {
      // Step 1: Create Token
      final token = await apiService.createRequestToken();

      // Step 2: Validate with login
      final validatedToken = await apiService.validateWithLogin(
        username: username,
        password: password,
        requestToken: token,
      );

      // Step 3: Create Session
      final sessionId = await apiService.createSession(validatedToken);
      // Step 4: Get Account Details → عشان تجيب account_id
      final account = await apiService.getAccountDetails(sessionId);
      final accountId = account["id"];


      userModel = UserModel(
        sessionId: sessionId,
        requestToken: validatedToken,
      );

      final prefs = await SharedPreferences.getInstance();
      await prefs.setString('session_id', sessionId);
      await prefs.setInt('account_id', accountId);

      emit(AuthLoginSuccess(userModel!));
    } catch (error) {
      emit(AuthLoginError(error.toString()));
    }
  }
}
