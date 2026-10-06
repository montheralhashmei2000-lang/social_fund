import 'dart:typed_data';
import 'package:excel/excel.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import '../db/database.dart';
import '../db/repositories/members_repository.dart';
import 'voucher_pdf_service.dart';

/// جدول تقرير جاهز للتصدير: عنوان + أعمدة + صفوف + صف إجماليات اختياري.
class ReportTable {
  final String title;
  final List<String> columns;
  final List<List<Object>> rows; // نص أو عدد
  final List<Object>? totals;
  const ReportTable(this.title, this.columns, this.rows, {this.totals});
}

/// تقارير الأعمال (الأعضاء، الاشتراكات، المساعدات، الخزينة، السندات) بصيغتي
/// PDF وExcel. المبالغ كلها بالعملة المحلية (المحفوظة في الجداول).
class ReportService {
  final AppDatabase db;
  ReportService(this.db);

  static const keys = ['members', 'subscriptions', 'aids', 'treasury', 'vouchers'];

  Future<ReportTable?> table(String key) async {
    switch (key) {
      case 'members':
        final l = await MembersRepository(db).list(limit: 1000000); // مفكوكة التشفير
        return ReportTable(
          'تقرير الأعضاء',
          ['الاسم', 'رقم الهوية', 'الجوال', 'المدينة', 'الحالة', 'الاشتراك الشهري', 'المدفوع', 'المتأخر'],
          [for (final m in l) [m.name, m.nationalId, m.phone, m.city ?? '-', m.status, m.monthlySubscription, m.totalPaid, m.balanceDue]],
          totals: ['الإجمالي', '', '', '', '', l.fold<int>(0, (s, m) => s + m.monthlySubscription),
            l.fold<int>(0, (s, m) => s + m.totalPaid), l.fold<int>(0, (s, m) => s + m.balanceDue)],
        );
      case 'subscriptions':
        final l = await (db.select(db.subscriptions)..where((t) => t.deleted.equals(false))).get();
        return ReportTable(
          'تقرير الاشتراكات',
          ['العضو', 'تاريخ الدفع', 'الشهر', 'الطريقة', 'المرجع', 'المبلغ'],
          [for (final s in l) [s.memberName, s.paymentDate, s.period ?? '-', s.method, s.referenceNo ?? '-', s.amount]],
          totals: ['الإجمالي', '', '', '', '', l.fold<int>(0, (a, s) => a + s.amount)],
        );
      case 'aids':
        final l = await (db.select(db.aidRequests)..where((t) => t.deleted.equals(false))).get();
        // الصرف الفعلي = المصروفة فقط
        final paid = l.where((a) => a.status == 'مصروفة').fold<int>(0, (s, a) => s + a.amount);
        return ReportTable(
          'تقرير طلبات المساعدة',
          ['العضو', 'نوع المساعدة', 'تاريخ الطلب', 'الحالة', 'المراجع', 'المبلغ'],
          [for (final a in l) [a.memberName, a.aidType, a.requestDate, a.status, a.reviewerName ?? '-', a.amount]],
          totals: ['إجمالي المصروف فعلياً', '', '', '', '', paid],
        );
      case 'treasury':
        final l = await (db.select(db.treasuryEntries)..where((t) => t.deleted.equals(false))).get();
        final inc = l.where((e) => e.type == 'إيراد').fold<int>(0, (s, e) => s + e.amount);
        final exp = l.where((e) => e.type == 'مصروف').fold<int>(0, (s, e) => s + e.amount);
        return ReportTable(
          'تقرير الخزينة',
          ['التاريخ', 'النوع', 'التصنيف', 'الوصف', 'المرجع', 'المبلغ'],
          [for (final e in l) [e.entryDate, e.type, e.category, e.description, e.referenceNo ?? '-', e.amount]],
          totals: ['صافي الخزينة (إيرادات − مصروفات)', '', '', '', '', inc - exp],
        );
      case 'vouchers':
        final l = await (db.select(db.vouchers)..where((t) => t.deleted.equals(false))).get();
        final active = l.where((v) => v.status != 'ملغي');
        final rec = active.where((v) => v.kind == 'قبض').fold<int>(0, (s, v) => s + v.amount);
        final pay = active.where((v) => v.kind == 'صرف').fold<int>(0, (s, v) => s + v.amount);
        return ReportTable(
          'تقرير السندات',
          ['رقم السند', 'النوع', 'التاريخ', 'الطرف', 'الوصف', 'الحالة', 'المبلغ'],
          [for (final v in l) [v.voucherNo, v.kind, v.voucherDate, (v.memberName ?? v.partyName ?? '-'), v.description, v.status, v.amount]],
          totals: ['قبض − صرف (المعتمدة)', '', '', '', '', '', rec - pay],
        );
    }
    return null;
  }

  Future<Uint8List> pdf(ReportTable t) async {
    final regular = pw.Font.ttf(VoucherPdfService.loadFont('Amiri-Regular.ttf'));
    final bold = pw.Font.ttf(VoucherPdfService.loadFont('Amiri-Bold.ttf'));
    final doc = pw.Document();
    final green = PdfColor.fromInt(0xFF1B5E20);
    final head = pw.TextStyle(color: PdfColors.white, fontWeight: pw.FontWeight.bold, fontSize: 9);
    const cell = pw.TextStyle(fontSize: 8.5);
    final now = DateTime.now().toIso8601String().split('T').first;

    // أعمدة بالترتيب العربي: الأول على اليمين (الاتجاه RTL في الصفحة)
    final data = <List<String>>[
      for (final r in t.rows) [for (final c in r) '$c'],
      if (t.totals != null) [for (final c in t.totals!) '$c'],
    ];

    doc.addPage(
      pw.MultiPage(
        pageFormat: PdfPageFormat.a4.landscape,
        textDirection: pw.TextDirection.rtl,
        theme: pw.ThemeData.withFont(base: regular, bold: bold),
        margin: const pw.EdgeInsets.all(24),
        header: (ctx) => pw.Column(children: [
          pw.Row(mainAxisAlignment: pw.MainAxisAlignment.spaceBetween, children: [
            pw.Text('الصندوق الاجتماعي التنموي',
                style: pw.TextStyle(fontSize: 13, color: green, fontWeight: pw.FontWeight.bold)),
            pw.Text('$now', style: const pw.TextStyle(fontSize: 9, color: PdfColors.grey700)),
          ]),
          pw.SizedBox(height: 2),
          pw.Text(t.title, style: pw.TextStyle(fontSize: 16, fontWeight: pw.FontWeight.bold)),
          pw.Divider(),
        ]),
        footer: (ctx) => pw.Align(
          alignment: pw.Alignment.center,
          child: pw.Text('صفحة ${ctx.pageNumber} من ${ctx.pagesCount}',
              style: const pw.TextStyle(fontSize: 8, color: PdfColors.grey700)),
        ),
        build: (ctx) => [
          if (t.rows.isEmpty)
            pw.Padding(
                padding: const pw.EdgeInsets.all(20),
                child: pw.Center(child: pw.Text('لا توجد بيانات')))
          else
            pw.TableHelper.fromTextArray(
              headers: t.columns,
              data: data,
              headerStyle: head,
              cellStyle: cell,
              headerDecoration: pw.BoxDecoration(color: green),
              cellAlignment: pw.Alignment.centerRight,
              headerAlignment: pw.Alignment.centerRight,
              oddRowDecoration: const pw.BoxDecoration(color: PdfColors.grey100),
              border: pw.TableBorder.all(color: PdfColors.grey400, width: 0.4),
              cellPadding: const pw.EdgeInsets.symmetric(horizontal: 4, vertical: 3),
            ),
        ],
      ),
    );
    return doc.save();
  }

  Uint8List xlsx(ReportTable t) {
    final book = Excel.createExcel();
    final defaultName = book.getDefaultSheet() ?? 'Sheet1';
    book.rename(defaultName, t.title);
    final sheet = book[t.title];
    sheet.isRTL = true;
    CellValue cv(Object v) => v is int ? IntCellValue(v) : (v is double ? DoubleCellValue(v) : TextCellValue('$v'));
    sheet.appendRow([for (final c in t.columns) TextCellValue(c)]);
    for (final r in t.rows) {
      sheet.appendRow([for (final c in r) cv(c)]);
    }
    if (t.totals != null) {
      sheet.appendRow([for (final c in t.totals!) cv(c)]);
    }
    final bytes = book.save();
    return Uint8List.fromList(bytes ?? const []);
  }
}
