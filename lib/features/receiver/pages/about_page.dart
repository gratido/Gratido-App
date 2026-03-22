import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'feedback_form.dart';

class AboutPage extends StatelessWidget {
  const AboutPage({super.key});

  static const primaryColor = Color(0xFF6E5CD6);
  static const bgColor = Color(0xFFF7F3FF);

  Future<void> _contactUs() async {
    final Uri uri = Uri(
      scheme: 'mailto',
      path: 'gratido4025@gmail.com',
      query: Uri.encodeQueryComponent(
        'subject=Contact Gratido&body=Hello Gratido Team,',
      ),
    );
    await launchUrl(uri, mode: LaunchMode.externalApplication);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: bgColor,
      appBar: AppBar(
        elevation: 0,
        backgroundColor: Colors.white,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black87),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text(
          "About Gratido",
          style: TextStyle(fontWeight: FontWeight.w700, color: Colors.black87),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            _card(_hero()),
            const SizedBox(height: 16),
            _banner(),
            const SizedBox(height: 16),
            _card(_about()),
            const SizedBox(height: 16),
            _missionVisionFixed(),
            const SizedBox(height: 16),
            _card(_valuesFixed()),
            const SizedBox(height: 16),
            _card(_howItWorks()),
            const SizedBox(height: 16),
            _card(_contact(context)),
            const SizedBox(height: 24),
            const Text(
              "Version 1.0 • © Gratido 2025",
              style: TextStyle(fontSize: 12, color: Colors.black54),
            ),
            const SizedBox(height: 40),
          ],
        ),
      ),
    );
  }

  Widget _card(Widget child) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(22),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
      ),
      child: child,
    );
  }

  Widget _hero() {
    return Row(
      children: [
        Container(
          width: 56,
          height: 56,
          decoration: BoxDecoration(
            color: primaryColor.withOpacity(.15),
            borderRadius: BorderRadius.circular(16),
          ),
          child: SvgPicture.asset(
            'assets/images/Gratido transperant.svg',
            colorFilter: const ColorFilter.mode(primaryColor, BlendMode.srcIn),
            fit: BoxFit.contain,
          ),
        ),
        const SizedBox(width: 16),
        const Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                "Receive kindness. Deliver hope.",
                style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w700,
                    color: Colors.black87),
              ),
              SizedBox(height: 6),
              Text(
                "A community-driven platform connecting surplus food providers to organisations in need.",
                style: TextStyle(fontSize: 14, color: Colors.black54),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _banner() {
    return ClipRRect(
      borderRadius: BorderRadius.circular(24),
      child: Image.network(
        "https://lh3.googleusercontent.com/aida-public/AB6AXuDxVRgqUZd_YHK--5p2OOevF_jPEavpN6thKjh63zji3GES7IWEqWKZuXqywSDuH7M-wA_5SS9vOmYBTFuRXk4LGnMPefcdm2NXrhydzpXAz_HYB7EryBnZiQjGL-xCOVs2CvpNVEkURe8I8wXdq8KAua2hiQrZ9-zqz90KtbomgHMs7cpuATFcqt7iKuiT2bJg0N79pJSxgTLNYoDchYNAQwXydOL8lAR-73fiIWloN-6Qml4WRFsDFOGKoEbvO1w4QCjvp04_RO0",
        height: 180,
        width: double.infinity,
        fit: BoxFit.cover,
      ),
    );
  }

  Widget _about() {
    return const Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text("About Gratido",
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.w700)),
        SizedBox(height: 8),
        Text(
          "Gratido connects volunteers, local kitchens, bakeries and organisations with receivers through a fast and simple app.",
          style: TextStyle(fontSize: 14, color: Colors.black54),
        ),
      ],
    );
  }

  Widget _missionVisionFixed() {
    return IntrinsicHeight(
      child: Row(
        children: const [
          Expanded(
            child: _EqualIconCard(
              title: "Mission",
              icon: Icons.flag,
              text:
                  "Make surplus food accessible to local organizations via a dependable platform.",
            ),
          ),
          SizedBox(width: 12),
          Expanded(
            child: _EqualIconCard(
              title: "Vision",
              icon: Icons.visibility,
              text:
                  "A future where surplus food never goes to waste and local networks thrive.",
            ),
          ),
        ],
      ),
    );
  }

  Widget _valuesFixed() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text("Our values",
            style: TextStyle(fontSize: 17, fontWeight: FontWeight.w700)),
        const SizedBox(height: 12),
        Row(
          children: [
            _valueBar("Safety"),
            const SizedBox(width: 12),
            _valueBar("Freshness"),
          ],
        ),
        const SizedBox(height: 10),
        Row(
          children: [
            _valueBar("Fairness"),
            const SizedBox(width: 12),
            _valueBar("Community"),
          ],
        ),
        const SizedBox(height: 10),
        Row(
          children: [
            _valueBar("Transparency"),
            const Spacer(),
          ],
        ),
      ],
    );
  }

  Widget _valueBar(String text) {
    return Expanded(
      child: Container(
        height: 38,
        alignment: Alignment.center,
        decoration: BoxDecoration(
          color: bgColor,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: Colors.black12),
        ),
        child: Text(
          text,
          style: const TextStyle(fontSize: 11, color: Colors.black87),
        ),
      ),
    );
  }

  Widget _howItWorks() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: const [
        Text("How it works",
            style: TextStyle(fontSize: 17, fontWeight: FontWeight.w700)),
        SizedBox(height: 18),
        _Step(
            1, "Browse listings", "See nearby food items posted by providers."),
        _Step(2, "Accept what you can pick", "Tap Accept to reserve the item."),
        _Step(3, "Confirm pickup", "Track and confirm pickup in-app.",
            isLast: true),
      ],
    );
  }

  Widget _contact(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text("Get in touch",
            style: TextStyle(fontSize: 17, fontWeight: FontWeight.w700)),
        const SizedBox(height: 6),
        const Text("Need help or want to partner with us?",
            style: TextStyle(fontSize: 15, color: Colors.black54)),
        const SizedBox(height: 16),
        Row(
          children: [
            Expanded(
              child: OutlinedButton(
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (_) => const FeedbackFormPage()),
                  );
                },
                child: const Text(
                  "Send feedback",
                  style: TextStyle(fontSize: 12),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: ElevatedButton(
                onPressed: _contactUs,
                style: ElevatedButton.styleFrom(
                  backgroundColor: primaryColor,
                  foregroundColor: Colors.white,
                ),
                child: const Text("Contact us", style: TextStyle(fontSize: 13)),
              ),
            ),
          ],
        ),
      ],
    );
  }
}

class _EqualIconCard extends StatelessWidget {
  final String title;
  final IconData icon;
  final String text;

  const _EqualIconCard({
    required this.title,
    required this.icon,
    required this.text,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
      ),
      child: Column(
        children: [
          SizedBox(
            height: 78,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                CircleAvatar(
                  backgroundColor: AboutPage.primaryColor.withOpacity(.15),
                  child: Icon(icon, color: AboutPage.primaryColor),
                ),
                const SizedBox(height: 8),
                Text(
                  title,
                  style: const TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 8),
          Expanded(
            child: Text(
              text,
              textAlign: TextAlign.center,
              style: const TextStyle(
                fontSize: 12,
                // 🔥 change size here
                height: 1.4,
                color: Colors.black54,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _Step extends StatelessWidget {
  final int number;
  final String title;
  final String desc;
  final bool isLast;

  const _Step(this.number, this.title, this.desc, {this.isLast = false});

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SizedBox(
          width: 28,
          child: Column(
            children: [
              CircleAvatar(
                radius: 13,
                backgroundColor: AboutPage.primaryColor.withOpacity(.15),
                child: Text("$number",
                    style: const TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                        color: AboutPage.primaryColor)),
              ),
              if (!isLast)
                Container(
                  width: 2,
                  height: 56,
                  color: AboutPage.primaryColor.withOpacity(.35),
                ),
            ],
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Padding(
            padding: const EdgeInsets.only(bottom: 18),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title,
                    style: const TextStyle(
                        fontSize: 15, fontWeight: FontWeight.w600)),
                const SizedBox(height: 4),
                Text(desc,
                    style:
                        const TextStyle(fontSize: 13, color: Colors.black54)),
              ],
            ),
          ),
        ),
      ],
    );
  }
}
