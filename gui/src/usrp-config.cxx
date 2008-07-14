#include "../include/usrp-config-gui.h"

int main(){
    UserInterface ui(450,500);
    ui.show();
    return Fl::run();
};
