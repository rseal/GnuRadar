#include<gnuradar/utils/GrHelper.hpp>

int main()
{
   std::string ip_status  = gr_helper::GetIpAddress("status");
   std::string ip_control = gr_helper::GetIpAddress("control");

   std::cout << "status  " << ip_status  << std::endl;
   std::cout << "control " << ip_control << std::endl;

   return 0;
}
