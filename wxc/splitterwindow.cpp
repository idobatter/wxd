//-----------------------------------------------------------------------------
// wx.NET - splitterwindow.cxx
//
// The wxSplitterWindow proxy interface.
//
// Written by Jason Perkins (jason@379.com)
// (C) 2003 by 379, Inc.
// Licensed under the wxWidgets license, see LICENSE.txt for details.
//
// $Id$
//-----------------------------------------------------------------------------

#include <wx/wx.h>
#include <wx/splitter.h>
#include "local_events.h"

#if defined(_WINDOWS)
#define CALLBACK __stdcall
#else
#define CALLBACK
#endif

typedef void (CALLBACK* Virtual_OnDoubleClickSash) (int, int);
typedef void (CALLBACK* Virtual_OnUnsplit) (wxWindow*);
typedef bool (CALLBACK* Virtual_OnSashPositionChange) (int);

//-----------------------------------------------------------------------------

class _SplitterWindow : public wxSplitterWindow
{
public:
	_SplitterWindow(wxWindow* parent, wxWindowID id, const wxPoint& pos,
					const wxSize& size, long style, const wxString& name)
		: wxSplitterWindow(parent, id, pos, size, style, name) { }
		
	void OnDoubleClickSash(int x, int y)
	{ m_OnDoubleClickSash(x, y); }
	
	void OnUnsplit(wxWindow* removed)
	{ m_OnUnsplit(removed); }
	
	bool OnSashPositionChange(int newSashPosition)
	{ return m_OnSashPositionChange(newSashPosition); }
	
	void RegisterVirtual(Virtual_OnDoubleClickSash onDoubleClickSash,
		Virtual_OnUnsplit onUnsplit,
		Virtual_OnSashPositionChange onSashPositionChange)
	{	
		m_OnDoubleClickSash = onDoubleClickSash;
		m_OnUnsplit = onUnsplit;
		m_OnSashPositionChange = onSashPositionChange;
	}
		
private:
	Virtual_OnDoubleClickSash m_OnDoubleClickSash;
	Virtual_OnUnsplit m_OnUnsplit;
	Virtual_OnSashPositionChange m_OnSashPositionChange;

public:
	DECLARE_OBJECTDELETED(_SplitterWindow)
};

//-----------------------------------------------------------------------------
// C stubs for class methods

extern "C" WXEXPORT
wxSplitterWindow* wxSplitWnd_ctor(wxWindow *parent, wxWindowID id, const wxPoint* pos,
					const wxSize* size, long style, const wxChar* name)
{
	if (pos == NULL)
		pos = &wxDefaultPosition;

	if (size == NULL)
		size = &wxDefaultSize;

	if (name == NULL)
		name = wxPanelNameStr;

	return new _SplitterWindow(parent, id, *pos, *size, style, name);
}

extern "C" WXEXPORT
void wxSplitWnd_RegisterVirtual(_SplitterWindow* self, Virtual_OnDoubleClickSash onDoubleClickSash,
		Virtual_OnUnsplit onUnsplit,
		Virtual_OnSashPositionChange onSashPositionChange)
{
	self->RegisterVirtual(onDoubleClickSash, onUnsplit, onSashPositionChange);
}

//-----------------------------------------------------------------------------

extern "C" WXEXPORT
void wxSplitWnd_OnDoubleClickSash(_SplitterWindow* self, int x, int y)
{
	self->wxSplitterWindow::OnDoubleClickSash(x, y);
}

//-----------------------------------------------------------------------------

extern "C" WXEXPORT
void wxSplitWnd_OnUnsplit(_SplitterWindow* self, wxWindow* removed)
{
	self->wxSplitterWindow::OnUnsplit(removed);
}

//-----------------------------------------------------------------------------

extern "C" WXEXPORT
bool wxSplitWnd_OnSashPositionChange(_SplitterWindow* self, int newSashPosition)
{
	return self->wxSplitterWindow::OnSashPositionChange(newSashPosition)?1:0;
}

//-----------------------------------------------------------------------------

extern "C" WXEXPORT
int wxSplitWnd_GetSplitMode(_SplitterWindow* self)
{
	return self->GetSplitMode();
}

//-----------------------------------------------------------------------------

extern "C" WXEXPORT
bool wxSplitWnd_IsSplit(_SplitterWindow* self)
{
	return self->IsSplit()?1:0;
}

//-----------------------------------------------------------------------------

extern "C" WXEXPORT
bool wxSplitWnd_SplitHorizontally(_SplitterWindow* self, wxWindow* window1, wxWindow* window2, int sashPosition)
{
	return self->SplitHorizontally(window1, window2, sashPosition)?1:0;
}

//-----------------------------------------------------------------------------

extern "C" WXEXPORT
bool wxSplitWnd_SplitVertically(_SplitterWindow* self, wxWindow* window1, wxWindow* window2, int sashPosition)
{
	return self->SplitVertically(window1, window2, sashPosition)?1:0;
}

//-----------------------------------------------------------------------------

extern "C" WXEXPORT
bool wxSplitWnd_Unsplit(_SplitterWindow* self, wxWindow* toRemove)
{
	return self->Unsplit(toRemove)?1:0;
}

//-----------------------------------------------------------------------------

extern "C" WXEXPORT
void wxSplitWnd_SetSashPosition(_SplitterWindow* self, int position, bool redraw)
{
    self->SetSashPosition(position, redraw);
}

//-----------------------------------------------------------------------------

extern "C" WXEXPORT
int wxSplitWnd_GetSashPosition(_SplitterWindow* self)
{
    return self->GetSashPosition();
}

//-----------------------------------------------------------------------------

extern "C" WXEXPORT
int wxSplitWnd_GetMinimumPaneSize(_SplitterWindow* self)
{
	return self->GetMinimumPaneSize();
}

//-----------------------------------------------------------------------------

extern "C" WXEXPORT
wxWindow* wxSplitWnd_GetWindow1(_SplitterWindow* self)
{
	return self->GetWindow1();
}

//-----------------------------------------------------------------------------

extern "C" WXEXPORT
wxWindow* wxSplitWnd_GetWindow2(_SplitterWindow* self)
{
	return self->GetWindow2();
}

//-----------------------------------------------------------------------------

extern "C" WXEXPORT
void wxSplitWnd_Initialize(_SplitterWindow* self, wxWindow* window)
{
	self->Initialize(window);
}

//-----------------------------------------------------------------------------

extern "C" WXEXPORT
bool wxSplitWnd_ReplaceWindow(_SplitterWindow* self, wxWindow* winOld, wxWindow* winNew)
{
	return self->ReplaceWindow(winOld, winNew)?1:0;
}

//-----------------------------------------------------------------------------

extern "C" WXEXPORT
void wxSplitWnd_SetMinimumPaneSize(_SplitterWindow* self, int paneSize)
{
	self->SetMinimumPaneSize(paneSize);
}

//-----------------------------------------------------------------------------

extern "C" WXEXPORT
void wxSplitWnd_SetSplitMode(_SplitterWindow* self, int mode)
{
	self->SetSplitMode(mode);
}

//-----------------------------------------------------------------------------

extern "C" WXEXPORT
void wxSplitWnd_UpdateSize(_SplitterWindow* self)
{
	self->UpdateSize();
}

