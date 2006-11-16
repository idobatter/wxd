//-----------------------------------------------------------------------------
// wx.NET - displaychangedevent.cxx
// 
// The wxDisplayChangedEvent proxy interface.
//
// Written by Alexander Olk (xenomorph2@onlinehome.de)
// (C) 2004 by Alexander Olk
// Licensed under the wxWidgets license, see LICENSE.txt for details.
//
// $Id$
//-----------------------------------------------------------------------------

#include <wx/wx.h>

//-----------------------------------------------------------------------------

extern "C" WXEXPORT
wxDisplayChangedEvent* wxDisplayChangedEvent_ctor()
{
    return new wxDisplayChangedEvent();
}
