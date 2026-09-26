import 'package:flutter_test/flutter_test.dart';

import 'package:social_fund_app/core/rbac.dart';

void main() {
  test('RBAC: viewer لا يملك صلاحية treasury', () {
    expect(Rbac.can('viewer', 'treasury'), isFalse);
    expect(Rbac.can('admin', 'treasury'), isTrue);
    expect(Rbac.can('accountant', 'treasury'), isTrue);
    expect(Rbac.can('reviewer', 'treasury'), isFalse);
    expect(Rbac.can(null, 'reports'), isFalse);
  });
}
