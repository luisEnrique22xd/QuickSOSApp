import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class DetailsScreen extends StatefulWidget {
  final String alertId;
  final Map<String, dynamic> alert;

  const DetailsScreen({super.key, required this.alert, required this.alertId});

  @override
  State<DetailsScreen> createState() => _DetailsScreenState();
}

class _DetailsScreenState extends State<DetailsScreen> {
  late bool isResolved;

  @override
  void initState() {
    super.initState();
    isResolved = widget.alert["status"]?.toLowerCase() == "resolved";
  }

  @override
  Widget build(BuildContext context) {
    final user = FirebaseAuth.instance.currentUser!;
    final creatorId = widget.alert["creatorId"];
    final isCreator = user.uid == creatorId;

    print(widget.alert);

    return Scaffold(
      appBar: AppBar(
        title: const Text("Detalles de la Alerta"),
        actions: [
          IconButton(
            icon: const Icon(Icons.arrow_back_ios_new_sharp, color: Colors.white),
            onPressed: () {
              Navigator.of(context).pushNamedAndRemoveUntil('/main', (route) => false);
            },
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Card(
          color: const Color(0xFF2C2C2C),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
          ),
          child: Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  widget.alert["type"],
                  style: const TextStyle(
                      color: Colors.white, fontSize: 24, fontWeight: FontWeight.bold),
                ),

                const SizedBox(height: 10),

                Text(
                  "Hora: ${widget.alert["time"]}",
                  style: const TextStyle(color: Colors.white70, fontSize: 16),
                ),

                const SizedBox(height: 15),

                const Text(
                  "Descripción:",
                  style: TextStyle(
                      color: Colors.white, fontWeight: FontWeight.bold, fontSize: 18),
                ),

                const SizedBox(height: 6),

                Text(
                  widget.alert["description"] ?? "Sin información",
                  style: const TextStyle(color: Colors.white70, fontSize: 16),
                ),

                const SizedBox(height: 20),

                Text(
                  "Prioridad: ${widget.alert["priority"]}",
                  style: TextStyle(
                    color: widget.alert["priorityColor"],
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),

                const SizedBox(height: 20),

                if (widget.alert["imageUrl"] != null && widget.alert["imageUrl"] != "")
                  ClipRRect(
                    borderRadius: BorderRadius.circular(15),
                    child:
                        Image.network(widget.alert["imageUrl"], fit: BoxFit.cover),
                  ),

                const SizedBox(height: 20),

                if (isCreator)
                  ElevatedButton(
                    onPressed: isResolved
                        ? null
                        : () async {
                            try {
                              await FirebaseFirestore.instance
                                  .collection("alerts")
                                  .doc(widget.alert["id"])
                                  .update({"status": "resolved"});

                              setState(() {
                                isResolved = true;
                              });

                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(
                                  content: Text(
                                    "La alerta ha sido marcada como resuelta.",
                                    style: TextStyle(color: Colors.white),
                                  ),
                                  backgroundColor: Colors.green,
                                  duration: Duration(seconds: 2),
                                ),
                              );

                              await Future.delayed(
                                const Duration(milliseconds: 500),
                              );

                              Navigator.of(context).pushNamedAndRemoveUntil(
                                '/main',
                                (route) => false,
                              );
                            } catch (e) {
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(
                                  content: Text("Error al actualizar: $e"),
                                  backgroundColor: Colors.red,
                                ),
                              );
                            }
                          },
                    style: ElevatedButton.styleFrom(backgroundColor: Colors.blue),
                    child:
                        Text(isResolved ? "Resuelta" : "Marcar como resuelta"),
                  ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
