// ============================================================================
// SECTION 1: IMPORTS
// ============================================================================
import 'package:flutter/material.dart';

class DiseasesScreen extends StatelessWidget {
  const DiseasesScreen({super.key});

  // ==========================================================================
  // SECTION 2: DISEASE DETAILS DATABASE
  // ==========================================================================
  Map<String, List<Map<String, dynamic>>> _getDiseaseDetailsDatabase() {
    return {
      "Corn": [
        {
          "disease": "Common Rust",
          "symptoms": ["Golden-brown, powdery, elongated pustules on both leaf surfaces", "Pustules turn black as the plant matures"],
          "causes": ["Puccinia sorghi fungus", "Spreads via wind-blown spores in high humidity"],
          "impact": ["Interrupts photosynthesis, leading to smaller ears of corn and reduced starch yield"]
        },
        {
          "disease": "Gray Leaf Spot",
          "symptoms": ["Rectangular, tan-to-grey lesions restricted by leaf veins", "A greyish, dusty appearance when spores are actively producing"],
          "causes": ["Cercospora zeae-maydis fungus", "Thrives in warm, wet climates and minimum-till fields"],
          "impact": ["Severe defoliation restricts stalk strength and can cause complete lodging (falling) of the crop"]
        },
        {
          "disease": "Northern Leaf Blight",
          "symptoms": ["Long, cigar-shaped, grey-green to tan lesions on leaves", "Lesions start on lower leaves and progress upwards"],
          "causes": ["Exserohilum turcicum fungus", "Thrives in moderate temperatures with heavy dew and rainfall"],
          "impact": ["Drastically reduces grain production if infection occurs prior to silking"]
        }
      ],
      "Potato": [
        {
          "disease": "Early Blight",
          "symptoms": ["Dark, concentric rings (bullseye pattern) on older leaves", "Yellowing around the leaf spots", "Dark, sunken lesions on potato tubers"],
          "causes": ["Alternaria solani fungus", "Spreads rapidly during alternating wet and dry weather"],
          "impact": ["Premature leaf death limits tuber size and yield"]
        },
        {
          "disease": "Late Blight",
          "symptoms": ["Large, dark, water-soaked lesions on leaves", "White, fuzzy mold on the undersides of leaves in high humidity", "Tubers develop dry, corky rot"],
          "causes": ["Phytophthora infestans (a water mold)", "Extremely contagious in cool, wet weather"],
          "impact": ["Can destroy an entire field within days if left unchecked"]
        }
      ],
      "Rice": [
        {
          "disease": "Brown Spot",
          "symptoms": ["Small, oval, dark brown spots with a greyish-center", "Spots are evenly distributed across the entire leaf blade"],
          "causes": ["Bipolaris oryzae fungus", "Thrives in nutrient-deficient, poorly drained soils"],
          "impact": ["Reduces grain weight, causing chalky kernels and severe milling losses"]
        },
        {
          "disease": "Leaf Blast",
          "symptoms": ["Eye-shaped (spindle) spots with dark borders and grey centers on leaves"],
          "causes": ["Magnaporthe oryzae fungus", "Highly destructive in fields with high nitrogen fertilizer and high humidity"],
          "impact": ["Severe leaf death reducing crop yield significantly"]
        },
        {
          "disease": "Neck Blast",
          "symptoms": ["Brownish-black lesions at the collar of the seed head causing the neck to collapse"],
          "causes": ["Magnaporthe oryzae fungus", "Spreads from leaves to the neck during high humidity"],
          "impact": ["Can cause 100% crop loss as it prevents the grains from filling up with starch"]
        }
      ],
      "Wheat": [
        {
          "disease": "Brown Rust",
          "symptoms": ["Small, circular, orange-brown pustules scattered randomly on leaves", "Pustules rupture the leaf skin to release dusty orange spores"],
          "causes": ["Puccinia triticina fungus", "Spreads rapidly in moderate temperatures with high humidity"],
          "impact": ["Reduces kernel size, wheat quality, and straw strength"]
        },
        {
          "disease": "Yellow Rust",
          "symptoms": ["Narrow, linear, yellow-to-orange stripes of pustules on the leaf veins", "Leaves dry out and die from the tip down"],
          "causes": ["Puccinia striiformis fungus", "Thrives in cooler climates (typical of early spring)"],
          "impact": ["Causes severe shriveling of grains and can decrease grain yields by 50% or more"]
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
          const Text("Identify Diseases", style: TextStyle(fontSize: 26, fontWeight: FontWeight.bold, color: Color(0xFF1C2333))),
          const SizedBox(height: 8),
          const Text("Identify and understand the symptoms, causes, and impacts of various crop diseases.", style: TextStyle(fontSize: 16, color: Colors.grey, height: 1.4)),
          const SizedBox(height: 30),

          // --- CROP SECTIONS ---
          _buildCropSection("Corn Diseases", Icons.eco, const Color(0xFFF1C40F), db["Corn"]!),
          const SizedBox(height: 25),
          _buildCropSection("Potato Diseases", Icons.grass, const Color(0xFFD35400), db["Potato"]!),
          const SizedBox(height: 25),
          _buildCropSection("Rice Diseases", Icons.spa, const Color(0xFF1ABC9C), db["Rice"]!),
          const SizedBox(height: 25),
          _buildCropSection("Wheat Diseases", Icons.eco, const Color(0xFFE67E22), db["Wheat"]!), // Swapped to universally compatible Icons.eco
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
