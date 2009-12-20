#include <iostream>
#include <complex>
#include <fstream>
#include <simpleHeader/Shs.h>
#include <simpleHeader/Timer.h>

using namespace std;

int main(int argc, char** argv)
{
    string fileName="/home/rseal/usrpLabTest";
    if(argc ==2) fileName = argv[1];

    typedef SimpleHeader<short,2> SHeader;

    Timer timer;

    SHeader shs(fileName, File::READ, File::BINARY);

    shs.ReadPrimary();
    shs.ReadData(100);

    int dim1 = shs.data.Dim(0);
    int dim2 = shs.data.Dim(1);

    int tableSize = shs.data.DataSize()/sizeof(short);

    short* buffer = shs.ReadData(0);

    //   for(int i=0; i<dim1; ++i)
//        cout << buffer[2*i] << endl;

    ofstream outFile("binary.dat", ios::binary);

    outFile.write(reinterpret_cast<char*>(buffer),tableSize*sizeof(short));
    //new short[tableSize];

    cout << "Dim1 = " << dim1 << " Dim2 = " << dim2 << endl;
    cout << "tableSize = " << tableSize << endl;

    //delete buffer;
    //Create a simple header structure for reading 
//    SimpleHeader<short,3>* 
//        format = new SimpleHeader<short,3>("../data/testfile", File::READ, File::ASCII);

    //!!!!! This is a bug - read primary and 1st table to initialize file !!!!!!!
//    format->ReadPrimary();
//    format->ReadData(0);

//    cout << endl;
//    cout << "--------------Header Preamble--------------" << endl;
//    format->primary.ProgramInfo(cout);

//    cout << endl;
//    cout << "--------------Primary Header--------------" << endl;
//    format->primary.PrintPrimary(cout);

//    cout << "--------------Data Set Title--------------" << endl;
//    cout << format->primary.Title() << endl << endl;

//    cout << "--------------Primary Header--------------" << endl;
//    cout << format->primary.Description() << endl << endl;

//    cout << "--------------System Byte Order-----------" << endl;
//    cout << format->primary.ByteOrder() << endl << endl;

//    float value1 = format->primaryValue<float>("RawVoltageSample");
//    int value2 = format->dataValue<int>("TestDataKey");

//    cout << "primary voltage sample = " << value1 << endl;
//    cout << "test data key = " << value2 << endl;

//    int numDims = format->data.NumDims();

//    cout << "File Format contains " << numDims << " dimensions" << endl << endl;
//    for(int i=0; i<numDims; ++i)
//        cout << "Dim " << i << " = " << format->data.Dim(i) << endl;

//    cout << endl;

//    cout << "File contains " << format->NumTables() << " tables " << endl << endl;
//   delete shs;
}

