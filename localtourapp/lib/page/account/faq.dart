// lib/faq_page.dart

import 'package:flutter/material.dart';
import '../../services/faq_service.dart';

class FAQPage extends StatelessWidget {
  final String languageCode;
  final FAQService _faqService = FAQService();

  FAQPage({Key? key, required this.languageCode}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final faqs = _faqService.getFAQs(languageCode);

    return Scaffold(
      appBar: AppBar(title: const Text('FAQ')),
      body: ListView.builder(
        itemCount: faqs.length,
        itemBuilder: (context, index) {
          final faq = faqs[index];
          return ExpansionTile(
            title: Text(faq.question),
            children: [Text(faq.answer)],
          );
        },
      ),
    );
  }
}
