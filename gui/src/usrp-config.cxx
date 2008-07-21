#include "../include/UsrpInterface.h"

int main(){
    UsrpInterface*  ui = new UsrpInterface(750,470);
    ui->show();
    return Fl::run();
};
