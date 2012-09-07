#include<gnuradar/RadarParameters.hpp>

int main()
{
   // standard setup for usrp1
   double sampleRate = 64e6;
   int decimation = 64;

   // 1 sample per usec.
   double outputRate = sampleRate/decimation;

   // standard pulse repitition rate for meteor radar.
   double prf = 1e3;
   
   // round trip wave propagation constant ~ 150m / usec
   // r0 = 75km -> n = 500 
   // r1 = 125km -> n = rnd(833.33) = 834 
   gnuradar::ReceiveWindow window1(500,834);

   // round trip wave propagation constant ~ 150m / usec
   // r0 = 150km -> n = 1000 
   // r1 = 200km -> n = rnd(1333.3) = 1334
   gnuradar::ReceiveWindow window2(1000,1334);

   gnuradar::ReceiveWindows windows;
   windows.push_back( window1 );
   windows.push_back( window2 );

   gnuradar::RadarParameters rp( outputRate, prf, windows );
   rp.Print();
   return 0;
}
