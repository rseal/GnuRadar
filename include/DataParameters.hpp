#ifndef DATA_PARAMETERS_HPP
#define DATA_PARAMETERS_HPP
#include<iostream>
#include<vector>
#include<gnuradar/commands/Control.pb.h>
#include<cmath>


////////////////////////////////////////////////////////////////////////////////
////////////////////////////////////////////////////////////////////////////////
namespace gnuradar{

	/////////////////////////////////////////////////////////////////////////////
	/////////////////////////////////////////////////////////////////////////////
	struct DataParameters{

		//////////////////////////////////////////////////////////////////////////
		//////////////////////////////////////////////////////////////////////////
		int WindowSize(gnuradar::File* file)
		{
			int sum=0;

			for(int i=0; i<file->window_size(); ++i)
			{
				double start = file->window(i).start();
				double stop = file->window(i).stop();
				sum += ceil(stop-start);
			}

			return sum;
		}

      int round( double x)
      {
         return static_cast<int>(floor( x + 0.5 ));
      }

		public:

		//////////////////////////////////////////////////////////////////////////
		/// Radar Parameters is used to define the underlying structure of the 
		/// memory buffer applied to incoming data.
		//
		// \param file google protocol buffer containing file params.
		// \param bytesPerSample number of bytes per sample. Default is 4.
		// \param secondsPerBuffer seconds per buffer. Default is 1.0 
		//////////////////////////////////////////////////////////////////////////
		DataParameters( gnuradar::File* file, int bytesPerSample=4, double secondsPerBuffer=1.0  )
		{
			gnuradar::RadarParameters* rp = file->mutable_radarparameters();
			rp->set_samplesperpri( this->WindowSize(file));
			rp->set_pri( file->ipp() );
			rp->set_prf( 1.0/rp->pri() );
			rp->set_bytespersample( bytesPerSample );
			rp->set_secondsperbuffer( secondsPerBuffer );
			rp->set_samplesperbuffer( round(rp->prf()*rp->samplesperpri()) );
			rp->set_prisperbuffer( round(rp->samplesperbuffer()/rp->samplesperpri()) );
			rp->set_bytesperbuffer( round(rp->samplesperbuffer()*rp->bytespersample()) );
			rp->set_bytespersecond( round(rp->bytesperbuffer()/rp->secondsperbuffer()) );

         std::cout << "samplesperpri    = " << rp->samplesperpri() << std::endl;
         std::cout << "pri              = " << rp->pri() << std::endl;
         std::cout << "prf              = " << rp->prf() << std::endl;
         std::cout << "bytespersample   = " << rp->bytespersample() << std::endl;
         std::cout << "secondsperbuffer = " << rp->secondsperbuffer() << std::endl;
         std::cout << "samplesperbuffer = " << rp->samplesperbuffer() << std::endl;
         std::cout << "prisperbuffer    = " << rp->prisperbuffer() << std::endl;
         std::cout << "bytesperbuffer   = " << rp->bytesperbuffer() << std::endl;
         std::cout << "bytespersecond   = " << rp->bytespersecond() << std::endl;
		}
	};
};

#endif
