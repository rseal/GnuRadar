////////////////////////////////////////////////////////////////////////////////
///UsrpInterface.cxx
///
///Primary Display window for USRP configuration GUI interface.///
///
///Author: Ryan Seal
///Modified: 08/06/08
////////////////////////////////////////////////////////////////////////////////
#include "../include/UsrpInterface.h"

using namespace std;
using namespace boost;

///Primary display interface for the USRP configuration GUI program.
///Root class of the USRP configuration GUI program. 
UsrpInterface::UsrpInterface(int X, int Y): Fl_Window(X, Y,750,400), maxChannels_(4)
{
    int width = 750;
    int height = 460;

    this->resize(X,Y,width,height);

    windowColor_     = fl_rgb_color(200,200,200);
    buttonColor_     = fl_rgb_color(180,180,180);
    tabColor_        = fl_rgb_color(200,200,255);

    //unit conversion vectors.
    phaseStr.push_back("Deg");
    phaseStr.push_back("Rad");
    ddcStr.push_back("MHz");
    ddcStr.push_back("kHz");
    ddcStr.push_back("Hz");
    windowStr.push_back("Samples");
    windowStr.push_back("usec");
    windowStr.push_back("km");
    ippStr.push_back("msec");
    ippStr.push_back("usec");
    ippStr.push_back("km");

    this->label("Universal Software Radio Peripheral Configuration Interface (v-1.00)");
    this->color(windowColor_);
    this->box(FL_PLASTIC_UP_BOX);
    
    //items declared for use with menu bar
    Fl_Menu_Item menuItems[] = {

	{ "&File",              0, 0, 0, FL_SUBMENU },
	{ "&Load File...",    FL_CTRL + 'o', UsrpInterface::LoadClicked, this},
	{ "&Save File",       FL_CTRL + 's', UsrpInterface::SaveClicked, this},
	{ "E&xit", FL_CTRL + 'q', UsrpInterface::QuitClicked, this },
	{ 0 },
	
	{ "&Help", 0, 0, 0, FL_SUBMENU},
	{ "&About", FL_CTRL + 'a', 0},
	{ 0 },
	{ 0 }
    };

    //menu bar at top of main window
    menuBar_ = shared_ptr<Fl_Menu_Bar>(new Fl_Menu_Bar(5, 5, width-10, 30, 0));
    menuBar_->box(FL_ENGRAVED_BOX);
    menuBar_->copy(menuItems);

    //channel options interface
    channelTab_ = 
	shared_ptr<ChannelInterface>
	(new ChannelInterface(usrpConfigStruct_,5,165,width-340,120,0));
    channelTab_->box(FL_ENGRAVED_BOX);
    channelTab_->Enable(0);
    channelTab_->value(0);
    
    //disable channels 2-4
    for(int i=1; i<4; ++i) channelTab_->Disable(i);

    //general settings interface
    settingsInterface_ = shared_ptr<SettingsInterface>
	(new SettingsInterface(5, 40, 410, 120, 0,usrpConfigStruct_));
    settingsInterface_->box(FL_ENGRAVED_BOX);
    settingsInterface_->callback(UsrpInterface::UpdateChannels,channelTab_.get());

    //header system group box interface
    headerInterface_ = shared_ptr<HeaderInterface>
	(new HeaderInterface(usrpConfigStruct_,width-330,40));
    headerInterface_->box(FL_ENGRAVED_BOX);

    //data window group box interface
    dataInterface_ = shared_ptr<DataInterface>
	(new DataInterface(usrpConfigStruct_,5,290,width-340,120,0));
    dataInterface_->box(FL_ENGRAVED_BOX);

    //fpga bit image interface
    fpgaGroup_ = shared_ptr<Fl_Group>(new Fl_Group(420,290,325,120));
    fpgaGroup_->box(FL_ENGRAVED_BOX);

    // !!!! this needs to be modified to load a selectable image 
    //      into the UsrpConfigStruct to be useful !!!!
    fileBrowserFPGA_ = shared_ptr<Fl_File_Browser>(
	new Fl_File_Browser(545, 320, 190, 25, "FPGA Bit Image"));
    fileBrowserFPGA_->align(FL_ALIGN_LEFT);
    fileBrowserFPGA_->load("../../../fpga");
    fpgaGroup_->add(fileBrowserFPGA_.get());
    fpgaGroup_->end();

    //load button
    buttonLoad_ = shared_ptr<Fl_Button>(new Fl_Button(20,420,70,25,"&Load"));
    buttonLoad_->box(FL_PLASTIC_DOWN_BOX);
    buttonLoad_->callback(UsrpInterface::LoadClicked,this);

    //save button
    buttonSave_ = shared_ptr<Fl_Button>(new Fl_Button(100,420,70,25,"&Save"));
    buttonSave_->box(FL_PLASTIC_DOWN_BOX);
    buttonSave_->callback(UsrpInterface::SaveClicked,this);

    //quit button
    buttonQuit_ = shared_ptr<Fl_Button>(new Fl_Button(660,420,70,25,"&Quit"));
    buttonQuit_->box(FL_PLASTIC_DOWN_BOX);
    buttonQuit_->callback(UsrpInterface::QuitClicked);

    this->add(settingsInterface_.get());
    this->add(channelTab_.get());    
    this->add(dataInterface_.get());
    this->add(headerInterface_.get());
    this->add(fpgaGroup_.get());
    this->add(buttonLoad_.get());
    this->add(buttonSave_.get());
    this->add(buttonQuit_.get());

    //tell fltk that were finished with ctor
    this->end();
}

///\todo Limit precision on floats and provide number of windows in file to ease parsing
void UsrpInterface::WriteFile(Parser& parser){

    parser.AddComment("USRP Configuration Interface File");
    parser.AddComment("Version 0.99");
    parser.AddSpace();
    parser.Put<float>("SampleRate",usrpConfigStruct_.sampleRate);
    parser.Put<int>("NumChannels",usrpConfigStruct_.numChannels);
    parser.Put<int>("Decimation",usrpConfigStruct_.decimation);
    parser.Put<int>("IPP",usrpConfigStruct_.ipp);

    parser.Put<string>("IPPUnits",ippStr[usrpConfigStruct_.ippUnits]);
    parser.Put<string>("FPGAImage",usrpConfigStruct_.fpgaImage);
    
    string str;
    string num;
    const USRP::ChannelVector& channels = usrpConfigStruct_.ChannelRef();
    for(uint i=0; i<channels.size(); ++i){
	parser.AddSpace();
	str = "Channel ";
	num = lexical_cast<string>(i);
	parser.AddComment(str+num);
	parser.Put<float>(     "DDC" + num , channels[i].ddc);
	parser.Put<string>(  "DDCUnits" + num , ddcStr[channels[i].ddcUnits]);
	parser.Put<float>(   "Phase" + num , channels[i].phase);
	parser.Put<string>("PhaseUnits" + num , phaseStr[channels[i].phaseUnits]);
    }

    const USRP::WindowVector& windows = usrpConfigStruct_.WindowRef();
    parser.AddSpace();
    parser.AddComment("Number of Windows");
    parser.Put<int>("NumWindows",windows.size());

    for(uint i=0; i<windows.size(); ++i){
	parser.AddSpace();
	str = "Window ";
	num = lexical_cast<string>(i);
	parser.AddComment(str+num);
	parser.Put<string>("Name"  + num , windows[i].name);
	parser.Put<int>(   "Start" + num , windows[i].start);
	parser.Put<int>(   "Size"  + num , windows[i].size);
	parser.Put<string>(   "Units" + num , windowStr[windows[i].units]);
    }

    const HeaderStruct& header = usrpConfigStruct_.HeaderRef();

    parser.AddSpace();
    parser.AddComment("Header Settings");
    parser.Put<string>("Institution", header.institution);
    parser.Put<string>("Observer"   , header.observer);
    parser.Put<string>("Object"     , header.object);
    parser.Put<string>("Radar"      , header.radar);
    parser.Put<string>("Receiver"   , header.receiver);

    parser.Write();
}

void UsrpInterface::LoadFile(Parser& parser){

    int numWindows;
    string str;
    string num;
    USRP::ChannelVector& channels = usrpConfigStruct_.ChannelRef();
    USRP::WindowVector& windows   = usrpConfigStruct_.WindowRef();
    HeaderStruct& header          = usrpConfigStruct_.HeaderRef();

    parser.Load();

    usrpConfigStruct_.sampleRate  = parser.Get<float>("SampleRate");
    usrpConfigStruct_.numChannels = parser.Get<int>("NumChannels");
    usrpConfigStruct_.decimation  = parser.Get<int>("Decimation");
    usrpConfigStruct_.ipp         = parser.Get<int>("IPP");
    usrpConfigStruct_.ippUnits    = Find(ippStr,parser.Get<string>("IPPUnits"));
    usrpConfigStruct_.fpgaImage   = parser.Get<string>("FPGAImage");

    //for(int i=0; i<channels.size(); ++i){
    for(uint i=0; i<channels.size(); ++i){
	num = lexical_cast<string>(i);
	str = "DDC" + num;
	channels[i].ddc        = parser.Get<float>(str);
	str = "DDCUnits" + num;
	channels[i].ddcUnits   = Find(ddcStr,parser.Get<string>(str));
	str = "Phase" + num;
	channels[i].phase      = parser.Get<float>(str);
	str = "PhaseUnits" + num;
	channels[i].phaseUnits = Find(phaseStr,parser.Get<string>(str));
    }
    
    //reset windows to load new file
    windows.resize(0);

    numWindows = parser.Get<int>("NumWindows");

    for(int i=0; i<numWindows; ++i){
	DataWindowStruct dws;
	num = lexical_cast<string>(i);	    
	dws.name =  parser.Get<string>("Name"+num);
	dws.start = parser.Get<int>("Start"+num);
	dws.size  = parser.Get<int>("Size"+num);
	dws.units = Find(windowStr,parser.Get<string>("Units"+num));
	windows.push_back(dws);
	}
    
    header.institution = parser.Get<string>("Institution");
    header.observer    = parser.Get<string>("Observer");
    header.object      = parser.Get<string>("Object");
    header.radar       = parser.Get<string>("Radar");
    header.receiver    = parser.Get<string>("Receiver");

    UpdateGUI();
}

void UsrpInterface::UpdateGUI(){

    const USRP::ChannelVector& channels   = usrpConfigStruct_.ChannelRef();
    //const USRP::WindowVector& windows     = usrpConfigStruct_.WindowRef();
    DataWindowInterface& dataWindow       = dataInterface_->DataWindowRef();
    const HeaderStruct& header            = usrpConfigStruct_.HeaderRef();
    
    settingsInterface_->SampleRate(usrpConfigStruct_.sampleRate);
    settingsInterface_->Decimation(usrpConfigStruct_.decimation);
    settingsInterface_->NumChannels(usrpConfigStruct_.numChannels);
    settingsInterface_->UpdateParameters();
    dataInterface_->IPP(usrpConfigStruct_.ipp);
    dataInterface_->IPPUnits(usrpConfigStruct_.ippUnits);
    dataWindow.Load();
    channelTab_->Load(channels);
    headerInterface_->Load(header);
}
