/* -*- c++ -*- */
//
// Copyright 2008,2009 Free Software Foundation, Inc.
//
// This file is part of GNU Radio
//
// GNU Radio is free software; you can redistribute it and/or modify
// it under the terms of the GNU General Public License as published by
// the Free Software Foundation; either asversion 3, or (at your option)
// any later version.
//
// GNU Radio is distributed in the hope that it will be useful,
// but WITHOUT ANY WARRANTY; without even the implied warranty of
// MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
// GNU General Public License for more details.
//
// You should have received a copy of the GNU General Public License
// along with GNU Radio; see the file COPYING.  If not, write to
// the Free Software Foundation, Inc., 51 Franklin Street,
// Boston, MA 02110-1301, USA.
//

#ifdef HAVE_CONFIG_H
#include "config.h"
#endif

#include <usrp/boards/db_boards.h>
#include <usrp/usrp/dbid.h>
#include <usrp/boards/db_basic.h>
#include <usrp/boards/db_dbs_rx.h>
#include <cstdio>

std::vector<db_base_sptr>
instantiate_dbs(int dbid, usrp_basic_sptr usrp, int which_side)
{
  std::vector<db_base_sptr> db;

  switch(dbid) {

  case(USRP_DBID_BASIC_TX):
    db.push_back(db_base_sptr(new db_basic_tx(usrp, which_side)));
    break;

  case(USRP_DBID_BASIC_RX):
    db.push_back(db_base_sptr(new db_basic_rx(usrp, which_side, 0)));
    db.push_back(db_base_sptr(new db_basic_rx(usrp, which_side, 1)));
    db.push_back(db_base_sptr(new db_basic_rx(usrp, which_side, 2)));
    break;

  case(USRP_DBID_LF_TX):
    db.push_back(db_base_sptr(new db_lf_tx(usrp, which_side)));
    break;

  case(USRP_DBID_LF_RX):
    db.push_back(db_base_sptr(new db_lf_rx(usrp, which_side, 0)));
    db.push_back(db_base_sptr(new db_lf_rx(usrp, which_side, 1)));
    db.push_back(db_base_sptr(new db_lf_rx(usrp, which_side, 2)));
    break;

  case(USRP_DBID_DBS_RX):
    db.push_back(db_base_sptr(new db_dbs_rx(usrp, which_side)));
    break;

  case(-1):
    if (boost::dynamic_pointer_cast<usrp_basic_tx>(usrp)){
      db.push_back(db_base_sptr(new db_basic_tx(usrp, which_side)));
    }
    else {
      db.push_back(db_base_sptr(new db_basic_rx(usrp, which_side, 0)));
      db.push_back(db_base_sptr(new db_basic_rx(usrp, which_side, 1)));
    }
    break;

  case(-2):
  default:
    if (boost::dynamic_pointer_cast<usrp_basic_tx>(usrp)){
      fprintf(stderr, "\n\aWarning: Treating daughterboard with invalid EEPROM contents as if it were a \"Basic Tx.\"\n");
      fprintf(stderr, "Warning: This is almost certainly wrong...  Use appropriate burn-*-eeprom utility.\n\n");
      db.push_back(db_base_sptr(new db_basic_tx(usrp, which_side)));
    }
    else {
      fprintf(stderr, "\n\aWarning: Treating daughterboard with invalid EEPROM contents as if it were a \"Basic Rx.\"\n");
      fprintf(stderr, "Warning: This is almost certainly wrong...  Use appropriate burn-*-eeprom utility.\n\n");
      db.push_back(db_base_sptr(new db_basic_rx(usrp, which_side, 0)));
      db.push_back(db_base_sptr(new db_basic_rx(usrp, which_side, 1)));
    }
    break;
  }

  return db;
}
