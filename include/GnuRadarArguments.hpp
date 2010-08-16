#ifndef GNURADAR_ARGUMENTS_HPP
#define GNURADAR_ARGUMENTS_HPP

#include <boost/any.hpp>
#include <vector>

struct Arguments
{
   public:
   typedef std::vector< boost::any > ArgumentList;

   Arguments( const ArgumentList args ) { args_ = args; }

   void Add( const boost::any value ) { args_.push_back( value ); }

   const ArgumentList& GetRef() { return args_; }

   template< typename T>
      const T& Get( const int index )
      {
         // throws on out of bounds or bad cast
         T value = boost::any_cast<T>( args_.at( index ) );
         return T;
      }

   private:
   const ArgumentList args_;
};

#endif
