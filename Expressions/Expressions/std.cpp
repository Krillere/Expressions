// Standard library
#include <iostream>
#include <vector>

template<typename T>
T first(const std::vector<T> obj) {
    return obj[0];
}

char first(std::string str) {
    return str[0];
}

template<typename T>
T last(const std::vector<T> obj) {
    
}

char last(std::string str) {
    return str[str.size()-1];
}

template<typename T>
size_t length(const std::vector<T> obj) {
    return obj.size();
}

size_t length(std::string str) {
    return str.size();
}

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

template<typename T>
T get(const std::vector<T> obj, int index) {
    return obj[index];
}

char get(std::string str, int index) {
    return str[index];
}

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

/*
 Basics:
 length(lst)
 first(lst) = Første objekt
 last(lst) = Sidste objekt
 reverse(lst)
 get(lst, n)
 
 init(lst) = ALT ANDET END SIDSTE
 tail(lst) = ALT ANDET END FØRSTE
 
 // Mangler:
 take(lst, n)
 
 null(lst) = { if length(lst) == 0 { true } { false } }
 
 */
