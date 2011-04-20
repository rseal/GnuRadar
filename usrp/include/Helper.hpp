#ifndef HELPER_HPP
#define HELPER_HPP

#include <iostream>

namespace usrp
{
	class Helper
	{
		public:

			static const std::string FindFile( const std::string& fileName, const int hwRev )
			{
				std::string result( getenv( USRP_ENV_PATH.c_str() ) );

				std::string hw_rev_str = boost::lexical_cast<std::string>( hwRev );

				if ( !result.empty() ) 
				{ 
					result += "/rev" + hw_rev_str + "/" + fileName ; 
				}
				else if ( access( DEFAULT_PATH.c_str(), R_OK ) == 0 )
				{
					result = DEFAULT_PATH + hw_rev_str + "/" + fileName;
				}

				return result;
			};


			static const std::string GetProtoFileName(const std::string user_filename, const std::string env_var, const std::string def)
			{
				std::string result = def;

				if ( !user_filename.empty() )
				{
					result = user_filename;
				}
				else
				{
					result = getenv( env_var.c_str() );
				}

				return result;
			};

	};
};
#endif 
