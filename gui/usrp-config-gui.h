#ifndef USRP_CONFIG_GUI_H
#define USRP_CONFIG_GUI_H

#include <FL/Fl.H>
#include <FL/Fl_Group.H>
#include <FL/Fl_Button.H>
#include <FL/Fl_Tabs.H>
#include <FL/Fl_Input.H>
#include <FL/Fl_File_Browser.H>
#include <FL/Fl_Window.h>
#include <iostream>
using std::auto_ptr;

class UserInterface : public Fl_Window 
{
    auto_ptr<Fl_Button>       buttonQuit_;
    auto_ptr<Fl_Button>       buttonSave_;
    auto_ptr<Fl_Button>       buttonApply_;
    auto_ptr<Fl_Tabs>         tabWindow_;
    auto_ptr<Fl_Group>        tab1Group_;
    auto_ptr<Fl_Group>        tab2Group_;
    auto_ptr<Fl_File_Browser> fileBrowserFPGA_;
    auto_ptr<Fl_Input>        tab1Input1_;
    auto_ptr<Fl_Input>        tab1Input2_;
    auto_ptr<Fl_Input>        tab1Input3_;
    auto_ptr<Fl_Input>        tab1Input4_;
    auto_ptr<Fl_Input>        tab1Input5_;
    auto_ptr<Fl_Input>        tab2Input1_;
    auto_ptr<Fl_Input>        tab2Input2_;
    auto_ptr<Fl_Input>        tab2Input3_;
    auto_ptr<Fl_Input>        tab2Input4_;
    auto_ptr<Fl_Input>        tab2Input5_;

   static void CallBackQuit(Fl_Widget* flw){
       std::cout << "quit" << std::endl;
       exit(0);
    }
 
public:
    UserInterface(int X, int Y);
};
#endif
