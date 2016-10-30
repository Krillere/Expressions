// Standard library
#include <iostream>
#include <vector>

// First
template<typename T>
T first(std::initializer_list<T> ini) {
    std::vector<T> obj(ini);
    return obj[0];
}
template<typename T>
T first(const std::vector<T> obj) {
    return obj[0];
}
char first(std::string str) {
    return str[0];
}

// Last
template<typename T>
T last(std::initializer_list<T> ini) {
    std::vector<T> obj(ini);
    return obj[obj.size()-1];
}
template<typename T>
T last(std::vector<T> obj) {
    return obj[obj.size()-1];
}
char last(std::string str) {
    return str[str.size()-1];
}

// Length
template<typename T>
size_t length(std::initializer_list<T> ini) {
    std::vector<T> obj(ini);
    return obj.size();
}
template<typename T>
size_t length(std::vector<T> obj) {
    return obj.size();
}
size_t length(std::string str) {
    return str.size();
}

// Reverse
template<typename T>
std::vector<T> reverse(std::initializer_list<T> ini) {
    std::vector<T> obj(ini);
    std::vector<T> tmp(obj);
    std::reverse(tmp.begin(), tmp.end());
    return tmp;
}
template<typename T>
std::vector<T> reverse(std::vector<T> obj) {
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
T get(std::initializer_list<T> ini, int index) {
    std::vector<T> obj(ini);
    return obj[index];
}
template<typename T>
T get(std::vector<T> obj, int index) {
    return obj[index];
}
char get(std::string str, int index) {
    return str[index];
}

// Tail
template<typename T>
std::vector<T> tail(std::initializer_list<T> ini) {
    std::vector<T> obj(ini);
    std::vector<T> tmp(obj);
    tmp.erase(tmp.begin());
    return tmp;
}
template<typename T>
std::vector<T> tail(std::vector<T> obj) {
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
std::vector<T> init(std::initializer_list<T> ini) {
    std::vector<T> obj(ini);
    std::vector<T> tmp(obj);
    tmp.erase(tmp.end());
    return tmp;
}
template<typename T>
std::vector<T> init(std::vector<T> obj) {
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
std::vector<T> take(std::initializer_list<T> ini, int num) {
    std::vector<T> obj(ini);
    std::vector<T> ret;
    for(int i = 0; i < num; i++) {
        ret.push_back(obj[i]);
    }
    
    return ret;
}
template<typename T>
std::vector<T> take(std::vector<T> obj, int num) {
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

/*
 Basics:
 length(lst)
 first(lst) = Første objekt
 last(lst) = Sidste objekt
 reverse(lst)
 get(lst, n)
 
 init(lst) = ALT ANDET END SIDSTE
 tail(lst) = ALT ANDET END FØRSTE
 take(lst, n)
 
 // Kan laves i expr
 null(lst) = { if length(lst) == 0 { true } { false } }
 
 */
