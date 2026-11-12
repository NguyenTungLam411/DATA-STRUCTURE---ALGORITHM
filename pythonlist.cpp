#include <iostream>
#include <vector>
#include <memory>
#include <string>

// Base class for all "objects"
struct Object {
    virtual ~Object() = default;
    virtual void print() const = 0;
};

// Derived class for integers
struct IntObject : Object {
    int value;
    IntObject(int v) : value(v) {}
    void print() const override {
        std::cout << "Int: " << value << "\n";
    }
};

// Derived class for strings
struct StringObject : Object {
    std::string value;
    StringObject(const std::string& v) : value(v) {}
    void print() const override {
        std::cout << "String: " << value << "\n";
    }
};

// Derived class for doubles
struct DoubleObject : Object {
    double value;
    DoubleObject(double v) : value(v) {}
    void print() const override {
        std::cout << "Double: " << value << "\n";
    }
};

// Python-like list that holds pointers to Objects
class PyList {
    std::vector<std::shared_ptr<Object>> elements;

public:
    void append(std::shared_ptr<Object> obj) {
        elements.push_back(obj);
    }

    void print_all() const {
        for (const auto& obj : elements) {
            obj->print();
        }
    }
};

int main() {
    PyList pylist;

    pylist.append(std::make_shared<IntObject>(42));
    pylist.append(std::make_shared<StringObject>("hello"));
    pylist.append(std::make_shared<DoubleObject>(3.14));

    pylist.print_all();

    return 0;
}
