/// Base failure hierarchy for the Awrad app domain layer.
///
/// All repository and use-case errors are mapped to typed [Failure] subclasses
/// so that BLoC states can carry meaningful, actionable error information
/// without leaking implementation details (SQL errors, file exceptions, etc.)
/// to the presentation layer.
library;

import 'package:equatable/equatable.dart';

// ── Base ──────────────────────────────────────────────────────────────────────

/// Abstract base class for all domain-layer failures.
abstract class Failure extends Equatable {
  /// Human-readable description of what went wrong.
  final String message;

  const Failure(this.message);

  @override
  List<Object?> get props => [message];
}

// ── Database Failures ─────────────────────────────────────────────────────────

/// Emitted when the SQLite database fails to open or initialise.
class DatabaseOpenFailure extends Failure {
  const DatabaseOpenFailure([
    super.message = 'Failed to open the local database.',
  ]);
}

/// Emitted when a read query against the database returns an unexpected error.
class DatabaseReadFailure extends Failure {
  const DatabaseReadFailure([
    super.message = 'Failed to read data from the local database.',
  ]);
}

/// Emitted when a write operation (insert / update / delete) fails.
class DatabaseWriteFailure extends Failure {
  const DatabaseWriteFailure([
    super.message = 'Failed to write data to the local database.',
  ]);
}

// ── Asset / Seeding Failures ──────────────────────────────────────────────────

/// Emitted when the JSON asset file cannot be loaded from the bundle.
class AssetLoadFailure extends Failure {
  const AssetLoadFailure([
    super.message = 'Failed to load the bundled Hisn al-Muslim data asset.',
  ]);
}

/// Emitted when the JSON asset contains malformed or unexpected data.
class AssetParseFailure extends Failure {
  const AssetParseFailure([
    super.message = 'Failed to parse the Hisn al-Muslim data asset.',
  ]);
}

/// Emitted when the database seed step fails mid-way.
class SeedFailure extends Failure {
  const SeedFailure([
    super.message = 'Failed to seed initial Dhikr data into the database.',
  ]);
}

// ── General Failures ──────────────────────────────────────────────────────────

/// Catch-all failure for unexpected errors that do not map to a specific type.
class UnexpectedFailure extends Failure {
  const UnexpectedFailure([
    super.message = 'An unexpected error occurred.',
  ]);
}

/// Emitted when a requested record was not found in the database.
class NotFoundFailure extends Failure {
  const NotFoundFailure([
    super.message = 'The requested record was not found.',
  ]);
}
