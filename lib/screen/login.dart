/*
import 'package:bookwormproject/controller/myprovider.dart';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_progress_hud/flutter_progress_hud.dart';
import 'package:provider/provider.dart';
import '../controller/routes.dart';
import 'newscoringsheet.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _isLoading = false;
  String? _errorMessage;

  @override
  void initState() {
    super.initState();

    // ✅ Auto-redirect if already logged in
    final user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        Navigator.pushReplacementNamed(context, Routes.dashboard);
      });
    }
  }
  @override
  Widget build(BuildContext context) {
    return Consumer<Myprovider>(
      builder: (BuildContext context, Myprovider value, Widget? child) {
        return Scaffold(
          body: ProgressHUD(
            child: Builder(
              // ✅ This context is inside ProgressHUD
              builder: (innerContext) {
                return Scaffold(
                  backgroundColor: const Color(0xFFE8F5E9),
                  body: Center(
                    child: SingleChildScrollView(
                      padding: const EdgeInsets.all(24.0),
                      child: Column(
                        children: [
                          const SizedBox(height: 40),
                          const CircleAvatar(
                            radius: 48,
                            backgroundImage: AssetImage('assets/images/bookwormlogo.jpg'),
                          ),
                          const SizedBox(height: 16),
                          const Text(
                            'Bookworm',
                            style: TextStyle(
                              fontSize: 22,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(height: 32),
                          Card(
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(16),
                            ),
                            elevation: 0,
                            child: ConstrainedBox(
                              constraints: const BoxConstraints(maxWidth: 700),
                              child: Padding(
                                padding: const EdgeInsets.all(24),
                                child: Form(
                                  key: _formKey,
                                  child: Column(
                                    children: [
                                      Text(
                                        'Staff Login',
                                        style: Theme.of(context).textTheme.titleLarge,
                                      ),
                                      const SizedBox(height: 24),
                                      TextFormField(
                                        keyboardType: TextInputType.phone,
                                        controller: _emailController,
                                        decoration: const InputDecoration(
                                          labelText: 'Phone Number',
                                          prefixIcon: Icon(Icons.phone_android_outlined),
                                          border: OutlineInputBorder(),
                                        ),
                                        validator: (value) =>
                                        value!.isEmpty ? 'Enter your phone number' : null,
                                      ),
                                      const SizedBox(height: 16),
                                      TextFormField(
                                        style: const TextStyle(color: Colors.black),
                                        controller: _passwordController,
                                        obscureText: true,
                                        decoration: const InputDecoration(
                                          labelText: 'Password',
                                          prefixIcon: Icon(Icons.lock),
                                          border: OutlineInputBorder(),
                                        ),
                                        validator: (value) =>
                                        value!.isEmpty ? 'Enter your password' : null,
                                      ),
                                      const SizedBox(height: 24),
                                      if (_errorMessage != null)
                                        Text(
                                          _errorMessage!,
                                          style: const TextStyle(color: Colors.red),
                                        ),
                                      const SizedBox(height: 8),
                                      SizedBox(
                                        width: double.infinity,
                                        child: ElevatedButton.icon(
                                          icon: const Icon(Icons.login, color: Colors.white),
                                          onPressed: () async {
                                            if (!_formKey.currentState!.validate()) return;

                                            final hud = ProgressHUD.of(innerContext);
                                            hud?.show();

                                            final phone = _emailController.text.trim();
                                            final password = _passwordController.text.trim();

                                            await value.login(phone, password, context);

                                            hud?.dismiss();
                                          },
                                          style: ElevatedButton.styleFrom(
                                            padding: const EdgeInsets.symmetric(vertical: 17),
                                            shape: RoundedRectangleBorder(
                                              borderRadius: BorderRadius.circular(10),
                                            ),
                                          ),
                                          label: const Text(
                                            'Login',
                                            style: TextStyle(
                                              fontSize: 16,
                                            ),
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                );
              },
            ),
          ),
        );
      },
    );
  }

}
*/



/*
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:provider/provider.dart';
import 'package:flutter_progress_hud/flutter_progress_hud.dart';

import '../controller/myprovider.dart';
import '../controller/routes.dart';
import '../model/usermodel.dart';
import 'signinpage.dart';

class SpacerSignUpPage extends StatefulWidget {
  const SpacerSignUpPage({super.key});

  @override
  State<SpacerSignUpPage> createState() => _SpacerSignUpPageState();
}

class _SpacerSignUpPageState extends State<SpacerSignUpPage> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _phoneController = TextEditingController();

  bool agreeToTerms = false;
  String? selectedDialCode = '+233';
  String? selectedCountryName;

  final List<Map<String, String>> countries = [
    {"name": "Ghana", "code": "GH", "dial_code": "+233"},
    {"name": "Nigeria", "code": "NG", "dial_code": "+234"},
    {"name": "United States", "code": "US", "dial_code": "+1"},
    {"name": "United Kingdom", "code": "GB", "dial_code": "+44"},
  ];

  @override
  Widget build(BuildContext context) {
    final isMobile = MediaQuery.of(context).size.width < 900;

    return SafeArea(
        child: Consumer<Myprovider>(
        builder: (context, value, _) {
      return Scaffold(
          body: ProgressHUD(
          child: Builder(
          builder: (innerContext) {
        return Center(
            child: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: 22, vertical: 30),
    child: SizedBox(
    width: isMobile ? double.infinity : 400,
    child: Card(
    elevation: 2,
    shape: RoundedRectangleBorder(
    borderRadius: BorderRadius.circular(12),
    ),
    child: Padding(
    padding: const EdgeInsets.all(20.0),
    child: Form(
    key: _formKey,
    child: Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
    const Text(
    "Create your account",
    style: TextStyle(
    fontSize: 22,
    fontWeight: FontWeight.bold,
    color: Colors.black87,
    ),
    ),
    const SizedBox(height: 20),
    TextFormField(
    controller: _nameController,
    decoration: const InputDecoration(
    labelText: 'Name',
    border: OutlineInputBorder(),
    ),
    validator: (value) =>
    value == null || value.isEmpty ? 'Enter your name' : null,
    ),
    const SizedBox(height: 12),
    TextFormField(
    controller: _emailController,
    decoration: const InputDecoration(
    labelText: 'Email Address',
    border: OutlineInputBorder(),
    ),
    validator: (value) {
    if (value == null || value.isEmpty) {
    return 'Enter your email';
    } else if (!RegExp(r'^[\w-.]+@([\w-]+\.)+[\w]{2,4}$')
        .hasMatch(value)) {
    return 'Enter a valid email';
    }
    return null;
    },
    ),
    const SizedBox(height: 12),
    TextFormField(
    controller: _passwordController,
    obscureText: true,
    decoration: const InputDecoration(
    labelText: 'Password',
    border: OutlineInputBorder(),
    ),
    validator: (value) => value == null || value.length < 6
    ? 'Password must be at least 6 characters'
        : null,
    ),
    const SizedBox(height: 12),
    DropdownButtonFormField<String>(
    decoration: const InputDecoration(
    labelText: 'Select Country',
    border: OutlineInputBorder(),
    ),
    isExpanded: true,
    value: selectedCountryName,
    items: countries.map((country) {
    return DropdownMenuItem<String>(
    value: country['name'],
    child: Text('${country['name']} (${country['dial_code']})'),
    );
    }).toList(),
    onChanged: (value) {
    if (value != null) {
    final selected = countries
        .firstWhere((country) => country['name'] == value);
    setState(() {
    selectedCountryName = selected['name'];
    selectedDialCode = selected['dial_code'];
    final cleaned = _phoneController.text
        .replaceFirst(RegExp(r'^\+\d+\s*'), '');
    _phoneController.text = '${selectedDialCode!}$cleaned';
    _phoneController.selection =
    TextSelection.fromPosition(
    TextPosition(offset: _phoneController.text.length),
    );
    });
    }
    },
    ),
    const SizedBox(height: 12),
    TextFormField(
    controller: _phoneController,
    keyboardType: TextInputType.phone,
    decoration: const InputDecoration(
    labelText: 'Phone Number',
    border: OutlineInputBorder(),
    ),
    validator: (value) => value == null || value.isEmpty
    ? 'Enter your phone number'
        : null,
    ),
    const SizedBox(height: 10),
    Row(
    children: [
    Checkbox(
    value: agreeToTerms,
    onChanged: (val) =>
    setState(() => agreeToTerms = val ?? false),
    ),
    const Expanded(
    child: Text(
    "By accepting, you agree to our terms and conditions.",
    style: TextStyle(fontSize: 14),
    ),
    ),
    ],
    ),
    const SizedBox(height: 16),
    SizedBox(
    width: double.infinity,
    child: ElevatedButton(
    style: ElevatedButton.styleFrom(
    backgroundColor: Colors.b
*/
import 'package:ksoftsms/controller/myprovider.dart';
import 'package:ksoftsms/controller/routes.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_progress_hud/flutter_progress_hud.dart';
import 'package:provider/provider.dart';
import 'package:go_router/go_router.dart';
import '../controller/loginprovider.dart';
import 'forgot_password.dart';


class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  bool _obscurePassword = true;
  @override
  Widget build(BuildContext context) {
    double w =  MediaQuery.of(context).size.width;
    return ProgressHUD(
      child: Consumer<Myprovider>(
        builder: (BuildContext context, Myprovider value, Widget? child) {
          final colors = Theme.of(context).colorScheme;
          return SafeArea(
            child: Scaffold(
              body: SingleChildScrollView(
                child: SizedBox(
                  height: MediaQuery.of(context).size.height,
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Container(
                        constraints: BoxConstraints(maxWidth:
                          w< 600 ?  w * 0.9
                          : w* 0.58,
                        ),
                         child: Padding(
                           padding: EdgeInsets.fromLTRB
                             (w < 600 ? 30.0 : w*0.09,
                               w < 600 ? 10.0 : 50.0,
                               w < 600 ? 30.0 : w*0.09,
                               w < 600 ? 30.0 : w*0.07
                           ),
                          child: Form(
                            key: _formKey,
                            child: Column(
                              mainAxisSize: MainAxisSize.min,
                              crossAxisAlignment: CrossAxisAlignment.center,
                              children: [
                                const CircleAvatar(
                                  radius: 48,
                                  backgroundImage: AssetImage('assets/images/bookwormlogo.jpg'),
                                ),
                                const SizedBox(height: 15),
                                const Text(
                                  'KMIS',
                                  style: TextStyle(
                                    fontSize: 22,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                const SizedBox(height: 15),
                                TextFormField(
                                  keyboardType: TextInputType.phone,
                                  controller: _emailController,
                                  decoration: const InputDecoration(
                                    labelText: 'Phone Number',
                                    prefixIcon: Icon(Icons.phone_android_outlined),
                                    border: OutlineInputBorder(),
                                  ),
                                  validator: (value) =>
                                  value!.isEmpty ? 'Enter your phone number' : null,
                                ),
                                const SizedBox(height: 20),
                                TextFormField(
                                  controller: _passwordController,
                                  obscureText: _obscurePassword,
                                  decoration: InputDecoration(
                                    labelText: 'Password',
                                    border: const OutlineInputBorder(),
                                    suffixIcon: IconButton(
                                      icon: Icon(
                                        _obscurePassword ? Icons.visibility_off : Icons.visibility,
                                      ),
                                      onPressed: () {
                                        setState(() {
                                          _obscurePassword = !_obscurePassword;
                                        });
                                      },
                                    ),
                                  ),
                                  validator: (value) {
                                    if (value == null || value.isEmpty) {
                                      return 'Password is required';
                                    }
                                    if (value.length < 6) {
                                      return 'Password must be at least 6 characters';
                                    }
                                    return null;
                                  },
                                ),
                                const SizedBox(height: 15),
                                Align(
                                  alignment: Alignment.centerRight,
                                  child: InkWell(
                                    onTap: () {
                                      Navigator.pushNamed(context, Routes.forgotpass);
                                    },
                                    child: const Text(
                                      'Forgot password?',
                                      style: TextStyle(fontSize: 14),
                                    ),
                                  ),
                                ),
                                const SizedBox(height: 10),
                                InkWell(
                                  onTap: () async {
                                    if (_formKey.currentState!.validate()) {
                                      context.go(Routes.dashboard);
                                    }
                                  },
                                  child: Container(
                                    width: double.infinity,
                                    padding: const EdgeInsets.all(14),
                                    decoration: BoxDecoration(
                                      color: colors.primary,
                                      borderRadius: BorderRadius.circular(8),
                                    ),
                                    child: Center(
                                      child: Text(
                                        'Sign In',
                                        style: TextStyle(color: colors.onPrimary, fontWeight: FontWeight.bold),
                                      ),
                                    ),
                                  ),
                                ),
                              SizedBox(height: 4,),

                              ],
                            ),
                          ),
                        ),
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
