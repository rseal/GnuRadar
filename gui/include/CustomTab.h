#ifndef CUSTOM_TAB_H
#define CUSTOM_TAB_H

#include <FL/Fl_Group.h>
//#include <FL/Fl_Color.h>

#include <iostream>
using std::cerr;
using std::endl;
using std::cout;

class CustomTab: public Fl_Group {
    Fl_Color enColor_;
    Fl_Color disColor_;

    Fl_Widget *value_;
    Fl_Widget *push_;
    int tab_positions(int*, int*);
    int tab_height();
    void draw_tab(int x1, int x2, int W, int H, Fl_Widget* o, int sel=0);
    const bool ValidateTabIndex(const int& tab);
    const bool CurrentVisible(const int& tab);

protected:
    void redraw_tabs();
    void draw();

public:
    int handle(int);
    Fl_Widget *value();
    //int value(Fl_Widget *);
    const int value(const int& tab);
    Fl_Widget *push() const {return push_;}
    int push(Fl_Widget *);
    Fl_Widget* GetPtr(const int& tab);
    CustomTab(int,int,int,int,const char * = 0);
    Fl_Widget *which(int event_x, int event_y);
    const int Index(const Fl_Widget* w);

    void Enable(const int& tab);
    void Disable(const int& tab);
    const bool Enabled(const int& tab);
};

#endif

