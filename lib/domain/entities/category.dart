/// Backward compatibility alias and re-export for [ParentCategory].
///
/// Use [ParentCategory] for new code to adhere to the 3-tier hierarchy.
library;

import 'parent_category.dart';

export 'parent_category.dart';

/// Legacy alias for [ParentCategory].
typedef Category = ParentCategory;
