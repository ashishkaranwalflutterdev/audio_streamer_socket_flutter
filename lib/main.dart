import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:socket/controllers/app_controller.dart';
import 'package:socket/screens/audio_listner.dart';
import 'package:socket/screens/audio_streamer.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {

  AppController _appController=Get.put(AppController(),permanent: true);


  @override
  Widget build(BuildContext context) {
    return GetMaterialApp(
      title: 'Socket.IO Client Test',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: HomeScreen(),
    );
  }
}


class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 30.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [

            const Text("Socket POC"),

            const SizedBox(height: 20,),

            InkWell(
              onTap: (){
                Get.to(()=> AudioStreamer());
              },
              child: const Card(
                color: Colors.orange,
                child: SizedBox(
                  height: 100,
                    width: double.infinity,
                    child: Center(child: Text("Stream",style: TextStyle(
                      fontSize: 25
                    ),))
                ),
              ),
            ),


            const SizedBox(height: 20,),


            InkWell(
              onTap: (){
                Get.to(()=> AudioListener());
              },
              child: const Card(
                color: Colors.grey,
                child: SizedBox(
                    height: 100,
                    width: double.infinity,
                    child: Center(child: Text("Listen",style: TextStyle(
                        fontSize: 25
                    ),))),
              ),
            ),


          ],
        ),
      ),
    );
  }
}





class CheckoutForm extends StatefulWidget {
  @override
  _CheckoutFormState createState() => _CheckoutFormState();
}

class _CheckoutFormState extends State<CheckoutForm> {
  int _currentStep = 0;
  final _formKey = GlobalKey<FormState>();

  final _nameController = TextEditingController();
  final _mobileController = TextEditingController();
  final _pincodeController = TextEditingController();
  final _addressController = TextEditingController();
  final _localityController = TextEditingController();
  final _cityController = TextEditingController();
  final _stateController = TextEditingController();

  final List<String> _cities = [
    'New York',
    'New York Old',
    'Greater New York',
    'Los Angeles',
    'Chicago',
    'Houston',
    'Phoenix',
  ];

  @override
  void dispose() {
    _nameController.dispose();
    _mobileController.dispose();
    _pincodeController.dispose();
    _addressController.dispose();
    _localityController.dispose();
    _cityController.dispose();
    _stateController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Checkout'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            Expanded(
              flex: 1,
              child: ElevatedCard(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Total Amount: \$123.45', style: TextStyle(fontSize: 20)),
                    SizedBox(height: 8),
                    Text('Items: Item1, Item2, Item3', style: TextStyle(fontSize: 16)),
                  ],
                ),
              ),
            ),
            SizedBox(height: 16),
            Expanded(
              flex: 3,
              child: Card(
                elevation: 3,
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20.0,vertical: 10),
                  child: Form(
                    key: _formKey,
                    child: Stepper(
                      currentStep: _currentStep,
                      onStepContinue: () {
                        if (_formKey.currentState!.validate()) {
                          if (_currentStep < 2) {
                            setState(() {
                              _currentStep += 1;
                            });
                          } else {
                            // Process the final submission
                            print('Form submitted');
                          }
                        }
                      },
                      onStepCancel: () {
                        if (_currentStep > 0) {
                          setState(() {
                            _currentStep -= 1;
                          });
                        }
                      },
                      steps: _buildSteps(),
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  List<Step> _buildSteps() {
    return [
      Step(
        title: Text('Personal Details'),
        content: Column(
          children: [
            TextFormField(
              controller: _nameController,
              decoration: InputDecoration(labelText: 'Full Name*'),
              validator: (value) {
                if (value==null && value==" ") {
                  return 'Please enter your full name';
                }
                return null;
              },
            ),
            TextFormField(
              controller: _mobileController,
              decoration: InputDecoration(labelText: 'Mobile No*'),
              keyboardType: TextInputType.phone,
              validator: (value) {
                if (value==null && value==" ") {
                  return 'Please enter your mobile number';
                }
                return null;
              },
            ),
          ],
        ),
      ),
      Step(
        title: Text('Shipping Details'),
        content: Column(
          children: [
            TextFormField(
              controller: _pincodeController,
              decoration: InputDecoration(labelText: 'Pincode*'),
              keyboardType: TextInputType.number,
              validator: (value) {
                if (value==null && value==" ") {
                  return 'Please enter your pincode';
                }
                return null;
              },
            ),
            TextFormField(
              controller: _addressController,
              decoration: InputDecoration(labelText: 'Address*'),
              validator: (value) {
                if (value==null && value==" ") {
                  return 'Please enter your address';
                }
                return null;
              },
            ),
            TextFormField(
              controller: _localityController,
              decoration: InputDecoration(labelText: 'Locality/Town*'),
              validator: (value) {
                if (value==null && value==" ") {
                  return 'Please enter your locality/town';
                }
                return null;
              },
            ),
            Autocomplete<String>(
              optionsBuilder: (TextEditingValue textEditingValue) {
                if (textEditingValue.text.isEmpty) {
                  return const Iterable<String>.empty();
                }
                return _cities.where((String option) {
                  return option.toLowerCase().contains(textEditingValue.text.toLowerCase());
                });
              },
              onSelected: (String selection) {
                _cityController.text = selection;
              },
              fieldViewBuilder: (BuildContext context, TextEditingController textEditingController, FocusNode focusNode, VoidCallback onFieldSubmitted) {
                return TextFormField(
                  controller: textEditingController,
                  focusNode: focusNode,
                  decoration: InputDecoration(
                    labelText: 'City/District*',
                  ),
                  validator: (value) {
                    if (value==null && value==" ") {
                      return 'Please select a city';
                    }
                    return null;
                  },
                );
              },
            ),
            TextFormField(
              controller: _stateController,
              decoration: InputDecoration(labelText: 'State*'),
              validator: (value) {
                if (value==null && value==" ") {
                  return 'Please enter your state';
                }
                return null;
              },
            ),
          ],
        ),
      ),
      Step(
        title: Text('Payment'),
        content: Column(
          children: [
            Text('Payment options go here'),
          ],
        ),
      ),
    ];
  }
}

class ElevatedCard extends StatelessWidget {
  final Widget child;

  const ElevatedCard({Key? key, required this.child}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 4.0,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8.0)),
      child: SizedBox(
        width: double.infinity,
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: child,
        ),
      ),
    );
  }
}
