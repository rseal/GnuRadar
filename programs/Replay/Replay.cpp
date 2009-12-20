#include <simpleHeader/Shs.h>
#include <clp/CommandLineParser.hpp>
#include <gnuradar/SThread.h>
#include <string>
#include <fstream>

using namespace std;

class Viewer: public SThread{

   typedef short Int16;
   typedef SimpleHeader<Int16,2> Header;
   Header header_;
   int numTables_;
   int sleep_;

   public: 
   Viewer(const string& fileName): header_(fileName, File::READ, File::BINARY){
      header_.ReadPrimary();
      header_.ReadData(0);
      //Waiting on IPP keyword to be added - hardcode for now
      //header_.primaryValue<int>("IPP");
      sleep_ = 1;
      numTables_ = header_.NumTables();
   }

   void Run(){

      Int16* dataPtr;
      int ipp=header_.data.Dim(0);
      int sample=header_.data.Dim(1);
      int table=0;
      int channels=header_.primaryValue<int>("Channels");

      cout << "IPPs    = " << ipp << endl;
      cout << "Samples = " << sample << endl;
      while(table != numTables_){
         dataPtr = header_.ReadData(table);
         for(int i=0; i<ipp; ++i){
            ofstream out("/dev/shm/splot.buf",ios::out); 
            for(int j=0; j<sample/(2*channels); ++j){
               float t1=static_cast<float>(j);
               float t2=static_cast<float>(*dataPtr);
               out.write(reinterpret_cast<char*>(&t1),sizeof(float));
               out.write(reinterpret_cast<char*>(&t2),sizeof(float));
               dataPtr += 2*channels;
            }
            out.close();
            Sleep(ST::ms, sleep_);
         } 
         ++table;
      }
   }
};

int main(int argc, char** argv){
   typedef short Int16;
   typedef SimpleHeader<Int16,2> Header;
   string fileName;

   //class to handle command line options/parsing
   CommandLineParser clp(argc,argv);
   clp.AddArg("f", "file to view", 1, true);
   clp.Parse();
   fileName = clp.GetArgValue<string>("f");

   Viewer view(fileName);
   view.Start();
   view.Wait();

   return 0;
}

