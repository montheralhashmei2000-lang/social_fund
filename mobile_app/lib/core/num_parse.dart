/// تحويل الأرقام المكتوبة بلوحة مفاتيح عربية (٠-٩ أو ۰-۹) إلى أرقام لاتينية،
/// وإزالة فواصل الآلاف وتوحيد الفاصلة العشرية، قبل التحليل.
String normalizeDigits(String input) {
  final b = StringBuffer();
  for (final r in input.trim().runes) {
    if (r >= 0x0660 && r <= 0x0669) {
      b.writeCharCode(r - 0x0660 + 0x30); // ٠-٩
    } else if (r >= 0x06F0 && r <= 0x06F9) {
      b.writeCharCode(r - 0x06F0 + 0x30); // ۰-۹
    } else if (r == 0x066B) {
      b.write('.'); // ٫ فاصلة عشرية عربية
    } else if (r == 0x066C || r == 0x2C || r == 0x20 || r == 0x60C) {
      // ٬ , مسافة ، فواصل آلاف: تُهمل
    } else {
      b.writeCharCode(r);
    }
  }
  return b.toString();
}

/// عدد صحيح من حقل نصي (يقبل الأرقام العربية)، أو null إن كان غير صالح.
int? parseInt(String input) => int.tryParse(normalizeDigits(input));

/// عدد عشري من حقل نصي (يقبل الأرقام العربية)، أو null إن كان غير صالح.
double? parseDouble(String input) => double.tryParse(normalizeDigits(input));
