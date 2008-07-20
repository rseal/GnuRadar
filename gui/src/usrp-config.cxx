#include "../include/usrp-config-gui.h"

int main(){
    UserInterface ui(750,470);
    ui.show();
    return Fl::run();
};
