// Standard library
#include <iostream>
#include <vector>
using namespace std;

template<typename T>
T first(const vector<T> obj) {
    return obj[0];
}

char first(string str) {
    return str[0];
}

template<typename T>
T last(const vector<T> obj) {
    
}

char last(string str) {
    return str[str.size()-1];
}

template<typename T>
int length(const vector<T> obj) {
    return obj.size();
}

int length(string str) {
    return str.size();
}

template<typename T>
vector<T> reverse(const vector<T> obj) {
    vector<T> tmp(obj);
    std::reverse(tmp.begin(), tmp.end());
    return tmp;
}

string reverse(string str) {
    string tmp = str;
    std::reverse(tmp.begin(), tmp.end());
    return tmp;
}

template<typename T>
T get(const vector<T> obj, int index) {
    return obj[index];
}

char get(string str, int index) {
    return str[index];
}


/*
 Basics:
 length(lst)
 first(lst) = Første objekt
 last(lst) = Sidste objekt
 reverse(lst)
 get(lst, n)
 
 take(lst, n)
 
 tail(lst) = ALT ANDET END FØRSTE
 init(lst) = ALT ANDET END SIDSTE
 
 null(lst) = { if length(lst) == 0 { true } { false } }
 
 */
