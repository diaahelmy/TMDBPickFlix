import 'package:flutter/cupertino.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:pick_flix/view/cubit/login/status_login.dart';
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

      userModel = UserModel(sessionId: sessionId, requestToken: validatedToken);
      emit(AuthLoginSuccess(userModel!));
    } catch (error) {
      emit(AuthLoginError(error.toString()));
    }
  }
}
