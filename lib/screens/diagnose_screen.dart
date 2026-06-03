// ============================================================================
// SECTION 1: IMPORTS
// ============================================================================
import 'dart:io';
import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:tflite_v2/tflite_v2.dart';
import 'package:path_provider/path_provider.dart';
import 'login_screen.dart'; // NEW: Imported to allow returning to the Login screen

class DiagnoseScreen extends StatefulWidget {
  final Uint8List imageBytes; // Receives the photo bytes from the HomeScreen
  const DiagnoseScreen({super.key, required this.imageBytes});

  @override
  State<DiagnoseScreen> createState() => _DiagnoseScreenState();
}

class _DiagnoseScreenState extends State<DiagnoseScreen> {
  // ==========================================================================
  // SECTION 2: VARIABLES
  // These hold the state of our AI analysis.
  // ==========================================================================
  String cropName = "Pending...";
  String diseaseName = "Waiting to scan...";
  String status = "Waiting to scan...";
  String rawLabel = ""; // Stores the exact label for the treatment dictionary
  int confidence = 0;
  bool isLoading = false;
  bool hasScanned = false; // Tracks if the AI has finished running
  File? _tempImageFile; // A temporary file we create to feed the AI

  // ==========================================================================
  // SECTION 3: INITIALIZATION
  // Runs once when the screen opens. Loads the model and preps the image.
  // ==========================================================================
  @override
  void initState() {
    super.initState();
    _loadModel();
    _saveBytesToTempFile();
  }

  // Loads the .tflite model and labels into memory
  Future<void> _loadModel() async {
    try {
      await Tflite.loadModel(
        model: "assets/model.tflite",
        labels: "assets/labels.txt",
        numThreads: 1,
        isAsset: true,
        useGpuDelegate: false,
      );
    } catch (e) {
      print("Failed to load model: $e");
    }
  }

  // TFLite requires a physical file path. This converts our raw bytes into a temporary .jpg file.
  Future<void> _saveBytesToTempFile() async {
    final tempDir = await getTemporaryDirectory();
    final file = await File('${tempDir.path}/temp_crop.jpg').create();
    file.writeAsBytesSync(widget.imageBytes);
    setState(() {
      _tempImageFile = file;
    });
  }

  // ==========================================================================
  // SECTION 4: AI INFERENCE ENGINE
  // Feeds the image into the neural network and parses the output.
  // ==========================================================================
  Future<void> runAiAnalysis() async {
    if (_tempImageFile == null) return;

    // Show the loading spinner
    setState(() {
      isLoading = true;
    });

    try {
      // Run the image through the AI model with Teachable Machine formatting
      var recognitions = await Tflite.runModelOnImage(
        path: _tempImageFile!.path,
        imageMean: 127.5,
        imageStd: 127.5,
        numResults: 15, // Evaluates all 15 labels
        threshold: 0.05, 
        asynch: true,
      );

      // If we got a valid guess back from the AI
      if (recognitions != null && recognitions.isNotEmpty) {
        String label = recognitions[0]['label'];
        double conf = recognitions[0]['confidence'];

        // Clean up the label string (removes leading numbers if they exist)
        label = label.replaceAll(RegExp(r'^[0-9]+\s'), '').trim();
        List<String> words = label.split(' ');

        String crop = "";
        String disease = "";

        // Parse out the Crop vs the Disease
        if (words.isNotEmpty) {
          crop = words[0]; // First word is the Crop (e.g., "Tomato")
          if (words.length > 1) {
            disease = words.sublist(1).join(' '); // Remaining words are the disease
          } else {
            disease = "Unknown Status";
          }
        }

        // Check if the word "Healthy" is in the disease string
        bool healthy = disease.toLowerCase().contains("healthy");

        // Update the screen with the results!
        setState(() {
          rawLabel = label; 
          cropName = crop;
          diseaseName = healthy ? "Healthy Crop" : disease;
          status = healthy ? "Healthy" : "Needs Attention";
          confidence = (conf * 100).toInt();
          isLoading = false;
          hasScanned = true;
        });
      } else {
        // AI couldn't figure it out
        setState(() {
          diseaseName = "Unrecognized Object";
          status = "Failed";
          isLoading = false;
          hasScanned = true;
        });
      }
    } catch (e) {
      setState(() {
        isLoading = false;
        diseaseName = "Error running model";
        status = "Failed";
        hasScanned = true;
      });
      print("Inference Error: $e");
    }
  }

  // Frees up memory when we leave this screen
  @override
  void dispose() {
    Tflite.close();
    super.dispose();
  }

  // ==========================================================================
  // SECTION 5: THE USER INTERFACE (UI)
  // ==========================================================================
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF4F6F5),
      appBar: AppBar(
        title: const Text('Crop Analysis', style: TextStyle(color: Colors.black)),
        backgroundColor: Colors.white,
        elevation: 0,
        iconTheme: const IconThemeData(color: Colors.black),
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(20.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // --- THE UPLOADED IMAGE ---
              ClipRRect(
                borderRadius: BorderRadius.circular(16),
                child: Image.memory(
                  widget.imageBytes,
                  width: double.infinity,
                  height: 300,
                  fit: BoxFit.cover,
                ),
              ),
              const SizedBox(height: 30),

              // --- RESULTS HEADER ---
              const Text(
                "AI Analysis Results",
                style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: Color(0xFF1C2333)),
              ),
              const SizedBox(height: 15),

              // --- RESULTS CARD ---
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(16),
                  boxShadow: [
                    BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 10, offset: const Offset(0, 4)),
                  ],
                ),
                child: isLoading
                    ? const Center(
                        child: Padding(
                          padding: EdgeInsets.all(20.0),
                          child: CircularProgressIndicator(color: Color(0xFF159A6C)),
                        ),
                      )
                    : Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          ResultRow(label: "Detected Crop", value: cropName),
                          const Divider(height: 30),
                          ResultRow(
                            label: "Disease / Health",
                            value: diseaseName,
                            isAlert: status != "Healthy" && status != "Waiting to scan...",
                          ),
                          const Divider(height: 30),
                          ResultRow(label: "Confidence Score", value: "$confidence%"),
                        ],
                      ),
              ),
              const SizedBox(height: 30),

              // --- MAIN ACTION BUTTON (Run Scan / See Treatments) ---
              SizedBox(
                width: double.infinity,
                height: 55,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF159A6C),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                  ),
                  onPressed: (_tempImageFile == null || isLoading)
                      ? null // Disable if no image or currently loading
                      : (hasScanned
                            ? () {
                                // Navigate to the dynamic Treatment Screen!
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (context) => TreatmentScreen(
                                      crop: cropName,
                                      disease: diseaseName,
                                      labelKey: rawLabel,
                                      isHealthy: status == "Healthy",
                                    ),
                                  ),
                                );
                              }
                            : runAiAnalysis),
                  child: isLoading
                      ? const SizedBox(width: 24, height: 24, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2))
                      : Text(
                          hasScanned ? "See Treatments" : "Run AI Scan",
                          style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.white),
                        ),
                ),
              ),
              
              const SizedBox(height: 15),

              // --- NEW: SECONDARY ACTION BUTTONS (Scan Again / Switch User) ---
              // These buttons only appear clearly when not loading, allowing the user to navigate away easily.
              if (!isLoading) 
                Row(
                  children: [
                    // Button 1: Go back to Home Screen to scan another plant
                    Expanded(
                      child: OutlinedButton.icon(
                        style: OutlinedButton.styleFrom(
                          padding: const EdgeInsets.symmetric(vertical: 14),
                          foregroundColor: const Color(0xFF159A6C),
                          side: const BorderSide(color: Color(0xFF159A6C)),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                        ),
                        icon: const Icon(Icons.refresh),
                        label: const Text("Scan Again", style: TextStyle(fontWeight: FontWeight.bold)),
                        onPressed: () {
                          Navigator.pop(context); // Pops this screen off, returning to Home
                        },
                      ),
                    ),
                    const SizedBox(width: 15),
                    
                    // Button 2: Log out / Switch User
                    Expanded(
                      child: OutlinedButton.icon(
                        style: OutlinedButton.styleFrom(
                          padding: const EdgeInsets.symmetric(vertical: 14),
                          foregroundColor: Colors.grey[700],
                          side: BorderSide(color: Colors.grey[400]!),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                        ),
                        icon: const Icon(Icons.people_alt_outlined),
                        label: const Text("Switch User", style: TextStyle(fontWeight: FontWeight.bold)),
                        onPressed: () {
                          // Clears the entire navigation history and goes back to the Login Screen
                          Navigator.pushAndRemoveUntil(
                            context,
                            MaterialPageRoute(builder: (context) => const LoginScreen()),
                            (route) => false, 
                          );
                        },
                      ),
                    ),
                  ],
                ),
                
              const SizedBox(height: 30), // Bottom padding
            ],
          ),
        ),
      ),
    );
  }
}

// ==========================================================================
// SECTION 6: REUSABLE UI WIDGETS
// ==========================================================================

// Prevents text overflow by wrapping values nicely
class ResultRow extends StatelessWidget {
  final String label;
  final String value;
  final bool isAlert;

  const ResultRow({super.key, required this.label, required this.value, this.isAlert = false});

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: const TextStyle(fontSize: 16, color: Colors.grey, fontWeight: FontWeight.w500)),
        const SizedBox(width: 16),
        Expanded(
          child: Text(
            value,
            textAlign: TextAlign.right,
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: isAlert ? const Color(0xFFE74C3C) : const Color(0xFF1C2333),
            ),
          ),
        ),
      ],
    );
  }
}

// =========================================================================
// SECTION 7: DEDICATED TREATMENT SCREEN
// Handles displaying the cures for the detected diseases.
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

  // Treatment Database mapped exactly to your 15 labels
  Map<String, Map<String, List<String>>> _getTreatmentData() {
    return {
      "Pepper Bell Bacterial Spot": {
        "Organic": ["Prune and destroy infected leaves", "Spray with copper-based organic fungicides"],
        "Chemical": ["Apply Copper hydroxide sprays", "Apply Streptomycin if permitted"],
        "Prevention": ["Rotate crops annually", "Avoid overhead watering"],
      },
      "Potato Early Blight": {
        "Organic": ["Remove lower infected leaves", "Apply compost tea or baking soda spray"],
        "Chemical": ["Apply Chlorothalonil or Mancozeb fungicides", "Use Azoxystrobin sprays"],
        "Prevention": ["Ensure good plant spacing for airflow", "Mulch around the base"],
      },
      "Potato Late Blight": {
        "Organic": ["Destroy all infected plants immediately (do not compost)", "Apply Copper sprays as a preventative"],
        "Chemical": ["Apply systemic fungicides like Mefenoxam or Chlorothalonil immediately"],
        "Prevention": ["Plant resistant potato varieties", "Destroy cull piles"],
      },
      "Tomato Bacterial Spot": {
        "Organic": ["Remove heavily infected foliage", "Use a fixed-copper organic spray"],
        "Chemical": ["Apply Copper-based bactericides combined with Mancozeb"],
        "Prevention": ["Water at the base of the plant only", "Disinfect gardening tools"],
      },
      "Tomato Early Blight": {
        "Organic": ["Trim lower leaves touching the soil", "Apply Neem oil or Bacillus subtilis"],
        "Chemical": ["Spray with Chlorothalonil or Copper fungicides every 7 days"],
        "Prevention": ["Use mulch to prevent soil splashing", "Stake or cage tomatoes"],
      },
      "Tomato Late Blight": {
        "Organic": ["Pull up and destroy infected plants immediately", "Apply preventative Copper spray"],
        "Chemical": ["Apply Mancozeb, Chlorothalonil, or Copper fungicides"],
        "Prevention": ["Keep foliage dry", "Ensure excellent air circulation"],
      },
      "Tomato Leaf Mold": {
        "Organic": ["Prune branches to improve airflow", "Reduce humidity in greenhouses"],
        "Chemical": ["Apply Chlorothalonil or Calcium polysulfide"],
        "Prevention": ["Water early in the day", "Space plants widely"],
      },
      "Tomato Septoria Leaf Spot": {
        "Organic": ["Remove infected leaves immediately", "Apply bio-fungicides like Serenade"],
        "Chemical": ["Spray with Mancozeb or Chlorothalonil-based fungicides"],
        "Prevention": ["Remove weeds and debris", "Do not work with plants when they are wet"],
      },
      "Tomato Spotted Spider Mites": {
        "Organic": ["Introduce predatory ladybugs", "Spray with insecticidal soap or Neem oil", "Spray plants with a strong stream of water"],
        "Chemical": ["Apply specific miticides (Acaricides) if infestation is severe", "Avoid broad-spectrum insecticides"],
        "Prevention": ["Keep plants well-watered (mites love dry conditions)", "Remove infested debris"],
      },
      "Tomato Target Spot": {
        "Organic": ["Remove infected plant parts", "Improve air circulation around the canopy"],
        "Chemical": ["Apply Azoxystrobin or Chlorothalonil"],
        "Prevention": ["Avoid overhead irrigation", "Use proper plant spacing"],
      },
      "Tomato Mosaic Virus": {
        "Organic": ["No cure exists. Pull and destroy infected plants immediately (do not compost)."],
        "Chemical": ["No chemical treatments exist for viruses."],
        "Prevention": ["Wash hands with soap before handling plants", "Disinfect tools with bleach", "Do not use tobacco products near plants"],
      },
      "Tomato Yellow Leaf Curl Virus": {
        "Organic": ["Remove infected plants", "Control whitefly populations with yellow sticky traps or Neem oil"],
        "Chemical": ["Use insecticides like Imidacloprid to control the whiteflies that spread the virus"],
        "Prevention": ["Use reflective mulches", "Plant resistant tomato varieties"],
      },
    };
  }

  @override
  Widget build(BuildContext context) {
    // If the crop is healthy, show a congratulatory screen!
    if (isHealthy) {
      return Scaffold(
        backgroundColor: const Color(0xFFF4F6F5),
        appBar: AppBar(
          backgroundColor: Colors.white,
          title: const Text("Diagnosis", style: TextStyle(color: Colors.black)),
          iconTheme: const IconThemeData(color: Colors.black),
        ),
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.check_circle, color: Color(0xFF2ECC71), size: 100),
              const SizedBox(height: 20),
              Text("Your $crop looks perfectly healthy!", style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
              const SizedBox(height: 10),
              const Text("Keep up the great farming practices.", style: TextStyle(color: Colors.grey, fontSize: 16)),
            ],
          ),
        ),
      );
    }

    // Match label to dictionary (Fallback to generic if exact match fails)
    final treatments = _getTreatmentData();
    String matchedKey = treatments.keys.firstWhere(
      (k) => labelKey.toLowerCase().contains(k.toLowerCase()),
      orElse: () => "Fallback",
    );

    Map<String, List<String>> plan = treatments[matchedKey] ?? {
      "Organic": ["Remove infected leaves", "Ensure good airflow and sunlight"],
      "Chemical": ["Consult a local agricultural expert for specific fungicides"],
      "Prevention": ["Rotate crops next season", "Avoid overhead watering"],
    };

    return Scaffold(
      backgroundColor: const Color(0xFFF4F6F5),
      appBar: AppBar(
        title: const Text('Treatment Plan', style: TextStyle(color: Colors.black)),
        backgroundColor: Colors.white,
        elevation: 0,
        iconTheme: const IconThemeData(color: Colors.black),
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(20.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text("Diagnosis: $crop", style: const TextStyle(fontSize: 16, color: Colors.grey, fontWeight: FontWeight.w600)),
              const SizedBox(height: 5),
              Text(disease, style: const TextStyle(fontSize: 26, fontWeight: FontWeight.bold, color: Color(0xFFE74C3C))),
              const SizedBox(height: 25),

              _buildTreatmentCard("Organic Treatments", Icons.eco, const Color(0xFF2ECC71), plan["Organic"]!),
              const SizedBox(height: 20),
              _buildTreatmentCard("Chemical Treatments", Icons.science, const Color(0xFFE67E22), plan["Chemical"]!),
              const SizedBox(height: 20),
              _buildTreatmentCard("Prevention Tips", Icons.shield, const Color(0xFF3498DB), plan["Prevention"]!),
            ],
          ),
        ),
      ),
    );
  }

  // Generates the nice white cards containing the list of treatments
  Widget _buildTreatmentCard(String title, IconData icon, Color color, List<String> items) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 10, offset: const Offset(0, 4)),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(color: color.withOpacity(0.15), borderRadius: BorderRadius.circular(10)),
                child: Icon(icon, color: color, size: 24),
              ),
              const SizedBox(width: 15),
              Text(title, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Color(0xFF1C2333))),
            ],
          ),
          const SizedBox(height: 15),
          ...items.map(
            (item) => Padding(
              padding: const EdgeInsets.only(bottom: 10),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text("• ", style: TextStyle(fontSize: 18, color: Colors.grey)),
                  Expanded(
                    child: Text(item, style: const TextStyle(fontSize: 15, color: Color(0xFF1C2333), height: 1.4)),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
