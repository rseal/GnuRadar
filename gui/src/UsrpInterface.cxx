#include "../include/UsrpInterface.h"

UsrpInterface::UsrpInterface(int X, int Y): Fl_Window(X, Y,750,400), maxChannels_(4)
{
    int width = 750;
    int height = 460;

    this->resize(X,Y,width,height);

    int baseX = 25;
    int baseY = 25;
    int tab1Width=50;
    int width2=80;
    int tab1Height=30;

    windowColor_     = fl_rgb_color(200,200,200);
    buttonColor_     = fl_rgb_color(180,180,180);
    tabColor_        = fl_rgb_color(200,200,255);
    Fl_Color wColor_ = fl_rgb_color(220,220,220);

    this->label("Universal Software Radio Peripheral Configuration Interface (v-0.99)");
    this->color(windowColor_);
    this->box(FL_PLASTIC_UP_BOX);
    
    Fl_Menu_Item menuItems[] = {

	{ "&File",              0, 0, 0, FL_SUBMENU },
	{ "&Load File...",    FL_CTRL + 'o'},
	{ "&Save File",       FL_CTRL + 's'},
	{ "E&xit", FL_CTRL + 'q', UsrpInterface::Quit, this },
	{ 0 },
	
	{ "&Help", 0, 0, 0, FL_SUBMENU},
	{ "&About", FL_CTRL + 'a', 0},
	{ 0 },
	{ 0 }
    };

    menuBar_ = auto_ptr<Fl_Menu_Bar>(new Fl_Menu_Bar(5, 5, width-10, 30, 0));
    menuBar_->box(FL_ENGRAVED_BOX);
    menuBar_->copy(menuItems);

    settingsInterface_ = auto_ptr<SettingsInterface>( 
	new SettingsInterface(5, 40, 410, 120, 0, usrpParameters_));
    settingsInterface_->box(FL_ENGRAVED_BOX);

    this->add(settingsInterface_.get());
    //create vector of channel labels for use with looping constructors
    vector<string> chLabels(maxChannels_);
    for(int i=0; i<maxChannels_; ++i)
	chLabels.push_back("Channel " + lexical_cast<string>(i));

    channelTab_ = auto_ptr<ChannelInterface>(new ChannelInterface(5,165,width-340,120,0));
    channelTab_->box(FL_ENGRAVED_BOX);
    channelTab_->Enable(0);
    channelTab_->value(0);
    this->add(channelTab_.get());    

    //disable channels 2-4
    for(int i=1; i<4; ++i)
	channelTab_->Disable(i);

    settingsInterface_->callback(UsrpInterface::UpdateChannels,channelTab_.get());

    headerInterface_ = auto_ptr<HeaderInterface>(new HeaderInterface(width-330,40));
    headerInterface_->box(FL_ENGRAVED_BOX);
    this->add(headerInterface_.get());

    dataInterface_ = auto_ptr<DataInterface>(new DataInterface(5,290,width-340,120,0));
    dataInterface_->box(FL_ENGRAVED_BOX);
    this->add(dataInterface_.get());

    fpgaGroup_ = auto_ptr<Fl_Group>(new Fl_Group(420,290,325,120));
    fpgaGroup_->box(FL_ENGRAVED_BOX);
    this->add(fpgaGroup_.get());

    fileBrowserFPGA_ = auto_ptr<Fl_File_Browser>(
	new Fl_File_Browser(545, 320, 190, 25, "FPGA Bit Image"));
    fileBrowserFPGA_->align(FL_ALIGN_LEFT);
    fileBrowserFPGA_->load("../../fpga");
    fpgaGroup_->add(fileBrowserFPGA_.get());
    fpgaGroup_->end();

    buttonLoad_ = auto_ptr<Fl_Button>(new Fl_Button(20,420,70,25,"&Load"));
    buttonLoad_->box(FL_PLASTIC_DOWN_BOX);
    this->add(buttonLoad_.get());
    buttonSave_ = auto_ptr<Fl_Button>(new Fl_Button(100,420,70,25,"&Save"));
    buttonSave_->box(FL_PLASTIC_DOWN_BOX);
    this->add(buttonSave_.get());
    buttonQuit_ = auto_ptr<Fl_Button>(new Fl_Button(660,420,70,25,"&Quit"));
    buttonQuit_->box(FL_PLASTIC_DOWN_BOX);
    buttonQuit_->callback(UsrpInterface::Quit);
    this->add(buttonQuit_.get());

    this->end();
}
