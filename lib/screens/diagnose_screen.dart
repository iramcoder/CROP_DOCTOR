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

  // Loads your new model.tflite and labels.txt from the assets folder
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
  // SECTION 4: AI INFERENCE ENGINE
  // ==========================================================================
  Future<void> runAiAnalysis() async {
    if (_tempImageFile == null) return;
    setState(() { isLoading = true; });

    try {
      // Preprocessing config adjusted for standard Keras/Python [0.0 to 1.0] scaling
      var recognitions = await Tflite.runModelOnImage(
        path: _tempImageFile!.path,
        imageMean: 0.0,    // Normalization mean set to 0.0 for Python TFLite models
        imageStd: 255.0,   // Divides raw 0-255 pixels by 255.0 to yield a 0.0-1.0 range
        numResults: 15,    // Set to 15 to map to the 15 classes in your new labels.txt
        threshold: 0.1,    
        asynch: true,
      );

      if (recognitions != null && recognitions.isNotEmpty) {
        // 1. Strip out the leading digits (e.g., "0 Corn___Common_Rust" -> "Corn___Common_Rust")
        String label = recognitions[0]['label'].replaceAll(RegExp(r'^[0-9]+\s'), '').trim();
        double conf = recognitions[0]['confidence'];

        String crop = "Unknown";
        String disease = "Unknown Status";
        bool healthy = false;

        // 2. Safely parse the "Invalid" class (Label 4)
        if (label.toLowerCase() == "invalid") {
          crop = "Unrecognized";
          disease = "Not a valid leaf";
        } else {
          // 3. Parse the new underscore layout (e.g., "Corn___Common_Rust" -> Crop: "Corn", Disease: "Common Rust")
          List<String> parts = label.split('___');
          
          if (parts.isNotEmpty) {
            crop = parts[0].replaceAll('_', ' '); 
            
            if (parts.length > 1) {
              disease = parts[1].replaceAll('_', ' '); // <--- FIXED: Safely parsing item index [1]
            }
          }
          // Scan history expects a standard check for the word 'healthy'
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

        // 5. Update UI
        setState(() {
          rawLabel = label; 
          cropName = crop;
          diseaseName = healthy ? "Healthy Crop" : disease;
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

              // Main button to trigger AI analysis
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
                                // Show a message if they try to click "See Treatments" on an invalid card
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

              // Vertical actions: Scan New & Change Profile
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

// =========================================================================
// SECTION 6: DEDICATED TREATMENT SCREEN
// =========================================================================
class TreatmentScreen extends StatelessWidget {
  final String crop;
  final String disease;
  final String labelKey;
  final bool isHealthy;

  const TreatmentScreen({
    super.key,
    required this.crop,
    required this.disease,
    required this.labelKey,
    required this.isHealthy,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF4F6F5),
      appBar: AppBar(
        title: const Text('Treatment Guide', style: TextStyle(color: Colors.black)),
        backgroundColor: Colors.white,
        elevation: 0,
        iconTheme: const IconThemeData(color: Colors.black),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.info_outline, size: 60, color: Color(0xFF159A6C)),
            const SizedBox(height: 15),
            Text(
              "Diagnosis: $crop",
              style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 5),
            Text(
              disease,
              style: const TextStyle(fontSize: 16, color: Colors.grey),
            ),
            const SizedBox(height: 25),
            const Padding(
              padding: EdgeInsets.symmetric(horizontal: 40.0),
              child: Text(
                "Detailed offline treatment plans for this model are being finalized. Check back in the next update!",
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 14, color: Colors.grey),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
