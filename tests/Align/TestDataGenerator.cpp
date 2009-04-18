#ifndef TEST_DATA_GENERATOR_H
#define TEST_DATA_GENERATOR_H

#include <fstream>
#include <iostream>
#include <boost/random.hpp>

using namespace std;

int main(){

    ofstream dout("test.dat", ios::binary | ios::out);

    vector<int> sequence(2,8192);

    boost::minstd_rand generator(42u);
    boost::uniform_real<> uni_dist(-1,1);
    boost::variate_generator<boost::minstd_rand&, boost::uniform_real<> > uni(generator, uni_dist);
    
//corresponds to a 512 sample window with a 1-msec IPP and a 1-second table
    int columns = 512;
    int row = 1000;
    int idx,jdx;
    vector<short> data(row*columns);

    int offset = static_cast<int>(abs(uni())*256);

    for(int i=0; i<offset; i++)
	data[i] = uni()*16384;

  
    int sr = offset/columns;

    int sc = 512-offset%columns;

    cout << "offset = " << offset << endl;
    cout << "sr = " << sr << endl;
    cout << "sc = " << sc << endl;

    for(idx=sr; idx<row-sr; ++idx){
	data[idx*columns+sc] = sequence[0];
	data[idx*columns+1+sc] = sequence[1];
	for(jdx=2+sc; jdx<columns; ++jdx)
	    data[idx*columns + jdx] = uni()*16384;
    }
    
    dout.write(reinterpret_cast<char*>(&data[0]),data.size()*2);

//     for(int i=0; i<idx*columns; ++i){
// 	cout << data[i] << " ";
// 	if((i%512)==0) cout << endl << endl;
//     }
    
}
    

#endif
