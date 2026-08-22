/// Fixed-point money in paise (1 ₹ = 100 paise). Avoids floating-point drift.
class Money implements Comparable<Money> {
  final int paise;

  const Money(this.paise);

  factory Money.fromRupees(num rupees) =>
      Money((rupees * 100).round());

  factory Money.parse(String value) {
    final cleaned = value.trim().replaceAll(',', '').replaceAll('₹', '');
    if (cleaned.isEmpty) return const Money(0);
    final parts = cleaned.split('.');
    final rupees = int.parse(parts[0].isEmpty ? '0' : parts[0]);
    var fraction = 0;
    if (parts.length > 1) {
      final frac = parts[1].padRight(2, '0').substring(0, 2);
      fraction = int.parse(frac);
    }
    final sign = cleaned.startsWith('-') ? -1 : 1;
    final absRupees = rupees.abs();
    return Money(sign * (absRupees * 100 + fraction));
  }

  double get asRupees => paise / 100.0;

  bool get isZero => paise == 0;
  bool get isNegative => paise < 0;
  bool get isPositive => paise > 0;

  Money operator +(Money other) => Money(paise + other.paise);
  Money operator -(Money other) => Money(paise - other.paise);
  Money operator -() => Money(-paise);

  Money operator *(int qty) => Money(paise * qty);

  /// Percent change of this amount relative to [basis] (e.g. change vs close).
  double percentOf(Money basis) {
    if (basis.paise == 0) return 0;
    return (paise * 10000.0 / basis.paise) / 100.0;
  }

  String get formatted {
    final sign = paise < 0 ? '-' : '';
    final abs = paise.abs();
    final rupees = abs ~/ 100;
    final p = (abs % 100).toString().padLeft(2, '0');
    return '$sign₹$rupees.$p';
  }

  String get formattedSigned {
    if (paise > 0) return '+$formatted';
    return formatted;
  }

  @override
  int compareTo(Money other) => paise.compareTo(other.paise);

  @override
  bool operator ==(Object other) =>
      identical(this, other) || other is Money && paise == other.paise;

  @override
  int get hashCode => paise.hashCode;

  @override
  String toString() => formatted;
}
