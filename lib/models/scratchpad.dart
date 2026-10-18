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
