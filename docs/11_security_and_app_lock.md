# ICHITO -- Security & App Lock

**Document**: 11 of 14
**Covers**: PIN setup, PIN verification, biometric authentication, auto-lock mechanism, security code recovery, data protection, lockout policies

---

## 1. Security Philosophy

ICHITO stores sensitive business data (customer contacts, revenue, business volume). Therefore, it implements an optional but robust application lock layer to protect this data if the device is shared or lost.

The security system is completely internal to the app (does not rely on server authentication) and works 100% offline.

---

## 2. PIN Setup Flow

When a user enables "App Lock" in Settings, they must complete the setup flow.

### 2.1 Screen Layout

```
┌─────────────────────────────────────────────────────┐
│  [Back]                                              │
├─────────────────────────────────────────────────────┤
│                                                      │
│           [LockIcon - 64dp, accent color]            │
│                                                      │
│           Create App PIN                             │
│           (Enter a 4-digit PIN to secure ICHITO)     │
│                                                      │
│                 [○] [○] [○] [○]                      │
│                                                      │
│                                                      │
│           [ 1 ]       [ 2 ]       [ 3 ]              │
│                                                      │
│           [ 4 ]       [ 5 ]       [ 6 ]              │
│                                                      │
│           [ 7 ]       [ 8 ]       [ 9 ]              │
│                                                      │
│           [Biometric] [ 0 ]       [<X]               │
│                                                      │
└─────────────────────────────────────────────────────┘
```

### 2.2 Setup Steps

1. **Enter PIN**: User enters 4 digits
2. **Confirm PIN**: "Confirm your PIN" - User enters same 4 digits
   - If mismatch: "PINs do not match. Try again." and return to step 1
3. **Security Code**: "Set a security code for PIN recovery"
   - Text input for a memorable word/phrase (e.g., mother's maiden name, favorite pet)
   - Minimum 4 characters
4. **Biometric Prompt**: "Enable Fingerprint/Face Unlock?" (if device supports it)
   - [Skip] [Enable]
5. **Success**: App Lock enabled. Return to Settings.

### 2.3 Cryptography

- **PIN Storage**: The PIN is never stored in plain text.
- It is hashed using SHA-256 with a unique device salt.
- The hash is stored in `flutter_secure_storage`.
- The Security Code is also hashed and stored securely.

```dart
// SecurityService snippet
Future<void> setPIN(String pin) async {
  final salt = await _getOrGenerateSalt();
  final bytes = utf8.encode(pin + salt);
  final digest = sha256.convert(bytes);
  
  await _secureStorage.write(key: 'pin_hash', value: digest.toString());
  await _secureStorage.write(key: 'app_lock_enabled', value: 'true');
}
```

---

## 3. PIN Lock Screen (Verification)

When the app is locked, this is the only screen accessible.

### 3.1 Screen Layout

```
┌─────────────────────────────────────────────────────┐
│                                                      │
│                                                      │
│                                                      │
│           [Logo - 80dp, accent circle]               │
│                                                      │
│           Enter PIN to unlock ICHITO                 │
│                                                      │
│                 [●] [●] [○] [○]                      │
│                                                      │
│           [Forgot PIN?]                              │
│                                                      │
│                                                      │
│           [ 1 ]       [ 2 ]       [ 3 ]              │
│                                                      │
│           [ 4 ]       [ 5 ]       [ 6 ]              │
│                                                      │
│           [ 7 ]       [ 8 ]       [ 9 ]              │
│                                                      │
│           [Fingerprint][ 0 ]      [<X]               │
│                                                      │
└─────────────────────────────────────────────────────┘
```

### 3.2 Verification Logic

```dart
Future<bool> verifyPIN(String enteredPin) async {
  final storedHash = await _secureStorage.read(key: 'pin_hash');
  if (storedHash == null) return false;
  
  final salt = await _getOrGenerateSalt();
  final bytes = utf8.encode(enteredPin + salt);
  final digest = sha256.convert(bytes);
  
  final isValid = digest.toString() == storedHash;
  
  if (isValid) {
    _resetFailedAttempts();
    return true;
  } else {
    await _incrementFailedAttempts();
    return false;
  }
}
```

### 3.3 Lockout Policy

To prevent brute force attacks:
- **3 failed attempts**: 1 minute timeout (keypad disabled)
- **5 failed attempts**: 5 minute timeout
- **10 failed attempts**: 30 minute timeout
- **15 failed attempts**: App data wiped (Factory Reset)
  - *Must display warning at 10 and 14 attempts*

```
┌─────────────────────────────────────────────────────┐
│  Too many failed attempts                            │
│  Try again in 04:59                                  │
│                                                      │
│  Warning: App data will be erased after 15           │
│  consecutive failed attempts (5 remaining).          │
└─────────────────────────────────────────────────────┘
```

---

## 4. Biometric Authentication

ICHITO uses the `local_auth` package to leverage Android's BiometricPrompt API.

### 4.1 Flow

1. If App Lock is ON and Biometrics is ON, trigger biometric prompt immediately upon reaching the Lock Screen.
2. The system fingerprint/face dialog appears: "Authenticate to unlock ICHITO".
3. On success: Unlock immediately.
4. On cancel/fail: Fall back to PIN entry. The biometric icon remains on the keypad to retry.

### 4.2 Implementation

```dart
Future<bool> authenticateWithBiometric() async {
  try {
    final canAuthenticateWithBiometrics = await _localAuth.canCheckBiometrics;
    final canAuthenticate = canAuthenticateWithBiometrics || await _localAuth.isDeviceSupported();
    
    if (!canAuthenticate) return false;
    
    final didAuthenticate = await _localAuth.authenticate(
      localizedReason: 'Please authenticate to unlock ICHITO',
      options: const AuthenticationOptions(
        stickyAuth: true,
        biometricOnly: false, // Allows system PIN fallback if biometrics fail
      ),
    );
    
    return didAuthenticate;
  } catch (e) {
    // Log error
    return false;
  }
}
```

---

## 5. Auto-Lock Mechanism

### 5.1 Lifecycle Tracking

The app tracks its lifecycle state using `WidgetsBindingObserver`.

```dart
void didChangeAppLifecycleState(AppLifecycleState state) {
  if (state == AppLifecycleState.paused) {
    // App moved to background
    _lastActiveTime = DateTime.now();
  } else if (state == AppLifecycleState.resumed) {
    // App moved to foreground
    _checkAutoLock();
  }
}

void _checkAutoLock() {
  if (!_isAppLockEnabled) return;
  if (_lastActiveTime == null) return;
  
  final now = DateTime.now();
  final difference = now.difference(_lastActiveTime!);
  
  if (difference.inMinutes >= _autoLockMinutes) {
    // Lock the app
    _isLocked = true;
    notifyListeners();
    // Navigator will reactively push PIN screen (see Routing)
  }
}
```

### 5.2 Auto-Lock Timeouts

Users can configure the timeout in Settings > Security:
- Immediately (0 minutes)
- 1 minute
- 5 minutes (default)
- 15 minutes
- 30 minutes

---

## 6. PIN Recovery (Security Code)

If a user forgets their PIN, they can use their Security Code to reset it.

### 6.1 Recovery Flow

1. Tap "Forgot PIN?" on Lock Screen
2. Dialog: "Enter your Security Code"
3. User enters the text code (case-insensitive)
4. If correct:
   - Unlock app
   - Navigate immediately to PIN Setup to create a new PIN
5. If incorrect:
   - "Incorrect Security Code" (adds to failed attempts counter)

### 6.2 Implementation

```dart
Future<bool> verifySecurityCode(String enteredCode) async {
  final storedHash = await _secureStorage.read(key: 'security_code_hash');
  if (storedHash == null) return false;
  
  // Normalize code: trim, lowercase
  final normalized = enteredCode.trim().toLowerCase();
  
  final salt = await _getOrGenerateSalt();
  final bytes = utf8.encode(normalized + salt);
  final digest = sha256.convert(bytes);
  
  return digest.toString() == storedHash;
}
```

---

## 7. App Lock Routing Guard

The app lock mechanism intercepts all navigation when locked.
This is implemented at the root `MaterialApp` level.

```dart
// main.dart (simplified)
MaterialApp(
  // Determine initial route based on lock state
  initialRoute: Provider.of<AppStateProvider>(context, listen: false).isLocked
      ? Routes.pinLock
      : Routes.splash,
      
  onGenerateRoute: (settings) {
    final isLocked = Provider.of<AppStateProvider>(context, listen: false).isLocked;
    
    // GUARD: If locked and trying to go anywhere except lock screen, redirect to lock
    if (isLocked && settings.name != Routes.pinLock) {
      return RouteGenerator.generateRoute(
        const RouteSettings(name: Routes.pinLock)
      );
    }
    
    return RouteGenerator.generateRoute(settings);
  },
)
```

---

## 8. Data Privacy Controls

Beyond just locking the app, ICHITO offers privacy controls for sensitive data:

| Setting | Effect |
|---------|--------|
| Hide Balances on Home | Replaces financial figures on the dashboard with `***` until tapped. Useful when showing the screen to a customer. |
| Require Auth for Export | Trigger biometric/PIN prompt before exporting data to CSV/JSON. |
| Prevent Screenshots | Android: Sets `WindowManager.LayoutParams.FLAG_SECURE`. Screen appears black in app switcher and screenshots are blocked. |

These are configurable in Settings > Security.

---

*This is Document 11 of 14 in the ICHITO Blueprint Documentation Set.*
*See: [Master Index](00_ichito_master_index.md) for the complete document map.*
