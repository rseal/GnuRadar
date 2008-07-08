#include "usrp-config-gui.h"

UserInterface::UserInterface(int X, int Y): Fl_Window(X, Y)
{
    //top-level buttons
    buttonSave_  = auto_ptr<Fl_Button>(new Fl_Button(120, 455, 100, 30, "Save"));
    buttonApply_ = auto_ptr<Fl_Button>(new Fl_Button(10, 455, 100, 30, "Apply"));
    buttonQuit_  = auto_ptr<Fl_Button>(new Fl_Button(320, 455, 100, 30, "Quit"));
    buttonQuit_->callback(UserInterface::CallBackQuit);

    //top-level tab container
    tabWindow_ = auto_ptr<Fl_Tabs>(new Fl_Tabs(25, 25, 400, 400));
      
    //tab1
    tab1Group_  = auto_ptr<Fl_Group>(new Fl_Group(60, 55, 375, 360, "USRP"));

    tab1Input1_ = auto_ptr<Fl_Input>(new Fl_Input(130, 70, 115, 25, "Sample Rate"));
    tab1Input2_ = auto_ptr<Fl_Input>(new Fl_Input(130, 100, 115, 25, "Channels"));
    tab1Input3_ = auto_ptr<Fl_Input>(new Fl_Input(130, 130, 115, 25, "Bandwidth"));
    tab1Input4_ = auto_ptr<Fl_Input>(new Fl_Input(130, 160, 115, 25, "IPP"));
    tab1Input5_ = auto_ptr<Fl_Input>(new Fl_Input(130, 190, 115, 25, "Sample Rate"));
    fileBrowserFPGA_ = auto_ptr<Fl_File_Browser>(new Fl_File_Browser(125, 390, 220, 25, "FPGA Image"));
    fileBrowserFPGA_->align(FL_ALIGN_LEFT);
    fileBrowserFPGA_->load("");

    tab1Group_->add(tab1Input1_.get());
    tab1Group_->add(tab1Input2_.get());
    tab1Group_->add(tab1Input3_.get());
    tab1Group_->add(tab1Input4_.get());
    tab1Group_->add(tab1Input5_.get());
    tab1Group_->add(fileBrowserFPGA_.get());

    //tab2
    tab2Group_  = auto_ptr<Fl_Group>(new Fl_Group(50, 50, 375, 375, "Header"));
    tab2Group_->hide();
      
    tab2Input1_ = auto_ptr<Fl_Input>(new Fl_Input(115, 60, 205, 25, "Name"));
    tab2Input2_ = auto_ptr<Fl_Input>(new Fl_Input(115, 95, 205, 25, "Description"));
    tab2Input3_ = auto_ptr<Fl_Input>(new Fl_Input(115, 125, 205, 25, "Instrument"));
    tab2Input4_ = auto_ptr<Fl_Input>(new Fl_Input(115, 155, 205, 25, "Object"));
    tab2Input5_ = auto_ptr<Fl_Input>(new Fl_Input(115, 185, 205, 25, "User(s)"));

    tab2Group_->add(tab2Input1_.get());
    tab2Group_->add(tab2Input2_.get());
    tab2Group_->add(tab2Input3_.get());
    tab2Group_->add(tab2Input4_.get());
    tab2Group_->add(tab2Input5_.get());

    tabWindow_->add(tab1Group_.get());
    tabWindow_->add(tab2Group_.get());
}
