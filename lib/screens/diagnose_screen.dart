// ============================================================================
// SECTION 1: IMPORTS
// ============================================================================
import 'dart:io';
import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:tflite_v2/tflite_v2.dart';
import 'package:path_provider/path_provider.dart';
import 'package:hive_flutter/hive_flutter.dart'; 
import 'login_screen.dart'; 
import 'treatments_screen.dart';

class DiagnoseScreen extends StatefulWidget {
  final Uint8List imageBytes;
  final String userName; 

  const DiagnoseScreen({super.key, required this.imageBytes, required this.userName});

  @override
  State<DiagnoseScreen> createState() => _DiagnoseScreenState();
}

class _DiagnoseScreenState extends State<DiagnoseScreen> {
  String cropName = "Pending...";
  String diseaseName = "Waiting to scan...";
  String status = "Waiting to scan...";
  String rawLabel = ""; 
  int confidence = 0;
  bool isLoading = false;
  bool hasScanned = false;
  File? _tempImageFile;

  @override
  void initState() {
    super.initState();
    _loadModel();
    _saveBytesToTempFile();
  }

  Future<void> _loadModel() async {
    try {
      await Tflite.loadModel(
        model: "assets/model.tflite", 
        labels: "assets/labels.txt", 
        numThreads: 1, 
        isAsset: true, 
        useGpuDelegate: false
      );
    } catch (e) {
      print("Failed to load model: $e");
    }
  }

  Future<void> _saveBytesToTempFile() async {
    final tempDir = await getTemporaryDirectory();
    final file = await File('${tempDir.path}/temp_crop.jpg').create();
    file.writeAsBytesSync(widget.imageBytes);
    setState(() { _tempImageFile = file; });
  }

  // ==========================================================================
  // SECTION 4: AI INFERENCE ENGINE (Updated for Django Python Model)
  // ==========================================================================
  Future<void> runAiAnalysis() async {
    if (_tempImageFile == null) return;
    setState(() { isLoading = true; });

    try {
      // Configured specifically for Keras/Python normalized models (Pixels divided by 255)
      var recognitions = await Tflite.runModelOnImage(
        path: _tempImageFile!.path,
        imageMean: 0.0,    // Changed to 0.0 for standard Python models
        imageStd: 255.0,   // Changed to 255.0 to scale pixels between 0 and 1
        numResults: 15,    // Matches the 15 classes in labels.txt
        threshold: 0.1,    
        asynch: true,
      );

      if (recognitions != null && recognitions.isNotEmpty) {
        // 1. Clean the label (removes leading digits like "0 Corn___Common_Rust")
        String label = recognitions[0]['label'].replaceAll(RegExp(r'^[0-9]+\s'), '').trim();
        double conf = recognitions[0]['confidence'];

        String crop = "Unknown";
        String disease = "Unknown Status";
        bool healthy = false;

        // 2. Handle the "Invalid" class (Label 4)
        if (label.toLowerCase() == "invalid") {
          crop = "Unrecognized";
          disease = "Not a valid leaf";
        } else {
          // 3. Parse the specific format (e.g. "Corn___Common_Rust")
          List<String> parts = label.split('___');
          
          if (parts.isNotEmpty) {
            // Replace single underscores with spaces for the crop
            crop = parts[0].replaceAll('_', ' '); 
            
            if (parts.length > 1) {
              // Replace single underscores with spaces for the disease
              disease = parts[1].replaceAll('_', ' '); 
            }
          }
          // Determine if it's a healthy leaf
          healthy = disease.toLowerCase().contains("healthy");
        }

        // 4. Save to Database History
        final historyBox = Hive.box('scan_history');
        List<dynamic> userHistory = historyBox.get(widget.userName, defaultValue: []);
        
        final newScan = {
          'crop': crop,
          'disease': healthy ? "Healthy" : disease,
          'isHealthy': healthy,
          'date': "${DateTime.now().day}/${DateTime.now().month}/${DateTime.now().year}",
        };
        
        userHistory.insert(0, newScan);
        historyBox.put(widget.userName, userHistory);

        // 5. Update UI state
        setState(() {
          rawLabel = label; 
          cropName = crop;
          diseaseName = healthy ? "Healthy Crop" : disease;
          // If the model caught an invalid image, mark it as Failed. Otherwise, use health status.
          status = (healthy || crop == "Unrecognized") ? (healthy ? "Healthy" : "Failed") : "Needs Attention";
          confidence = (conf * 100).toInt();
          isLoading = false;
          hasScanned = true;
        });
      } else {
        setState(() { diseaseName = "Unrecognized Object"; status = "Failed"; isLoading = false; hasScanned = true; });
      }
    } catch (e) {
      setState(() { isLoading = false; diseaseName = "Error running model"; status = "Failed"; hasScanned = true; });
    }
  }

  @override
  void dispose() {
    Tflite.close();
    super.dispose();
  }

  // ==========================================================================
  // SECTION 5: USER INTERFACE
  // ==========================================================================
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF4F6F5),
      appBar: AppBar(title: const Text('Crop Analysis', style: TextStyle(color: Colors.black)), backgroundColor: Colors.white, elevation: 0, iconTheme: const IconThemeData(color: Colors.black)),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(20.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              ClipRRect(borderRadius: BorderRadius.circular(16), child: Image.memory(widget.imageBytes, width: double.infinity, height: 300, fit: BoxFit.cover)),
              const SizedBox(height: 30),
              const Text("AI Analysis Results", style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: Color(0xFF1C2333))),
              const SizedBox(height: 15),
              
              // --- RESULTS CARD ---
              Container(
                width: double.infinity, padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(16), boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 10, offset: const Offset(0, 4))]),
                child: isLoading
                    ? const Center(child: Padding(padding: EdgeInsets.all(20.0), child: CircularProgressIndicator(color: Color(0xFF159A6C))))
                    : Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          ResultRow(label: "Detected Crop", value: cropName), const Divider(height: 30),
                          ResultRow(label: "Disease / Health", value: diseaseName, isAlert: status != "Healthy" && status != "Waiting to scan..."), const Divider(height: 30),
                          ResultRow(label: "Confidence Score", value: "$confidence%"),
                        ],
                      ),
              ),
              const SizedBox(height: 30),

              // --- MAIN ACTION BUTTON (See Treatments / Run Scan) ---
              SizedBox(
                width: double.infinity,
                height: 58,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF159A6C),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                  ),
                  onPressed: (_tempImageFile == null || isLoading)
                      ? null
                      : (hasScanned
                            ? () { 
                                // Disable treatment screen if the image was invalid
                                if (cropName == "Unrecognized") {
                                  ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Cannot show treatments for an invalid image.")));
                                  return;
                                }
                                Navigator.push(context, MaterialPageRoute(builder: (context) => TreatmentScreen(crop: cropName, disease: diseaseName, labelKey: rawLabel, isHealthy: status == "Healthy"))); 
                              }
                            : runAiAnalysis),
                  child: isLoading
                      ? const SizedBox(width: 24, height: 24, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2))
                      : Text(
                          hasScanned ? "See Treatments" : "Run AI Scan",
                          style: const TextStyle(fontSize: 19, fontWeight: FontWeight.bold, color: Colors.white), 
                        ),
                ),
              ),
              
              const SizedBox(height: 15),

              // --- SECONDARY ACTION BUTTONS (Scan New & Change Profile) ---
              if (!isLoading) ...[
                SizedBox(
                  width: double.infinity,
                  height: 52,
                  child: OutlinedButton.icon(
                    style: OutlinedButton.styleFrom(
                      foregroundColor: const Color(0xFF159A6C),
                      side: const BorderSide(color: Color(0xFF159A6C), width: 1.5),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                    ),
                    icon: const Icon(Icons.refresh), 
                    label: const Text("Scan New Crop", style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                    onPressed: () { Navigator.pop(context); },
                  ),
                ),
                const SizedBox(height: 12),
                
                SizedBox(
                  width: double.infinity,
                  height: 52,
                  child: OutlinedButton.icon(
                    style: OutlinedButton.styleFrom(
                      foregroundColor: Colors.grey[700],
                      side: BorderSide(color: Colors.grey[400]!, width: 1.5),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                    ),
                    icon: const Icon(Icons.people_alt_outlined), 
                    label: const Text("Change Profile", style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                    onPressed: () {
                      Navigator.pushAndRemoveUntil(context, MaterialPageRoute(builder: (context) => const LoginScreen()), (route) => false);
                    },
                  ),
                ),
              ],
              const SizedBox(height: 30),
            ],
          ),
        ),
      ),
    );
  }
}

class ResultRow extends StatelessWidget {
  final String label; final String value; final bool isAlert;
  const ResultRow({super.key, required this.label, required this.value, this.isAlert = false});
  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween, crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: const TextStyle(fontSize: 16, color: Colors.grey, fontWeight: FontWeight.w500)), const SizedBox(width: 16),
        Expanded(child: Text(value, textAlign: TextAlign.right, style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: isAlert ? const Color(0xFFE74C3C) : const Color(0xFF1C2333)))),
      ],
    );
  }
}
