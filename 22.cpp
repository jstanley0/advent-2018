#include <iostream>
#include <vector>
#include <cstdlib>

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

    Matrix<long> matrix(target_x * 2, target_y * 2);
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

    Matrix<char> cave(matrix.width(), matrix.height());
    for(int x = 0; x < cave.width(); ++x) {
        for(int y = 0; y < cave.height(); ++y) {
            char c;
            switch(matrix(x, y) % 3) {
            case 0:
                c = '.';
                break;
            case 1:
                c = '=';
                break;
            case 2:
                c = '|';
                break;
            }
            cave(x, y) = c;
        }
    }

    for(int y = 0; y < cave.height(); ++y) {
        for(int x = 0; x < cave.width(); ++x) {
            putchar(cave(x, y));
        }
        putchar('\n');
    }



}
