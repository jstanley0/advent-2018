#include <iostream>
#include <fstream>
#include <map>
#include <queue>
#include <stdexcept>
#include <cctype>

using namespace std;

struct Coord {
    int x, y;
    bool operator== (const Coord& rhs) const { return x == rhs.x && y == rhs.y; }
    bool operator< (const Coord& rhs) const { return y < rhs.y || (y == rhs.y && x < rhs.x); }
};

struct Node {
    bool n = false, s = false, w = false, e = false;
    bool visited = false;
};

struct SearchElem {
    Coord coord;
    int distance;
    bool operator< (const SearchElem& rhs) const { return rhs.distance > distance; }
};

void parse_pattern(map<Coord, Node>& nodes, string::iterator& it, int x, int y)
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
            Node &node = nodes[{x, y}];

            switch(*it) {
            case 'N':
                node.n = true;
                --y;
                nodes[{x, y}].s = true;
                break;
            case 'W':
                node.w = true;
                --x;
                nodes[{x, y}].e = true;
                break;
            case 'E':
                node.e = true;
                ++x;
                nodes[{x, y}].w = true;
                break;
            case 'S':
                node.s = true;
                ++y;
                nodes[{x, y}].n = true;
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
    ifstream input{argv[1]};
    string data;
    getline(input, data);

    map<Coord, Node> nodes;
    nodes[{0, 0}];

    auto it = data.begin();
    if (*it == '^')
        ++it;
    parse_pattern(nodes, it, 0, 0);
    cout << "room count: " << nodes.size() << endl;

    priority_queue<SearchElem> search_set;
    search_set.push({{0, 0}, 0});
    int max_dist = -1;
    int distant_rooms = 0;
    while (!search_set.empty()) {
        auto elem = search_set.top();
        search_set.pop();
        printf("searching at (%d, %d) / %d [%lu]\n", elem.coord.x, elem.coord.y, elem.distance, search_set.size());
        max_dist = max(max_dist, elem.distance);
        if (elem.distance >= 1000)
            ++distant_rooms;
        Node &node = nodes[elem.coord];
        if (node.visited) {
            printf(":(");
        } else {
            node.visited = true;
            if (node.n) {
                auto c = Coord{elem.coord.x, elem.coord.y - 1};
                printf("-> (%d,%d)\n", c.x, c.y);
                Node &n = nodes[c];
                if (!n.visited) {
                    search_set.push({c, elem.distance + 1});
                }
            }
            if (node.s) {
                auto c = Coord{elem.coord.x, elem.coord.y + 1};
                printf("-> (%d,%d)\n", c.x, c.y);
                Node &n = nodes[c];
                if (!n.visited) {
                    search_set.push({c, elem.distance + 1});
                }
            }
            if (node.w) {
                auto c = Coord{elem.coord.x - 1, elem.coord.y};
                printf("-> (%d,%d)\n", c.x, c.y);
                Node &n = nodes[c];
                if (!n.visited) {
                    search_set.push({c, elem.distance + 1});
                }
            }
            if (node.e) {
                auto c = Coord{elem.coord.x + 1, elem.coord.y};
                printf("-> (%d,%d)\n", c.x, c.y);
                Node &n = nodes[c];
                if (!n.visited) {
                    search_set.push({c, elem.distance + 1});
                }
            }
        }
    }

    printf("%d; %d\n", max_dist, distant_rooms);
    return 0;
}
