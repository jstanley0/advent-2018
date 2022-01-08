#include <iostream>
#include <vector>
#include <map>
#include <queue>
#include <cstdlib>
#include <cmath>

using namespace std;

template<typename T>
class Matrix
{
    vector<T> data;
    int w, h;

public:
    Matrix(int w, int h) : w(w), h(h)
    {
        data.resize(w * h);
    }

    T& operator()(int x, int y)
    {
        return data[w * y + x];
    }

    int width() { return w; }
    int height() { return h; }
};

int main(int argc, char **argv)
{
    if (argc < 4) {
        cerr << "usage: %s depth target_x target_y" << endl;
        return 1;
    }
    int depth = atoi(argv[1]);
    int target_x = atoi(argv[2]);
    int target_y = atoi(argv[3]);

    auto erosion_level = [depth](long geologic_index) {
        return (geologic_index + depth) % 20183;
    };

    Matrix<long> matrix(target_x * 5, target_y * 3);
    matrix(0, 0) = erosion_level(0);
    matrix(target_x, target_y) = erosion_level(0);
    for(int x = 1; x < matrix.width(); ++x) {
        matrix(x, 0) = erosion_level((long)x * 16807);
    }
    for(int y = 1; y < matrix.height(); ++y) {
        matrix(0, y) = erosion_level((long)y * 48271);
    }
    for(int x = 1; x < matrix.width(); ++x) {
        for(int y = 1; y < matrix.height(); ++y) {
            if (x != target_x || y != target_y) {
                matrix(x, y) = erosion_level(matrix(x - 1, y) * matrix(x, y - 1));
            }
        }
    }

    long risk = 0;
    for(int x = 0; x <= target_x; ++x) {
        for(int y = 0; y <= target_y; ++y) {
            risk += matrix(x, y) % 3;
        }
    }
    cout << risk << endl;

    // and now, for something completely different...
    // ... but kind of the same

    // topography   tooling
    //  .  0        T C    0 1
    //  =  1          C N    1 2
    //  |  2        T   N  0   2

    // so we will model this as a three-dimensional maze with height 3
    // where the z axis wraps around, and there is an open vertical space
    // of height 2 in every (x, y) coordinate, starting at z = risk/topo.
    // where we start at (0, 0, 0) and end at (target_x, target_y, 0).
    // it costs 7 to move in z, and 1 to move in (x, y).

    // now I get to implement A* yet again!

    struct Coord {
        int x, y, z;

        bool operator==(const Coord& rhs) const {
            return x == rhs.x && y == rhs.y && z == rhs.z;
        }
        bool operator<(const Coord& rhs) const {
            return z < rhs.z ||
                  (z == rhs.z && y < rhs.y) ||
                  (z == rhs.z && y == rhs.y && x < rhs.x);
        }
    };

    struct QueueEntry {
        Coord c;
        int est_total_time;

        bool operator<(const QueueEntry& rhs) const {
            return est_total_time > rhs.est_total_time;
        }
    };

    Coord home{0, 0, 0};
    Coord target{target_x, target_y, 0};

    auto time_bound = [&target](const Coord& coord) {
        return abs(target.x - coord.x) + abs(target.y - coord.y) + ((coord.z > 0) ? 7 : 0);
    };

    auto open_cell = [&matrix](const Coord& coord) {
        int topo = matrix(coord.x, coord.y) % 3;
        return coord.z != (topo + 2) % 3;
    };

    priority_queue<QueueEntry> fringe;
    fringe.push({home, time_bound(home)});

    map<Coord, int> best_time_to = {{home, 0}};

    while (!fringe.empty()) {
        auto current = fringe.top();
        fringe.pop();
        int time_so_far = best_time_to[current.c];

        if (current.c == target) {
            cout << time_so_far << endl;
            return 0;
        }

        auto consider_neighbor = [&](Coord c, int sub_time) {
            if (open_cell(c)) {
                if (!best_time_to.contains(c) || sub_time < best_time_to[c]) {
                    best_time_to[c] = sub_time;
                    fringe.push({c, sub_time + time_bound(c)});
                }
            }
        };

        if (current.c.x > 0) consider_neighbor({current.c.x - 1, current.c.y, current.c.z}, time_so_far + 1);
        if (current.c.y > 0) consider_neighbor({current.c.x, current.c.y - 1, current.c.z}, time_so_far + 1);
        if (current.c.x < matrix.width() - 1) consider_neighbor({current.c.x + 1, current.c.y, current.c.z}, time_so_far + 1);
        if (current.c.y < matrix.height() - 1) consider_neighbor({current.c.x, current.c.y + 1, current.c.z}, time_so_far + 1);
        consider_neighbor({current.c.x, current.c.y, (current.c.z + 1) % 3}, time_so_far + 7);
        consider_neighbor({current.c.x, current.c.y, (current.c.z + 2) % 3}, time_so_far + 7);
    }

    cout << "no path found :(" << endl;
    return 1;
}
