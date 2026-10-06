import 'dart:io';
import 'dart:typed_data';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import '../db/database.dart';

class VoucherPdfService {
  /// يولّد PDF لسند قبض/صرف مع دعم كامل للعربية.
  static Future<Uint8List> build(Voucher voucher) async {
    final fontRegular = pw.Font.ttf(loadFont('Amiri-Regular.ttf'));
    final fontBold = pw.Font.ttf(loadFont('Amiri-Bold.ttf'));

    final doc = pw.Document();
    final isReceipt = voucher.kind == 'قبض';
    final title = isReceipt ? 'سند قبض' : 'سند صرف';
    final color = isReceipt ? PdfColor.fromInt(0xFF1B5E20) : PdfColor.fromInt(0xFFC62828);

    doc.addPage(
      pw.Page(
        pageFormat: PdfPageFormat.a5,
        textDirection: pw.TextDirection.rtl,
        theme: pw.ThemeData.withFont(base: fontRegular, bold: fontBold),
        build: (ctx) => pw.Column(
          crossAxisAlignment: pw.CrossAxisAlignment.stretch,
          children: [
            pw.Container(
              padding: const pw.EdgeInsets.all(10),
              decoration: pw.BoxDecoration(
                color: color,
                borderRadius: pw.BorderRadius.circular(6),
              ),
              child: pw.Column(
                crossAxisAlignment: pw.CrossAxisAlignment.center,
                children: [
                  pw.Text('الصندوق الاجتماعي التنموي',
                      style: pw.TextStyle(color: PdfColors.white, fontSize: 14, fontWeight: pw.FontWeight.bold)),
                  pw.SizedBox(height: 4),
                  pw.Text(title,
                      style: pw.TextStyle(color: PdfColors.white, fontSize: 18, fontWeight: pw.FontWeight.bold)),
                ],
              ),
            ),
            pw.SizedBox(height: 14),
            _row('رقم السند', voucher.voucherNo),
            _row('التاريخ', voucher.voucherDate),
            _row('النوع', voucher.kind),
            if (voucher.partyName != null) _row('الجهة', voucher.partyName!),
            if (voucher.memberName != null) _row('العضو', voucher.memberName!),
            _row('طريقة الدفع', voucher.method),
            _row('البيان', voucher.description),
            pw.SizedBox(height: 10),
            pw.Container(
              padding: const pw.EdgeInsets.all(12),
              decoration: pw.BoxDecoration(
                border: pw.Border.all(color: color, width: 1.5),
                borderRadius: pw.BorderRadius.circular(6),
              ),
              child: pw.Row(
                mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                children: [
                  pw.Text('المبلغ الإجمالي',
                      style: pw.TextStyle(fontSize: 13, fontWeight: pw.FontWeight.bold)),
                  pw.Column(crossAxisAlignment: pw.CrossAxisAlignment.end, children: [
                    pw.Text('${voucher.amount} ريال يمني',
                        style: pw.TextStyle(fontSize: 16, color: color, fontWeight: pw.FontWeight.bold)),
                    // مبلغ مُدخَل بعملة أخرى: يُعرض الأصل وسعر الصرف وقت التسجيل
                    if (voucher.currencyCode != null && voucher.originalAmount != null)
                      pw.Text(
                          '${voucher.originalAmount} ${voucher.currencyCode}'
                          '${voucher.exchangeRate == null ? '' : '  (سعر الصرف ${voucher.exchangeRate})'}',
                          style: const pw.TextStyle(fontSize: 10, color: PdfColors.grey700)),
                  ]),
                ],
              ),
            ),
            pw.Spacer(),
            pw.Row(
              mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
              children: [
                pw.Column(children: [
                  pw.Text('توقيع أمين الصندوق', style: const pw.TextStyle(fontSize: 10)),
                  pw.SizedBox(height: 22),
                  pw.Container(width: 100, height: 1, color: PdfColors.black),
                ]),
                pw.Column(children: [
                  pw.Text('توقيع المدير', style: const pw.TextStyle(fontSize: 10)),
                  pw.SizedBox(height: 22),
                  pw.Container(width: 100, height: 1, color: PdfColors.black),
                ]),
              ],
            ),
            pw.SizedBox(height: 8),
            pw.Divider(),
            pw.Center(
              child: pw.Text('نظام إدارة الصندوق الاجتماعي التنموي',
                  style: const pw.TextStyle(fontSize: 8, color: PdfColors.grey700)),
            ),
          ],
        ),
      ),
    );

    return doc.save();
  }

  /// شهادة شكر لمانح بإجمالي تبرعاته المعتمدة.
  static Future<Uint8List> buildDonorCertificate(Donor donor, int totalDonated) async {
    final fontRegular = pw.Font.ttf(loadFont('Amiri-Regular.ttf'));
    final fontBold = pw.Font.ttf(loadFont('Amiri-Bold.ttf'));
    final doc = pw.Document();
    final gold = PdfColor.fromInt(0xFFB8860B);
    final green = PdfColor.fromInt(0xFF1B5E20);
    doc.addPage(
      pw.Page(
        pageFormat: PdfPageFormat.a4.landscape,
        textDirection: pw.TextDirection.rtl,
        theme: pw.ThemeData.withFont(base: fontRegular, bold: fontBold),
        build: (ctx) => pw.Container(
          decoration: pw.BoxDecoration(border: pw.Border.all(color: gold, width: 4)),
          padding: const pw.EdgeInsets.all(28),
          child: pw.Column(
            mainAxisAlignment: pw.MainAxisAlignment.center,
            crossAxisAlignment: pw.CrossAxisAlignment.center,
            children: [
              pw.Text('الصندوق الاجتماعي التنموي',
                  style: pw.TextStyle(fontSize: 22, color: green, fontWeight: pw.FontWeight.bold)),
              pw.SizedBox(height: 18),
              pw.Text('شهادة شكر وتقدير',
                  style: pw.TextStyle(fontSize: 34, color: gold, fontWeight: pw.FontWeight.bold)),
              pw.SizedBox(height: 22),
              pw.Text('يتقدم الصندوق بجزيل الشكر والامتنان إلى', style: const pw.TextStyle(fontSize: 16)),
              pw.SizedBox(height: 10),
              pw.Text(donor.name,
                  style: pw.TextStyle(fontSize: 28, color: green, fontWeight: pw.FontWeight.bold)),
              pw.SizedBox(height: 14),
              pw.Text('على مساهمته الكريمة بمبلغ إجماليه $totalDonated ريال يمني',
                  style: const pw.TextStyle(fontSize: 16)),
              pw.SizedBox(height: 8),
              pw.Text('جزاه الله خير الجزاء ونفع بماله', style: const pw.TextStyle(fontSize: 14)),
              pw.SizedBox(height: 26),
              pw.Text('التاريخ: ${DateTime.now().toIso8601String().split('T').first}',
                  style: const pw.TextStyle(fontSize: 11, color: PdfColors.grey700)),
            ],
          ),
        ),
      ),
    );
    return doc.save();
  }

  /// يبحث عن الخط في عدة مواضع: ASSETS_DIR، مجلد التشغيل، ثم مجلد الخادم.
  static ByteData loadFont(String name) {
    final candidates = [
      if (Platform.environment['ASSETS_DIR'] != null)
        '${Platform.environment['ASSETS_DIR']}/fonts/$name',
      'assets/fonts/$name',
      'SocialFund-Dart-Server/assets/fonts/$name',
    ];
    for (final path in candidates) {
      final f = File(path);
      if (f.existsSync()) return ByteData.view(f.readAsBytesSync().buffer);
    }
    throw StateError('الخط $name غير موجود (جرّب ASSETS_DIR)');
  }

  static pw.Widget _row(String label, String value) => pw.Padding(
        padding: const pw.EdgeInsets.symmetric(vertical: 4),
        child: pw.Row(
          children: [
            pw.SizedBox(
              width: 110,
              child: pw.Text('$label:',
                  style: pw.TextStyle(fontWeight: pw.FontWeight.bold, fontSize: 12)),
            ),
            pw.Expanded(child: pw.Text(value, style: const pw.TextStyle(fontSize: 12))),
          ],
        ),
      );
}
