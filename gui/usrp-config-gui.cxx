#include "usrp-config-gui.h"

UserInterface::UserInterface(int X, int Y): Fl_Window(X, Y)
{
    int baseX = 25;
    int baseY = 25;

    this->box(FL_PLASTIC_UP_BOX);
    this->label("Universal Software Radio Peripheral Configuration Interface (v-0.99)");
    this->color(57);
    
    //top-level buttons
    buttonSave_  = auto_ptr<Fl_Button>(new Fl_Button(120, 455, 100, 30, "Save"));
    buttonSave_->box(FL_PLASTIC_UP_BOX);
    buttonApply_ = auto_ptr<Fl_Button>(new Fl_Button(10, 455, 100, 30, "Apply"));
    buttonApply_->box(FL_PLASTIC_UP_BOX);
    buttonQuit_  = auto_ptr<Fl_Button>(new Fl_Button(320, 455, 100, 30, "Quit"));
    buttonQuit_->box(FL_PLASTIC_UP_BOX);
    buttonQuit_->callback(UserInterface::Quit);

    //buttonSave_->labelcolor(45);
    //buttonApply_->labelcolor(45);
    //buttonQuit_->labelcolor(45);
    
    //top-level tab container
    tabWindow_ = auto_ptr<Fl_Tabs>(new Fl_Tabs(25, 25, 400, 400));
    tabWindow_->box(FL_PLASTIC_UP_BOX);

    //tab1
    tab1Group_  = auto_ptr<Fl_Group>(new Fl_Group(30, 70, 390, 350, "USRP"));
    tab1Group_->box(FL_PLASTIC_UP_BOX);
    //tab1Group_->color(65);

    tab1Input1_ = auto_ptr<Fl_Float_Input>(new Fl_Float_Input(130, 80, 115, 25, "Sample Rate"));
    tab1Input1_->value(usrpParameters_.SampleRateString());
    tab1Input1_->callback(UserInterface::UpdateSampleRate,this);
    tab1Input1_->box(FL_PLASTIC_UP_BOX);

    //change to choice 1,2,4
    tab1Input2_ = auto_ptr<Fl_Input>(new Fl_Input(130, 110, 115, 25, "Channels"));
    tab1Input2_->box(FL_PLASTIC_UP_BOX);

    tab1Output1_ = auto_ptr<Fl_Output>(new Fl_Output(130,140,115,25, "Bandwidth"));
    tab1Output1_->value("8");
    tab1Output1_->color(FL_GRAY);
    tab1Output1_->box(FL_PLASTIC_UP_BOX);

    tab1Input4_ = auto_ptr<Fl_Input>(new Fl_Input(130, 170, 115, 25, "IPP"));
    tab1Input4_->box(FL_PLASTIC_UP_BOX);

    tab1Slider_ = auto_ptr<Fl_Value_Slider>(new Fl_Value_Slider(130,200, 115, 25, "Decimation"));
    tab1Slider_->align(FL_ALIGN_LEFT);
    tab1Slider_->type(FL_HOR_NICE_SLIDER);
    tab1Slider_->step(2);
    tab1Slider_->range(8,256);
    tab1Slider_->value(8);
    tab1Slider_->box(FL_PLASTIC_UP_BOX);
    tab1Slider_->callback(UserInterface::UpdateDecimation,this);

    fileBrowserFPGA_ = auto_ptr<Fl_File_Browser>(new Fl_File_Browser(125, 380, 220, 25, "FPGA Image"));
    fileBrowserFPGA_->align(FL_ALIGN_LEFT);
    fileBrowserFPGA_->load("../fpga");
    fileBrowserFPGA_->box(FL_PLASTIC_UP_BOX);

    tab1Group_->add(tab1Input1_.get());
    tab1Group_->add(tab1Input2_.get());
    tab1Group_->add(tab1Output1_.get());
    tab1Group_->add(tab1Input4_.get());
    tab1Group_->add(tab1Slider_.get());
    tab1Group_->add(fileBrowserFPGA_.get());
    tab1Group_->box(FL_PLASTIC_UP_BOX);
    
//    tab1Group_->labelcolor(65);
    
    //tab2  
    tab2Group_  = auto_ptr<Fl_Group>(new Fl_Group(30, 70, 390, 350, "Header"));
    tab2Group_->hide();
    tab2Group_->box(FL_PLASTIC_UP_BOX);
    //tab2Group_->color(65);
    tab2Group_->labelcolor(65);
    tab2Input1_ = auto_ptr<Fl_Input>(new Fl_Input(125, 100, 205, 25, "Name"));
    tab2Input1_->box(FL_PLASTIC_UP_BOX);
    tab2Input2_ = auto_ptr<Fl_Input>(new Fl_Input(125, 135, 205, 25, "Description"));
    tab2Input2_->box(FL_PLASTIC_UP_BOX);
    tab2Input3_ = auto_ptr<Fl_Input>(new Fl_Input(125, 165, 205, 25, "Instrument"));
    tab2Input3_->box(FL_PLASTIC_UP_BOX);
    tab2Input4_ = auto_ptr<Fl_Input>(new Fl_Input(125, 195, 205, 25, "Object"));
    tab2Input4_->box(FL_PLASTIC_UP_BOX);
    tab2Input5_ = auto_ptr<Fl_Input>(new Fl_Input(125, 225, 205, 25, "User(s)"));
    tab2Input5_->box(FL_PLASTIC_UP_BOX);

    tab2Group_->add(tab2Input1_.get());
    tab2Group_->add(tab2Input2_.get());
    tab2Group_->add(tab2Input3_.get());
    tab2Group_->add(tab2Input4_.get());
    tab2Group_->add(tab2Input5_.get());

    tabWindow_->add(tab1Group_.get());
    tabWindow_->add(tab2Group_.get());

    resizable(this);
}
