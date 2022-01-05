#include <iostream>
#include <unordered_set>

using namespace std;

int main()
{
  int r3 = 0, r4 = 0, old_r4 = 0;

  unordered_set<int> values_seen;

  for(;;)
  {
    r3 = r4 | 0x010000;
    r4 = 16098955;

    while(r3 > 0) {
      r4 += r3 & 0xff;
      r4 &= 0xffffff;
      r4 *= 65899;
      r4 &= 0xffffff;

      r3 /= 256;
    }

    auto res = values_seen.insert(r4);
    if (!res.second) {
      cout << old_r4 << endl;
      break;
    }
    old_r4 = r4;
  }

  return 0;
}
