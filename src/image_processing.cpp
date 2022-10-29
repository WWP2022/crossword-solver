#define EXPORT extern "C" __attribute__((visibility("default"))) __attribute__((used))

EXPORT
int get_number() {
  return 22;
}
