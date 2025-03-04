import 'package:flutter/material.dart';

class ProcedureDetailScreen extends StatelessWidget {
  final Map<String, dynamic> procedure;

  const ProcedureDetailScreen(this.procedure, {Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(procedure['name'])),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                procedure['name'],
                style:
                    const TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 16),
              Text(procedure['description']),
              const SizedBox(height: 16),
              Text(
                'First Aid Steps:',
                style:
                    const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
              ),
              ...List.generate(
                (procedure['steps'] as List<dynamic>).length,
                (index) => Padding(
                  padding:
                      const EdgeInsets.symmetric(vertical: 4.0),
                  child:
                      Text('${index + 1}. ${procedure['steps'][index]}'),
                ),
              ),
              if (procedure.containsKey('notes') &&
                  procedure['notes'] != null)
                Padding(
                  padding:
                      const EdgeInsets.only(top: 16.0),
                  child:
                      Text('Notes:\n${procedure['notes']}'),
                ),
            ],
          ),
        ),
      ),
    );
  }
}
