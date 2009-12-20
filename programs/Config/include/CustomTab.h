////////////////////////////////////////////////////////////////////////////////
///CustomTab.h
///
///Almost complete rewrite of existing Fl_Tabs class. Provides enabling and 
///disabling of windows as needed. Also removed several strange / redundant
///methods used to determine graphical object positions.
///
///Author: Ryan Seal
///Modified: 08/06/08
////////////////////////////////////////////////////////////////////////////////
#ifndef CUSTOM_TAB_H
#define CUSTOM_TAB_H

#include <FL/Fl_Group.h>
#include <iostream>
#include <vector>

using std::vector;
using std::cerr;
using std::endl;
using std::cout;

///Structure to hold tab dimensions used in creating box boundaries for 
///tab labels.
struct TabDim{
    int x_;
    int y_;
    int width_;
    int height_;

public:
    ///Constructor
    TabDim(): x_(0), y_(0), width_(0), height_(0){}
    const int Width() { return width_;}
    const int Height() { return height_;}
    const int X() {return x_;}
    const int Y() {return y_;}
    const int End() { return x_ + width_;}
    const bool Selected(const int& event_x, const int& event_y) {
	return (event_x > x_ && event_x < x_+width_) && 
	    (event_y < y_ && event_y > y_-height_);
    }
    void Adjust(const int& x, const int& y, const int& width, const int& height){
	x_ = x; y_ = y; width_ = width; height_ = height;
    }

    void Print() {
	cout << "X = " << x_ << "\n";
	cout << "Y = " << y_ << "\n";
	cout << "W = " << width_ << "\n";
	cout << "H = " << height_ << endl;
    }
};


class CustomTab: public Fl_Group {
    Fl_Color enColor_;
    Fl_Color disColor_;
    Fl_Widget *value_;
    const Fl_Widget *activeChild_;
    bool topTab_;
    int labelWidth_;
    int labelHeight_;
    vector<TabDim> tabDimArray_;
    int tab_height();
    void draw_tab(int x1, int x2, int W, int H, Fl_Widget* o, int sel=0);
    const bool ValidateTabIndex(const int& tab);
    const bool CurrentVisible(const int& tab);
    const int SelectedTab(const int& event_x, const int& event_y) {
	int ret = -1;
	for(int i=0; i<tabDimArray_.size(); ++i)
	    if(tabDimArray_[i].Selected(event_x,event_y)) ret = i;
	return ret;
    }
    const Fl_Widget* ActiveChild() { return activeChild_;}
    void ActiveChild(const Fl_Widget* activeChild) { activeChild_ = activeChild;}
    const int ActiveChildIndex() { return Index(activeChild_);}
protected:
    void redraw_tabs();
    void draw();
    void UpdateTabs();

public:
    int handle(int);
    Fl_Widget *value();
    const int value(const int& tab);
//    int push(Fl_Widget *);
    Fl_Widget* GetPtr(const int& tab);
    CustomTab(int,int,int,int,const char * = 0);
    Fl_Widget *which(int event_x, int event_y);
    const int Index(const Fl_Widget* w);
    void Enable(const int& tab);
    void Disable(const int& tab);
    const bool Enabled(const int& tab);
};

#endif

