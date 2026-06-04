// ============================================================================
// SECTION 1: IMPORTS
// ============================================================================
import 'package:flutter/material.dart';

class TreatmentsScreen extends StatelessWidget {
  const TreatmentsScreen({super.key});

  // ==========================================================================
  // SECTION 2: TREATMENT DATABASE
  // Grouped by Crop. Contains Organic, Chemical, and Preventative measures.
  // ==========================================================================
  Map<String, List<Map<String, dynamic>>> _getTreatmentDatabase() {
    return {
      "Pepper": [
        {
          "disease": "Bacterial Spot",
          "organic": ["Prune and destroy infected leaves", "Spray with copper-based organic fungicides"],
          "chemical": ["Apply Copper hydroxide sprays", "Apply Streptomycin if permitted"],
          "prevention": ["Rotate crops annually", "Avoid overhead watering"]
        }
      ],
      "Potato": [
        {
          "disease": "Early Blight",
          "organic": ["Remove lower infected leaves", "Apply compost tea or baking soda spray"],
          "chemical": ["Apply Chlorothalonil or Mancozeb fungicides", "Use Azoxystrobin sprays"],
          "prevention": ["Ensure good plant spacing for airflow", "Mulch around the base"]
        },
        {
          "disease": "Late Blight",
          "organic": ["Destroy all infected plants immediately", "Apply Copper sprays as a preventative"],
          "chemical": ["Apply systemic fungicides like Mefenoxam or Chlorothalonil immediately"],
          "prevention": ["Plant resistant potato varieties", "Destroy cull piles"]
        }
      ],
      "Tomato": [
        {
          "disease": "Bacterial Spot",
          "organic": ["Remove heavily infected foliage", "Use a fixed-copper organic spray"],
          "chemical": ["Apply Copper-based bactericides combined with Mancozeb"],
          "prevention": ["Water at the base of the plant only", "Disinfect gardening tools"]
        },
        {
          "disease": "Early Blight",
          "organic": ["Trim lower leaves touching the soil", "Apply Neem oil or Bacillus subtilis"],
          "chemical": ["Spray with Chlorothalonil or Copper fungicides every 7 days"],
          "prevention": ["Use mulch to prevent soil splashing", "Stake or cage tomatoes"]
        },
        {
          "disease": "Late Blight",
          "organic": ["Pull up and destroy infected plants immediately", "Apply preventative Copper spray"],
          "chemical": ["Apply Mancozeb, Chlorothalonil, or Copper fungicides"],
          "prevention": ["Keep foliage dry", "Ensure excellent air circulation"]
        },
        {
          "disease": "Leaf Mold",
          "organic": ["Prune branches to improve airflow", "Reduce humidity in greenhouses"],
          "chemical": ["Apply Chlorothalonil or Calcium polysulfide"],
          "prevention": ["Water early in the day", "Space plants widely"]
        },
        {
          "disease": "Septoria Leaf Spot",
          "organic": ["Remove infected leaves immediately", "Apply bio-fungicides like Serenade"],
          "chemical": ["Spray with Mancozeb or Chlorothalonil-based fungicides"],
          "prevention": ["Remove weeds and debris", "Do not work with plants when wet"]
        },
        {
          "disease": "Spotted Spider Mites",
          "organic": ["Introduce predatory ladybugs", "Spray with insecticidal soap or Neem oil"],
          "chemical": ["Apply specific miticides if infestation is severe"],
          "prevention": ["Keep plants well-watered", "Remove infested debris"]
        },
        {
          "disease": "Target Spot",
          "organic": ["Remove infected plant parts", "Improve air circulation around canopy"],
          "chemical": ["Apply Azoxystrobin or Chlorothalonil"],
          "prevention": ["Avoid overhead irrigation", "Use proper plant spacing"]
        },
        {
          "disease": "Mosaic Virus",
          "organic": ["No cure exists. Pull and destroy infected plants immediately."],
          "chemical": ["No chemical treatments exist for viruses."],
          "prevention": ["Wash hands with soap before handling", "Disinfect tools with bleach"]
        },
        {
          "disease": "Yellow Leaf Curl Virus",
          "organic": ["Remove infected plants", "Control whiteflies with yellow sticky traps"],
          "chemical": ["Use insecticides like Imidacloprid to control whiteflies"],
          "prevention": ["Use reflective mulches", "Plant resistant tomato varieties"]
        }
      ]
    };
  }

  // ==========================================================================
  // SECTION 3: THE USER INTERFACE
  // ==========================================================================
  @override
  Widget build(BuildContext context) {
    final db = _getTreatmentDatabase();

    return Scaffold(
      backgroundColor: const Color(0xFFF4F6F5),
      appBar: AppBar(
        title: const Text('Treatment Guide', style: TextStyle(color: Colors.black)),
        backgroundColor: Colors.white,
        elevation: 0,
        iconTheme: const IconThemeData(color: Colors.black),
      ),
      body: ListView(
        padding: const EdgeInsets.all(20.0),
        children: [
          const Text(
            "Cures & Treatments",
            style: TextStyle(fontSize: 26, fontWeight: FontWeight.bold, color: Color(0xFF1C2333)),
          ),
          const SizedBox(height: 8),
          const Text(
            "Browse comprehensive organic, chemical, and preventative treatment plans for all supported crops.",
            style: TextStyle(fontSize: 16, color: Colors.grey, height: 1.4),
          ),
          const SizedBox(height: 30),

          // --- CROP SECTIONS ---
          _buildCropSection("Pepper Treatments", Icons.eco, const Color(0xFF27AE60), db["Pepper"]!),
          const SizedBox(height: 25),
          _buildCropSection("Potato Treatments", Icons.grass, const Color(0xFFD35400), db["Potato"]!),
          const SizedBox(height: 25),
          _buildCropSection("Tomato Treatments", Icons.local_florist, const Color(0xFFE74C3C), db["Tomato"]!),
          const SizedBox(height: 40),
        ],
      ),
    );
  }

  // ==========================================================================
  // SECTION 4: REUSABLE UI BUILDERS
  // ==========================================================================
  Widget _buildCropSection(String title, IconData icon, Color themeColor, List<Map<String, dynamic>> diseases) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(color: themeColor.withOpacity(0.15), borderRadius: BorderRadius.circular(10)),
              child: Icon(icon, color: themeColor, size: 24),
            ),
            const SizedBox(width: 15),
            Text(title, style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: themeColor)),
          ],
        ),
        const SizedBox(height: 15),
        ...diseases.map((data) => _buildExpandableCard(data, themeColor)),
      ],
    );
  }

  Widget _buildExpandableCard(Map<String, dynamic> data, Color themeColor) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Container(
        decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(16), boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.04), blurRadius: 8, offset: const Offset(0, 2))]),
        child: Theme(
          data: ThemeData().copyWith(dividerColor: Colors.transparent),
          child: ExpansionTile(
            iconColor: themeColor, collapsedIconColor: Colors.grey,
            title: Text(data["disease"], style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Color(0xFF1C2333))),
            childrenPadding: const EdgeInsets.only(left: 20, right: 20, bottom: 20),
            expandedCrossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Divider(), const SizedBox(height: 10),
              _buildRow(Icons.eco, "Organic:", data["organic"], const Color(0xFF2ECC71)), const SizedBox(height: 15),
              _buildRow(Icons.science, "Chemical:", data["chemical"], const Color(0xFFE67E22)), const SizedBox(height: 15),
              _buildRow(Icons.shield, "Prevention:", data["prevention"], const Color(0xFF3498DB)),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildRow(IconData icon, String title, List<String> items, Color color) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(children: [Icon(icon, size: 20, color: color), const SizedBox(width: 8), Text(title, style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: color))]),
        const SizedBox(height: 6),
        ...items.map((item) => Padding(padding: const EdgeInsets.only(left: 28, bottom: 4), child: Row(crossAxisAlignment: CrossAxisAlignment.start, children: [const Text("• ", style: TextStyle(fontSize: 16, color: Colors.grey)), Expanded(child: Text(item, style: const TextStyle(fontSize: 14, color: Color(0xFF1C2333), height: 1.4)))]))),
      ],
    );
  }
}
