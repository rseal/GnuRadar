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
   int offset_;

   public: 
   Viewer(const string& fileName): header_(fileName, File::READ, File::BINARY){
      header_.ReadPrimary();
      header_.ReadData(0);
      //Waiting on IPP keyword to be added - hardcode for now
      //header_.primaryValue<int>("IPP");
      sleep_ = 10;
      offset_ = 0;
      numTables_ = header_.NumTables();
   }

   void RefreshRate(const int& ms){ sleep_ = ms; }
   void Offset(const int& offset){offset_ = offset;}

   void Run(){

      Int16* dataPtr;
      int ipp=header_.data.Dim(0);
      int sample=header_.data.Dim(1);
      int table=0;
      int channels=header_.primaryValue<int>("Channels");

      cout << "IPPs    = " << ipp << endl;
      cout << "Samples = " << sample << endl;
      float f = 200e3/500e3;
      float phase = 0;

      while(table != numTables_){
         dataPtr = header_.ReadData(table);
         for(int i=0; i<ipp; ++i){
            ofstream out("/dev/shm/splot.buf",ios::out); 
            for(int j=offset_; j<sample/(2*channels); ++j){
               float t1=static_cast<float>(j-offset_);
               float t2=static_cast<float>(dataPtr[i*sample + j*2*channels]);
               float t2_cos = cos(2*M_PI*j*f + M_PI*phase/180.0)*t2;
               t2 = 1.6*t2;
               t2 = t2_cos;
               out.write(reinterpret_cast<char*>(&t1),sizeof(float));
               out.write(reinterpret_cast<char*>(&t2),sizeof(float));
               //if(i%100 == 0 && j==offset_){
               //   cout << "phase = " << ++phase << endl;
               //   if(phase == 361) phase=0;
               //}
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
   int refreshRate;
   int offset;
   //class to handle command line options/parsing
   CommandLineParser clp(argc,argv);
   Arg arg1("f", "file to view", 1, true);
   Arg arg2("r", "refresh rate", 1, false, "100");
   Arg arg3("o", "offset", 1, false, "0");
   clp.AddArg(arg1);
   clp.AddArg(arg2);
   clp.AddArg(arg3);
   clp.Parse();
   fileName = clp.GetArgValue<string>("f");
   refreshRate = clp.GetArgValue<int>("r");
   offset = clp.GetArgValue<int>("o");

   Viewer view(fileName);
   view.RefreshRate(refreshRate);
   view.Offset(offset);
   view.Start();
   view.Wait();

   return 0;
}

