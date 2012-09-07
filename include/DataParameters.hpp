#ifndef DATA_PARAMETERS_HPP
#define DATA_PARAMETERS_HPP
#include<iostream>
#include<vector>
#include<gnuradar/commands/Control.pb.h>


////////////////////////////////////////////////////////////////////////////////
////////////////////////////////////////////////////////////////////////////////
namespace gnuradar{

	/////////////////////////////////////////////////////////////////////////////
	/////////////////////////////////////////////////////////////////////////////
	struct DataParameters{

		//////////////////////////////////////////////////////////////////////////
		//////////////////////////////////////////////////////////////////////////
		int WindowSize(gnuradar::File& file)
		{
			int sum=0;

			for(int i=0; i<file.window_size(); ++i)
			{
				int start = file.window(i).start();
				int stop = file.window(i).stop();
				sum += stop-start;
			}

			return sum;
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
		DataParameters( gnuradar::File& file, int bytesPerSample=4, double secondsPerBuffer=1.0  )
		{
			gnuradar::RadarParameters* rp = file.mutable_radarparameters();
			rp->set_samplesperpri( this->WindowSize(file));
			rp->set_pri( file.ipp() );
			rp->set_prf( 1.0/rp->pri() );
			rp->set_bytespersample( bytesPerSample );
			rp->set_secondsperbuffer( secondsPerBuffer );
			rp->set_samplesperbuffer( rp->prf() * rp->samplesperpri() );
			rp->set_prisperbuffer( rp->samplesperbuffer() / rp->samplesperpri() );
			rp->set_bytesperbuffer( rp->samplesperbuffer() * rp->bytespersample() );
			rp->set_bytespersecond( rp->bytesperbuffer() / rp->secondsperbuffer() );
		}
	};
};

#endif
