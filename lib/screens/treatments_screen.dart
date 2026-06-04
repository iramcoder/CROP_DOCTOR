// ============================================================================
// SECTION 1: IMPORTS
// ============================================================================
import 'package:flutter/material.dart';

class TreatmentsScreen extends StatelessWidget {
  const TreatmentsScreen({super.key});

  // ==========================================================================
  // SECTION 2: TREATMENT DATABASE
  // ==========================================================================
  Map<String, List<Map<String, dynamic>>> _getTreatmentDatabase() {
    return {
      "Corn": [
        {
          "disease": "Common Rust",
          "organic": ["Apply neem oil or sulfur-based organic sprays", "Remove infected foliage near garden plants"],
          "chemical": ["Apply preventative fungicides containing Pyraclostrobin or Azoxystrobin"],
          "prevention": ["Plant resistant corn hybrids", "Destroy infected crop residues after harvest"]
        },
        {
          "disease": "Gray Leaf Spot",
          "organic": ["Apply Bacillus subtilis bio-fungicide sprays", "Rotate crops away from grass families"],
          "chemical": ["Apply strobilurin or triazole group fungicides (e.g., Propiconazole)"],
          "prevention": ["Avoid no-till farming in infected fields", "Maintain highly balanced soil nitrogen"]
        },
        {
          "disease": "Northern Leaf Blight",
          "organic": ["Apply biological fungicides as preventative measures", "Ensure clean tillage to bury residues"],
          "chemical": ["Use foliar fungicides containing Azoxystrobin or Propiconazole"],
          "prevention": ["Choose disease-resistant hybrids", "Rotate with non-host crops like soybeans"]
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
          "organic": ["Destroy all infected plants immediately (do not compost)", "Apply Copper sprays as a preventative"],
          "chemical": ["Apply systemic fungicides like Mefenoxam or Chlorothalonil immediately"],
          "prevention": ["Plant resistant potato varieties", "Destroy cull piles"]
        }
      ],
      "Rice": [
        {
          "disease": "Brown Spot",
          "organic": ["Apply balanced organic compost to correct soil deficiencies", "Use healthy, disease-free seed batches"],
          "chemical": ["Treat seeds with Captan or Thiram", "Apply Propiconazole or Edifenphos foliar spray"],
          "prevention": ["Apply proper potassium and zinc fertilizers", "Keep fields well-drained"]
        },
        {
          "disease": "Leaf Blast",
          "organic": ["Avoid excessive water logging", "Burn or deeply plow infected crop straw after harvest"],
          "chemical": ["Treat seeds with Tricyclazole", "Apply Isoprothiolane"],
          "prevention": ["Avoid excessive nitrogen fertilizer application", "Plant blast-resistant rice cultivars"]
        },
        {
          "disease": "Neck Blast",
          "organic": ["Control weeds near fields", "Manage water levels carefully"],
          "chemical": ["Apply Kasugamycin or Tricyclazole if Neck Blast appears"],
          "prevention": ["Avoid excessive nitrogen fertilizer application", "Plant blast-resistant rice cultivars"]
        }
      ],
      "Wheat": [
        {
          "disease": "Brown Rust",
          "organic": ["Apply botanical sprays like Neem oil or Garlic extract", "Remove alternative weed hosts"],
          "chemical": ["Apply systemic triazole fungicides like Tebuconazole or Propiconazole"],
          "prevention": ["Plant rust-resistant wheat varieties", "Sow early in the season to evade spore spikes"]
        },
        {
          "disease": "Yellow Rust",
          "organic": ["Prune and destroy infected leaves", "Avoid working in wet fields to prevent spore spread"],
          "chemical": ["Apply Triadimefon, Propiconazole, or Tebuconazole foliar sprays immediately"],
          "prevention": ["Sow resistant cultivars", "Ensure wide plant spacing for fast leaf-drying"]
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
          const Text("Cures & Treatments", style: TextStyle(fontSize: 26, fontWeight: FontWeight.bold, color: Color(0xFF1C2333))),
          const SizedBox(height: 8),
          const Text("Browse comprehensive organic, chemical, and preventative treatment plans for all supported crops.", style: TextStyle(fontSize: 16, color: Colors.grey, height: 1.4)),
          const SizedBox(height: 30),

          // --- CROP SECTIONS ---
          _buildCropSection("Corn Treatments", Icons.eco, const Color(0xFFF1C40F), db["Corn"]!),
          const SizedBox(height: 25),
          _buildCropSection("Potato Treatments", Icons.grass, const Color(0xFFD35400), db["Potato"]!),
          const SizedBox(height: 25),
          _buildCropSection("Rice Treatments", Icons.spa, const Color(0xFF1ABC9C), db["Rice"]!),
          const SizedBox(height: 25),
          _buildCropSection("Wheat Treatments", Icons.eco, const Color(0xFFE67E22), db["Wheat"]!), // Swapped to universally compatible Icons.eco
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
