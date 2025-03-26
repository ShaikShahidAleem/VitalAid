import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:vitalaid/medical_records_page.dart';
import 'package:vitalaid/welcome_page.dart';
import 'profile_page.dart';
import 'procedure_detail_screen.dart';
import 'procedure_search_delegate.dart';

class HomePage extends StatefulWidget {
  const HomePage({Key? key}) : super(key: key);

  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  final user = FirebaseAuth.instance.currentUser!;
  List<Map<String, dynamic>> procedures = [];
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    fetchProcedures();
  }

  Future<void> fetchProcedures() async {
    try {
      final querySnapshot = await FirebaseFirestore.instance.collection('first_aid_procedures').get();
      setState(() {
        procedures = querySnapshot.docs.map((doc) {
          final data = doc.data();
          data['id'] = doc.id;
          return data;
        }).toList();
        isLoading = false;
      });
    } catch (e) {
      print("Error fetching procedures: $e");
      setState(() {
        isLoading = false;
      });
    }
  }

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
        automaticallyImplyLeading: false,
        title: Row(
          children: [
            Expanded(
              child: GestureDetector(
                onTap: () {
                  showSearch(
                    context: context,
                    delegate: ProcedureSearchDelegate(procedures),
                  );
                },
                child: TextField(
                  enabled: false,
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
            ),
            const SizedBox(width: 8),
          ],
        ),
        backgroundColor: const Color.fromARGB(255, 68, 205, 255),
      ),
      endDrawer: Drawer(
        child: SafeArea(
          child: Column(
            children: [
              const SizedBox(height: 20),
              // User profile section
              CircleAvatar(
                radius: 50,
                backgroundColor: Colors.grey,
                child: Icon(Icons.person, size: 80, color: Colors.white),
              ),
              const SizedBox(height: 10),
              Text(
                user.displayName ?? 'Username',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              Text(
                user.phoneNumber ?? 'Phone number',
                style: TextStyle(fontSize: 14, color: Colors.grey[600]),
              ),
              TextButton(
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => ProfilePage(user: user)),
                  );
                },
                child: Text(
                  'View/Edit Profile',
                  style: TextStyle(color: Colors.blue),
                ),
              ),
              const SizedBox(height: 20),
              // Additional features
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16.0),
                child: Column(
                  children: [
                    _buildFeatureButton('Additional feature 1'),
                    const SizedBox(height: 10),
                    _buildFeatureButton('Additional feature 2'),
                    const SizedBox(height: 10),
                    _buildFeatureButton('Additional feature 3'),
                    const SizedBox(height: 10),
                    _buildFeatureButton('Additional feature 4'),
                    const SizedBox(height: 10),
                    _buildFeatureButton('Additional feature 5'),
                    const SizedBox(height: 20),
                    // Logout button
                    Container(
                      width: double.infinity,
                      child: ElevatedButton(
                        onPressed: () => signUserOut(context),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.black,
                          padding: EdgeInsets.symmetric(vertical: 12),
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text('Log out', style: TextStyle(color: Colors.white)),
                            SizedBox(width: 8),
                            Icon(Icons.logout, color: Colors.white),
                          ],
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
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Major First Aid Procedures',
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 10),
                  Expanded(
                    child: GridView.builder(
                      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                        crossAxisCount: 2,
                        childAspectRatio: 1.5,
                        crossAxisSpacing: 10,
                        mainAxisSpacing: 10,
                      ),
                      itemCount: procedures.length,
                      itemBuilder: (context, index) {
                        final procedure = procedures[index];
                        return ElevatedButton(
                          onPressed: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => ProcedureDetailScreen(procedure),
                              ),
                            );
                          },
                          style: ElevatedButton.styleFrom(
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(10.0),
                            ),
                          ),
                          child: Text(
                            procedure['name'],
                            textAlign: TextAlign.center,
                            style: TextStyle(fontSize: 14),
                          ),
                        );
                      },
                    ),
                  ),
                  const SizedBox(height: 20),
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
                        onPressed: () {},
                        icon: const Icon(Icons.featured_play_list),
                        label: Text('Feature ${index + 1}'),
                        style: ElevatedButton.styleFrom(
                          minimumSize: const Size(150, 50),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
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
              IconButton(
                icon: const Icon(Icons.home),
                onPressed: () {},
              ),
              // Add this to your home_page.dart, in the bottomNavigationBar section
              IconButton(
                icon: const Icon(Icons.medical_services),
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => MedicalRecordsPage()),
                  );
                },
              ),
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
                  onPressed: () {},
                ),
              ),
              IconButton(
                icon: const Icon(Icons.health_and_safety),
                onPressed: () {},
              ),
              IconButton(
                icon: const Icon(Icons.person_add),
                onPressed: () {},
              ),
            ],
          ),
        ),
      ),
    );
  }
  Widget _buildFeatureButton(String text) {
    return Container(
      width: double.infinity,
      child: ElevatedButton(
        onPressed: () {},
        style: ElevatedButton.styleFrom(
          backgroundColor: const Color.fromARGB(255, 68, 205, 255),
          padding: EdgeInsets.symmetric(vertical: 15),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(8),
          ),
        ),
        child: Text(
          text,
          style: TextStyle(color: Colors.white),
        ),
      ),
    );
  }
}