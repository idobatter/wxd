//-----------------------------------------------------------------------------
// wxD - combobox.cpp
// (C) 2005 bero <berobero.sourceforge.net>
// based on
// wx.NET - combobox.cxx
//
// The wxComboBox proxy interface
//
// Written by Bryan Bulten (bryan@bulten.ca)
// (C) 2003 by Bryan Bulten
// Licensed under the wxWidgets license, see LICENSE.txt for details.
//
// $Id$
//-----------------------------------------------------------------------------

#include <wx/wx.h>
#include "common.h"
#include <wx/combobox.h>
#include "local_events.h"

//-----------------------------------------------------------------------------

class _ComboBox : public wxComboBox
{
public:
    DECLARE_OBJECTDELETED(_ComboBox)
};

//-----------------------------------------------------------------------------

extern "C" WXEXPORT
wxComboBox* wxComboBox_ctor()
{
    return new _ComboBox();
}

extern "C" WXEXPORT
dbit wxComboBox_Create(wxComboBox* self, wxWindow* window, int id,
                       dstr value,
                       const wxPoint* pos, const wxSize* size,
                       int n, dstr choices[], long style,
                       const wxValidator* validator, dstr name)
{
    int i;

    if (pos == NULL)
        pos = &wxDefaultPosition;

    if (size == NULL)
        size = &wxDefaultSize;

    if (validator == NULL)
        validator = &wxDefaultValidator;

    if (name.data==NULL)
        name = dstr("comboBox");

    wxString* strings = new wxString[n];
    for (i = 0; i < n; ++i)
        strings[i] = wxstr(choices[i]);

    return self->Create(window, id, wxstr(value), *pos, *size,
                        n, strings, style, *validator,
                        wxstr(name))?1:0;
}

//-----------------------------------------------------------------------------

extern "C" WXEXPORT
void wxComboBox_Append(wxComboBox* self, dstr item)
{
    self->Append(wxstr(item));
}

extern "C" WXEXPORT
void wxComboBox_AppendData(wxComboBox* self, dstr item, void* data)
{
    self->Append(wxstr(item), data);
}

//-----------------------------------------------------------------------------

extern "C" WXEXPORT
void wxComboBox_Clear(wxComboBox* self)
{
    self->Clear();
}

extern "C" WXEXPORT
void wxComboBox_Delete(wxComboBox* self, int n)
{
    self->Delete(n);
}

//-----------------------------------------------------------------------------

extern "C" WXEXPORT
int wxComboBox_FindString(wxComboBox* self, dstr str)
{
    return self->FindString(wxstr(str));
}

//-----------------------------------------------------------------------------

extern "C" WXEXPORT
int wxComboBox_GetCount(wxComboBox* self)
{
    return self->GetCount();
}

//-----------------------------------------------------------------------------

extern "C" WXEXPORT
int wxComboBox_GetSelection(wxComboBox* self)
{
    return self->GetSelection();
}

extern "C" WXEXPORT
dstrret wxComboBox_GetString(wxComboBox* self, int n)
{
    return dstr_ret(self->GetString(n).c_str());
}

#if 0
extern "C" WXEXPORT
void wxComboBox_SetString(wxComboBox* self, int n, dstr text)
{
    self->SetString(n, wxstr(text));
}
#endif

extern "C" WXEXPORT
dstrret wxComboBox_GetStringSelection(wxComboBox* self)
{
    return dstr_ret(self->GetStringSelection());
}

extern "C" WXEXPORT
void wxComboBox_SetStringSelection(wxComboBox* self, dstr str)
{
    self->SetStringSelection(wxstr(str));
}

//-----------------------------------------------------------------------------

extern "C" WXEXPORT
void* wxComboBox_GetClientData(wxComboBox* self, int n)
{
    return self->GetClientData(n);
}

extern "C" WXEXPORT
void wxComboBox_SetClientData(wxComboBox* self, int n, void* data)
{
    self->SetClientData(n, data);
}

//-----------------------------------------------------------------------------

extern "C" WXEXPORT
void wxComboBox_SetSelectionSingle(wxComboBox* self, int n)
{
    self->SetSelection(n);
}

//-----------------------------------------------------------------------------

extern "C" WXEXPORT
void wxComboBox_Copy(wxComboBox* self)
{
    self->Copy();
}

//-----------------------------------------------------------------------------

extern "C" WXEXPORT
void wxComboBox_Cut(wxComboBox* self)
{
    self->Cut();
}

//-----------------------------------------------------------------------------

extern "C" WXEXPORT
void wxComboBox_Paste(wxComboBox* self)
{
    self->Paste();
}

//-----------------------------------------------------------------------------

extern "C" WXEXPORT
void wxComboBox_SetInsertionPoint(wxComboBox* self, long pos)
{
    self->SetInsertionPoint(pos);
}

//-----------------------------------------------------------------------------

extern "C" WXEXPORT
long wxComboBox_GetInsertionPoint(wxComboBox* self)
{
    return self->GetInsertionPoint();
}

//-----------------------------------------------------------------------------

extern "C" WXEXPORT
long wxComboBox_GetLastPosition(wxComboBox* self)
{
    return self->GetLastPosition();
}

//-----------------------------------------------------------------------------

extern "C" WXEXPORT
void wxComboBox_Replace(wxComboBox* self, long from, long to, dstr value)
{
    self->Replace(from, to, wxstr(value));
}

//-----------------------------------------------------------------------------

extern "C" WXEXPORT
void wxComboBox_SetSelectionMult(wxComboBox* self, long from, long to)
{
    self->SetSelection(from, to);
}

//-----------------------------------------------------------------------------

extern "C" WXEXPORT
void wxComboBox_SetEditable(wxComboBox* self, dbit editable)
{
    self->SetEditable(editable);
}

//-----------------------------------------------------------------------------

extern "C" WXEXPORT
void wxComboBox_SetInsertionPointEnd(wxComboBox* self)
{
    self->SetInsertionPointEnd();
}

//-----------------------------------------------------------------------------

extern "C" WXEXPORT
void wxComboBox_Remove(wxComboBox* self, long from, long to)
{
    self->Remove(from, to);
}

//-----------------------------------------------------------------------------

extern "C" WXEXPORT
dstrret wxComboBox_GetValue(wxComboBox* self)
{
    return dstr_ret(self->GetValue());
}

extern "C" WXEXPORT
void wxComboBox_SetValue(wxComboBox* self, dstr text)
{
    self->SetValue(wxstr(text));
}

//-----------------------------------------------------------------------------

extern "C" WXEXPORT
void wxComboBox_SetSelection(wxComboBox* self, int n)
{
	self->SetSelection(n);
}

//-----------------------------------------------------------------------------

extern "C" WXEXPORT
void wxComboBox_Select(wxComboBox* self, int n)
{
	self->Select(n);
}




