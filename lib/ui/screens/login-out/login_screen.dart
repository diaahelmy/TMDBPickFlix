import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../view/api_service/ApiService.dart';
import '../../../view/cubit/login/cubit_login.dart';
import '../../../view/cubit/login/status_login.dart';
import '../../component/home_componant/default_form_field.dart';
import '../../component/navigation_helper.dart';
import '../navbarmenu/home_screen.dart';

class LoginScreen extends StatelessWidget {
  final TextEditingController emailController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();
  final GlobalKey<FormState> formKey = GlobalKey<FormState>();

  LoginScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => AuthCubit(ApiService()),
      child: BlocConsumer<AuthCubit, AuthState>(
        listener: (context, state) {
          if (state is AuthLoginSuccess) {
            navigateAndFinish(context, const HomeScreen(

            ));
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text("Login successful")),

            );
          } else if (state is AuthLoginError) {
            ScaffoldMessenger.of(
              context,
            ).showSnackBar(SnackBar(content: Text(state.error)));
          }
        },
        builder: (context, state) {
          var cubit = context.read<AuthCubit>();
          return Scaffold(
            appBar: AppBar(title: const Text("Login"), centerTitle: true),
            body: Center(
              child: Padding(
                padding: const EdgeInsets.all(20.0),
                child: Form(
                  key: formKey,
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      defaultFormField(
                        controler: emailController,
                        type: TextInputType.text,
                        lable: "Username (TMDB)",
                        prefix: Icons.person_outline,
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return "Please enter username";
                          }
                          return null;
                        },
                      ),
                      const SizedBox(height: 20),
                      defaultFormField(
                        controler: passwordController,
                        type: TextInputType.text,
                        lable: "Password (TMDB)",
                        prefix: Icons.lock_outline,
                        obscuretext: true,
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return "Please enter password";
                          }
                          return null;
                        },
                      ),
                      const SizedBox(height: 30),
                      state is AuthLoginLoading
                          ? const CircularProgressIndicator()
                          : ElevatedButton(
                              onPressed: () {
                                if (formKey.currentState!.validate()) {
                                  cubit.login(
                                    username: emailController.text,
                                    password: passwordController.text,
                                  );
                                }
                              },
                              child: const Text("Login"),
                            ),
                    ],
                  ),
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}
