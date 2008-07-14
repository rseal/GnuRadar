#include "../include/usrp-config-gui.h"

UserInterface::UserInterface(int X, int Y): Fl_Window(X, Y), maxChannels_(4)
{
    int baseX = 25;
    int baseY = 25;
    int tab1Width=50;
    int width2=80;
    int tab1Height=30;

    windowColor_ = fl_rgb_color(50,50,255);
    buttonColor_ = fl_rgb_color(180,180,180);
    tabColor_    = fl_rgb_color(200,200,255);

    //create vector of channel labels for use with looping constructors
    vector<string> chLabels(maxChannels_);
    for(int i=0; i<maxChannels_; ++i)
	chLabels.push_back("Channel " + lexical_cast<string>(i));

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
    tabWindow_ = auto_ptr<Fl_Tabs>(new Fl_Tabs(25, 25, 400, 400));
    tabWindow_->box(FL_PLASTIC_UP_BOX);
    
    //tab1
    tab1Group_  = auto_ptr<Fl_Group>(new Fl_Group(30, 70, 390, 350, "USRP"));

    tab1Input1_ = auto_ptr<Fl_Float_Input>(new Fl_Float_Input(130, 80, tab1Width, tab1Height, "Sample Rate"));
    tab1Input1_->value(usrpParameters_.SampleRateString());
    tab1Input1_->callback(UserInterface::UpdateSampleRate,this);
    tab1Input1_->color(FL_WHITE);

    //add channel options to Fl_Choice widget
    vector<string> chNum;
    chNum.push_back("1");
    chNum.push_back("2");
    chNum.push_back("4");

    tab1Channels_ = auto_ptr<Fl_Choice>( new Fl_Choice(130, 110, tab1Width, tab1Height, "Channels"));
    tab1Channels_->add(chNum[0].c_str(),0,0);
    tab1Channels_->add(chNum[1].c_str(),0,0);
    tab1Channels_->add(chNum[2].c_str(),0,0);
    tab1Channels_->value(0);
    tab1Channels_->callback(UserInterface::UpdateChannel,this);

    tab1Slider_ = auto_ptr<Fl_Value_Slider>(new Fl_Value_Slider(130,140, width2, tab1Height, "Decimation"));
    tab1Slider_->align(FL_ALIGN_LEFT);
    tab1Slider_->type(FL_HOR_NICE_SLIDER);
    tab1Slider_->step(2);
    tab1Slider_->range(8,256);
    tab1Slider_->value(8);
    tab1Slider_->color(FL_WHITE);

    //tab1Slider_->box(FL_PLASTIC_UP_BOX);
    tab1Slider_->callback(UserInterface::UpdateDecimation,this);

    tab1Output1_ = auto_ptr<Fl_Output>(new Fl_Output(130,220,width2,tab1Height, "Bandwidth"));
    tab1Output1_->value("8");
    tab1Output1_->color(FL_GRAY);
    //tab1Output1_->box(FL_PLASTIC_UP_BOX);

    tab1Input4_ = auto_ptr<Fl_Input>(new Fl_Input(130, 170, tab1Width, tab1Height, "IPP"));
    //tab1Input4_->box(FL_PLASTIC_UP_BOX);


    fileBrowserFPGA_ = auto_ptr<Fl_File_Browser>(new Fl_File_Browser(125, 380, 220, 25, "FPGA Image"));
    fileBrowserFPGA_->align(FL_ALIGN_LEFT);
    fileBrowserFPGA_->load("../../fpga");
    //fileBrowserFPGA_->box(FL_PLASTIC_UP_BOX);

    tab1Group_->add(tab1Input1_.get());
    tab1Group_->add(tab1Channels_.get());
    tab1Group_->add(tab1Output1_.get());
    tab1Group_->add(tab1Input4_.get());
    tab1Group_->add(tab1Slider_.get());
    tab1Group_->add(fileBrowserFPGA_.get());
    
    //tab2  
    tab2Group_  = auto_ptr<Fl_Group>(new Fl_Group(30, 70, 390, 350, "Header"));
    tab2Group_->hide();

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
