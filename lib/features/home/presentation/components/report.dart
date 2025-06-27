import 'package:Cinemate/themes/font_theme.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

class ReportDialog extends StatefulWidget {
  final String postUserId;
  final String reporterUserId;

  const ReportDialog({required this.postUserId, required this.reporterUserId, super.key});

  @override
  State<ReportDialog> createState() => _ReportDialogState();
}

class _ReportDialogState extends State<ReportDialog> {
  String? selectedReason;
  final reasons = [
    'Uygunsuz içerik',
    'Hakaret',
    'Spam',
    'Diğer',
  ];

  Future<void> _sendReport() async {
    if (selectedReason != null) {
      await FirebaseFirestore.instance.collection('reports').add({
        'postUserId': widget.postUserId,
        'reporterUserId': widget.reporterUserId,
        'reason': selectedReason,
        'timestamp': FieldValue.serverTimestamp(),
      });

      Navigator.pop(context); // diyaloğu kapat
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Şikayetiniz başarıyla gönderildi.'),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title:  Text('Gönderiyi Şikayet Et',style: AppTextStyles.bold,),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: reasons.map((reason) {
          return RadioListTile<String>(
            title: Text(reason,style: AppTextStyles.medium,),
            value: reason,
            groupValue: selectedReason,
            onChanged: (value) {
              setState(() {
                selectedReason = value;
              });
            },
          );
        }).toList(),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('İptal'),
        ),
        TextButton(
          onPressed: selectedReason == null ? null : _sendReport,
          child: const Text('Gönder'),
        ),
      ],
    );
  }
}
