#include <list>
#include <vector>
#include <iostream>
#include <cstdlib>

using namespace std;

list<int>::iterator iterate_cw(list<int> &circle, list<int>::iterator pos, int count)
{
    while(count > 0) {
        if (++pos == circle.end())
            pos = circle.begin();
        --count;
    }
    return pos;
}

list<int>::iterator iterate_ccw(list<int> &circle, list<int>::iterator pos, int count)
{
    while(count > 0) {
        if (pos == circle.begin())
            pos = circle.end();
        --pos;
        --count;
    }
    return pos;
}

void print_circle(list<int> &circle, list<int>::iterator pos)
{
    for(auto it = circle.begin(); it != circle.end(); ++it) {
        cout << ((it == pos) ? "(" : " ");
        cout << *it;
        cout << ((it == pos) ? ")" : " ");
    }
    cout << endl;
}

int main(int argc, char **argv)
{
    if (argc < 3) {
        cerr << "usage: " << argv[0] << " num_players hi_marble" << endl;
        return 1;
    }
    int num_players = atoi(argv[1]);
    int hi_marble = atoi(argv[2]);

    vector<long long> scores(num_players, 0);
    list<int> circle = { 0 };
    list<int>::iterator pos = circle.begin();
    int marble = 1;
    int player = 0;

    while(marble <= hi_marble) {
        // print_circle(circle, pos);

        if (marble % 23 == 0) {
            scores[player] += marble;
            pos = iterate_ccw(circle, pos, 7);
            scores[player] += *pos;
            pos = circle.erase(pos);
        } else {
            pos = iterate_cw(circle, pos, 2);
            pos = circle.insert(pos, marble);
        }
        player = (player + 1) % num_players;
        marble++;
    }

    cout << *max_element(scores.begin(), scores.end()) << endl;

    return 0;
}



