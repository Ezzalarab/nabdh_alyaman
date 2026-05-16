Run from project root to regenerate Drift code:
  dart run build_runner build --force-jit

If AOT compile fails (exit 78), use --force-jit as above.

Wire: AppDatabase in di.dart, LocationsLocalDataSourceImpl uses SQLite.
