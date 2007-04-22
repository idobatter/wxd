//////////////////////////////////////////////////////////////////////////////
// File:        edit.h
// Purpose:     STC test module
// Maintainer:  Wyo
// Created:     2003-09-01
// RCS-ID:      $Id$
// Copyright:   (c) wxGuide
// Licence:     wxWindows licence
//////////////////////////////////////////////////////////////////////////////

//! wxWidgets headers
import wx.wx;
import wx.StyledTextCtrl;

//! application headers
public import Prefs;

//! wxWidgets headers
//private import wx.File;     // raw file io support
//private import wx.Filename; // filename support

//! application headers
private import defsext;     // additional definitions


//----------------------------------------------------------------------------
//! Edit
class Edit: public wxStyledTextCtrl {

public:

//! constructor
this (wxWindow parent, int id = wxID_ANY,
            wxPoint pos = wxDefaultPosition,
            wxSize size= wxDefaultSize,
            long style = wxSUNKEN_BORDER|wxVSCROLL) {

    super(parent, id, pos, size, style);

    m_filename = wxEmptyString;

    m_LineNrID = 0;
    m_DividerID = 1;
    m_FoldingID = 2;

    // initialize language
    m_language = NULL;

    // default font for all styles
    SetViewEOL (g_CommonPrefs.displayEOLEnable);
    SetIndentationGuides (g_CommonPrefs.indentGuideEnable);
    SetEdgeMode (g_CommonPrefs.longLineOnEnable?
                 wxSTC_EDGE_LINE: wxSTC_EDGE_NONE);
    SetViewWhiteSpace (g_CommonPrefs.whiteSpaceEnable?
                       wxSTC_WS_VISIBLEALWAYS: wxSTC_WS_INVISIBLE);
    SetOvertype (g_CommonPrefs.overTypeInitial);
    SetReadOnly (g_CommonPrefs.readOnlyInitial);
    SetWrapMode (g_CommonPrefs.wrapModeInitial?
                 wxSTC_WRAP_WORD: wxSTC_WRAP_NONE);
    wxFont font = new wxFont(10, wxMODERN, wxNORMAL, wxNORMAL);
    StyleSetFont (wxSTC_STYLE_DEFAULT, font);
    StyleSetForeground (wxSTC_STYLE_DEFAULT, *wxBLACK);
    StyleSetBackground (wxSTC_STYLE_DEFAULT, *wxWHITE);
    StyleSetForeground (wxSTC_STYLE_LINENUMBER, new wxColour ("DARK GREY"));
    StyleSetBackground (wxSTC_STYLE_LINENUMBER, *wxWHITE);
    StyleSetForeground(wxSTC_STYLE_INDENTGUIDE, new wxColour ("DARK GREY"));
    InitializePrefs (DEFAULT_LANGUAGE);

    // set visibility
    SetVisiblePolicy (wxSTC_VISIBLE_STRICT|wxSTC_VISIBLE_SLOP, 1);
    SetXCaretPolicy (wxSTC_CARET_EVEN|wxSTC_VISIBLE_STRICT|wxSTC_CARET_SLOP, 1);
    SetYCaretPolicy (wxSTC_CARET_EVEN|wxSTC_VISIBLE_STRICT|wxSTC_CARET_SLOP, 1);

    // markers
    MarkerDefine (wxSTC_MARKNUM_FOLDER,        wxSTC_MARK_DOTDOTDOT, "BLACK", "BLACK");
    MarkerDefine (wxSTC_MARKNUM_FOLDEROPEN,    wxSTC_MARK_ARROWDOWN, "BLACK", "BLACK");
    MarkerDefine (wxSTC_MARKNUM_FOLDERSUB,     wxSTC_MARK_EMPTY,     "BLACK", "BLACK");
    MarkerDefine (wxSTC_MARKNUM_FOLDEREND,     wxSTC_MARK_DOTDOTDOT, "BLACK", "WHITE");
    MarkerDefine (wxSTC_MARKNUM_FOLDEROPENMID, wxSTC_MARK_ARROWDOWN, "BLACK", "WHITE");
    MarkerDefine (wxSTC_MARKNUM_FOLDERMIDTAIL, wxSTC_MARK_EMPTY,     "BLACK", "BLACK");
    MarkerDefine (wxSTC_MARKNUM_FOLDERTAIL,    wxSTC_MARK_EMPTY,     "BLACK", "BLACK");

    // miscelaneous
    m_LineNrMargin = TextWidth (wxSTC_STYLE_LINENUMBER, "_999999");
    m_FoldingMargin = 16;
    CmdKeyClear (wxSTC_KEY_TAB, 0); // this is done by the menu accelerator key
    SetLayoutCache (wxSTC_CACHE_PAGE);

    // common
    EVT_SIZE (                         &OnSize);
    // edit
    EVT_MENU (wxID_CLEAR,              &OnEditClear);
    EVT_MENU (wxID_CUT,                &OnEditCut);
    EVT_MENU (wxID_COPY,               &OnEditCopy);
    EVT_MENU (wxID_PASTE,              &OnEditPaste);
    EVT_MENU (myID_INDENTINC,          &OnEditIndentInc);
    EVT_MENU (myID_INDENTRED,          &OnEditIndentRed);
    EVT_MENU (wxID_SELECTALL,          &OnEditSelectAll);
    EVT_MENU (myID_SELECTLINE,         &OnEditSelectLine);
    EVT_MENU (wxID_REDO,               &OnEditRedo);
    EVT_MENU (wxID_UNDO,               &OnEditUndo);
    // find
    EVT_MENU (wxID_FIND,               &OnFind);
    EVT_MENU (myID_FINDNEXT,           &OnFindNext);
    EVT_MENU (myID_REPLACE,            &OnReplace);
    EVT_MENU (myID_REPLACENEXT,        &OnReplaceNext);
    EVT_MENU (myID_BRACEMATCH,         &OnBraceMatch);
    EVT_MENU (myID_GOTO,               &OnGoto);
    // view
    EVT_MENU_RANGE (myID_HILIGHTFIRST, myID_HILIGHTLAST,
                                       &OnHilightLang);
    EVT_MENU (myID_DISPLAYEOL,         &OnDisplayEOL);
    EVT_MENU (myID_INDENTGUIDE,        &OnIndentGuide);
    EVT_MENU (myID_LINENUMBER,         &OnLineNumber);
    EVT_MENU (myID_LONGLINEON,         &OnLongLineOn);
    EVT_MENU (myID_WHITESPACE,         &OnWhiteSpace);
    EVT_MENU (myID_FOLDTOGGLE,         &OnFoldToggle);
    EVT_MENU (myID_OVERTYPE,           &OnSetOverType);
    EVT_MENU (myID_READONLY,           &OnSetReadOnly);
    EVT_MENU (myID_WRAPMODEON,         &OnWrapmodeOn);
    EVT_MENU (myID_CHARSETANSI,        &OnUseCharset);
    EVT_MENU (myID_CHARSETMAC,         &OnUseCharset);
    // extra
    EVT_MENU (myID_CHANGELOWER,        &OnChangeCase);
    EVT_MENU (myID_CHANGEUPPER,        &OnChangeCase);
    EVT_MENU (myID_CONVERTCR,          &OnConvertEOL);
    EVT_MENU (myID_CONVERTCRLF,        &OnConvertEOL);
    EVT_MENU (myID_CONVERTLF,          &OnConvertEOL);
    // stc
    EVT_STC_MARGINCLICK (wxID_ANY,     &OnMarginClick);
    EVT_STC_CHARADDED (wxID_ANY,       &OnCharAdded);

}

//! destructor
~this () {}

//----------------------------------------------------------------------------
// common event handlers
void OnSize( wxSizeEvent event ) {
    int x = GetClientSize().x +
            (g_CommonPrefs.lineNumberEnable? m_LineNrMargin: 0) +
            (g_CommonPrefs.foldEnable? m_FoldingMargin: 0);
    if (x > 0) SetScrollWidth (x);
    event.Skip();
}

// edit event handlers
void OnEditRedo (wxCommandEvent event) {
    if (!CanRedo()) return;
    Redo ();
}

void OnEditUndo (wxCommandEvent event) {
    if (!CanUndo()) return;
    Undo ();
}

void OnEditClear (wxCommandEvent event) {
    if (GetReadOnly()) return;
    Clear ();
}

void OnEditCut (wxCommandEvent event) {
    if (GetReadOnly() || (GetSelectionEnd()-GetSelectionStart() <= 0)) return;
    Cut ();
}

void OnEditCopy (wxCommandEvent event) {
    if (GetSelectionEnd()-GetSelectionStart() <= 0) return;
    Copy ();
}

void OnEditPaste (wxCommandEvent event) {
    if (!CanPaste()) return;
    Paste ();
}

void OnFind (wxCommandEvent event) {
}

void OnFindNext (wxCommandEvent event) {
}

void OnReplace (wxCommandEvent event) {
}

void OnReplaceNext (wxCommandEvent event) {
}

void OnBraceMatch (wxCommandEvent event) {
    int min = GetCurrentPos ();
    int max = BraceMatch (min);
    if (max > (min+1)) {
        BraceHighlight (min+1, max);
        SetSelection (min+1, max);
    }else{
        BraceBadLight (min);
    }
}

void OnGoto (wxCommandEvent event) {
}

void OnEditIndentInc (wxCommandEvent event) {
    CmdKeyExecute (wxSTC_CMD_TAB);
}

void OnEditIndentRed (wxCommandEvent event) {
    CmdKeyExecute (wxSTC_CMD_DELETEBACK);
}

void OnEditSelectAll (wxCommandEvent event) {
    SetSelection (0, GetTextLength ());
}

void OnEditSelectLine (wxCommandEvent event) {
    int lineStart = PositionFromLine (GetCurrentLine());
    int lineEnd = PositionFromLine (GetCurrentLine() + 1);
    SetSelection (lineStart, lineEnd);
}

void OnHilightLang (wxCommandEvent event) {
    InitializePrefs (g_LanguagePrefs [event.GetId() - myID_HILIGHTFIRST].name);
}

void OnDisplayEOL (wxCommandEvent event) {
    SetViewEOL (!GetViewEOL());
}

void OnIndentGuide (wxCommandEvent event) {
    SetIndentationGuides (!GetIndentationGuides());
}

void OnLineNumber (wxCommandEvent event) {
    SetMarginWidth (m_LineNrID,
                    GetMarginWidth (m_LineNrID) == 0? m_LineNrMargin: 0);
}

void OnLongLineOn (wxCommandEvent event) {
    SetEdgeMode (GetEdgeMode() == 0? wxSTC_EDGE_LINE: wxSTC_EDGE_NONE);
}

void OnWhiteSpace (wxCommandEvent event) {
    SetViewWhiteSpace (GetViewWhiteSpace() == 0?
                       wxSTC_WS_VISIBLEALWAYS: wxSTC_WS_INVISIBLE);
}

void OnFoldToggle (wxCommandEvent event) {
    ToggleFold (GetFoldParent(GetCurrentLine()));
}

void OnSetOverType (wxCommandEvent event) {
    SetOvertype (!GetOvertype());
}

void OnSetReadOnly (wxCommandEvent event) {
    SetReadOnly (!GetReadOnly());
}

void OnWrapmodeOn (wxCommandEvent event) {
    SetWrapMode (GetWrapMode() == 0? wxSTC_WRAP_WORD: wxSTC_WRAP_NONE);
}

void OnUseCharset (wxCommandEvent event) {
    int Nr;
    int charset = GetCodePage();
    switch (event.GetId()) {
        case myID_CHARSETANSI: {charset = wxSTC_CHARSET_ANSI; break;}
        case myID_CHARSETMAC: {charset = wxSTC_CHARSET_ANSI; break;}
    }
    for (Nr = 0; Nr < wxSTC_STYLE_LASTPREDEFINED; Nr++) {
        StyleSetCharacterSet (Nr, charset);
    }
    SetCodePage (charset);
}

void OnChangeCase (wxCommandEvent event) {
    switch (event.GetId()) {
        case myID_CHANGELOWER: {
            CmdKeyExecute (wxSTC_CMD_LOWERCASE);
            break;
        }
        case myID_CHANGEUPPER: {
            CmdKeyExecute (wxSTC_CMD_UPPERCASE);
            break;
        }
    }
}

void OnConvertEOL (wxCommandEvent event) {
    int eolMode = GetEOLMode();
    switch (event.GetId()) {
        case myID_CONVERTCR: { eolMode = wxSTC_EOL_CR; break;}
        case myID_CONVERTCRLF: { eolMode = wxSTC_EOL_CRLF; break;}
        case myID_CONVERTLF: { eolMode = wxSTC_EOL_LF; break;}
    }
    ConvertEOLs (eolMode);
    SetEOLMode (eolMode);
}

//! misc
void OnMarginClick (wxStyledTextEvent event) {
    if (event.GetMargin() == 2) {
        int lineClick = LineFromPosition (event.GetPosition());
        int levelClick = GetFoldLevel (lineClick);
        if ((levelClick & wxSTC_FOLDLEVELHEADERFLAG) > 0) {
            ToggleFold (lineClick);
        }
    }
}

void OnCharAdded (wxStyledTextEvent event) {
    char chr = cast(char)event.GetKey();
    int currentLine = GetCurrentLine();
    // Change this if support for mac files with \r is needed
    if (chr == '\n') {
        int lineInd = 0;
        if (currentLine > 0) {
            lineInd = GetLineIndentation(currentLine - 1);
        }
        if (lineInd == 0) return;
        SetLineIndentation (currentLine, lineInd);
        GotoPos(PositionFromLine (currentLine) + lineInd);
    }
}


//----------------------------------------------------------------------------
// private functions
wxString DeterminePrefs (wxString filename) {

    Prefs.LanguageInfo* curInfo;

    // determine language from filepatterns
    int languageNr;
    for (languageNr = 0; languageNr < g_LanguagePrefsSize; languageNr++) {
        curInfo = &g_LanguagePrefs [languageNr];
        wxString filepattern = curInfo.filepattern;
        filepattern.Lower();
        while (!filepattern.empty()) {
            wxString cur = filepattern.BeforeFirst (';');
            if ((cur == filename) ||
                (cur == (filename.BeforeLast ('.') + ".*")) ||
                (cur == ("*." + filename.AfterLast ('.')))) {
                return curInfo.name;
            }
            filepattern = filepattern.AfterFirst (';');
        }
    }
    return wxEmptyString;

}

bool InitializePrefs (wxString name) {

    // initialize styles
    StyleClearAll();
    Prefs.LanguageInfo* curInfo = NULL;

    // determine language
    bool found = false;
    int languageNr;
    for (languageNr = 0; languageNr < g_LanguagePrefsSize; languageNr++) {
        curInfo = &g_LanguagePrefs [languageNr];
        if (curInfo.name == name) {
            found = true;
            break;
        }
    }
    if (!found) return false;

    // set lexer and language
    SetLexer (curInfo.lexer);
    m_language = curInfo;

    // set margin for line numbers
    SetMarginType (m_LineNrID, wxSTC_MARGIN_NUMBER);
    StyleSetForeground (wxSTC_STYLE_LINENUMBER, wxColour ("DARK GREY"));
    StyleSetBackground (wxSTC_STYLE_LINENUMBER, *wxWHITE);
    SetMarginWidth (m_LineNrID, 0); // start out not visible

    // default fonts for all styles!
    int Nr;
    for (Nr = 0; Nr < wxSTC_STYLE_LASTPREDEFINED; Nr++) {
        wxFont font = new wxFont(10, wxMODERN, wxNORMAL, wxNORMAL);
        StyleSetFont (Nr, font);
    }

    // set common styles
    StyleSetForeground (wxSTC_STYLE_DEFAULT, wxColour ("DARK GREY"));
    StyleSetForeground (wxSTC_STYLE_INDENTGUIDE, wxColour ("DARK GREY"));

    // initialize settings
    if (g_CommonPrefs.syntaxEnable) {
        int keywordnr = 0;
        for (Nr = 0; Nr < STYLE_TYPES_COUNT; Nr++) {
            if (curInfo.styles[Nr].type == -1) continue;
            const StyleInfo curType = g_StylePrefs [curInfo.styles[Nr].type];
            wxFont font = new wxFont(curType.fontsize, wxMODERN, wxNORMAL, wxNORMAL, false,
                         curType.fontname);
            StyleSetFont (Nr, font);
            if (curType.foreground) {
                StyleSetForeground (Nr, wxColour (curType.foreground));
            }
            if (curType.background) {
                StyleSetBackground (Nr, wxColour (curType.background));
            }
            StyleSetBold (Nr, (curType.fontstyle & mySTC_STYLE_BOLD) > 0);
            StyleSetItalic (Nr, (curType.fontstyle & mySTC_STYLE_ITALIC) > 0);
            StyleSetUnderline (Nr, (curType.fontstyle & mySTC_STYLE_UNDERL) > 0);
            StyleSetVisible (Nr, (curType.fontstyle & mySTC_STYLE_HIDDEN) == 0);
            StyleSetCase (Nr, curType.lettercase);
            wxChar *pwords = curInfo.styles[Nr].words;
            if (pwords) {
                SetKeyWords (keywordnr, pwords);
                keywordnr += 1;
            }
        }
    }

    // set margin as unused
    SetMarginType (m_DividerID, wxSTC_MARGIN_SYMBOL);
    SetMarginWidth (m_DividerID, 0);
    SetMarginSensitive (m_DividerID, false);

    // folding
    SetMarginType (m_FoldingID, wxSTC_MARGIN_SYMBOL);
    SetMarginMask (m_FoldingID, wxSTC_MASK_FOLDERS);
    StyleSetBackground (m_FoldingID, *wxWHITE);
    SetMarginWidth (m_FoldingID, 0);
    SetMarginSensitive (m_FoldingID, false);
    if (g_CommonPrefs.foldEnable) {
        SetMarginWidth (m_FoldingID, curInfo.folds != 0? m_FoldingMargin: 0);
        SetMarginSensitive (m_FoldingID, curInfo.folds != 0);
        SetProperty ("fold", curInfo.folds != 0? "1": "0");
        SetProperty ("fold.comment",
                     (curInfo.folds & mySTC_FOLD_COMMENT) > 0? "1": "0");
        SetProperty ("fold.compact",
                     (curInfo.folds & mySTC_FOLD_COMPACT) > 0? "1": "0");
        SetProperty ("fold.preprocessor",
                     (curInfo.folds & mySTC_FOLD_PREPROC) > 0? "1": "0");
        SetProperty ("fold.html",
                     (curInfo.folds & mySTC_FOLD_HTML) > 0? "1": "0");
        SetProperty ("fold.html.preprocessor",
                     (curInfo.folds & mySTC_FOLD_HTMLPREP) > 0? "1": "0");
        SetProperty ("fold.comment.python",
                     (curInfo.folds & mySTC_FOLD_COMMENTPY) > 0? "1": "0");
        SetProperty ("fold.quotes.python",
                     (curInfo.folds & mySTC_FOLD_QUOTESPY) > 0? "1": "0");
    }
    SetFoldFlags (wxSTC_FOLDFLAG_LINEBEFORE_CONTRACTED |
                  wxSTC_FOLDFLAG_LINEAFTER_CONTRACTED);

    // set spaces and indention
    SetTabWidth (4);
    SetUseTabs (false);
    SetTabIndents (true);
    SetBackSpaceUnIndents (true);
    SetIndent (g_CommonPrefs.indentEnable? 4: 0);

    // others
    SetViewEOL (g_CommonPrefs.displayEOLEnable);
    SetIndentationGuides (g_CommonPrefs.indentGuideEnable);
    SetEdgeColumn (80);
    SetEdgeMode (g_CommonPrefs.longLineOnEnable? wxSTC_EDGE_LINE: wxSTC_EDGE_NONE);
    SetViewWhiteSpace (g_CommonPrefs.whiteSpaceEnable?
                       wxSTC_WS_VISIBLEALWAYS: wxSTC_WS_INVISIBLE);
    SetOvertype (g_CommonPrefs.overTypeInitial);
    SetReadOnly (g_CommonPrefs.readOnlyInitial);
    SetWrapMode (g_CommonPrefs.wrapModeInitial?
                 wxSTC_WRAP_WORD: wxSTC_WRAP_NONE);

    return true;
}

bool LoadFile ()
{
    // get filname
    if (!m_filename) {
        wxFileDialog dlg = new wxFileDialog(this, "Open file", wxEmptyString, wxEmptyString,
                          "Any file (*)|*", wxOPEN | wxFILE_MUST_EXIST | wxCHANGE_DIR);
        if (dlg.ShowModal() != wxID_OK) return false;
        m_filename = dlg.GetPath();
    }

    // load file
    return LoadFile (m_filename);
}

bool LoadFile (wxString filename) {

    // load file in edit and clear undo
    if (!filename.empty()) m_filename = filename;
//     wxFile file (m_filename);
//     if (!file.IsOpened()) return false;
    ClearAll ();
//     long lng = file.Length ();
//     if (lng > 0) {
//         wxString buf;
//         wxChar *buff = buf.GetWriteBuf (lng);
//         file.Read (buff, lng);
//         buf.UngetWriteBuf ();
//         InsertText (0, buf);
//     }
//     file.Close();

    wxStyledTextCtrl.LoadFile(m_filename);

    EmptyUndoBuffer();

    // determine lexer language
    wxFileName fname (m_filename);
    InitializePrefs (DeterminePrefs (fname.GetFullName()));

    return true;
}

bool SaveFile ()
{
    // return if no change
    if (!Modified()) return true;

    // get filname
    if (!m_filename) {
        wxFileDialog dlg = new wxFileDialog(this, "Save file", wxEmptyString, wxEmptyString, "Any file (*)|*",
                          wxSAVE | wxOVERWRITE_PROMPT);
        if (dlg.ShowModal() != wxID_OK) return false;
        m_filename = dlg.GetPath();
    }

    // save file
    return SaveFile (m_filename);
}

bool SaveFile (wxString filename) {

    // return if no change
    if (!Modified()) return true;

//     // save edit in file and clear undo
//     if (!filename.empty()) m_filename = filename;
//     wxFile file (m_filename, wxFile::write);
//     if (!file.IsOpened()) return false;
//     wxString buf = GetText();
//     bool okay = file.Write (buf);
//     file.Close();
//     if (!okay) return false;
//     EmptyUndoBuffer();
//     SetSavePoint();

//     return true;

    return wxStyledTextCtrl.SaveFile(filename);

}

bool Modified () {

    // return modified state
    return (GetModify() && !GetReadOnly());
}


    Prefs.LanguageInfo* GetLanguageInfo () {return m_language;}

    wxString GetFilename () {return m_filename;}
    void SetFilename (wxString filename) {m_filename = filename;}

private:
    // file
    wxString m_filename;

    // lanugage properties
    Prefs.LanguageInfo* m_language;

    // margin variables
    int m_LineNrID;
    int m_LineNrMargin;
    int m_FoldingID;
    int m_FoldingMargin;
    int m_DividerID;

}

//----------------------------------------------------------------------------
// EditProperties
//----------------------------------------------------------------------------

//! EditProperties
class EditProperties: public wxDialog {

public:

this (Edit *edit,
                                long style) {

    this (edit, wxID_ANY, wxEmptyString,
                    wxDefaultPosition, wxDefaultSize,
                    style | wxDEFAULT_DIALOG_STYLE | wxRESIZE_BORDER);

    // sets the application title
    SetTitle (_("Properties"));
    wxString text;

    // fullname
    wxBoxSizer *fullname = new wxBoxSizer (wxHORIZONTAL);
    fullname.Add (10, 0);
    fullname.Add (new wxStaticText (this, wxID_ANY, _("Full filename"),
                                     wxDefaultPosition, wxSize(80, wxDefaultCoord)),
                   0, wxALIGN_LEFT|wxALIGN_CENTER_VERTICAL);
    fullname.Add (new wxStaticText (this, wxID_ANY, edit.GetFilename()),
                   0, wxALIGN_LEFT|wxALIGN_CENTER_VERTICAL);

    // text info
    wxGridSizer *textinfo = new wxGridSizer (4, 0, 2);
    textinfo.Add (new wxStaticText (this, wxID_ANY, _("Language"),
                                     wxDefaultPosition, wxSize(80, wxDefaultCoord)),
                   0, wxALIGN_LEFT|wxALIGN_CENTER_VERTICAL|wxLEFT, 4);
    textinfo.Add (new wxStaticText (this, wxID_ANY, edit.m_language.name),
                   0, wxALIGN_LEFT|wxALIGN_CENTER_VERTICAL|wxRIGHT, 4);
    textinfo.Add (new wxStaticText (this, wxID_ANY, _("Lexer-ID: "),
                                     wxDefaultPosition, wxSize(80, wxDefaultCoord)),
                   0, wxALIGN_LEFT|wxALIGN_CENTER_VERTICAL|wxLEFT, 4);
    text = wxString.Format ("%d", edit.GetLexer());
    textinfo.Add (new wxStaticText (this, wxID_ANY, text),
                   0, wxALIGN_RIGHT|wxALIGN_CENTER_VERTICAL|wxRIGHT, 4);
    wxString EOLtype = wxEmptyString;
    switch (edit.GetEOLMode()) {
        case wxSTC_EOL_CR: {EOLtype = "CR (Unix)"; break; }
        case wxSTC_EOL_CRLF: {EOLtype = "CRLF (Windows)"; break; }
        case wxSTC_EOL_LF: {EOLtype = "CR (Macintosh)"; break; }
    }
    textinfo.Add (new wxStaticText (this, wxID_ANY, _("Line endings"),
                                     wxDefaultPosition, wxSize(80, wxDefaultCoord)),
                   0, wxALIGN_LEFT|wxALIGN_CENTER_VERTICAL|wxLEFT, 4);
    textinfo.Add (new wxStaticText (this, wxID_ANY, EOLtype),
                   0, wxALIGN_LEFT|wxALIGN_CENTER_VERTICAL|wxRIGHT, 4);

    // text info box
    wxStaticBoxSizer *textinfos = new wxStaticBoxSizer (
                     new wxStaticBox (this, wxID_ANY, _("Informations")),
                     wxVERTICAL);
    textinfos.Add (textinfo, 0, wxEXPAND);
    textinfos.Add (0, 6);

    // statistic
    wxGridSizer *statistic = new wxGridSizer (4, 0, 2);
    statistic.Add (new wxStaticText (this, wxID_ANY, _("Total lines"),
                                     wxDefaultPosition, wxSize(80, wxDefaultCoord)),
                    0, wxALIGN_LEFT|wxALIGN_CENTER_VERTICAL|wxLEFT, 4);
    text = wxString.Format ("%d", edit.GetLineCount());
    statistic.Add (new wxStaticText (this, wxID_ANY, text),
                    0, wxALIGN_RIGHT|wxALIGN_CENTER_VERTICAL|wxRIGHT, 4);
    statistic.Add (new wxStaticText (this, wxID_ANY, _("Total chars"),
                                     wxDefaultPosition, wxSize(80, wxDefaultCoord)),
                    0, wxALIGN_LEFT|wxALIGN_CENTER_VERTICAL|wxLEFT, 4);
    text = wxString.Format ("%d", edit.GetTextLength());
    statistic.Add (new wxStaticText (this, wxID_ANY, text),
                    0, wxALIGN_RIGHT|wxALIGN_CENTER_VERTICAL|wxRIGHT, 4);
    statistic.Add (new wxStaticText (this, wxID_ANY, _("Current line"),
                                     wxDefaultPosition, wxSize(80, wxDefaultCoord)),
                    0, wxALIGN_LEFT|wxALIGN_CENTER_VERTICAL|wxLEFT, 4);
    text = wxString.Format ("%d", edit.GetCurrentLine());
    statistic.Add (new wxStaticText (this, wxID_ANY, text),
                    0, wxALIGN_RIGHT|wxALIGN_CENTER_VERTICAL|wxRIGHT, 4);
    statistic.Add (new wxStaticText (this, wxID_ANY, _("Current pos"),
                                     wxDefaultPosition, wxSize(80, wxDefaultCoord)),
                    0, wxALIGN_LEFT|wxALIGN_CENTER_VERTICAL|wxLEFT, 4);
    text = wxString.Format ("%d", edit.GetCurrentPos());
    statistic.Add (new wxStaticText (this, wxID_ANY, text),
                    0, wxALIGN_RIGHT|wxALIGN_CENTER_VERTICAL|wxRIGHT, 4);

    // char/line statistics
    wxStaticBoxSizer *statistics = new wxStaticBoxSizer (
                     new wxStaticBox (this, wxID_ANY, _("Statistics")),
                     wxVERTICAL);
    statistics.Add (statistic, 0, wxEXPAND);
    statistics.Add (0, 6);

    // total pane
    wxBoxSizer *totalpane = new wxBoxSizer (wxVERTICAL);
    totalpane.Add (fullname, 0, wxEXPAND | wxLEFT | wxRIGHT | wxTOP, 10);
    totalpane.Add (0, 6);
    totalpane.Add (textinfos, 0, wxEXPAND | wxLEFT | wxRIGHT, 10);
    totalpane.Add (0, 10);
    totalpane.Add (statistics, 0, wxEXPAND | wxLEFT | wxRIGHT, 10);
    totalpane.Add (0, 6);
    wxButton *okButton = new wxButton (this, wxID_OK, _("OK"));
    okButton.SetDefault();
    totalpane.Add (okButton, 0, wxALIGN_CENTER | wxALL, 10);

    SetSizerAndFit (totalpane);

    ShowModal();
}

}

//----------------------------------------------------------------------------
// EditPrint
//----------------------------------------------------------------------------

//! EditPrint
class EditPrint: public wxPrintout {

public:

//! constructor
this (Edit *edit, wxChar *title = "") {

    super(title);

    m_edit = edit;
    m_printed = 0;

}

//! event handlers
bool OnPrintPage (int page) {

    wxDC *dc = GetDC();
    if (!dc) return false;

    // scale DC
    PrintScaling (dc);

    // print page
    if (page == 1) m_printed = 0;
    m_printed = m_edit.FormatRange (1, m_printed, m_edit.GetLength(),
                                     dc, dc, m_printRect, m_pageRect);

    return true;
}

bool OnBeginDocument (int startPage, int endPage) {

    if (!wxPrintout.OnBeginDocument (startPage, endPage)) {
        return false;
    }

    return true;
}

void GetPageInfo (int *minPage, int *maxPage, int *selPageFrom, int *selPageTo) {

    // initialize values
    *minPage = 0;
    *maxPage = 0;
    *selPageFrom = 0;
    *selPageTo = 0;

    // scale DC if possible
    wxDC *dc = GetDC();
    if (!dc) return;
    PrintScaling (dc);

    // get print page informations and convert to printer pixels
    wxSize ppiScr;
    GetPPIScreen (&ppiScr.x, &ppiScr.y);
    wxSize page = g_pageSetupData.GetPaperSize();
    page.x = cast(int) (page.x * ppiScr.x / 25.4);
    page.y = cast(int) (page.y * ppiScr.y / 25.4);
    m_pageRect = wxRect (0,
                         0,
                         page.x,
                         page.y);

    // get margins informations and convert to printer pixels
    wxPoint pt = g_pageSetupData.GetMarginTopLeft();
    int left = pt.x;
    int top = pt.y;
    pt = g_pageSetupData.GetMarginBottomRight();
    int right = pt.x;
    int bottom = pt.y;

    top = cast(int) (top * ppiScr.y / 25.4);
    bottom = cast(int) (bottom * ppiScr.y / 25.4);
    left = cast(int) (left * ppiScr.x / 25.4);
    right = cast(int) (right * ppiScr.x / 25.4);

    m_printRect = wxRect (left,
                          top,
                          page.x - (left + right),
                          page.y - (top + bottom));

    // count pages
    while (HasPage (*maxPage)) {
        m_printed = m_edit.FormatRange (0, m_printed, m_edit.GetLength(),
                                       dc, dc, m_printRect, m_pageRect);
        *maxPage += 1;
    }
    if (*maxPage > 0) *minPage = 1;
    *selPageFrom = *minPage;
    *selPageTo = *maxPage;
}

//! print functions
bool HasPage (int page) {

    return (m_printed < m_edit.GetLength());
}

bool PrintScaling (wxDC *dc){

    // check for dc, return if none
    if (!dc) return false;

    // get printer and screen sizing values
    wxSize ppiScr;
    GetPPIScreen (&ppiScr.x, &ppiScr.y);
    if (ppiScr.x == 0) { // most possible guess 96 dpi
        ppiScr.x = 96;
        ppiScr.y = 96;
    }
    wxSize ppiPrt;
    GetPPIPrinter (&ppiPrt.x, &ppiPrt.y);
    if (ppiPrt.x == 0) { // scaling factor to 1
        ppiPrt.x = ppiScr.x;
        ppiPrt.y = ppiScr.y;
    }
    wxSize dcSize = dc.GetSize();
    wxSize pageSize;
    GetPageSizePixels (&pageSize.x, &pageSize.y);

    // set user scale
    float scale_x = cast(float)(ppiPrt.x * dcSize.x) /
                    cast(float)(ppiScr.x * pageSize.x);
    float scale_y = cast(float)(ppiPrt.y * dcSize.y) /
                    cast(float)(ppiScr.y * pageSize.y);
    dc.SetUserScale (scale_x, scale_y);

    return true;
}


private:
    Edit *m_edit;
    int m_printed;
    wxRect m_pageRect;
    wxRect m_printRect;

}