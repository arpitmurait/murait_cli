import 'dart:io';
import 'firebase_service_handler.dart';

/// Handles Firebase Auth setup with social sign-in
class AuthHandler implements FirebaseServiceHandler {
  @override
  String get serviceType => 'auth';

  @override
  Future<void> setup() async {
    await _updateAuthRepository();
  }

  @override
  Future<bool> isConfigured() async {
    final authRepoFile = File('lib/data/repository/auth_repository.dart');
    if (!await authRepoFile.exists()) return false;
    
    final content = await authRepoFile.readAsString();
    return content.contains('signInWithGoogle') &&
           content.contains('signInWithApple');
  }

  Future<void> _updateAuthRepository() async {
    final authRepoFile = File('lib/data/repository/auth_repository.dart');
    if (!await authRepoFile.exists()) {
      print('⚠️ Warning: lib/data/repository/auth_repository.dart not found. Could not add social sign-in methods.');
      return;
    }
    print('   -> Updating AuthRepository with Google & Apple Sign-In methods...');

    var lines = await authRepoFile.readAsLines();
    bool contentModified = false;

    // Add imports
    const firebaseAuthImport = "import 'package:firebase_auth/firebase_auth.dart';";
    const googleSignInImport = "import 'package:google_sign_in/google_sign_in.dart';";
    const appleSignInImport = "import 'package:sign_in_with_apple/sign_in_with_apple.dart';";

    int lastImportIndex = lines.lastIndexWhere((line) => line.trim().startsWith('import '));
    if (lastImportIndex == -1) lastImportIndex = 0;

    if (!lines.any((line) => line.contains('firebase_auth.dart'))) {
      lines.insert(lastImportIndex + 1, firebaseAuthImport);
      contentModified = true;
    }
    if (!lines.any((line) => line.contains('google_sign_in.dart'))) {
      lines.insert(lastImportIndex + 2, googleSignInImport);
      contentModified = true;
    }
    if (!lines.any((line) => line.contains('sign_in_with_apple.dart'))) {
      lines.insert(lastImportIndex + 3, appleSignInImport);
      contentModified = true;
    }

    // Update abstract class
    final abstractClassEnd = lines.indexWhere(
      (line) => line.trim().startsWith('}'),
      lines.indexWhere((l) => l.contains('abstract class AuthRepository')),
    );
    if (abstractClassEnd != -1 && !lines.any((line) => line.contains('signInWithGoogle'))) {
      lines.insert(abstractClassEnd, '  Future<UserModel?> signInWithGoogle();');
      lines.insert(abstractClassEnd + 1, '  Future<UserModel?> signInWithApple();');
      contentModified = true;
    }

    // Update implementation class
    final implClassStart = lines.indexWhere((line) => line.contains('class AuthRepositoryImpl'));
    if (implClassStart != -1) {
      if (!lines.any((line) => line.contains('_firebaseAuth'))) {
        lines.insert(implClassStart + 1, '  final FirebaseAuth _firebaseAuth = FirebaseAuth.instance;');
        contentModified = true;
      }

      final implClassEnd = lines.indexWhere((line) => line.startsWith('}'), implClassStart);
      if (implClassEnd != -1 && !lines.any((line) => line.contains('Future<UserModel?> signInWithGoogle() '))) {
        final socialLoginMethods = _getSocialLoginMethods();
        lines.insert(implClassEnd, socialLoginMethods);
        contentModified = true;
      }
    }

    _printSocialAuthInstructions();
    if (contentModified) {
      await authRepoFile.writeAsString(lines.join('\n'));
      print('   -> Updated lib/data/repository/auth_repository.dart successfully.');
    } else {
      print('   -> AuthRepository already contains social sign-in methods.');
    }
  }

  String _getSocialLoginMethods() {
    return '''

  @override
  Future<UserModel?> signInWithGoogle() async {
    try {
      final GoogleSignIn signIn = GoogleSignIn.instance;
      await signIn.initialize(clientId: Platform.isAndroid ? AppValues.clientIdKey : AppValues.iOSClientIdKey);
      final googleUser = await signIn.authenticate();

      final GoogleSignInAuthentication googleAuth = await googleUser.authentication;
      final AuthCredential credential = GoogleAuthProvider.credential(
        accessToken: googleAuth.accessToken,
        idToken: googleAuth.idToken,
      );

      final UserCredential userCredential = await _firebaseAuth.signInWithCredential(credential);
      final User? firebaseUser = userCredential.user;

      if (firebaseUser != null) {
        return _socialLoginBackend(
          provider: 'google',
          providerId: firebaseUser.uid,
          email: firebaseUser.email ?? '',
          name: firebaseUser.displayName ?? '',
        );
      }
    } catch (e) {
      logger.e("Google Sign-In failed: \$e");
      rethrow;
    }
    return null;
  }

  @override
  Future<UserModel?> signInWithApple() async {
    try {
      final AuthorizationCredentialAppleID appleCredential = await SignInWithApple.getAppleIDCredential(
        scopes: [
          AppleIDAuthorizationScopes.email,
          AppleIDAuthorizationScopes.fullName,
        ],
      );

      final OAuthCredential credential = OAuthProvider("apple.com").credential(
        idToken: String.fromCharCodes(appleCredential.identityToken!),
        accessToken: String.fromCharCodes(appleCredential.authorizationCode!),
      );

      final UserCredential userCredential = await _firebaseAuth.signInWithCredential(credential);
      final User? firebaseUser = userCredential.user;
      
      if (firebaseUser != null) {
        return _socialLoginBackend(
          provider: 'apple',
          providerId: firebaseUser.uid,
          email: firebaseUser.email ?? appleCredential.email ?? '',
          name: firebaseUser.displayName ?? '\${appleCredential.givenName} \${appleCredential.familyName}',
        );
      }
    } catch (e) {
      logger.e("Apple Sign-In failed: \$e");
      rethrow;
    }
    return null;
  }
  
  /// A helper method to handle the backend call after a successful social sign-in.
  Future<UserModel> _socialLoginBackend({
    required String provider,
    required String providerId,
    required String email,
    required String name,
  }) async {
    try {
      final response = await apiService.post<UserResponseModel>(
        endpoint: '/api/social-login',
        data: {
          'provider': provider,
          'provider_id': providerId,
          'email': email,
          'name': name,
        },
        fromJson: (json) => UserResponseModel.fromJson(json),
      );
      _persistUserData(response.token, response.data);
      return response.data;
    } catch (e) {
      rethrow;
    }
  }
''';
  }

  void _printSocialAuthInstructions() {
    print('\n');
    print('--------------------------------------------------');
    print('🚀 ACTION REQUIRED: Platform Setup for Social Sign-In');
    print('--------------------------------------------------');
    print('\n➡️ For Google Sign-In (Android):');
    print('   1. Go to your Firebase Console.');
    print('   2. Navigate to Authentication -> Sign-in method -> Google and enable it.');
    print('   3. In Project Settings, add your Android app\'s SHA-1 fingerprint.');
    print('      - You can get your SHA-1 key by running `cd android && ./gradlew signingReport`');
    print('   4. Download the updated `google-services.json` and place it in `android/app/`.');
    print('\n➡️ For Apple Sign-In (iOS):');
    print('   1. Open your project in Xcode (`open ios/Runner.xcworkspace`).');
    print('   2. Go to the "Signing & Capabilities" tab for the "Runner" target.');
    print('   3. Click "+ Capability" and add "Sign In with Apple".');
    print('   4. In your Firebase Console, enable Apple as a Sign-in method.');
    print('--------------------------------------------------');
  }
}

