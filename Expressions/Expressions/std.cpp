// Standard library
#include <iostream>
#include <fstream>
#include <vector>
#include <typeinfo>

// Print
template<typename T>
void print(T obj) {
    std::cout << obj;
}

template<typename T>
void print(std::vector<T> obj) {
    typename std::vector<T>::iterator it;
    for (it = obj.begin() ; it != obj.end(); ++it) {
        print(*it);
    }
}
void print(std::vector<char> obj) {
    for (std::vector<char>::iterator it = obj.begin() ; it != obj.end(); ++it) {
        print(*it);
    }
}
template<typename T>
void print(std::initializer_list<T> obj) {
    std::vector<T>tmp(obj);
    for(int n = 0; n < tmp.size(); n++) {
        print(tmp[n]);
    }
}

void print(std::initializer_list<char> obj) {
    std::vector<char> tmp(obj);
    print(tmp);
}

template<typename T>
void printLn(T obj) {
    print(obj);
    print("\n");
}


// readFileContents
std::vector<char> readFileContents(std::vector<char> pathv) {
    std::string path(pathv.begin(), pathv.end());
    std::ifstream ifs(path);
    std::string content( (std::istreambuf_iterator<char>(ifs) ),
                        (std::istreambuf_iterator<char>()    ) );
    ifs.close();
    
    std::vector<char> data(content.begin(), content.end());
    return data;
}

// writeFileContents
void writeFileContents(std::vector<char> pathv, std::vector<char> content) {
    std::string path(pathv.begin(), pathv.end());
    std::ofstream ofs (path, std::ofstream::binary);
    for (std::vector<char>::iterator it = content.begin() ; it != content.end(); ++it) {
        ofs << *it;
    }
    ofs.close();
}

// List
template<typename T>
std::vector<T> list(T obj) {
    std::vector<T> ret;
    ret.push_back(obj);
    
    return ret;
}

// Append
template<typename T>
std::vector<T> append(const std::vector<T> lst, T obj) {
    std::vector<T>tmp(lst);
    tmp.push_back(obj);
    
    return tmp;
}

// First
template<typename T>
T first(const std::vector<T> obj) {
    return obj[0];
}

// Last
template<typename T>
T last(const std::vector<T> obj) {
    return obj[obj.size()-1];
}

// Length
template<typename T>
size_t length(const std::vector<T> obj) {
    return obj.size();
}

// Reverse
template<typename T>
std::vector<T> reverse(const std::vector<T> obj) {
    std::vector<T> tmp(obj);
    std::reverse(tmp.begin(), tmp.end());
    return tmp;
}

// Get
template<typename T>
T get(const std::vector<T> obj, int index) {
    return obj[index];
}


// Tail
template<typename T>
std::vector<T> tail(const std::vector<T> obj) {
    std::vector<T> tmp(obj);
    tmp.erase(tmp.begin());
    return tmp;
}


// Init
template<typename T>
std::vector<T> init(const std::vector<T> obj) {
    std::vector<T> tmp(obj);
    tmp.erase(tmp.end());
    return tmp;
}

// Take
template<typename T>
std::vector<T> take(const std::vector<T> obj, int num) {
    std::vector<T> ret;
    for(int i = 0; i < num; i++) {
        ret.push_back(obj[i]);
    }
    
    return ret;
}
template<typename T>
std::vector<T> take(const std::initializer_list<T> tmp, int num) {
    std::vector<T>obj(tmp);
    std::vector<T> ret;
    for(int i = 0; i < num; i++) {
        ret.push_back(obj[i]);
    }
    
    return ret;
}


// null
template<typename T>
bool null(const std::vector<T> obj) {
    return obj.size() == 0;
}

// Typecheck
template<typename T>
bool isInteger(T obj) {
    return (typeid(obj) == typeid(int));
}
template<typename T>
bool isFloat(T obj) {
    return (typeid(obj) == typeid(float) || typeid(obj) == typeid(double));
}
template<typename T>
bool isString(T obj) {
    return (typeid(obj) == typeid(std::vector<char>));
}
template<typename T>
bool isCharacter(T obj) {
    return (typeid(obj) == typeid(char));
}
