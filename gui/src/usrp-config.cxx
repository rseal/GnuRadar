#include "../include/usrp-config-gui.h"

int main(){
    UserInterface ui(650,500);
    ui.show();
    return Fl::run();
};
