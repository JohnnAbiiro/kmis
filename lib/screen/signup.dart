import 'package:carousel_slider/carousel_slider.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:ksoftsms/controller/dbmodels/staffmodel.dart';
import 'package:ksoftsms/controller/myprovider.dart';
import 'package:provider/provider.dart';
import 'package:flutter_progress_hud/flutter_progress_hud.dart';

import '../controller/routes.dart';

class SpacerSignUpPage extends StatefulWidget {
  const SpacerSignUpPage({super.key});

  @override
  State<SpacerSignUpPage> createState() => _SpacerSignUpPageState();
}

class _SpacerSignUpPageState extends State<SpacerSignUpPage> {
  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final provider = Provider.of<Myprovider>(context, listen: false);
      provider.getdata();
      if(provider.auth.currentUser != null){
        context.go(Routes.dashboard);
      }

    });
  }

  // Helper for package card
  Widget _buildPackageCard({
    required String title,
    required String price,
    required List<String> features,
    VoidCallback? onSelect,
    Color? headerColor,
  }) {
    return Container(
      width: 220,
      margin: const EdgeInsets.symmetric(vertical: 12, horizontal: 10),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: Colors.grey.shade200, width: 1.2),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.13),
            blurRadius: 12,
            offset: Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Colored header
          Container(
            height: 44,
            decoration: BoxDecoration(
              color: headerColor ?? Colors.blue.shade700,
              borderRadius: const BorderRadius.only(
                topLeft: Radius.circular(18),
                topRight: Radius.circular(18),
              ),
            ),
            child: Center(
              child: Text(
                title,
                style: const TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                  fontSize: 18,
                  letterSpacing: 0.5,
                ),
              ),
            ),
          ),
          const SizedBox(height: 18),
          // Price
          Center(
            child: Text(
              price,
              style: const TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 28,
                color: Color(0xFF00244A),
              ),
            ),
          ),
          const SizedBox(height: 10),
          // Features
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: features
                  .map(
                    (f) => Padding(
                  padding: const EdgeInsets.only(bottom: 7.0),
                  child: Row(
                    children: [
                      const Icon(
                        Icons.check_circle,
                        size: 18,
                        color: Colors.green,
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          f,
                          style: const TextStyle(fontSize: 14),
                        ),
                      ),
                    ],
                  ),
                ),
              )
                  .toList(),
            ),
          ),
          const SizedBox(height: 18),
          // Select button
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16.0),
            child: ElevatedButton(
              onPressed: onSelect ?? () {},
              style: ElevatedButton.styleFrom(
                backgroundColor: headerColor ?? Colors.blue.shade700,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
                padding: const EdgeInsets.symmetric(vertical: 10),
              ),
              child: const Text(
                'Select',
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 15),
              ),
            ),
          ),
          const SizedBox(height: 12),
        ],
      ),
    );
  }

  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _schoolController = TextEditingController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  bool agreeToTerms = false;
  String? selectedDialCode = '+233';
  String? selectedCountryCode;
  String? selectedCountryName;

  final TextEditingController _phoneController = TextEditingController();
  final List<Map<String, String>> countries = [
    {"name": "Afghanistan", "code": "AF", "dial_code": "+93"},
    {"name": "Albania", "code": "AL", "dial_code": "+355"},
    {"name": "Algeria", "code": "DZ", "dial_code": "+213"},
    {"name": "Andorra", "code": "AD", "dial_code": "+376"},
    {"name": "Angola", "code": "AO", "dial_code": "+244"},
    {"name": "Argentina", "code": "AR", "dial_code": "+54"},
    {"name": "Australia", "code": "AU", "dial_code": "+61"},
    {"name": "Austria", "code": "AT", "dial_code": "+43"},
    {"name": "Bangladesh", "code": "BD", "dial_code": "+880"},
    {"name": "Belgium", "code": "BE", "dial_code": "+32"},
    {"name": "Brazil", "code": "BR", "dial_code": "+55"},
    {"name": "Cameroon", "code": "CM", "dial_code": "+237"},
    {"name": "Canada", "code": "CA", "dial_code": "+1"},
    {"name": "China", "code": "CN", "dial_code": "+86"},
    {"name": "Egypt", "code": "EG", "dial_code": "+20"},
    {"name": "France", "code": "FR", "dial_code": "+33"},
    {"name": "Germany", "code": "DE", "dial_code": "+49"},
    {"name": "Ghana", "code": "GH", "dial_code": "+233"},
    {"name": "India", "code": "IN", "dial_code": "+91"},
    {"name": "Kenya", "code": "KE", "dial_code": "+254"},
    {"name": "Nigeria", "code": "NG", "dial_code": "+234"},
    {"name": "South Africa", "code": "ZA", "dial_code": "+27"},
    {"name": "United Kingdom", "code": "GB", "dial_code": "+44"},
    {"name": "United States", "code": "US", "dial_code": "+1"},
    // Add more as needed...
  ];

  final List<String> carouselImages = [
    'assets/images/undraw_access-account_aydp.png',
    'assets/images/undraw_certificate_cqps.png',
    'assets/images/undraw_notebook_8ihb.png',
    'assets/images/undraw_product-explainer_b7ft.png',
    'assets/images/undraw_two-factor-authentication_8tds.png',
    'assets/images/undraw_book-lover_m9n3.png',
  ];

  String? selectedPaymentMethod;


  @override
  Widget build(BuildContext context) {
    final isMobile = MediaQuery.of(context).size.width < 900;

    Widget leftPanel(BuildContext context) {
      return SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.only(left: 8.0, top: 8.0, bottom: 8.0),
          child: Container(
            width: double.infinity,
            child: Column(
              children: [
                // Both intro and carousel in the same width container
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.symmetric(
                    vertical: 16,
                    horizontal: 12,
                  ),
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.85),
                    borderRadius: BorderRadius.circular(12),
                    // boxShadow: [
                    //   BoxShadow(
                    //     color: Colors.grey.withOpacity(0.1),
                    //     blurRadius: 8,
                    //     offset: Offset(0, 2),
                    //   ),
                    //],
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: const [
                      Text(
                        'Welcome to the Election System',
                        style: TextStyle(
                          fontSize: 22,
                          fontWeight: FontWeight.bold,
                          color: Color(0xFF00244A),
                        ),
                      ),
                      SizedBox(height: 8),
                      Text(
                        'Our digital election system provides a secure, transparent, and user-friendly platform for casting votes and monitoring results. Join us in shaping the future of democracy with technology-driven solutions.',
                        style: TextStyle(fontSize: 15, color: Colors.black87),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 18),
                SizedBox(
                  width: double.infinity,
                  child: CarouselSlider(
                    options: CarouselOptions(
                      height: isMobile
                          ? MediaQuery.of(context).size.height * 0.38
                          : 380,
                      autoPlay: true,
                      enlargeCenterPage: true,
                      aspectRatio: 16 / 7,
                      viewportFraction: 0.98,
                    ),
                    items: carouselImages.map((imgPath) {
                      return Builder(
                        builder: (BuildContext context) {
                          return Container(
                            width: double.infinity,
                            margin: const EdgeInsets.symmetric(horizontal: 0),
                            decoration: BoxDecoration(
                              //borderRadius: BorderRadius.circular(18),
                              // boxShadow: [
                              //   BoxShadow(
                              //     color: Colors.grey.withOpacity(0.2),
                              //     blurRadius: 10,
                              //     offset: Offset(0, 2),
                              //   ),
                              // ],
                              image: DecorationImage(
                                image: AssetImage(imgPath),
                                fit: BoxFit.cover,
                              ),
                            ),
                          );
                        },
                      );
                    }).toList(),
                  ),
                ),
                const SizedBox(height: 18),
                // Pricing Packages Scrollable Cards
                SizedBox(
                  width: double.infinity,
                  height: 320,
                  child: ScrollConfiguration(
                    behavior: ScrollConfiguration.of(
                      context,
                    ).copyWith(scrollbars: true),
                    child: ListView(
                      scrollDirection: Axis.horizontal,
                      physics: const BouncingScrollPhysics(),
                      children: [
                        _buildPackageCard(
                          title: 'Basic',
                          price: 'Free',
                          features: [
                            'Vote in elections',
                            'View results',
                            'Basic support',
                          ],
                          headerColor: Colors.blue.shade700,
                        ),
                        _buildPackageCard(
                          title: 'Premium',
                          price: 'GHS 20',
                          features: [
                            'All Basic features',
                            'Priority support',
                            'Detailed analytics',
                          ],
                          headerColor: Colors.orange.shade700,
                        ),
                        _buildPackageCard(
                          title: 'Organization',
                          price: 'GHS 100',
                          features: [
                            'Manage elections',
                            'Custom branding',
                            'Advanced analytics',
                          ],
                          headerColor: Colors.green.shade700,
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      );
    }

    Widget mobileLeftPanel(BuildContext context) {
      return Consumer<Myprovider>(
        builder: (BuildContext context,  value, Widget? child) {
          // final value = ref.watch(formsProvider);
          return  Padding(
            padding: const EdgeInsets.only(left: 8.0, top: 8.0, bottom: 8.0),
            child: Container(
              width: double.infinity,
              child: Column(
                children: [
                  // Both intro and carousel in the same width container
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.symmetric(
                      vertical: 12,
                      horizontal: 8,
                    ),
                    decoration: BoxDecoration(
                      //color: Colors.white.withOpacity(0.85),
                      // borderRadius: BorderRadius.circular(10),
                      // boxShadow: [
                      //   BoxShadow(
                      //     color: Colors.grey.withOpacity(0.1),
                      //     blurRadius: 6,
                      //     offset: Offset(0, 2),
                      //   ),
                      // ],
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: const [
                        Text(
                          'Welcome to the Election System',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: Color(0xFF00244A),
                          ),
                        ),
                        SizedBox(height: 6),
                        Text(
                          'A secure, transparent, and user-friendly platform for digital voting and results.',
                          style: TextStyle(fontSize: 13, color: Colors.black87),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 10),
                  Container(
                    width: double.infinity,
                    child: CarouselSlider(
                      options: CarouselOptions(
                        height: isMobile
                            ? MediaQuery.of(context).size.height * 0.28
                            : 220,
                        autoPlay: true,
                        enlargeCenterPage: true,
                        aspectRatio: 16 / 7,
                        viewportFraction: 0.98,
                      ),
                      items: carouselImages.map((imgPath) {
                        return Builder(
                          builder: (BuildContext context) {
                            return Container(
                              width: double.infinity,
                              margin: const EdgeInsets.symmetric(horizontal: 0),
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(16),
                                boxShadow: [
                                  BoxShadow(
                                    color: Colors.grey.withOpacity(0.15),
                                    blurRadius: 8,
                                    offset: Offset(0, 2),
                                  ),
                                ],
                                image: DecorationImage(
                                  image: AssetImage(imgPath),
                                  fit: BoxFit.cover,
                                ),
                              ),
                            );
                          },
                        );
                      }).toList(),
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      );
    }

    Widget rightPanel(BuildContext context) {
      return Padding(
        padding: const EdgeInsets.only(
          right: 8.0,
          top: 8.0,
          bottom: 8.0,
          left: 5.0,
        ),
        child: Container(
          decoration: BoxDecoration(color: const Color(0xFFffffff)),
          child: LayoutBuilder(
            builder: (context, constraints) {
              return ProgressHUD(
                child: SingleChildScrollView(
                  physics: const BouncingScrollPhysics(),
                  child: ConstrainedBox(
                    constraints: BoxConstraints(minHeight: constraints.maxHeight),
                    child: Padding(
                      padding: isMobile
                          ? const EdgeInsets.symmetric(
                        horizontal: 22,
                        vertical: 0,
                      )
                          : const EdgeInsets.symmetric(
                        horizontal: 32,
                        vertical: 60,
                      ),
                      child: Form(
                        key: _formKey,
                        child: Consumer<Myprovider>(
                          builder: (BuildContext context, value, Widget? child) {
                            return Column(
                              children: [
                                Visibility(
                                  visible:value.regform,
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      // Payment Method
                                      const SizedBox(height: 6),
                                      const Text(
                                        'Create your account',
                                        style: TextStyle(
                                          fontSize: 24,
                                          fontWeight: FontWeight.bold,
                                          color: Colors.black87,
                                        ),
                                      ),
                                      const SizedBox(height: 10),
                                      TextFormField(
                                        controller: _nameController,
                                        decoration: const InputDecoration(
                                          labelText: 'Name',
                                          //floatingLabelStyle: TextStyle(color: Colors.orange),
                                          border: UnderlineInputBorder(),
                                        ),

                                        validator: (value) =>
                                        value == null || value.isEmpty
                                            ? 'Please enter your name'
                                            : null,
                                      ),
                                      const SizedBox(height: 10),
                                      TextFormField(
                                        controller: _schoolController,
                                        decoration: const InputDecoration(
                                          labelText: 'School Name',
                                          //floatingLabelStyle: TextStyle(color: Colors.orange),
                                          border: UnderlineInputBorder(),
                                        ),

                                        validator: (value) =>
                                        value == null || value.isEmpty
                                            ? 'Please enter school Name'
                                            : null,
                                      ),
                                      const SizedBox(height: 8),
                                      TextFormField(
                                        controller: _emailController,
                                        decoration: const InputDecoration(
                                          labelText: 'E-mail Address',
                                          border: UnderlineInputBorder(),
                                        ),
                                        validator: (value) {
                                          if (value == null || value.isEmpty) {
                                            return 'Please enter your email';
                                          } else if (!RegExp(
                                            r'^[\w-.]+@([\w-]+\.)+[\w]{2,4}',
                                          ).hasMatch(value)) {
                                            return 'Enter a valid email';
                                          }
                                          return null;
                                        },
                                      ),
                                      const SizedBox(height: 8),
                                      TextFormField(
                                        controller: _passwordController,
                                        obscureText: true,
                                        decoration: const InputDecoration(
                                          labelText: 'Password',
                                          border: UnderlineInputBorder(),
                                        ),
                                        validator: (value) =>
                                        value == null || value.length < 6
                                            ? 'Password must be at least 6 characters'
                                            : null,
                                      ),
                                      const SizedBox(height: 8),
                                      DropdownButtonFormField<String>(
                                        decoration: const InputDecoration(
                                          labelText: 'Select Country',
                                          border: UnderlineInputBorder(),
                                        ),
                                        isExpanded: true,
                                        value: selectedCountryName,
                                        items: countries.map((country) {
                                          return DropdownMenuItem<String>(
                                            value: country['name'],
                                            child: Text(
                                              '${country['name']} (${country['dial_code']})',
                                            ),
                                          );
                                        }).toList(),
                                        onChanged: (value) {
                                          if (value != null) {
                                            final selected = countries.firstWhere(
                                                  (country) => country['name'] == value,
                                            );
                                            setState(() {
                                              selectedCountryName = selected['name'];
                                              selectedDialCode = selected['dial_code'];

                                              final cleanedNumber = _phoneController.text
                                                  .replaceFirst(RegExp(r'^\+\d+\s*'), '');
                                              _phoneController.text =
                                              '${selectedDialCode!}$cleanedNumber';

                                              _phoneController
                                                  .selection = TextSelection.fromPosition(
                                                TextPosition(
                                                  offset: _phoneController.text.length,
                                                ),
                                              );
                                            });
                                          }
                                        },
                                        validator: (value) {
                                          if (value == null) {
                                            return 'Please select a country';
                                          }
                                          if (!_phoneController.text.startsWith(
                                            selectedDialCode ?? '',
                                          )) {
                                            return 'Phone number must start with selected dial code';
                                          }
                                          return null;
                                        },
                                      ),
                                      const SizedBox(height: 8),
                                      TextFormField(
                                        controller: _phoneController,
                                        keyboardType: TextInputType.phone,
                                        decoration: const InputDecoration(
                                          labelText: 'Phone Number',
                                          border: UnderlineInputBorder(),
                                        ),
                                        validator: (value) {
                                          if (value == null || value.isEmpty) {
                                            return 'Please enter your phone number';
                                          }
                                          if (selectedDialCode != null &&
                                              !value.startsWith(selectedDialCode!)) {
                                            return 'Number must start with $selectedDialCode';
                                          }
                                          return null;
                                        },
                                      ),
                                      const SizedBox(height: 5),
                                      Row(
                                        crossAxisAlignment: CrossAxisAlignment.start,
                                        children: [
                                          Checkbox(
                                            value: agreeToTerms,
                                            onChanged: (value) {
                                              setState(() {
                                                agreeToTerms = value ?? false;
                                              });
                                            },
                                          ),
                                          Expanded(
                                            child: Text(
                                              'By accepting, you agree that the carrier of your luggage will not be held liable for any illegal, prohibited, or harmful substances found in your possession. You acknowledge full responsibility and understand that you may be held accountable in a court of law.',
                                              style: TextStyle(fontSize: 14),
                                              textAlign: TextAlign.justify,
                                            ),
                                          ),
                                        ],
                                      ),
                                      const SizedBox(height: 8),
                                      Wrap(
                                        spacing: 20,
                                        runSpacing: 20,
                                        children: [
                                          InkWell(
                                            onTap: () async {
                                              if (_formKey.currentState!.validate()) {
                                                if (!agreeToTerms){
                                                  ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('You must agree to the terms to continue.'),));
                                                  return;
                                                }

                                                String school = _schoolController.text.trim();
                                                String name = _nameController.text.trim();
                                                String email = _emailController.text.trim().toString().toLowerCase();
                                                String password = _passwordController.text;
                                                String phone = _phoneController.text.trim();
                                                String countryCode = selectedDialCode.toString();
                                                String country = selectedCountryName.toString();
                                                final DateTime dateTime = Timestamp.now().toDate();
                                                final result = await value.db.collection('schools').where('email',isEqualTo:email).get();
                                                final result_count = await value.db.collection('schools').get();
                                                final progress=ProgressHUD.of(context);
                                                progress?.showWithText('Setting up your school...');

                                                int count_exist=result_count.docs.length;
                                                int new_count=count_exist+1;
                                                String schoolid='KS${new_count.toString().padLeft(4, '0')}';
                                                final Map<String,dynamic>  staffdata=Staff(name: name, accessLevel: "admin", phone: phone, email: email, sex: "", region: "", schoolId: schoolid, schoolname: school, createdAt: dateTime).toMap();

                                                try{
                                                  if(result.docs.isEmpty){
                                                    await value.db.collection("schools").doc(schoolid).set(staffdata);
                                                    await value.db.collection("staff").doc(schoolid).set(staffdata);
                                                    // await value.auth.createUserWithEmailAndPassword(email: email, password: password);
                                                    // await value.auth.currentUser!.sendEmailVerification();
                                                    String message='Welcome to KologSoft MIS, $name. Your school ID is $schoolid. Please verify your email to complete the registration process.';
                                                    // await value.db.collection("smsQueue").add({
                                                    //   'phone': phone,
                                                    //   'message': message,
                                                    //   'senderId': "KologSoft",
                                                    //   'createdat': dateTime,
                                                    //   'status': 'pending',
                                                    // });
                                                    SnackBar snackBar =  SnackBar(
                                                      content: Text(message,style: TextStyle(color:Colors.white),),
                                                      backgroundColor: Colors.green.shade900,
                                                    );
                                                    ScaffoldMessenger.of(context).showSnackBar(snackBar);
                                                  }else{
                                                    SnackBar snackBar =  SnackBar(
                                                      content: Text('School already exists',style: TextStyle(color:Colors.white),),
                                                      backgroundColor: Colors.red.shade900,
                                                    );
                                                    ScaffoldMessenger.of(context).showSnackBar(snackBar);
                                                  }
                                                  progress!.dismiss();
                                                }
                                                catch(e){
                                                  print(e);
                                                  progress?.dismiss();

                                                }



                                              }
                                            },
                                            child: Container(
                                              width:
                                              MediaQuery.sizeOf(context).width * 0.8,
                                              padding: const EdgeInsets.all(12),
                                              decoration: BoxDecoration(
                                                color: Color(0xFF00244A),
                                                border: Border.all(
                                                  color: Colors.grey.shade300,
                                                ),
                                                borderRadius: BorderRadius.circular(8),
                                              ),
                                              child: Center(
                                                child: const Text(
                                                  'Sign Up',
                                                  style: TextStyle(color: Colors.white),
                                                ),
                                              ),
                                            ),
                                          ),
                                          TextButton(
                                            onPressed: () {
                                              value.showform(true,"login");
                                            },
                                            child: const Text('Sign In'),
                                          ),
                                        ],
                                      ),
                                      SizedBox(height: 8),
                                      Row(
                                        children: [
                                          const Expanded(
                                            child: Divider(
                                              thickness: 1,
                                              color: Colors.grey,
                                            ),
                                          ),
                                          const Padding(
                                            padding: EdgeInsets.symmetric(
                                              horizontal: 8.0,
                                            ),
                                            child: Text(
                                              "Sign up with",
                                              style: TextStyle(
                                                fontSize: 14,
                                                color: Colors.black54,
                                                fontWeight: FontWeight.w500,
                                              ),
                                            ),
                                          ),
                                          const Expanded(
                                            child: Divider(
                                              thickness: 1,
                                              color: Colors.grey,
                                            ),
                                          ),
                                        ],
                                      ),
                                      SizedBox(height: 20.0),
                                      Center(
                                        child: Wrap(
                                          spacing: 20,
                                          runSpacing: 10,
                                          alignment: WrapAlignment.start,
                                          crossAxisAlignment: WrapCrossAlignment.center,
                                          children: [
                                            // Google Icon Button
                                            InkWell(
                                              onTap: () {},
                                              child: Container(
                                                width:
                                                MediaQuery.sizeOf(context).width *
                                                    0.8,
                                                padding: const EdgeInsets.all(12),
                                                decoration: BoxDecoration(
                                                  border: Border.all(
                                                    color: Colors.grey.shade300,
                                                  ),
                                                  borderRadius: BorderRadius.circular(8),
                                                ),
                                                child: Image.asset(
                                                  "assets/images/google.png",
                                                  height: 28,
                                                  width: 28,
                                                ),
                                              ),
                                            ),

                                            // Facebook Icon Button
                                          ],
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                                Visibility(
                                  visible: value.loginform,
                                  child: Column(
                                    children: [
                                      Container(
                                        width: double.infinity,
                                        padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 12),
                                        decoration: BoxDecoration(
                                          color: Colors.white.withOpacity(0.85),
                                          borderRadius: BorderRadius.circular(12),
                                          boxShadow: [
                                            BoxShadow(
                                              color: Colors.grey.withOpacity(0.1),
                                              blurRadius: 8,
                                              offset: Offset(0, 2),
                                            ),
                                          ],
                                        ),
                                        child: Column(
                                          crossAxisAlignment: CrossAxisAlignment.start,

                                          children: const [
                                            Text(
                                              'Login',
                                              style: TextStyle(
                                                fontSize: 22,
                                                fontWeight: FontWeight.bold,
                                                color: Color(0xFF00244A),
                                              ),
                                            ),

                                          ],
                                        ),
                                      ),
                                      TextFormField(
                                        controller: _emailController,
                                        decoration: const InputDecoration(labelText: 'E-mail Address', border: UnderlineInputBorder()),
                                        validator: (value) {
                                          if (value == null || value.isEmpty) return 'Email is required';
                                          if (!RegExp(r'\S+@\S+\.\S+').hasMatch(value)) return 'Enter a valid email';
                                          return null;
                                        },
                                      ),
                                      const SizedBox(height: 8),
                                      TextFormField(
                                        controller: _passwordController,
                                        obscureText: true,
                                        decoration: const InputDecoration(labelText: 'Password', border: UnderlineInputBorder()),
                                        validator: (value) {
                                          if (value == null || value.isEmpty) return 'Password is required';
                                          if (value.length < 6) return 'Password must be at least 6 characters';
                                          return null;
                                        },
                                      ),
                                      const SizedBox(height: 8),
                                      Align(
                                        alignment: Alignment.centerRight,
                                        child: InkWell(
                                          onTap: () async{
                                            // Navigator.push(context, MaterialPageRoute(builder: (_) => const ForgotPasswordPage()));
                                          },
                                          child: const Text('Forgot password?', style: TextStyle(fontSize: 14)),
                                        ),
                                      ),
                                      const SizedBox(height: 5),

                                      InkWell(
                                        onTap: () async {
                                          if (_formKey.currentState!.validate()) {
                                            try {
                                              final email = _emailController
                                                  .text.trim();
                                              final password = _passwordController
                                                  .text.trim();
                                              final progress = ProgressHUD.of(
                                                  context);
                                              progress?.show();
                                              await value.login(
                                                  email, password, context);
                                              progress?.dismiss();
                                            }catch(e){
                                              SnackBar snackBar=SnackBar(content: Text(value.errorMessage));
                                              ScaffoldMessenger.of(context).showSnackBar(snackBar);
                                            }
                                          }
                                        },
                                        child: Container(
                                          width: MediaQuery.sizeOf(context).width * 0.8,
                                          padding: const EdgeInsets.all(12),
                                          decoration: BoxDecoration(
                                            color: Color(0xFF00244A),
                                            border: Border.all(
                                                color:Colors.grey.shade300
                                            ),
                                            borderRadius: BorderRadius.circular(8),
                                          ),
                                          child: Center(child: const Text('Sign In', style: TextStyle(color: Colors.white))),
                                        ),
                                      ),
                                      SizedBox(height: 3.0,),
                                      TextButton(
                                        onPressed: () {
                                          value.showform(true, "signup");

                                        },
                                        child: const Text("Don't have an account? Sign Up"),
                                      ),
                                      const SizedBox(height: 5),

                                      Center(
                                        child: Wrap(
                                          spacing: 20,
                                          runSpacing: 10,
                                          alignment: WrapAlignment.start,
                                          crossAxisAlignment: WrapCrossAlignment.center,
                                          children: [
                                            // Google Icon Button
                                            InkWell(
                                              onTap: () async{
                                                // await value.signInWithGoogle(context);
                                              },
                                              child: Container(
                                                width: MediaQuery.sizeOf(context).width * 0.8,
                                                padding: const EdgeInsets.all(12),
                                                decoration: BoxDecoration(
                                                  border: Border.all(
                                                      color:Colors.grey.shade300
                                                  ),
                                                  borderRadius: BorderRadius.circular(8),
                                                ),
                                                child: Image.asset(
                                                  "assets/images/google.png",
                                                  height: 28,
                                                  width: 28,
                                                ),
                                              ),
                                            ),
                                            // Facebook Icon Button

                                          ],
                                        ),
                                      ),
                                    ],
                                  ),
                                )
                              ],
                            );
                          },
                        ),
                      ),
                    ),
                  ),
                ),
              );
            },
          ),
        ),
      );
    }

    return Scaffold(
      appBar: AppBar(
        elevation: 0,
        backgroundColor: Colors.white,
        iconTheme: const IconThemeData(color: Colors.black),
        actions: [
          TextButton(
            onPressed: () {},
            child: Row(
              children: [
                Icon(Icons.how_to_vote_rounded),
                Text('Vote', style: TextStyle(color: Colors.black)),
              ],
            ),
          ),
        ],
      ),
      backgroundColor: Color(0xFFffffff),
      body: isMobile
          ? Column(
        children: [
          mobileLeftPanel(context),
          Expanded(child: rightPanel(context)),
        ],
      )
          : Row(
        children: [
          Flexible(flex: 1, child: leftPanel(context)),
          Flexible(flex: 1, child: rightPanel(context)),
        ],
      ),
    );
  }
}