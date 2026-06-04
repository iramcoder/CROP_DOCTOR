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
  bool _showTreatments = false; 
  File? _tempImageFile;

  @override
  void initState() {
    super.initState();
    _loadModel();
    _saveBytesToTempFile();
  }

  Future<void> _loadModel() async {
    try {
      String? res = await Tflite.loadModel(
        model: "assets/model.tflite", 
        labels: "assets/labels.txt", 
        numThreads: 1, 
        isAsset: true, 
        useGpuDelegate: false
      );
      print("AI_LOG: Model Load Status -> $res");
    } catch (e) {
      print("AI_LOG: Failed to load model -> $e");
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
    setState(() { 
      isLoading = true; 
      _showTreatments = false; 
    });

    try {
      // Configuration 1: Standard Python MobileNet [-1.0 to 1.0] scaling
      var recognitions = await Tflite.runModelOnImage(
        path: _tempImageFile!.path,
        imageMean: 127.5,    
        imageStd: 127.5,     
        numResults: 15,      
        threshold: 0.0,      
        // REMOVED: imageHeight and imageWidth parameters to fix compile error
        asynch: true,
      );

      print("AI_LOG: Raw results -> $recognitions");

      if (recognitions != null && recognitions.isNotEmpty) {
        
        String rawLabelStr = recognitions[0]['label'].trim();
        double conf = recognitions[0]['confidence'];

        String crop = "Unknown";
        String disease = "Unknown Status";
        bool healthy = false;

        if (rawLabelStr.toLowerCase().contains("invalid")) {
          crop = "Unrecognized";
          disease = "Not a valid leaf";
        } else {
          String cleanLabel = rawLabelStr.replaceAll(RegExp(r'^\d+\s*'), '').trim();
          List<String> parts = cleanLabel.split('___');
          
          if (parts.isNotEmpty) {
            crop = parts[0].replaceAll('_', ' ').trim(); 
            
            if (parts.length > 1) {
              disease = parts[1].replaceAll('_', ' ').trim(); 
            }
          }
          healthy = disease.toLowerCase().contains("healthy");
        }

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

        setState(() {
          rawLabel = rawLabelStr; 
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
      print("AI_LOG: Prediction Exception -> $e");
    }
  }

  @override
  void dispose() {
    Tflite.close();
    super.dispose();
  }

  // ==========================================================================
  // SECTION 5: INLINE TREATMENT DATABASE & CASCADING VIEW
  // ==========================================================================
  Map<String, dynamic>? _getSpecificTreatment(String crop, String disease) {
    final db = {
      "Corn": {
        "Common Rust": {"organic": ["Apply neem oil or sulfur-based sprays", "Remove infected foliage"], "chemical": ["Apply preventative fungicides (Pyraclostrobin/Azoxystrobin)"], "prevention": ["Plant resistant hybrids", "Destroy infected crop residues"]},
        "Gray Leaf Spot": {"organic": ["Apply Bacillus subtilis bio-fungicide", "Rotate away from grass families"], "chemical": ["Apply strobilurin or triazole fungicides"], "prevention": ["Avoid no-till farming", "Maintain balanced soil nitrogen"]},
        "Northern Leaf Blight": {"organic": ["Apply biological fungicides", "Ensure clean tillage to bury residues"], "chemical": ["Use foliar fungicides (Azoxystrobin)"], "prevention": ["Choose disease-resistant hybrids", "Rotate with soybeans"]}
      },
      "Potato": {
        "Early Blight": {"organic": ["Remove lower infected leaves", "Apply compost tea/baking soda spray"], "chemical": ["Apply Chlorothalonil or Mancozeb", "Use Azoxystrobin sprays"], "prevention": ["Ensure good plant spacing", "Mulch around the base"]},
        "Late Blight": {"organic": ["Destroy infected plants immediately", "Apply Copper sprays as prevention"], "chemical": ["Apply systemic fungicides (Mefenoxam) immediately"], "prevention": ["Plant resistant varieties", "Destroy cull piles"]}
      },
      "Rice": {
        "Brown Spot": {"organic": ["Apply organic compost", "Use disease-free seed batches"], "chemical": ["Treat seeds with Captan or Thiram", "Apply Propiconazole spray"], "prevention": ["Apply proper potassium/zinc", "Keep fields well-drained"]},
        "Leaf Blast": {"organic": ["Avoid excessive water logging", "Deeply plow infected crop straw"], "chemical": ["Treat seeds with Tricyclazole", "Apply Isoprothiolane"], "prevention": ["Avoid excessive nitrogen", "Plant blast-resistant cultivars"]},
        "Neck Blast": {"organic": ["Control weeds near fields", "Manage water levels carefully"], "chemical": ["Apply Kasugamycin or Tricyclazole"], "prevention": ["Avoid excessive nitrogen", "Plant blast-resistant cultivars"]}
      },
      "Wheat": {
        "Brown Rust": {"organic": ["Apply Neem oil or Garlic extract", "Remove alternative weed hosts"], "chemical": ["Apply triazole fungicides (Tebuconazole)"], "prevention": ["Plant rust-resistant varieties", "Sow early in the season"]},
        "Yellow Rust": {"organic": ["Prune and destroy infected leaves", "Avoid working in wet fields"], "chemical": ["Apply Triadimefon or Tebuconazole sprays"], "prevention": ["Sow resistant cultivars", "Ensure wide plant spacing"]}
      }
    };
    if (db.containsKey(crop) && db[crop]!.containsKey(disease)) return db[crop]![disease];
    return null;
  }

  Widget _buildCascadingTreatmentView() {
    final data = _getSpecificTreatment(cropName, diseaseName);
    if (data == null) {
      return const Padding(
        padding: EdgeInsets.only(top: 15),
        child: Text("Treatment data for this specific issue is currently unavailable.", style: TextStyle(color: Colors.grey)),
      );
    }

    return Padding(
      padding: const EdgeInsets.only(top: 15),
      child: Container(
        decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(16), boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.04), blurRadius: 10, offset: const Offset(0, 4))]),
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Row(
              children: [
                Icon(Icons.healing, color: Color(0xFF159A6C), size: 24),
                SizedBox(width: 10),
                Text("Recommended Action Plan", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Color(0xFF1C2333))),
              ],
            ),
            const Divider(height: 30),
            _buildTreatmentRow(Icons.eco, "Organic Solutions", data["organic"], const Color(0xFF2ECC71)),
            const SizedBox(height: 15),
            _buildTreatmentRow(Icons.science, "Chemical Solutions", data["chemical"], const Color(0xFFE67E22)),
            const SizedBox(height: 15),
            _buildTreatmentRow(Icons.shield, "Prevention Tactics", data["prevention"], const Color(0xFF3498DB)),
          ],
        ),
      ),
    );
  }

  Widget _buildTreatmentRow(IconData icon, String title, List<String> items, Color color) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(children: [Icon(icon, size: 18, color: color), const SizedBox(width: 8), Text(title, style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold, color: color))]),
        const SizedBox(height: 6),
        ...items.map((item) => Padding(padding: const EdgeInsets.only(left: 26, bottom: 4), child: Row(crossAxisAlignment: CrossAxisAlignment.start, children: [const Text("• ", style: TextStyle(fontSize: 16, color: Colors.grey)), Expanded(child: Text(item, style: const TextStyle(fontSize: 14, color: Color(0xFF1C2333), height: 1.4)))]))),
      ],
    );
  }

  // ==========================================================================
  // SECTION 6: MAIN USER INTERFACE
  // ==========================================================================
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF4F6F5),
      appBar: AppBar(title: const Text('Diagnosis', style: TextStyle(color: Colors.black)), backgroundColor: Colors.white, elevation: 0, iconTheme: const IconThemeData(color: Colors.black)),
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

              // MAIN ACTION BUTTON
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
                                if (cropName == "Unrecognized") {
                                  ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Cannot show treatments for an invalid image.")));
                                  return;
                                }
                                if (status == "Healthy") {
                                  ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Crop is healthy! No treatments required.")));
                                  return;
                                }
                                setState(() { _showTreatments = !_showTreatments; }); 
                              }
                            : runAiAnalysis),
                  child: isLoading
                      ? const SizedBox(width: 24, height: 24, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2))
                      : Text(
                          hasScanned ? (_showTreatments ? "Hide Treatments" : "See Treatments") : "Run AI Scan",
                          style: const TextStyle(fontSize: 19, fontWeight: FontWeight.bold, color: Colors.white), 
                        ),
                ),
              ),
              
              // --- ANIMATED CASCADING TREATMENT VIEW ---
              AnimatedSize(
                duration: const Duration(milliseconds: 300),
                curve: Curves.easeInOutCubic,
                child: _showTreatments ? _buildCascadingTreatmentView() : const SizedBox.shrink(),
              ),

              const SizedBox(height: 15),

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
