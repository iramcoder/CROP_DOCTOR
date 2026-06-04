// ============================================================================
// SECTION 1: IMPORTS
// ============================================================================
import 'package:flutter/material.dart';

class DiseasesScreen extends StatelessWidget {
  const DiseasesScreen({super.key});

  // ==========================================================================
  // SECTION 2: DISEASE DETAILS DATABASE
  // Focuses on identifying and understanding the diseases.
  // ==========================================================================
  Map<String, List<Map<String, dynamic>>> _getDiseaseDetailsDatabase() {
    return {
      "Pepper": [
        {
          "disease": "Bacterial Spot",
          "symptoms": ["Water-soaked spots on leaves that turn brown/black", "Leaves may turn yellow and drop prematurely", "Raised, scabby spots on the pepper fruit"],
          "causes": ["Caused by Xanthomonas bacteria", "Thrives in warm, highly humid, and wet weather"],
          "impact": ["Severe defoliation reduces fruit yield", "Sun-scald on exposed fruit"]
        }
      ],
      "Potato": [
        {
          "disease": "Early Blight",
          "symptoms": ["Dark, concentric rings (bullseye pattern) on older leaves", "Yellowing around the leaf spots", "Dark, sunken lesions on potato tubers"],
          "causes": ["Caused by the Alternaria solani fungus", "Spreads rapidly during alternating wet and dry weather"],
          "impact": ["Premature leaf death limits tuber size and yield"]
        },
        {
          "disease": "Late Blight",
          "symptoms": ["Large, dark, water-soaked lesions on leaves", "White, fuzzy mold on the undersides of leaves in high humidity", "Tubers develop dry, corky rot"],
          "causes": ["Caused by Phytophthora infestans (a water mold)", "Extremely contagious in cool, wet weather"],
          "impact": ["Can destroy an entire field within days if left unchecked"]
        }
      ],
      "Tomato": [
        {
          "disease": "Bacterial Spot",
          "symptoms": ["Small, dark, greasy spots on leaves", "Spots on fruit that look like tiny, raised scabs"],
          "causes": ["Xanthomonas bacteria spread by splashing rain or tools"],
          "impact": ["Causes early leaf drop and unmarketable fruit"]
        },
        {
          "disease": "Early Blight",
          "symptoms": ["Bullseye-patterned spots starting on the lowest leaves", "Heavy yellowing around the spots"],
          "causes": ["Alternaria solani fungus dwelling in the soil"],
          "impact": ["Defoliation exposes fruit to sunscald and reduces yield"]
        },
        {
          "disease": "Late Blight",
          "symptoms": ["Irregular greenish-black water-soaked patches", "Rapid wilting of the entire plant"],
          "causes": ["Phytophthora infestans spreading via wind-blown spores"],
          "impact": ["Total crop failure; highly destructive"]
        },
        {
          "disease": "Leaf Mold",
          "symptoms": ["Pale green or yellow spots on the upper leaf surface", "Olive-green to brown velvety mold on the bottom"],
          "causes": ["Passalora fulva fungus", "Thrives in greenhouses with poor ventilation and high humidity"],
          "impact": ["Reduces photosynthetic area, weakening the plant"]
        },
        {
          "disease": "Septoria Leaf Spot",
          "symptoms": ["Numerous small, circular spots with dark borders and grey/tan centers", "Tiny black specks in the center of the spots"],
          "causes": ["Septoria lycopersici fungus from infected plant debris"],
          "impact": ["Vigorous defoliation starting from the bottom up"]
        },
        {
          "disease": "Spotted Spider Mites",
          "symptoms": ["Tiny yellow or white speckles (stippling) on leaves", "Fine, silky webbing visible on stems and leaves"],
          "causes": ["Tetranychus urticae (a tiny pest, not a fungus)", "Thrive in hot, very dry conditions"],
          "impact": ["Leaves dry up and fall off; severe stress to the plant"]
        },
        {
          "disease": "Target Spot",
          "symptoms": ["Small brown spots with yellow halos", "Spots develop into target-like concentric circles"],
          "causes": ["Corynespora cassiicola fungus"],
          "impact": ["Causes lesions on both leaves and fruit, causing rot"]
        },
        {
          "disease": "Mosaic Virus",
          "symptoms": ["Mottled light and dark green patterns on leaves", "Leaves become fern-like or stringy", "Stunted overall plant growth"],
          "causes": ["ToMV virus", "Spread easily by contaminated hands, tools, or tobacco products"],
          "impact": ["Incurable. Permanently stunts growth and fruit production"]
        },
        {
          "disease": "Yellow Leaf Curl Virus",
          "symptoms": ["Severe upward curling and crinkling of leaves", "Yellowing of leaf margins", "Flowers drop before setting fruit"],
          "causes": ["TYLCV virus, transmitted almost exclusively by Silverleaf Whiteflies"],
          "impact": ["Devastating to yields; plants stop producing completely"]
        }
      ]
    };
  }

  // ==========================================================================
  // SECTION 3: THE USER INTERFACE
  // ==========================================================================
  @override
  Widget build(BuildContext context) {
    final db = _getDiseaseDetailsDatabase();

    return Scaffold(
      backgroundColor: const Color(0xFFF4F6F5),
      appBar: AppBar(
        title: const Text('Disease Encyclopedia', style: TextStyle(color: Colors.black)),
        backgroundColor: Colors.white,
        elevation: 0,
        iconTheme: const IconThemeData(color: Colors.black),
      ),
      body: ListView(
        padding: const EdgeInsets.all(20.0),
        children: [
          const Text(
            "Identify Diseases",
            style: TextStyle(fontSize: 26, fontWeight: FontWeight.bold, color: Color(0xFF1C2333)),
          ),
          const SizedBox(height: 8),
          const Text(
            "Identify and understand the symptoms, causes, and impacts of various crop diseases.",
            style: TextStyle(fontSize: 16, color: Colors.grey, height: 1.4),
          ),
          const SizedBox(height: 30),

          // --- CROP SECTIONS ---
          _buildCropSection("Pepper Diseases", Icons.eco, const Color(0xFF27AE60), db["Pepper"]!),
          const SizedBox(height: 25),
          _buildCropSection("Potato Diseases", Icons.grass, const Color(0xFFD35400), db["Potato"]!),
          const SizedBox(height: 25),
          _buildCropSection("Tomato Diseases", Icons.local_florist, const Color(0xFFE74C3C), db["Tomato"]!),
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
              // Updated to show Symptoms, Causes, and Impact
              _buildRow(Icons.warning_amber_rounded, "Symptoms:", data["symptoms"], const Color(0xFFE67E22)), const SizedBox(height: 15),
              _buildRow(Icons.biotech, "Causes:", data["causes"], const Color(0xFF8E44AD)), const SizedBox(height: 15),
              _buildRow(Icons.trending_down, "Impact:", data["impact"], const Color(0xFFE74C3C)),
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
