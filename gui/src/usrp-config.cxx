////////////////////////////////////////////////////////////////////////////////
///usrp-config.cxx
///
/// Main loop that loads UsrpInterface
///
///Author: Ryan Seal
///Modified: 08/06/08
////////////////////////////////////////////////////////////////////////////////
#include "../include/UsrpInterface.h"

///Main loop for program execution
int main(){
    UsrpInterface*  ui = new UsrpInterface(0,0);
    ui->show();
    return Fl::run();
};
