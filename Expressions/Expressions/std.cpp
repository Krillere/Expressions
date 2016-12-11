// Standard library
#include <iostream>
#include <fstream>
#include <vector>
#include <typeinfo>
#include <string>
#include <algorithm>
#include <functional>

// Std vars
std::vector<std::vector<char>> internal_arguments;

// Prototypes for std
template<typename T>
void print(T obj);
template<typename T>
void print(std::vector<T> obj);
void print(std::vector<char> obj);
template<typename T>
void print(std::initializer_list<T> obj);
void print(std::initializer_list<char> obj);
template<typename T>
void printLn(T obj);
std::vector<char> readFileContents(std::vector<char> pathv);
void writeFileContents(std::vector<char> pathv, std::vector<char> content);
template<typename T>
std::vector<T> list(T obj);
template<typename T>
std::vector<T> append(const std::vector<T> lst);
template<typename T>
std::vector<T> append(const std::vector<T> lst, std::vector<T> obj);
template <typename T, typename ... Rest>
std::vector<T> append(const std::vector<T> lst, const std::vector<T>& obj, const Rest&... rest);
template<typename T>
size_t length(const std::vector<T> obj);
template<typename T>
std::vector<T> reverse(const std::vector<T> obj);
template<typename T>
T get(const std::vector<T> obj, int index);
template<typename T>
std::vector<T> tail(const std::vector<T> obj);
template<typename T>
std::vector<T> init(const std::vector<T> obj);
template<typename T>
std::vector<T> take(const std::vector<T> obj, int num);
template<typename T>
bool isInt(T obj);
template<typename T>
bool isFloat(T obj);
template<typename T>
bool isString(T obj);
template<typename T>
bool isChar(T obj);
template<typename T>
bool isBool(T obj);
int convertToInt(std::vector<char> str);
int convertToInt(float f);
int convertToInt(char c);
float convertToFloat(int i);
float convertToFloat(std::vector<char> str);
char convertToChar(int i);
std::vector<char> convertToString(int i);
std::vector<char> convertToString(float f);
std::vector<char> convertToString(char c);
std::vector<std::vector<char>> CLArguments();

// Print
template<typename T>
void print(T obj) {
    std::cout << obj;
}

template<typename T>
void print(std::vector<T> obj) {
    typename std::vector<T>::iterator it;
    print("[");
    for (it = obj.begin() ; it != obj.end(); ++it) {
        print(*it);
        if(it != obj.end()-1) {
            print(", ");
        }
    }
    print("]");
}
void print(std::vector<char> obj) {
    for (std::vector<char>::iterator it = obj.begin() ; it != obj.end(); ++it) {
        print(*it);
    }
}
template<typename T>
void print(std::initializer_list<T> obj) {
    std::vector<T>tmp(obj);
    print("[");
    for(int n = 0; n < tmp.size(); n++) {
        print(tmp[n]);
        if(n != tmp.size()-1) {
            print(", ");
        }
    }
    print("]");
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
std::vector<T> append(const std::vector<T> lst) {
    std::vector<T> tmp(lst);
    return tmp;
}
template<typename T>
std::vector<T> append(const std::vector<T> lst, std::vector<T> obj) {
    std::vector<T>tmp(lst);
    tmp.insert(tmp.end(), obj.begin(), obj.end());
    
    return tmp;
}
template <typename T, typename ... Rest>
std::vector<T> append(const std::vector<T> lst, const std::vector<T>& obj, const Rest&... rest) {
    std::vector<T> tmp(lst);
    tmp.insert(tmp.end(), obj.begin(), obj.end());
    return append(tmp, rest...);
}
template<typename T>
std::vector<T> append(const std::vector<T> lst, T obj) {
    std::vector<T> tmp(lst);
    tmp.push_back(obj);
    return tmp;
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

// Typecheck
template<typename T>
bool isInt(T obj) {
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
bool isChar(T obj) {
    return (typeid(obj) == typeid(char));
}
template<typename T>
bool isBool(T obj) {
    return (typeid(obj) == typeid(bool));
}

// Conversions
int convertToInt(std::vector<char> str) {
    std::string tmp(str.begin(), str.end());
    std::string::size_type sz;
    return std::stoi(tmp, &sz);
}
int convertToInt(float f) {
    return (int)f;
}
int convertToInt(char c) {
    return (int)c;
}

float convertToFloat(int i) {
    return (float)i;
}
float convertToFloat(std::vector<char> str) {
    std::string tmp(str.begin(), str.end());
    std::string::size_type sz;
    return std::stof(tmp, &sz);
}

char convertToChar(int i) {
    return (char)i;
}

std::vector<char> convertToString(int i) {
    std::string tmp;
    tmp = std::to_string(i);
    std::vector<char> data(tmp.begin(), tmp.end());
    return data;
}
std::vector<char> convertToString(float f) {
    std::string tmp;
    tmp = std::to_string(f);
    std::vector<char> data(tmp.begin(), tmp.end());
    return data;
}
std::vector<char> convertToString(char c) {
    return {c};
}

// Command line arguments (Created as function, because 'global variables' does not exist in Expressions (Kinda))
std::vector<std::vector<char>> CLArguments() {
    return internal_arguments;
}

// Environment variables
std::vector<char> getEnvironmentVariable(std::vector<char> name) {
    std::string stringName(name.begin(), name.end());
    char const* tmp = getenv(stringName.c_str());
    
    if(tmp == NULL) {
        std::vector<char> ret;
        return ret;
    }
    else {
        std::string retString = std::string(tmp);
        std::vector<char> retVector(retString.begin(), retString.end());
        return retVector;
    }
}
