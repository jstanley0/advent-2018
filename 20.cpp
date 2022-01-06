#include <iostream>
#include <fstream>
#include <map>
#include <stdexcept>
#include <cctype>

using namespace std;

struct Coord {
    int x, y;
    Coord(int x_ = 0, int y_ = 0) : x(x_), y(y_) {}
    Coord(const Coord &rhs) : x(rhs.x), y(rhs.y) {}
    bool operator== (const Coord& rhs) const { return x == rhs.x && y == rhs.y; }
    bool operator< (const Coord& rhs) const { return y < rhs.y || (y == rhs.y && x < rhs.x); }
};

struct Node {
    bool n, s, w, e;
    Node() : n(false), s(false), w(false), e(false) {}
};

void parse_pattern(map<Coord, Node>& nodes, string::iterator &it, int x, int y)
{
    for(;;) {
        if (*it == '(') {
            ++it;
            for(;;) {
                parse_pattern(nodes, it, x, y);
                if (*it != '|')
                    break;
                ++it;
            }
            if (*it != ')') {
                throw runtime_error("expected )");
            }
            ++it;
        }

        while(isalpha(*it)) {
            Node &node = nodes[Coord(x, y)];

            switch(*it) {
            case 'N':
                node.n = true;
                --y;
                nodes[Coord(x, y)].s = true;
                break;
            case 'W':
                node.w = true;
                --x;
                nodes[Coord(x, y)].e = true;
                break;
            case 'E':
                node.e = true;
                ++x;
                nodes[Coord(x, y)].w = true;
                break;
            case 'S':
                node.s = true;
                ++y;
                nodes[Coord(x, y)].n = true;
                break;
            }
            ++it;
        }

        if (*it != '(')
            break;
    }
}

int main(int argc, char **argv)
{
    if (argc < 2) {
        cerr << "no filename given\n";
        return 1;
    }
    ifstream input(argv[1]);
    string data;
    getline(input, data);

    map<Coord, Node> nodes;
    nodes.emplace(make_pair(Coord(0, 0), Node()));

    auto it = data.begin();
    if (*it == '^')
        ++it;
    parse_pattern(nodes, it, 0, 0);

    cout << "room count: " << nodes.size() << endl;
}
