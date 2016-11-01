// Standard library
#include <iostream>
#include <fstream>
#include <vector>

// Print
template<typename T>
void print(T obj) {
    std::cout << obj;
}
template<typename T>
void printLn(T obj) {
    std::cout << obj << std::endl;
}

// readFileContents
std::string readFileContents(std::string path) {
    std::ifstream ifs(path);
    std::string content( (std::istreambuf_iterator<char>(ifs) ),
                        (std::istreambuf_iterator<char>()    ) );
    ifs.close();
    return content;
}

// writeFileContents
void writeFileContents(std::string path, std::string content) {
    std::ofstream ofs (path, std::ofstream::binary);
    ofs << content;
    ofs.close();
}

// List
template<typename T>
std::vector<T> list(T obj) {
    std::vector<T> ret;
    ret.push_back(obj);
    
    return ret;
}
std::string list(char c) {
    std::string ret;
    ret.push_back(c);
    
    return ret;
}

// Append
std::string append(std::string str, char c) {
    std::string tmp(str);
    tmp.push_back(c);
    
    return tmp;
}
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
char first(std::string str) {
    return str[0];
}

// Last
template<typename T>
T last(const std::vector<T> obj) {
    return obj[obj.size()-1];
}
char last(std::string str) {
    return str[str.size()-1];
}

// Length
template<typename T>
size_t length(const std::vector<T> obj) {
    return obj.size();
}
size_t length(std::string str) {
    return str.size();
}

// Reverse
template<typename T>
std::vector<T> reverse(const std::vector<T> obj) {
    std::vector<T> tmp(obj);
    std::reverse(tmp.begin(), tmp.end());
    return tmp;
}
std::string reverse(std::string str) {
    std::string tmp = str;
    std::reverse(tmp.begin(), tmp.end());
    return tmp;
}

// Get
template<typename T>
T get(const std::vector<T> obj, int index) {
    return obj[index];
}
char get(std::string str, int index) {
    return str[index];
}

// Tail
template<typename T>
std::vector<T> tail(const std::vector<T> obj) {
    std::vector<T> tmp(obj);
    tmp.erase(tmp.begin());
    return tmp;
}
std::string tail(std::string str) {
    std::string tmp(str);
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
std::string init(std::string str) {
    std::string tmp(str);
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
std::string take(std::string str, int num) {
    std::string ret;
    
    for(int i = 0; i < num; i++) {
        ret.push_back(str[i]);
    }
    
    return ret;
}

// null
template<typename T>
bool null(const std::vector<T> obj) {
    return obj.size() == 0;
}
bool null(std::string obj) {
    return obj.size() == 0;
}
