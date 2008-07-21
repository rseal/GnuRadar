//
// "$Id: Fl_Tabs.cxx 5791 2007-05-01 20:20:21Z matt $"
//
// Tab widget for the Fast Light Tool Kit (FLTK).
//
// Copyright 1998-2005 by Bill Spitzak and others.
//
// This library is free software; you can redistribute it and/or
// modify it under the terms of the GNU Library General Public
// License as published by the Free Software Foundation; either
// version 2 of the License, or (at your option) any later version.
//
// This library is distributed in the hope that it will be useful,
// but WITHOUT ANY WARRANTY; without even the implied warranty of
// MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the GNU
// Library General Public License for more details.
//
// You should have received a copy of the GNU Library General Public
// License along with this library; if not, write to the Free Software
// Foundation, Inc., 59 Temple Place, Suite 330, Boston, MA 02111-1307
// USA.
//
// Please report all bugs and problems on the following page:
//
//     http://www.fltk.org/str.php
//

// This is the "file card tabs" interface to allow you to put lots and lots
// of buttons and switches in a panel, as popularized by many toolkits.

// Each child widget is a card, and it's label() is printed on the card tab.
// Clicking the tab makes that card visible.

#include <stdio.h>
#include <FL/Fl.H>
#include "../include/CustomTab.h"
#include <FL/fl_draw.H>
#include <FL/Fl_Tooltip.H>

#define BORDER 2
#define EXTRASPACE 10


CustomTab::CustomTab(int X,int Y,int W, int H, const char *l) :
    Fl_Group(X,Y,W,H,l), enColor_(FL_BLACK), disColor_(FL_WHITE)
{
    box(FL_THIN_UP_BOX);
    push_ = 0;
}

//Private member
//ensure that requested tab exists
const bool CustomTab::ValidateTabIndex(const int& tab){
    const int numTabs = this->children();
    return ((tab < numTabs) && (tab >= 0)) ? true : false;
}

//Public member
//disable requested tab - prevents user from focusing and changes color
void CustomTab::Disable(const int& tab){

    if(!ValidateTabIndex(tab)) return;

    Fl_Widget* w = this->child(tab);
    w->clear_visible_focus();
    w->labelcolor(disColor_);
    this->redraw();
}

//Public member
//accepts pointer to child widget and returns tab location index
const int CustomTab::Index(const Fl_Widget* w){
    int ret = -1;
    for (int i=0; i<this->children(); ++i)
	if(w == this->child(i)) ret = i;
    return ret;
}

//Public member
//accepts tab location index and returns pointer to child widget
Fl_Widget* CustomTab::GetPtr(const int& tab){
    //cout << "requested tab " << child(tab) << endl;
    if(!ValidateTabIndex(tab)) return 0;
    //cout << "valid" << endl;
    return this->child(tab);
}

//Public member
//enables user to select tab and changes label color
void CustomTab::Enable(const int& tab){
    if(!ValidateTabIndex(tab)) return;

    Fl_Widget* w = this->child(tab);
    w->set_visible_focus();
    w->labelcolor(enColor_);
    this->redraw();
}

//Public member
//returns whether tab is currently enabled or not
const bool CustomTab::Enabled(const int& tab){
    if(!ValidateTabIndex(tab)) return false;
    return this->child(tab)->visible_focus() != 0 ? true : false; 
}

//Public member
//looks at requested tab and returns true if the tab is active (focused)
const bool CustomTab::CurrentVisible(const int& tab){
    if(!ValidateTabIndex(tab)) return false;
    return this->current() == GetPtr(tab);
}

// const int CustomTab::ActiveTab(){
//     const int numChildren = this->children();
//     int index;
//     for(index = 0; index < numChildren; ++index)
	
// return the left edges of each tab (plus a fake left edge for a tab
// past the right-hand one).  These position are actually of the left
// edge of the slope.  They are either seperated by the correct distance
// or by EXTRASPACE or by zero.
// Return value is the index of the selected item.
int CustomTab::tab_positions(int* p, int* wp) {
    int selected = 0;
    //Fl_Widget*const* a = array();
    int i;
    char prev_draw_shortcut = fl_draw_shortcut;
    fl_draw_shortcut = 1;

    p[0] = Fl::box_dx(box());

    for (i=0; i<children(); ++i) {
	Fl_Widget* o = this->child(i);
	if (o->visible()) selected = i;

	int wt = 0; int ht = 0;
	o->measure_label(wt,ht);

	wp[i]  = wt+EXTRASPACE;
	p[i+1] = p[i]+wp[i]+BORDER;
    }

    fl_draw_shortcut = prev_draw_shortcut;

    int r = w();
    if (p[i] <= r) return selected;
    // uh oh, they are too big:
    // pack them against right edge:
    p[i] = r;
    for (i = children(); i--;) {
	int l = r-wp[i];
	if (p[i+1] < l) l = p[i+1];
	if (p[i] <= l) break;
	p[i] = l;
	r -= EXTRASPACE;
    }
    // pack them against left edge and truncate width if they still don't fit:
    for (i = 0; i<children(); i++) {
	if (p[i] >= i*EXTRASPACE) break;
	p[i] = i*EXTRASPACE;
	int W = w()-1-EXTRASPACE*(children()-i) - p[i];
	if (wp[i] > W) wp[i] = W;
    }
    // adjust edges according to visiblity:
    for (i = children(); i > selected; i--) {
	p[i] = p[i-1]+wp[i-1];
    }
    return selected;
}

// return space needed for tabs.  Negative to put them on the bottom:
int CustomTab::tab_height() {
    int H = h();
    int H2 = y();
    Fl_Widget*const* a = array();
    for (int i=children(); i--;) {
	Fl_Widget* o = *a++;
	if (o->y() < y()+H) H = o->y()-y();
	if (o->y()+o->h() > H2) H2 = o->y()+o->h();
    }
    H2 = y()+h()-H2;
    if (H2 > H) return (H2 <= 0) ? 0 : -H2;
    else return (H <= 0) ? 0 : H;
}

// this is used by fluid to pick tabs:
Fl_Widget *CustomTab::which(int event_x, int event_y) {
    int H = tab_height();
    if (H < 0) {
	if (event_y > y()+h() || event_y < y()+h()+H) return 0;
    } else {
	if (event_y > y()+H || event_y < y()) return 0;
    }
    if (event_x < x()) return 0;
    int p[128], wp[128];
    tab_positions(p, wp);
    for (int i=0; i<children(); i++) {
	if (event_x < x()+p[i+1]) return child(i);
    }
    return 0;
}

void CustomTab::redraw_tabs()
{
    int H = tab_height();
    if (H >= 0) {
	H += Fl::box_dy(box());
	damage(FL_DAMAGE_SCROLL, x(), y(), w(), H);
    } else {
	H = Fl::box_dy(box()) - H;
	damage(FL_DAMAGE_SCROLL, x(), y() + h() - H, w(), H);
    }
}

int CustomTab::handle(int event) {

    Fl_Widget *o;
    int i;
    int numChildren = this->children();
 
    switch (event) {

    case FL_PUSH: {
	//cerr << "FL_PUSH" << endl;
	int H = tab_height();
	if (H >= 0) {
	    if (Fl::event_y() > y()+H) return Fl_Group::handle(event);
	} else {
	    if (Fl::event_y() < y()+h()+H) return Fl_Group::handle(event);
	}}
    case FL_DRAG:
	//cerr << "FL_DRAG" << endl;
    case FL_RELEASE:
	//cerr << "FL_RELEASE" << endl;

	//determine which tab was released - if any
	o = which(Fl::event_x(), Fl::event_y());

	//if tab was released, tab container is visible, and tab widget is not in focus
	// redraw tabs. 
	if(o && o->visible_focus() && (this->current() != o)){
	    value(Index(o));
	    //set focus to selected tab
	    o->take_focus();
            set_changed();
	    do_callback();
	    redraw_tabs();
	    Fl_Tooltip::current(o);
	}
	return 1;

    case FL_MOVE: {
//	cout << "FL_MOVE" << endl;
	int ret = Fl_Group::handle(event);
	Fl_Widget *o = Fl_Tooltip::current(), *n = o;
	int H = tab_height();
	if ( (H>=0) && (Fl::event_y()>y()+H) )
	    return ret;
	else if ( (H<0) && (Fl::event_y() < y()+h()+H) )
	    return ret;
	else { 
	    n = which(Fl::event_x(), Fl::event_y());
	    if (!n) n = this;
	}
	if (n!=o)
	    Fl_Tooltip::enter(n);
	return ret; 
    }

    case FL_FOCUS:

	//activate first tab when user TABs into tab widget
	if(Fl::event_key(FL_Tab)){
	    value(0);
	    redraw_tabs();
	    set_changed();
	    do_callback();
	}

    case FL_UNFOCUS:
//	cout << "FL_UNFOCUS" << endl;
	if (!Fl::visible_focus()) return Fl_Group::handle(event);
	if (Fl::event() == FL_RELEASE ||
	    Fl::event() == FL_SHORTCUT ||
	    Fl::event() == FL_KEYBOARD ||
	    Fl::event() == FL_FOCUS ||
	    Fl::event() == FL_UNFOCUS) {
	    redraw_tabs();
	    if (Fl::event() == FL_FOCUS || Fl::event() == FL_UNFOCUS) return 0;
	    else return 1;
	} else return Fl_Group::handle(event);

    case FL_KEYBOARD:
	switch (Fl::event_key()) {

	case FL_Left:
	    //cout << "FL_Left" << endl;

	    //if first child visible - return focus
	    if (CurrentVisible(0)) return 0;
	    
	    for (i = 1; i < numChildren; ++i)
		if (CurrentVisible(i)) break;

	    //set tab to left active
	    value(i-1);
	    set_changed();
	    do_callback();

	    return 1;

	case FL_Right:
	    //cout << "FL_Right" << endl;

	    //if last child is active - do nothing
	    if (CurrentVisible(numChildren - 1)) return 0;
	    

	    for (i = 0; i < numChildren-1; ++i){
		if (CurrentVisible(i)) break;
	    }

	    //set tab to right active
	    value(i+1);
            set_changed();
	    do_callback();
	    redraw_tabs();

	    return 1;
	
	case FL_Down:

	    redraw();
	    return Fl_Group::handle(FL_FOCUS);

	default:
	    break;
	}

	return Fl_Group::handle(event);
    
    case FL_SHORTCUT:
	for (i = 0; i < children(); ++i) {
	    Fl_Widget *c = child(i);
	    if (c->test_shortcut(c->label())) {
		char sc = !c->visible();
		value(Index(c));
		if (sc) set_changed();
		do_callback();
		return 1;
	    }
	}
	return Fl_Group::handle(event);
   
    case FL_SHOW:
	//cout << "FL_SHOW" << endl;
	value(); // update visibilities and fall through
	
    case FL_ENTER:
	//cout << "FL_ENTER" << endl;

    default:
	return Fl_Group::handle(event);

    }
}

// Locate and return first visible child - hide others 
Fl_Widget* CustomTab::value() {
    
    Fl_Widget *visible,*current;
    int numChildren = this->children();
    bool childrenVisible=false;

    for (int i=0; i<numChildren; ++i) {
	current = this->child(i);
	//if current child is visible - mark - and hide others
	if(CurrentVisible(i)){
	    visible=current;
	    childrenVisible = true;
	}
	else current->hide();
    }

    //if no children are visible - default to first tab
    if(!childrenVisible){
	current = this->child(0);
	current->show();
	visible = current;
    }

    return visible;
}

// Public Member
// Sets requested tab visible - hides others
const int CustomTab::value(const int& newvalue){
    Fl_Widget* w;

    //valid index requested?
    if(!ValidateTabIndex(newvalue)) return -1;

    //can child accept focus?
    if(!this->child(newvalue)->visible_focus()) return -2;
    
    //show active - hide others
    for(int i=0; i<this->children(); ++i){
	w = this->child(i);
	if( GetPtr(newvalue) != w) w->hide();
	else{
	    w->show();
            //set active widget
	    this->current(reinterpret_cast<Fl_Group*>(w));
	}
    }
    return 0;
};

enum {LEFT, RIGHT, SELECTED};

void CustomTab::draw() {
    Fl_Widget *v = value();
    int H = tab_height();

    //modified from & to && assuming bug
    if (damage() && FL_DAMAGE_ALL) { // redraw the entire thing:
	Fl_Color c = v ? v->color() : color();

	draw_box(box(), x(), y()+(H>=0?H:0), w(), h()-(H>=0?H:-H), c);

	if (selection_color() != c) {
	    // Draw the top 5 lines of the tab pane in the selection color so
	    // that the user knows which tab is selected...
	    if (H >= 0) fl_push_clip(x(), y() + H, w(), 5);
	    else fl_push_clip(x(), y() + h() - H - 4, w(), 5);

	    draw_box(box(), x(), y()+(H>=0?H:0), w(), h()-(H>=0?H:-H),
		     selection_color());

	    fl_pop_clip();
	}
	if (v) draw_child(*v);
    } else { // redraw the child
	if (v) update_child(*v);
    }

    //modified & and | to && and || assuming bug
    if (damage() && (FL_DAMAGE_SCROLL || FL_DAMAGE_ALL)) {
	int p[128]; int wp[128];
	int selected = tab_positions(p,wp);
	int i;
	Fl_Widget*const* a = array();
	for (i=0; i<selected; i++)
	    draw_tab(x()+p[i], x()+p[i+1], wp[i], H, a[i], LEFT);
	for (i=children()-1; i > selected; i--)
	    draw_tab(x()+p[i], x()+p[i+1], wp[i], H, a[i], RIGHT);
	if (v) {
	    i = selected;
	    draw_tab(x()+p[i], x()+p[i+1], wp[i], H, a[i], SELECTED);
	}
    }
}

void CustomTab::draw_tab(int x1, int x2, int W, int H, Fl_Widget* o, int what) {
    int sel = (what == SELECTED);
    int dh = Fl::box_dh(box());
    int dy = Fl::box_dy(box());
    char prev_draw_shortcut = fl_draw_shortcut;
    fl_draw_shortcut = 1;

    Fl_Boxtype bt = (o==push_ &&!sel) ? fl_down(box()) : box();

    // compute offsets to make selected tab look bigger
    int yofs = sel ? 0 : BORDER;

    if ((x2 < x1+W) && what == RIGHT) x1 = x2 - W;

    if (H >= 0) {
	if (sel) fl_clip(x1, y(), x2 - x1, H + dh - dy);
	else fl_clip(x1, y(), x2 - x1, H);

	H += dh;

	Fl_Color c = sel ? selection_color() : o->selection_color();

	draw_box(bt, x1, y() + yofs, W, H + 10 - yofs, c);

	// Save the previous label color
	Fl_Color oc = o->labelcolor();

	// Draw the label using the current color...
	o->labelcolor(sel ? labelcolor() : o->labelcolor());    
	o->draw_label(x1, y() + yofs, W, H - yofs, FL_ALIGN_CENTER);

	// Restore the original label color...
	o->labelcolor(oc);


	if(CurrentVisible(Index(o)))
	    draw_focus(box(), x1, y(), W, H);

	fl_pop_clip();
    } else {
	H = -H;

	if (sel) fl_clip(x1, y() + h() - H - dy, x2 - x1, H + dy);
	else fl_clip(x1, y() + h() - H, x2 - x1, H);

	H += dh;

	Fl_Color c = sel ? selection_color() : o->selection_color();

	draw_box(bt, x1, y() + h() - H - 10, W, H + 10 - yofs, c);

	// Save the previous label color
	Fl_Color oc = o->labelcolor();

	// Draw the label using the current color...
	o->labelcolor(sel ? labelcolor() : o->labelcolor());
	o->draw_label(x1, y() + h() - H, W, H - yofs, FL_ALIGN_CENTER);

	// Restore the original label color...
	o->labelcolor(oc);

	if(CurrentVisible(Index(o)))
	    draw_focus(box(), x1, y() + h() - H, W, H);

	fl_pop_clip();
    }
    fl_draw_shortcut = prev_draw_shortcut;
}
