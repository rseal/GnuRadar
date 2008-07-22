#include "../include/UsrpInterface.h"

int main(){
    UsrpInterface*  ui = new UsrpInterface(0,0);
    ui->show();
    return Fl::run();
};
