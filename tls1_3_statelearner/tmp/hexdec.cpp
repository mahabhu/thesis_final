#include<bits/stdc++.h>
using namespace std;

int main(){
    while(1){
        string hexInput;
        cin >> hexInput;
        unsigned long decimalValue;
        stringstream ss;

        ss << hex << hexInput;
        ss >> decimalValue;

        cout << decimalValue<< " "<< decimalValue*2 << endl;
    }
}