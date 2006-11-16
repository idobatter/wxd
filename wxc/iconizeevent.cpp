//-----------------------------------------------------------------------------
// wx.NET - iconizeevent.cxx
// 
// The wxIconizeEvent proxy interface.
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
wxIconizeEvent* wxIconizeEvent_ctor(wxEventType type)
{
    return new wxIconizeEvent(type);
}

extern "C" WXEXPORT
bool wxIconizeEvent_Iconized(wxIconizeEvent* self)
{
	return self->Iconized()?1:0;
}
