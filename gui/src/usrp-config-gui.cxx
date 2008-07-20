#include "../include/usrp-config-gui.h"

UserInterface::UserInterface(int X, int Y): Fl_Window(X, Y), maxChannels_(4)
{
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
    this->box(FL_PLASTIC_UP_BOX);//PLASTIC_UP_BOX);
    
    Fl_Menu_Item menuItems[] = {

	{ "&File",              0, 0, 0, FL_SUBMENU },
	{ "&New File",        0},
	{ "&Open File...",    FL_CTRL + 'o'},
	{ "&Insert File...",  FL_CTRL + 'i',0, 0, FL_MENU_DIVIDER },
	{ "&Save File",       FL_CTRL + 's'},
	{ "Save File &As...", FL_CTRL + FL_SHIFT + 's',0, 0, FL_MENU_DIVIDER },
	{ "New &View", FL_ALT + 'v', 0, 0 },
	{ "&Close View", FL_CTRL + 'w', 0, 0, FL_MENU_DIVIDER },
	{ "E&xit", FL_CTRL + 'q', UserInterface::Quit, 0 },
	{ 0 },

	{ "&Edit", 0, 0, 0, FL_SUBMENU },
	{ "&Undo",       FL_CTRL + 'z', 0, 0, FL_MENU_DIVIDER },
	{ "Cu&t",        FL_CTRL + 'x', 0 },
	{ "&Copy",       FL_CTRL + 'c', 0 },
	{ "&Paste",      FL_CTRL + 'v', 0 },
	{ "&Delete",     0, 0 },
	{ 0 },

	{ "&Search", 0, 0, 0, FL_SUBMENU },
	{ "&Find...",       FL_CTRL + 'f', 0 },
	{ "F&ind Again",    FL_CTRL + 'g', 0 },
	{ "&Replace...",    FL_CTRL + 'r', 0 },
	{ "Re&place Again", FL_CTRL + 't', 0 },
	{ 0 },

	{ 0 }
    };

    menuBar_ = auto_ptr<Fl_Menu_Bar>(new Fl_Menu_Bar(5, 5, 740, 30, ""));
//    menuBar_->box(FL_PLASTIC_UP_BOX);
    menuBar_->box(FL_ENGRAVED_BOX);
    menuBar_->copy(menuItems);

    settingsInterface_ = auto_ptr<SettingsInterface>( 
	new SettingsInterface(5, 40, 410, 120, "", usrpParameters_));
    //settingsInterface_->box(FL_PLASTIC_DOWN_BOX);
    //settingsInterface_->box(FL_PLASTIC_UP_BOX);
    settingsInterface_->box(FL_ENGRAVED_BOX);
    //settingsInterface_->color(buttonColor_);
    //settingsInterface_->color(wColor_);

    this->add(settingsInterface_.get());
    //create vector of channel labels for use with looping constructors
    vector<string> chLabels(maxChannels_);
    for(int i=0; i<maxChannels_; ++i)
	chLabels.push_back("Channel " + lexical_cast<string>(i));

    fileBrowserFPGA_ = auto_ptr<Fl_File_Browser>(
	new Fl_File_Browser(105, 380, 220, 25, "FPGA Image"));
    fileBrowserFPGA_->align(FL_ALIGN_LEFT);
    fileBrowserFPGA_->load("../../fpga");
    this->add(fileBrowserFPGA_.get());

    channelTab_ = auto_ptr<ChannelInterface>(new ChannelInterface(5,165,410,120,""));
    //channelTab_->box(FL_PLASTIC_UP_BOX);
    channelTab_->box(FL_ENGRAVED_BOX);
    //channelTab_->color(wColor_);
    this->add(channelTab_.get());

    channelTab_->Enable(0);
    channelTab_->value(0);
    

    //disable channels 2-4
    for(int i=1; i<4; ++i)
	channelTab_->Disable(i);

    //channelTab_->callback(
    settingsInterface_->ChannelRef()->callback(UserInterface::NumChannels,channelTab_.get());
//     tab1Group_->add(settingsInterface_.get());
//     tab1Group_->add(fileBrowserFPGA_.get());

    //tab2  
//     tab2Group_  = auto_ptr<Fl_Group>(new Fl_Group(30, 70, 390, 350, "Header"));
//     tab2Group_->hide();

//     tab2Input1_ = auto_ptr<Fl_Input>(new Fl_Input(125, 100, 205, 25, "Name"));
//     //tab2Input1_->box(FL_PLASTIC_UP_BOX);
//     tab2Input2_ = auto_ptr<Fl_Input>(new Fl_Input(125, 135, 205, 25, "Description"));
//     //tab2Input2_->box(FL_PLASTIC_UP_BOX);
//     tab2Input3_ = auto_ptr<Fl_Input>(new Fl_Input(125, 165, 205, 25, "Instrument"));
//     //tab2Input3_->box(FL_PLASTIC_UP_BOX);
//     tab2Input4_ = auto_ptr<Fl_Input>(new Fl_Input(125, 195, 205, 25, "Object"));
//     //tab2Input4_->box(FL_PLASTIC_UP_BOX);
//     tab2Input5_ = auto_ptr<Fl_Input>(new Fl_Input(125, 225, 205, 25, "User(s)"));
//     //tab2Input5_->box(FL_PLASTIC_UP_BOX);

//     tab2Group_->add(tab2Input1_.get());
//     tab2Group_->add(tab2Input2_.get());
//     tab2Group_->add(tab2Input3_.get());
//     tab2Group_->add(tab2Input4_.get());
//     tab2Group_->add(tab2Input5_.get());

//     tabWindow_->add(tab1Group_.get());
//     tabWindow_->add(tab2Group_.get());
    this->end();
    //resizable(this);
}
