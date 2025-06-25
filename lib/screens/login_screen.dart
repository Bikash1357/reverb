import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:flutter_facebook_auth/flutter_facebook_auth.dart';
import 'package:reverb/screens/gender_screen.dart';
import 'package:reverb/screens/signup_screen.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final _formKey = GlobalKey<FormState>();
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final GoogleSignIn _googleSignIn = GoogleSignIn();

  bool _isLoading = false;
  bool _isGoogleLoading = false;
  bool _isFacebookLoading = false;

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  // Enhanced Email/Password Login with better error handling
  Future<void> _loginWithEmailPassword() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() {
      _isLoading = true;
    });

    try {
      await _auth.signInWithEmailAndPassword(
        email: _emailController.text.trim(),
        password: _passwordController.text,
      );

      if (mounted) {
        _navigateToGenderPage();
      }
    } on FirebaseAuthException catch (e) {
      String errorMessage;
      switch (e.code) {
        case 'user-not-found':
          errorMessage = 'No account found with this email address.';
          break;
        case 'wrong-password':
          errorMessage = 'Incorrect password. Please try again.';
          break;
        case 'invalid-email':
          errorMessage = 'Please enter a valid email address.';
          break;
        case 'user-disabled':
          errorMessage =
              'This account has been temporarily disabled. Contact support.';
          break;
        case 'too-many-requests':
          errorMessage = 'Too many failed attempts. Please try again later.';
          break;
        case 'invalid-credential':
          errorMessage =
              'Invalid email or password. Please check your credentials.';
          break;
        case 'network-request-failed':
          errorMessage =
              'Network error. Please check your internet connection.';
          break;
        case 'operation-not-allowed':
          errorMessage =
              'Email/password login is not enabled. Contact support.';
          break;
        default:
          errorMessage = e.message ?? 'Login failed. Please try again.';
      }
      _showErrorSnackBar(errorMessage);
    } catch (e) {
      // Handle unexpected errors
      _showErrorSnackBar('An unexpected error occurred. Please try again.');
      debugPrint('Unexpected login error: $e');
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  // Enhanced Google Sign In with comprehensive error handling
  Future<void> _signInWithGoogle() async {
    setState(() {
      _isGoogleLoading = true;
    });

    try {
      // Check if Google Services are available
      final GoogleSignInAccount? googleUser = await _googleSignIn.signIn();

      // User cancelled the sign-in process
      if (googleUser == null) {
        setState(() {
          _isGoogleLoading = false;
        });
        return;
      }

      final GoogleSignInAuthentication googleAuth =
          await googleUser.authentication;

      // Check if we got the necessary tokens
      if (googleAuth.accessToken == null || googleAuth.idToken == null) {
        throw Exception('Failed to get authentication tokens from Google');
      }

      final credential = GoogleAuthProvider.credential(
        accessToken: googleAuth.accessToken,
        idToken: googleAuth.idToken,
      );

      await _auth.signInWithCredential(credential);

      if (mounted) {
        _navigateToGenderPage();
      }
    } on FirebaseAuthException catch (e) {
      String errorMessage;
      switch (e.code) {
        case 'account-exists-with-different-credential':
          errorMessage =
              'This email is already registered with a different sign-in method.';
          break;
        case 'invalid-credential':
          errorMessage = 'Google authentication failed. Please try again.';
          break;
        case 'operation-not-allowed':
          errorMessage = 'Google sign-in is not enabled. Contact support.';
          break;
        case 'user-disabled':
          errorMessage = 'This account has been disabled. Contact support.';
          break;
        case 'user-not-found':
          errorMessage = 'No account found. Please sign up first.';
          break;
        case 'wrong-password':
          errorMessage = 'Authentication failed. Please try again.';
          break;
        case 'network-request-failed':
          errorMessage =
              'Network error. Please check your internet connection.';
          break;
        default:
          errorMessage =
              e.message ?? 'Google sign-in failed. Please try again.';
      }
      _showErrorSnackBar(errorMessage);
    } catch (e) {
      String errorMessage;
      if (e.toString().contains('network_error') ||
          e.toString().contains('NETWORK_ERROR')) {
        errorMessage = 'Network error. Please check your internet connection.';
      } else if (e.toString().contains('sign_in_canceled') ||
          e.toString().contains('SIGN_IN_CANCELLED')) {
        // Don't show error for user cancellation
        return;
      } else if (e.toString().contains('sign_in_failed') ||
          e.toString().contains('SIGN_IN_FAILED')) {
        errorMessage = 'Google sign-in failed. Please try again.';
      } else {
        errorMessage = 'Google sign-in failed. Please try again.';
      }
      _showErrorSnackBar(errorMessage);
      debugPrint('Google Sign-In error: $e');
    } finally {
      if (mounted) {
        setState(() {
          _isGoogleLoading = false;
        });
      }
    }
  }

  // Enhanced Facebook Sign In with comprehensive error handling
  Future<void> _signInWithFacebook() async {
    setState(() {
      _isFacebookLoading = true;
    });

    try {
      final LoginResult result = await FacebookAuth.instance.login(
        permissions: ['email', 'public_profile'],
      );

      if (result.status == LoginStatus.success) {
        if (result.accessToken == null) {
          throw Exception('Failed to get Facebook access token');
        }

        final OAuthCredential credential = FacebookAuthProvider.credential(
          result.accessToken!.tokenString,
        );

        await _auth.signInWithCredential(credential);

        if (mounted) {
          _navigateToGenderPage();
        }
      } else if (result.status == LoginStatus.cancelled) {
        // User cancelled - don't show error
        return;
      } else if (result.status == LoginStatus.failed) {
        String errorMessage = 'Facebook login failed.';
        if (result.message != null) {
          if (result.message!.contains('network')) {
            errorMessage =
                'Network error. Please check your internet connection.';
          } else if (result.message!.contains('USER_CANCELLED')) {
            return; // Don't show error for user cancellation
          } else {
            errorMessage = 'Facebook login failed: ${result.message}';
          }
        }
        throw Exception(errorMessage);
      } else {
        throw Exception(
          'Facebook login returned unexpected status: ${result.status}',
        );
      }
    } on FirebaseAuthException catch (e) {
      String errorMessage;
      switch (e.code) {
        case 'account-exists-with-different-credential':
          errorMessage =
              'This email is already registered with a different sign-in method.';
          break;
        case 'invalid-credential':
          errorMessage = 'Facebook authentication failed. Please try again.';
          break;
        case 'operation-not-allowed':
          errorMessage = 'Facebook sign-in is not enabled. Contact support.';
          break;
        case 'user-disabled':
          errorMessage = 'This account has been disabled. Contact support.';
          break;
        case 'user-not-found':
          errorMessage = 'No account found. Please sign up first.';
          break;
        case 'wrong-password':
          errorMessage = 'Authentication failed. Please try again.';
          break;
        case 'network-request-failed':
          errorMessage =
              'Network error. Please check your internet connection.';
          break;
        default:
          errorMessage =
              e.message ?? 'Facebook sign-in failed. Please try again.';
      }
      _showErrorSnackBar(errorMessage);
    } catch (e) {
      String errorMessage;
      String errorStr = e.toString().toLowerCase();

      if (errorStr.contains('network') || errorStr.contains('connection')) {
        errorMessage = 'Network error. Please check your internet connection.';
      } else if (errorStr.contains('cancelled') ||
          errorStr.contains('cancel')) {
        // Don't show error for user cancellation
        return;
      } else if (errorStr.contains('not installed') ||
          errorStr.contains('unavailable')) {
        errorMessage =
            'Facebook app not available. Please install Facebook app or try another method.';
      } else {
        errorMessage = 'Facebook sign-in failed. Please try again.';
      }

      _showErrorSnackBar(errorMessage);
      debugPrint('Facebook Sign-In error: $e');
    } finally {
      if (mounted) {
        setState(() {
          _isFacebookLoading = false;
        });
      }
    }
  }

  // Helper method to show error messages
  void _showErrorSnackBar(String message) {
    if (!mounted) return;

    ScaffoldMessenger.of(
      context,
    ).clearSnackBars(); // Clear any existing snackbars
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            const Icon(Icons.error_outline, color: Colors.white, size: 20),
            const SizedBox(width: 8),
            Expanded(
              child: Text(message, style: const TextStyle(fontSize: 14)),
            ),
          ],
        ),
        backgroundColor: Colors.red.shade600,
        behavior: SnackBarBehavior.floating,
        margin: const EdgeInsets.all(16),
        duration: const Duration(seconds: 4),
        action: SnackBarAction(
          label: 'Dismiss',
          textColor: Colors.white,
          onPressed: () {
            ScaffoldMessenger.of(context).hideCurrentSnackBar();
          },
        ),
      ),
    );
  }

  // Helper method to show success messages
  void _showSuccessSnackBar(String message) {
    if (!mounted) return;

    ScaffoldMessenger.of(context).clearSnackBars();
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            const Icon(
              Icons.check_circle_outline,
              color: Colors.white,
              size: 20,
            ),
            const SizedBox(width: 8),
            Expanded(
              child: Text(message, style: const TextStyle(fontSize: 14)),
            ),
          ],
        ),
        backgroundColor: Colors.green.shade600,
        behavior: SnackBarBehavior.floating,
        margin: const EdgeInsets.all(16),
        duration: const Duration(seconds: 2),
      ),
    );
  }

  void _navigateToGenderPage() {
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (context) => GenderSelectionPage()),
    );
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;

    return Scaffold(
      body: Stack(
        children: [
          // 🎨 Background Image
          Container(
            decoration: const BoxDecoration(
              image: DecorationImage(
                image: AssetImage('assets/images/bg_login.png'),
                fit: BoxFit.cover,
              ),
            ),
          ),

          // 🌟 Content
          SingleChildScrollView(
            child: Form(
              key: _formKey,
              child: Column(
                children: [
                  const SizedBox(height: 40),
                  Image.asset('assets/images/logo2.png', height: 120),
                  const SizedBox(height: 10),
                  // 🟣 Translucent Full Card
                  Container(
                    margin: const EdgeInsets.symmetric(horizontal: 28),
                    padding: const EdgeInsets.fromLTRB(20, 30, 20, 30),
                    decoration: BoxDecoration(
                      color: Colors.black.withOpacity(0.35),
                      borderRadius: BorderRadius.circular(30),
                    ),
                    child: Column(
                      children: [
                        const Text(
                          "Login",
                          style: TextStyle(
                            fontSize: 28,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                        ),

                        const SizedBox(height: 24),

                        // Email
                        _customField(
                          "Email",
                          controller: _emailController,
                          validator: (value) {
                            if (value == null || value.isEmpty) {
                              return 'Please enter your email';
                            }
                            if (!RegExp(
                              r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$',
                            ).hasMatch(value)) {
                              return 'Please enter a valid email';
                            }
                            return null;
                          },
                        ),

                        const SizedBox(height: 14),

                        // Password
                        _customField(
                          "Password",
                          controller: _passwordController,
                          isPassword: true,
                          validator: (value) {
                            if (value == null || value.isEmpty) {
                              return 'Please enter your password';
                            }
                            if (value.length < 6) {
                              return 'Password must be at least 6 characters';
                            }
                            return null;
                          },
                        ),

                        Align(
                          alignment: Alignment.centerRight,
                          child: TextButton(
                            onPressed: () {
                              // TODO: Implement forgot password
                            },
                            child: const Text(
                              "Forget password?",
                              style: TextStyle(color: Colors.white),
                            ),
                          ),
                        ),

                        const SizedBox(height: 12),

                        // 🔘 Login Button
                        GestureDetector(
                          onTap: _isLoading ? null : _loginWithEmailPassword,
                          child: Container(
                            height: 50,
                            width: double.infinity,
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(25),
                              gradient: _isLoading
                                  ? LinearGradient(
                                      colors: [
                                        const Color(
                                          0xFFDC2953,
                                        ).withOpacity(0.6),
                                        const Color(
                                          0xFFF78E36,
                                        ).withOpacity(0.6),
                                      ],
                                    )
                                  : const LinearGradient(
                                      colors: [
                                        Color(0xFFDC2953),
                                        Color(0xFFF78E36),
                                      ],
                                    ),
                            ),
                            child: Center(
                              child: _isLoading
                                  ? const SizedBox(
                                      width: 20,
                                      height: 20,
                                      child: CircularProgressIndicator(
                                        strokeWidth: 2,
                                        valueColor:
                                            AlwaysStoppedAnimation<Color>(
                                              Colors.white,
                                            ),
                                      ),
                                    )
                                  : const Text(
                                      "Log in",
                                      style: TextStyle(
                                        fontSize: 18,
                                        fontWeight: FontWeight.bold,
                                        color: Colors.white,
                                      ),
                                    ),
                            ),
                          ),
                        ),

                        const SizedBox(height: 20),

                        Row(
                          children: const [
                            Expanded(child: Divider(color: Colors.white70)),
                            Padding(
                              padding: EdgeInsets.symmetric(horizontal: 8),
                              child: Text(
                                "or",
                                style: TextStyle(color: Colors.white),
                              ),
                            ),
                            Expanded(child: Divider(color: Colors.white70)),
                          ],
                        ),

                        const SizedBox(height: 18),

                        _socialLogin(
                          "Continue with Google",
                          'assets/images/google.png',
                          onTap: _isGoogleLoading ? null : _signInWithGoogle,
                          isLoading: _isGoogleLoading,
                        ),
                        const SizedBox(height: 12),
                        _socialLogin(
                          "Continue with Facebook",
                          'assets/images/facebook.png',
                          onTap: _isFacebookLoading
                              ? null
                              : _signInWithFacebook,
                          isLoading: _isFacebookLoading,
                        ),

                        const SizedBox(height: 14),

                        TextButton(
                          onPressed: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => SignupScreen(),
                              ),
                            );
                          },
                          child: const Text(
                            "Sign up",
                            style: TextStyle(
                              color: Colors.white,
                              decoration: TextDecoration.underline,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _customField(
    String hint, {
    bool isPassword = false,
    TextEditingController? controller,
    String? Function(String?)? validator,
  }) {
    return TextFormField(
      controller: controller,
      obscureText: isPassword,
      validator: validator,
      style: const TextStyle(color: Colors.white),
      decoration: InputDecoration(
        hintText: hint,
        hintStyle: const TextStyle(color: Colors.white70),
        filled: true,
        fillColor: Colors.white24,
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 16,
          vertical: 14,
        ),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: BorderSide.none,
        ),
        errorStyle: const TextStyle(color: Colors.redAccent),
      ),
    );
  }

  Widget _socialLogin(
    String text,
    String iconPath, {
    VoidCallback? onTap,
    bool isLoading = false,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        height: 48,
        decoration: BoxDecoration(
          color: isLoading ? Colors.white12 : Colors.white24,
          borderRadius: BorderRadius.circular(14),
        ),
        padding: const EdgeInsets.symmetric(horizontal: 20),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            if (isLoading) ...[
              const SizedBox(
                width: 20,
                height: 20,
                child: CircularProgressIndicator(
                  strokeWidth: 2,
                  valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                ),
              ),
              const SizedBox(width: 12),
            ] else ...[
              Image.asset(iconPath, height: 22),
              const SizedBox(width: 12),
            ],
            Text(
              isLoading ? 'Signing in...' : text,
              style: TextStyle(
                color: isLoading ? Colors.white70 : Colors.white,
                fontSize: 15,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
