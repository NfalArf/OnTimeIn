import 'dart:ui';

class Scratchpad {
  const Scratchpad({
    this.idea = '',
    this.reference = '',
    this.referenceUrl = '',
    this.strokes = const [],
  });

  final String idea;
  final String reference;
  final String referenceUrl;
  final List<List<Offset>> strokes;

  factory Scratchpad.fromJson(Map<String, dynamic> json) => Scratchpad(
    idea: json['idea'] as String? ?? '',
    reference: json['reference'] as String? ?? '',
    referenceUrl: json['referenceUrl'] as String? ?? '',
    strokes: (json['strokes'] as List<dynamic>? ?? const [])
        .map(
          (stroke) => (stroke as List<dynamic>).map((point) {
            final coordinates = point as List<dynamic>;
            return Offset(
              (coordinates[0] as num).toDouble(),
              (coordinates[1] as num).toDouble(),
            );
          }).toList(),
        )
        .toList(),
  );

  Map<String, Object?> toJson() => {
    'idea': idea,
    'reference': reference,
    'referenceUrl': referenceUrl,
    'strokes': strokes
        .map((stroke) => stroke.map((point) => [point.dx, point.dy]).toList())
        .toList(),
  };

  bool get hasContent =>
      idea.trim().isNotEmpty ||
      reference.trim().isNotEmpty ||
      referenceUrl.trim().isNotEmpty ||
      strokes.any((stroke) => stroke.isNotEmpty);

  Scratchpad copyWith({
    String? idea,
    String? reference,
    String? referenceUrl,
    List<List<Offset>>? strokes,
  }) {
    return Scratchpad(
      idea: idea ?? this.idea,
      reference: reference ?? this.reference,
      referenceUrl: referenceUrl ?? this.referenceUrl,
      strokes: strokes ?? this.strokes,
    );
  }
}

class ScratchpadEditResult {
  const ScratchpadEditResult.saved(this.scratchpad) : isDeleted = false;

  const ScratchpadEditResult.deleted() : scratchpad = null, isDeleted = true;

  final Scratchpad? scratchpad;
  final bool isDeleted;
}
