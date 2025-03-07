#include <bits/stdc++.h>
using namespace std;

bool matchings(string s, string f){
    for(int i=0; i+f.size()<=s.size(); i++){
        if(s.substr(i,f.size())==f) return true;
    }
    return false;
}

string extract(string s){
    string f = " [label";
    for(int i=0; i+f.size()<=s.size(); i++){
        if(s.substr(i,f.size())==f) return s.substr(0,i);
    }
    return "";
}

// Function to process the .dot file
void processDotFile(const string& inputFileName, const string& outputFileName) {
    ifstream inputFile(inputFileName);
    ofstream outputFile(outputFileName);
    
    if (!inputFile.is_open() || !outputFile.is_open()) {
        cerr << "Error opening file(s)." << endl;
        return;
    }
    
    unordered_map<string, bool> connections;
    string line;

    // Read and process the input .dot file
    while (getline(inputFile, line)) {
        if(matchings(line,"->") && matchings(line,"ConnectionClosed")){
            string state = extract(line);
                if(connections[state]==false){
                    outputFile<< state<< " [label=\"~ / ConnectionClosed\"];\n";
                }
                connections[state] = true;
        }
        else{
            outputFile<< line<< endl;
        }
    }
    
    inputFile.close();
    outputFile.close();
}

int main(int argc, char **argv) {
    if(argc<3){
        return 0;
    }
    string inputFileName = argv[1];//"openssl_server/learnedModel.dot";
    string outputFileName = argv[2];//"openssl_server/newmodel.dot";
    
    processDotFile(inputFileName, outputFileName);
    
    cout << "Processed state diagram has been written to " << outputFileName << endl;
    return 0;
}
