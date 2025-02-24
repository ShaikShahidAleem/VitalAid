import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:vitalaid/welcome_page.dart';
import 'profile_page.dart';

class HomePage extends StatelessWidget {
  HomePage({Key? key}) : super(key: key);

  final user = FirebaseAuth.instance.currentUser!;

  void signUserOut(BuildContext context) async {
    try {
      await FirebaseAuth.instance.signOut();
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => const WelcomePage()),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error signing out: $e')),
      );
    }
  }


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        automaticallyImplyLeading: false, // Removes default back button
        title: Row(
          children: [
            Expanded(
              child: TextField(
                decoration: InputDecoration(
                  hintText: 'Search...',
                  prefixIcon: const Icon(Icons.search),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8.0),
                    borderSide: BorderSide.none,
                  ),
                  filled: true,
                  fillColor: Colors.white,
                ),
              ),
            ),
            const SizedBox(width: 10),
            IconButton(
              icon: const Icon(Icons.person),
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => ProfilePage(user: user)),
                );
              },
            ),
            IconButton(
              icon: const Icon(Icons.logout),
              onPressed: () => signUserOut(context),
            ),
          ],
        ),
        backgroundColor: Colors.blueAccent,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Section for Major First Aid Procedures
            const Text(
              'Major First Aid Procedures',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 10),
            Wrap(
              spacing: 10,
              runSpacing: 10,
              children: List.generate(6, (index) {
                return ElevatedButton(
                  onPressed: () {}, // Non-functional for now
                  style: ElevatedButton.styleFrom(
                    minimumSize: const Size(100, 100),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10.0),
                    ),
                  ),
                  child: Text('Procedure ${index + 1}'),
                );
              }),
            ),
            const SizedBox(height: 20),

            // Section for Additional Features
            const Text(
              'Additional Features',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 10),
            Wrap(
              spacing: 10,
              runSpacing: 10,
              children: List.generate(4, (index) {
                return ElevatedButton.icon(
                  onPressed: () {}, // Non-functional for now
                  icon: const Icon(Icons.featured_play_list),
                  label: Text('Feature ${index + 1}'),
                  style: ElevatedButton.styleFrom(
                    minimumSize: const Size(150, 50),
                    shape:
                        RoundedRectangleBorder(borderRadius:
                        BorderRadius.circular(8)),
                  ),
                );
              }),
            ),
          ],
        ),
      ),
      bottomNavigationBar: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          boxShadow: [
            BoxShadow(
              color: Colors.grey.withOpacity(0.3),
              spreadRadius: 1,
              blurRadius: 5,
            ),
          ],
        ),
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 8.0),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              // Home Button
              IconButton(
                icon: const Icon(Icons.home),
                onPressed: () {
                  // Already on home page
                },
              ),
              // Placeholder Icon 1
              IconButton(
                icon: const Icon(Icons.medical_services),
                onPressed: () {
                  // Functionality to be added later
                },
              ),
              // SOS/Emergency Alert Button
              Container(
                decoration: BoxDecoration(
                  color: Colors.red,
                  borderRadius: BorderRadius.circular(30),
                ),
                child: IconButton(
                  icon: const Icon(
                    Icons.warning_rounded,
                    color: Colors.white,
                  ),
                  onPressed: () {
                    // Emergency alert functionality to be added
                  },
                ),
              ),
              // Placeholder Icon 2
              IconButton(
                icon: const Icon(Icons.health_and_safety),
                onPressed: () {
                  // Functionality to be added later
                },
              ),
              // Placeholder Icon 3
              IconButton(
                icon: const Icon(Icons.person_add),
                onPressed: () {
                  // Functionality to be added later
                },
              ),
            ],
          ),
        ),
      ),
    );
  }
}
