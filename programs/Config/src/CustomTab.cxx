// Copyright (c) 2010 Ryan Seal <rlseal -at- gmail.com>
//
// This file is part of GnuRadar Software.
//
// GnuRadar is free software: you can redistribute it and/or modify
// it under the terms of the GNU General Public License as published by
// the Free Software Foundation, either version 3 of the License, or
// (at your option) any later version.
//  
// GnuRadar is distributed in the hope that it will be useful,
// but WITHOUT ANY WARRANTY; without even the implied warranty of
// MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
// GNU General Public License for more details.
//
// You should have received a copy of the GNU General Public License
// along with GnuRadar.  If not, see <http://www.gnu.org/licenses/>.
////////////////////////////////////////////////////////////////////////////////
///CustomTab.cxx
///
///Almost complete rewrite of existing Fl_Tabs class. Provides enabling and 
///disabling of windows as needed. Also removed several strange / redundant
///methods used to determine graphical object positions.
///
///Author: Ryan Seal
///Modified: 08/06/08
////////////////////////////////////////////////////////////////////////////////

#include <stdio.h>
#include <FL/Fl.H>
#include "../include/CustomTab.h"
#include <FL/fl_draw.H>
#include <FL/Fl_Tooltip.H>

#define BORDER 2
#define EXTRASPACE 10

///Constructor
CustomTab::CustomTab(int X,int Y,int W, int H, const char *l) :
   Fl_Group(X,Y,W,H,l), enColor_(FL_BLACK), disColor_(FL_WHITE),
   topTab_(true),activeChild_(0){
      box(FL_THIN_UP_BOX);
   }

///Determines the number of defined tabs and updates
///each tab's label dimensions and stores in a vector
///container.
void CustomTab::UpdateTabs(){

   int labelWidth,labelHeight,xOffset;
   int tabWidth,tabHeight;
   //static bool first = true;
   const unsigned int numTabs = this->children();
   const int hSpace = 15;
   const int vSpace = 0;

   //should do this only when size changes
   if(numTabs != tabDimArray_.size() || numTabs==1){

      //resize vector
      tabDimArray_.resize(numTabs);

      //compute offset for box style
      xOffset = Fl::box_dx(this->box());

      //setup first label's dimensions
      this->child(0)->measure_label(labelWidth,labelHeight);
      tabHeight = labelHeight + 2*vSpace;
      tabWidth = labelWidth + 2*hSpace;
      tabDimArray_[0].Adjust(x() + xOffset,
            this->child(0)->y(),
            tabWidth,
            tabHeight);

      //store remaining dimensions referenced from first
      for(unsigned int i=1; i<numTabs; ++i){
         this->child(i)->measure_label(labelWidth,labelHeight);
         tabHeight = labelHeight + 2*vSpace;
         tabWidth = labelWidth + 2*hSpace;
         tabDimArray_[i].Adjust(tabDimArray_[i-1].End(),
               this->child(i)->y(),
               tabWidth,
               tabHeight);
      }
   }
}

//Private member
///Ensures that the requested tab is valide
const bool CustomTab::ValidateTabIndex(const int& tab){
   const int numTabs = this->children();
   return ((tab < numTabs) && (tab >= 0)) ? true : false;
}

//Public member
///Disable requested tab - prevents user from focusing and changes color
void CustomTab::Disable(const int& tab){
   if(!ValidateTabIndex(tab)) return;
   Fl_Widget* w = this->child(tab);
   w->clear_visible_focus();
   w->labelcolor(disColor_);
   this->redraw();
}

//Public member
///Enables user to select tab and changes label color
void CustomTab::Enable(const int& tab){
   if(!ValidateTabIndex(tab)) return;
   Fl_Widget* w = this->child(tab);
   w->set_visible_focus();
   w->labelcolor(enColor_);
   this->redraw();
}

//Public member
///Returns whether tab is currently enabled or not
const bool CustomTab::Enabled(const int& tab){
   if(!ValidateTabIndex(tab)) return false;
   return this->child(tab)->visible_focus() != 0 ? true : false; 
}

//Public member
//Accepts tab location index and returns pointer to child widget
Fl_Widget* CustomTab::GetPtr(const int& tab){
   if(!ValidateTabIndex(tab)) return 0;
   return this->child(tab);
}

//Public member
//Accepts pointer to child widget and returns tab location index
const int CustomTab::Index(const Fl_Widget* w){
   int ret = -1;
   for (int i=0; i<this->children(); ++i)
      if(w == this->child(i)) ret = i;
   return ret;
}

//Public member
//Looks at requested tab and returns true if the tab is active (focused)
const bool CustomTab::CurrentVisible(const int& tab){
   if(!ValidateTabIndex(tab)) return false;
   return this->current() == GetPtr(tab);
}

///Return tab height - negative for bottom tabs
int CustomTab::tab_height() {

   //if no children, don't bother
   if(!this->children()) return 0;

   topTab_ = true;
   Fl_Widget* o = this->child(0);
   int topHeight = o->y() - y();
   int bottomHeight = (h()+y()) - (o->y()+o->h());

   //assume tabs on top
   int ret = topHeight > 0 ? (topHeight) : 0;

   //tabs on bottom
   if(bottomHeight > topHeight && bottomHeight > 0){
      ret = -(bottomHeight-EXTRASPACE);
      topTab_ = false;
   }

   return ret;
}

///Finds the tab responsible for the event
Fl_Widget *CustomTab::which(int event_x, int event_y) {
   UpdateTabs();
   for(unsigned int i=0; i<tabDimArray_.size(); ++i)
      if(tabDimArray_[i].Selected(event_x,event_y)) return this->child(i);
   return 0;
};

///Redraws damaged tabs
void CustomTab::redraw_tabs()
{
   //cout << "redraw tabs" << endl;
   int H = tab_height();
   H += Fl::box_dy(box()) - topTab_ ? 0 : H;
   damage(FL_DAMAGE_SCROLL, x(), y() + topTab_ ? 0 : h()-H, w(), H);
}

///Event handler
int CustomTab::handle(int event) {

   switch (event) {

      case FL_PUSH:{
                      //if user clicks in tab area - return handled
                      Fl_Widget* o = which(Fl::event_x(),Fl::event_y());

                      if(o){
                         value(Index(o));
                         Fl_Tooltip::current(o);
                         return 1;
                      }

                      value(!ActiveChild() && children() ? 0 : ActiveChildIndex());

                      //needs to be here
                      return Fl_Group::handle(event);
                   }

      case FL_DRAG:
                   //cerr << "FL_DRAG" << endl;
                   //break;

      case FL_RELEASE:{
                         //cout << "FL_RELEASE" << endl;
                         //pass to children?
                         return Fl_Group::handle(event);
                      }

      case FL_MOVE:{ 
                         //show tooltip
                         Fl_Widget* o = which(Fl::event_x(),Fl::event_y());
                         if(o && o->visible_focus()){
                            Fl_Tooltip::enter(o);
                         }
                         return Fl_Group::handle(event);
                   }

      case FL_FOCUS:
                      //activate first tab when user TABs into tab widget
                      if(Fl::event_key(FL_Tab)){
                         value(0);
                         return 1;
                      }

                      return Fl_Group::handle(event);

      case FL_UNFOCUS:
                      //cout << "FL_UNFOCUS" << endl;
                      if (!this->visible_focus())
                         return Fl_Group::handle(event);

                      if (Fl::event() == FL_RELEASE ||
                            Fl::event() == FL_SHORTCUT ||
                            Fl::event() == FL_KEYBOARD ||
                            Fl::event() == FL_FOCUS ||
                            Fl::event() == FL_UNFOCUS)
                      {
                         redraw_tabs();
                         return (Fl::event() == FL_FOCUS || Fl::event() == FL_UNFOCUS) ? 0 : 1;
                      } else
                         return Fl_Group::handle(event);

      case FL_KEYBOARD:

                      switch (Fl::event_key()) {

                         case FL_Left:{
                                         int i;
                                         //if first child visible - return focus
                                         if(ActiveChildIndex() == 0) return 0;
                                         for (i = 1; i < this->children(); ++i)
                                            if(ActiveChildIndex() == i) break;
                                         //set tab to left active
                                         value(i-1);
                                         return 1;
                                      }

                         case FL_Right:{
                                          int i;
                                          //cout << "FL_Right" << endl;
                                          int numChildren = this->children();
                                          //if last child is active - do nothing
                                          if(ActiveChildIndex() == numChildren -1) return 0;
                                          for (i = 0; i < numChildren-1; ++i){
                                             if(ActiveChildIndex() == i) break;
                                          }
                                          //set tab to right active
                                          value(i+1);
                                          return 1;
                                       }

                         case FL_Down:
                                       redraw();
                                       return Fl_Group::handle(FL_FOCUS);

                         default:
                                       break;
                      }

      case FL_SHORTCUT:{
                          int i;
                          for (i = 0; i < children(); ++i) {
                             Fl_Widget *c = child(i);
                             if (c->test_shortcut(c->label())) {
                                value(Index(c));
                                do_callback();
                                return 1;
                             }
                          }
                          return Fl_Group::handle(event);
                       }
      case FL_SHOW:
                       //cout << "FL_SHOW" << endl;
                       value();
                       return Fl_Group::handle(event);

      case FL_ENTER:
                       //cout << "FL_ENTER" << endl;
                       break;

      default:
                       return Fl_Group::handle(event);

   }
}

///Locates and returns first visible child - hide others 
Fl_Widget* CustomTab::value() {
   //if a child is in focus and is removed, ActiveChild() must be updated - or segfault
   Fl_Widget *visible = const_cast<Fl_Widget*>(ActiveChild());
   int numChildren = this->children();
   int activeIndex = ActiveChildIndex();

   //hide all inactive tabs
   for(int i=0; i<numChildren; ++i)
      if(activeIndex != i) this->child(i)->hide();

   //if no tabs visible - make tab 0 visible by default
   if(!visible){
      visible = this->child(0);
      visible->show();
   }

   //show visible tab
   visible->show();
   //cout << visible << " is visible" << endl;
   return visible;
}

// Public Member
///Sets requested tab visible - hides others
const int CustomTab::value(const int& newvalue){
   //Fl_Widget* w;

   //valid index requested?
   if(!ValidateTabIndex(newvalue)) return -1;

   //can child accept focus?
   if(!this->child(newvalue)->visible_focus()) return -2;

   ActiveChild(this->child(newvalue));
   value();
   //     //lets others know that the tab group has changed
   set_changed();
   do_callback();
   redraw_tabs();

   return 0;
};

enum {LEFT, RIGHT, SELECTED};

///Redraws tabs based on damage.
void CustomTab::draw() {
   Fl_Widget *v = value();

   int H = tab_height();

   //int xParent = parent()->x();
   //int yParent = parent()->y();
   //int wParent = parent()->w();
   //int hParent = parent()->h();

   //initialize if necessary 
   UpdateTabs();

   if (damage() & FL_DAMAGE_ALL) { // redraw the entire thing:
      // 	cout << "damage & FL_DAMAGE_ALL" << endl;
      Fl_Color c = v ? v->color() : color();
      bool colorMatch = selection_color() == c;


      // 	cout << "x = " << x() << endl;
      // 	cout << "y = " << y() << endl;
      // 	cout << "w = " << w() << endl;
      // 	cout << "H = " << H   << endl;
      // 	cout << "xParent = " << xParent << endl;
      // 	cout << "yParent = " << yParent << endl;
      // 	cout << "wParent = " << wParent << endl;
      // 	cout << "hParent = " << hParent << endl;
      draw_box(box(), 
            x(), 
            y()+(topTab_ ? H:0), 
            w(), 
            h()-(topTab_ ? H:-H), c);

      if(!colorMatch){
         fl_push_clip(
               x(), 
               y() + topTab_ ? H : h()-H-4,
               w(),
               5);

         draw_box(box(), 
               x(), 
               y()+(topTab_ ? H:0), 
               w(), 
               h()-(topTab_ ? H:-H), 
               colorMatch ? c : selection_color());

         fl_pop_clip();
      }
      if (v) draw_child(*v);
   }
   else if(damage() & FL_DAMAGE_CHILD){
      // 	cout << "damage & FL_DAMAGE_CHILD" << endl;
      update_child(*v);
   }

   if (damage() & (FL_DAMAGE_SCROLL | FL_DAMAGE_ALL)) {
      // 	cout << "damage & (FL_DAMAGE_SCROLL | FL_DAMAGE_ALL)" << endl;
      int selected = Index(value());

      for (int i=0; i<selected; i++)
         draw_tab(
               tabDimArray_[i].X(), 
               tabDimArray_[i].End(), 
               tabDimArray_[i].Width(), 
               H, 
               child(i), 
               LEFT);

      for (int i=children()-1; i > selected; i--)
         draw_tab(
               tabDimArray_[i].X(), 
               tabDimArray_[i].End(), 
               tabDimArray_[i].Width(), 
               H, 
               child(i), 
               RIGHT);

      if (v) {
         draw_tab(
               tabDimArray_[selected].X(),
               tabDimArray_[selected].End(), 
               tabDimArray_[selected].Width(), 
               H, 
               child(selected), 
               SELECTED);
      }
   }
}

///Draws tab's label box. 
void CustomTab::draw_tab(int x1, int x2, int W, int H, Fl_Widget* o, int what) {

   int sel = (what == SELECTED);
   int dh = Fl::box_dh(box());
   int dy = Fl::box_dy(box());
   char prev_draw_shortcut = fl_draw_shortcut;
   fl_draw_shortcut = 1;

   int width = x2 - x1;
   int height = H;

   Fl_Boxtype bt = (o==ActiveChild() &&!sel) ? fl_down(box()) : box();

   // compute offsets to make selected tab look bigger
   int yofs = sel ? 0 : BORDER;

   if ((x2 < x1+W) && what == RIGHT) x1 = x2 - W;

   if (topTab_) {

      if (sel) fl_clip(x1, y(), width, height + dh - dy);
      else fl_clip(x1, y(), width, height);

      H += dh;

      Fl_Color c = sel ? selection_color() : o->selection_color();

      draw_box(bt, x1, y() + yofs, W, H + 10 - yofs, c);

      // 	cout << "--------------------\n";
      // 	cout << "x = " << x1 << "\n"
      // 	     << "y = " << y() + yofs << "\n"
      // 	     << "w = " << W << "\n"
      // 	     << "h = " << H + 10 - yofs << "\n";
      // 	cout << "--------------------\n";
      // 	cout << endl;

      // Save the previous label color
      Fl_Color oc = o->labelcolor();

      // Draw the label using the current color...
      o->labelcolor(sel ? labelcolor() : o->labelcolor());    
      o->draw_label(x1, y() + yofs, W, H - yofs, FL_ALIGN_CENTER);

      // Restore the original label color...
      o->labelcolor(oc);

      if(Fl::focus() && ActiveChild() == Fl::focus()->parent()) draw_focus(box(), x1, y(), W, H);

      fl_pop_clip();

   } else {
      H = -H;

      //	cout << "bottom tabs" << endl;
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

      if(Fl::focus()){
         //cout << "Focus = " << Fl::focus()->parent() << " " << " this = " << ActiveChild() << endl;
         if(ActiveChild() == Fl::focus()->parent()) draw_focus(box(), x1, y()+h()-H, W, H);
      }

      // 	if (Fl::focus() == this && o->visible())
      // 	    draw_focus(box(), x1, y() + h() - H, W, H);

      fl_pop_clip();
   }

   fl_draw_shortcut = prev_draw_shortcut;
}
