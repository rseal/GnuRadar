#include "../include/usrp-config-gui.h"

UserInterface::UserInterface(int X, int Y): Fl_Window(X, Y), maxChannels_(4)
{
    int baseX = 25;
    int baseY = 25;
    int tab1Width=50;
    int width2=80;
    int tab1Height=30;

    windowColor_ = fl_rgb_color(200,220,255);
    buttonColor_ = fl_rgb_color(180,180,180);
    tabColor_    = fl_rgb_color(200,200,255);
    Fl_Color wColor_ = fl_rgb_color(220,220,220);
    this->label("Universal Software Radio Peripheral Configuration Interface (v-0.99)");
    this->color(windowColor_);
    
    //top-level buttons
    buttonSave_  = auto_ptr<Fl_Button>(new Fl_Button(120, 455, 100, 30, "&Save"));
    buttonApply_ = auto_ptr<Fl_Button>(new Fl_Button(10, 455, 100, 30, "&Apply"));
    buttonQuit_  = auto_ptr<Fl_Button>(new Fl_Button(320, 455, 100, 30, "&Quit"));
    buttonQuit_->callback(UserInterface::Quit);

    buttonSave_->color(buttonColor_);
    buttonApply_->color(buttonColor_);
    buttonQuit_->color(buttonColor_);
    
    //top-level tab container
    tabWindow_ = auto_ptr<Fl_Tabs>(new Fl_Tabs(25, 25, 600, 400));
    //tabWindow_->box(FL_PLASTIC_UP_BOX);
    //tabWindow_->color(fl_rgb_color(200,100,200));
    
    //tab1
    tab1Group_  = auto_ptr<Fl_Group>(new Fl_Group(30, 50, 600, 350, "USRP"));

    settingsInterface_ = auto_ptr<SettingsInterface>( 
	new SettingsInterface(35, 70, 450, 120, "Settings", usrpParameters_));
    settingsInterface_->color(wColor_);
    settingsInterface_->align(FL_ALIGN_INSIDE | FL_ALIGN_TOP);
//    settingsInterface_->align(FL_ALIGN_TOP);
//    settingsInterface_->box(FL_BORDER_BOX);
    settingsInterface_->labeltype(FL_ENGRAVED_LABEL);
    settingsInterface_->box(FL_ROUNDED_BOX);

    //create vector of channel labels for use with looping constructors
    vector<string> chLabels(maxChannels_);
    for(int i=0; i<maxChannels_; ++i)
	chLabels.push_back("Channel " + lexical_cast<string>(i));

    fileBrowserFPGA_ = auto_ptr<Fl_File_Browser>(
	new Fl_File_Browser(125, 380, 220, 25, "FPGA Image"));
    fileBrowserFPGA_->align(FL_ALIGN_LEFT);
    fileBrowserFPGA_->load("../../fpga");

    tab1Group_->add(settingsInterface_.get());
    tab1Group_->add(fileBrowserFPGA_.get());

    //tab2  
    tab2Group_  = auto_ptr<Fl_Group>(new Fl_Group(30, 70, 390, 350, "Header"));
    tab2Group_->hide();

    tab2Input1_ = auto_ptr<Fl_Input>(new Fl_Input(125, 100, 205, 25, "Name"));
    //tab2Input1_->box(FL_PLASTIC_UP_BOX);
    tab2Input2_ = auto_ptr<Fl_Input>(new Fl_Input(125, 135, 205, 25, "Description"));
    //tab2Input2_->box(FL_PLASTIC_UP_BOX);
    tab2Input3_ = auto_ptr<Fl_Input>(new Fl_Input(125, 165, 205, 25, "Instrument"));
    //tab2Input3_->box(FL_PLASTIC_UP_BOX);
    tab2Input4_ = auto_ptr<Fl_Input>(new Fl_Input(125, 195, 205, 25, "Object"));
    //tab2Input4_->box(FL_PLASTIC_UP_BOX);
    tab2Input5_ = auto_ptr<Fl_Input>(new Fl_Input(125, 225, 205, 25, "User(s)"));
    //tab2Input5_->box(FL_PLASTIC_UP_BOX);

    tab2Group_->add(tab2Input1_.get());
    tab2Group_->add(tab2Input2_.get());
    tab2Group_->add(tab2Input3_.get());
    tab2Group_->add(tab2Input4_.get());
    tab2Group_->add(tab2Input5_.get());

    tabWindow_->add(tab1Group_.get());
    tabWindow_->add(tab2Group_.get());

    resizable(this);
}
