import 'package:flutter/material.dart';

class Forms extends StatefulWidget {
  const Forms({super.key});

  @override
  State<Forms> createState() => _FormsState();
}

class _FormsState extends State<Forms> {
  final formKey = GlobalKey<FormState>();

  final TextEditingController nameController = TextEditingController();
  final TextEditingController emailController = TextEditingController();
  final TextEditingController passController = TextEditingController();
  final TextEditingController phoneController = TextEditingController();
  final TextEditingController ageController = TextEditingController();
  final TextEditingController dateController = TextEditingController();
  final TextEditingController timeController = TextEditingController();

  bool isHidden = true;
  String? selectedGender;
  String? selectedCountry;

  double satisfaction = 3.0;
  double progress = 0.5;
  RangeValues budget = const RangeValues(20, 80);

  bool subscribe = false;
  bool agree = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Complete Form Example"),
        backgroundColor: Colors.blue,
      ),
      body: SingleChildScrollView(
        padding: EdgeInsets.all(20),
        child: Form(
          key: formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                "Personal Information",
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.blue),
              ),
              SizedBox(height: 20),

              TextFormField(
                controller: nameController,
                decoration: InputDecoration(
                  labelText: "Full Name *",
                  prefixIcon: Icon(Icons.person),
                  border: OutlineInputBorder(),
                ),
                validator: (value) => value!.isEmpty ? "This field is required" : null,
              ),
              SizedBox(height: 15),

              TextFormField(
                controller: emailController,
                decoration: InputDecoration(
                  labelText: "Email Address *",
                  prefixIcon: Icon(Icons.email),
                  border: OutlineInputBorder(),
                ),
                validator: (value) => value!.isEmpty ? "This field is required" : null,
              ),
              SizedBox(height: 15),

              StatefulBuilder(
                builder: (context, setState2) {
                  return TextFormField(
                    controller: passController,
                    obscureText: isHidden,
                    decoration: InputDecoration(
                      labelText: "Password *",
                      prefixIcon: Icon(Icons.lock_outline),
                      border: OutlineInputBorder(),
                      suffixIcon: IconButton(
                        icon: Icon(isHidden ? Icons.visibility_off : Icons.visibility),
                        onPressed: () => setState2(() => isHidden = !isHidden),
                      ),
                    ),
                    validator: (value) => value!.isEmpty ? "This field is required" : null,
                  );
                },
              ),
              SizedBox(height: 15),

              TextFormField(
                controller: phoneController,
                keyboardType: TextInputType.phone,
                decoration: InputDecoration(
                  labelText: "Phone Number",
                  prefixIcon: Icon(Icons.phone),
                  border: OutlineInputBorder(),
                ),
              ),
              SizedBox(height: 15),

              TextFormField(
                controller: ageController,
                keyboardType: TextInputType.number,
                decoration: InputDecoration(
                  labelText: "Age",
                  prefixIcon: Icon(Icons.numbers),
                  border: OutlineInputBorder(),
                ),
              ),

              SizedBox(height: 25),
              Text(
                "Demographics",
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.blue),
              ),
              SizedBox(height: 15),

              StatefulBuilder(
                builder: (context, setState2) {
                  return DropdownButtonFormField(
                    decoration: InputDecoration(
                      labelText: "Select your gender",
                      prefixIcon: Icon(Icons.transgender),
                      border: OutlineInputBorder(),
                    ),
                    value: selectedGender,
                    items: [
                      DropdownMenuItem(value: "Male", child: Text("Male")),
                      DropdownMenuItem(value: "Female", child: Text("Female")),
                    ],
                    onChanged: (value) => setState2(() => selectedGender = value),
                  );
                },
              ),
              SizedBox(height: 15),

              StatefulBuilder(
                builder: (context, setState2) {
                  return DropdownButtonFormField(
                    decoration: InputDecoration(
                      labelText: "Select your country",
                      prefixIcon: Icon(Icons.location_on),
                      border: OutlineInputBorder(),
                    ),
                    value: selectedCountry,
                    items: [
                      DropdownMenuItem(value: "Yemen", child: Text("Yemen")),
                      DropdownMenuItem(value: "Saudi Arabia", child: Text("Saudi Arabia")),
                      DropdownMenuItem(value: "UAE", child: Text("UAE")),
                      DropdownMenuItem(value: "Egypt", child: Text("Egypt")),
                    ],
                    onChanged: (value) => setState2(() => selectedCountry = value),
                  );
                },
              ),

              SizedBox(height: 25),
              Text(
                "Date & Time",
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.blue),
              ),
              SizedBox(height: 15),

              TextFormField(
                controller: dateController,
                readOnly: true,
                decoration: InputDecoration(
                  labelText: "Birth Date",
                  prefixIcon: Icon(Icons.calendar_today),
                  border: OutlineInputBorder(),
                ),
                onTap: () async {
                  DateTime? date = await showDatePicker(
                    context: context,
                    initialDate: DateTime(2000),
                    firstDate: DateTime(1950),
                    lastDate: DateTime.now(),
                  );
                  if (date != null) {
                    dateController.text = "${date.year}-${date.month}-${date.day}";
                  }
                },
              ),
              SizedBox(height: 15),

              TextFormField(
                controller: timeController,
                readOnly: true,
                decoration: InputDecoration(
                  labelText: "Preferred Time",
                  prefixIcon: Icon(Icons.access_time),
                  border: OutlineInputBorder(),
                ),
                onTap: () async {
                  TimeOfDay? t = await showTimePicker(
                    context: context,
                    initialTime: TimeOfDay.now(),
                  );
                  if (t != null) {
                    timeController.text = "${t.hour}:${t.minute}";
                  }
                },
              ),

              SizedBox(height: 30),
              Text(
                "Ratings & Preferences",
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.blue),
              ),
              SizedBox(height: 20),

              Text("Satisfaction Rating: ${satisfaction.toStringAsFixed(1)}"),
              Slider(
                value: satisfaction,
                min: 1,
                max: 5,
                divisions: 4,
                onChanged: (v) => setState(() => satisfaction = v),
                activeColor: Colors.blue,
              ),

              SizedBox(height: 25),

              Text("Progress Level: ${(progress * 100).round()}%"),
              Slider(
                value: progress,
                min: 0,
                max: 1,
                onChanged: (v) => setState(() => progress = v),
                activeColor: Colors.blue,
              ),
              SizedBox(height: 25),

              Text("Budget Range: \$${budget.start.round()} - \$${budget.end.round()}"),
              RangeSlider(
                values: budget,
                min: 0,
                max: 100,
                divisions: 20,
                onChanged: (v) => setState(() => budget = v),
                activeColor: Colors.blue,
              ),

              SizedBox(height: 30),
              Text(
                "Preferences",
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.blue),
              ),
              SizedBox(height: 15),

              Row(
                children: [
                  Icon(Icons.notifications, color: Colors.black54),
                  SizedBox(width: 10),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text("Subscribe to Newsletter"),
                        Text("Receive updates and promotions",
                            style: TextStyle(color: Colors.grey, fontSize: 12)),
                      ],
                    ),
                  ),
                  Switch(
                    value: subscribe,
                    onChanged: (v) => setState(() => subscribe = v),
                  ),
                ],
              ),

              SizedBox(height: 15),

              Row(
                children: [
                  Checkbox(
                    value: agree,
                    onChanged: (v) => setState(() => agree = v ?? false),
                  ),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text("I agree to the Terms and Conditions"),
                        Text("You must agree to proceed",
                            style: TextStyle(color: Colors.grey, fontSize: 12)),
                      ],
                    ),
                  ),
                ],
              ),

              SizedBox(height: 20),

              ElevatedButton(
                onPressed: () {
                  if (formKey.currentState!.validate()) {
                    print("Full Name: ${nameController.text}");
                    print("Email: ${emailController.text}");
                    print("Password: ${passController.text}");
                    print("Phone: ${phoneController.text}");
                    print("Age: ${ageController.text}");
                    print("Gender: $selectedGender");
                    print("Country: $selectedCountry");
                    print("Birth Date: ${dateController.text}");
                    print("Preferred Time: ${timeController.text}");
                    print("Satisfaction: $satisfaction");
                    print("Progress: ${(progress * 100).round()}%");
                    print("Budget Range: ${budget.start} - ${budget.end}");
                    print("Subscribe: $subscribe");
                    print("Agree: $agree");
                  }
                },
                child: Text("Submit Form"),
              ),

              TextButton(
                onPressed: () {
                  setState(() {
                    nameController.clear();
                    emailController.clear();
                    passController.clear();
                    phoneController.clear();
                    ageController.clear();
                    dateController.clear();
                    timeController.clear();
                    selectedGender = null;
                    selectedCountry = null;
                    subscribe = false;
                    agree = false;
                  });
                },
                child: Text("Reset Form"),
              ),
            ],
          ),
        ),
      ),
    );
  }
}