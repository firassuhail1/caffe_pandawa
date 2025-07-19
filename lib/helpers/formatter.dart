import 'package:intl/intl.dart';

String formatter(digit) {
  return NumberFormat('#,###', 'id_ID').format(digit);
}

String shortFormatter(double value) {
  if (value >= 1000000000) {
    return '${(value / 1000000000).toStringAsFixed(1)}M';
  } else if (value >= 1000000) {
    return '${(value / 1000000).toStringAsFixed(1)}Jt';
  } else if (value >= 1000) {
    return '${(value / 1000).toStringAsFixed(0)}K';
  } else {
    return value.toStringAsFixed(0);
  }
}
