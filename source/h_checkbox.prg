/*
 * $Id: h_checkbox.prg,v 1.29 2011-09-11 03:27:55 fyurisich Exp $
 */
/*
 * ooHG source code:
 * PRG checkbox functions
 *
 * Copyright 2005-2009 Vicente Guerra <vicente@guerra.com.mx>
 * www - http://www.oohg.org
 *
 * Portions of this code are copyrighted by the Harbour MiniGUI library.
 * Copyright 2002-2005 Roberto Lopez <roblez@ciudad.com.ar>
 *
 * This program is free software; you can redistribute it and/or modify
 * it under the terms of the GNU General Public License as published by
 * the Free Software Foundation; either version 2, or (at your option)
 * any later version.
 *
 * This program is distributed in the hope that it will be useful,
 * but WITHOUT ANY WARRANTY; without even the implied warranty of
 * MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
 * GNU General Public License for more details.
 *
 * You should have received a copy of the GNU General Public License
 * along with this software; see the file COPYING.  If not, write to
 * the Free Software Foundation, Inc., 59 Temple Place, Suite 330,
 * Boston, MA 02111-1307 USA (or visit the web site http://www.gnu.org/).
 *
 * As a special exception, the ooHG Project gives permission for
 * additional uses of the text contained in its release of ooHG.
 *
 * The exception is that, if you link the ooHG libraries with other
 * files to produce an executable, this does not by itself cause the
 * resulting executable to be covered by the GNU General Public License.
 * Your use of that executable is in no way restricted on account of
 * linking the ooHG library code into it.
 *
 * This exception does not however invalidate any other reasons why
 * the executable file might be covered by the GNU General Public License.
 *
 * This exception applies only to the code released by the ooHG
 * Project under the name ooHG. If you copy code from other
 * ooHG Project or Free Software Foundation releases into a copy of
 * ooHG, as the General Public License permits, the exception does
 * not apply to the code that you add in this way. To avoid misleading
 * anyone as to the status of such modified files, you must delete
 * this exception notice from them.
 *
 * If you write modifications of your own for ooHG, it is your choice
 * whether to permit this exception to apply to your modifications.
 * If you do not wish that, delete this exception notice.
 *
 */
/*----------------------------------------------------------------------------
 MINIGUI - Harbour Win32 GUI library source code

 Copyright 2002-2005 Roberto Lopez <roblez@ciudad.com.ar>
 http://www.geocities.com/harbour_minigui/

 This program is free software; you can redistribute it and/or modify it under
 the terms of the GNU General Public License as published by the Free Software
 Foundation; either version 2 of the License, or (at your option) any later
 version.

 This program is distributed in the hope that it will be useful, but WITHOUT
 ANY WARRANTY; without even the implied warranty of MERCHANTABILITY or FITNESS
 FOR A PARTICULAR PURPOSE. See the GNU General Public License for more details.

 You should have received a copy of the GNU General Public License along with
 this software; see the file COPYING. If not, write to the Free Software
 Foundation, Inc., 59 Temple Place, Suite 330, Boston, MA 02111-1307 USA (or
 visit the web site http://www.gnu.org/).

 As a special exception, you have permission for additional uses of the text
 contained in this release of Harbour Minigui.

 The exception is that, if you link the Harbour Minigui library with other
 files to produce an executable, this does not by itself cause the resulting
 executable to be covered by the GNU General Public License.
 Your use of that executable is in no way restricted on account of linking the
 Harbour-Minigui library code into it.

 Parts of this project are based upon:

	"Harbour GUI framework for Win32"
 	Copyright 2001 Alexander S.Kresin <alex@belacy.belgorod.su>
 	Copyright 2001 Antonio Linares <alinares@fivetech.com>
	www - http://www.harbour-project.org

	"Harbour Project"
	Copyright 1999-2003, http://www.harbour-project.org/
---------------------------------------------------------------------------*/

#include "oohg.ch"
#include "common.ch"
#include "hbclass.ch"
#include "i_windefs.ch"


CLASS TCheckBox FROM TLabel
   DATA Type      INIT "CHECKBOX" READONLY
   DATA cPicture  INIT ""
   DATA IconWidth INIT 19
   DATA nWidth    INIT 100
   DATA nHeight   INIT 28
   DATA TabHandle INIT 0

   METHOD Define
   METHOD Value       SETGET
   METHOD Events_Command
   METHOD Events_Color

   EMPTY( _OOHG_AllVars )
ENDCLASS

*-----------------------------------------------------------------------------*
METHOD Define( ControlName, ParentForm, x, y, Caption, Value, fontname, ;
               fontsize, tooltip, changeprocedure, w, h, lostfocus, gotfocus, ;
               HelpId, invisible, notabstop, bold, italic, underline, ;
               strikeout, field, backcolor, fontcolor, transparent, autosize, ;
               lRtl, lDisabled ) CLASS TCheckBox
*-----------------------------------------------------------------------------*
Local ControlHandle, nStyle, nStyleEx := 0

   ASSIGN ::nCol        VALUE x TYPE "N"
   ASSIGN ::nRow        VALUE y TYPE "N"
   ASSIGN ::nWidth      VALUE w TYPE "N"
   ASSIGN ::nHeight     VALUE h TYPE "N"
   ASSIGN ::Transparent VALUE transparent  TYPE "L"

   IF !HB_IsLogical( value )
      value := .F.
   ENDIF
   ASSIGN autosize      VALUE autosize TYPE "L" DEFAULT .F.

   IF ::Transparent .AND. OSisWinXPorLater()
      ::Transparent := .F.
   ENDIF

   ::SetForm( ControlName, ParentForm, FontName, FontSize, FontColor, BackColor,, lRtl )

   nStyle := ::InitStyle( ,, Invisible, NoTabStop, lDisabled ) + BS_AUTOCHECKBOX
   If ::Transparent
      nStyleEx += WS_EX_TRANSPARENT
   EndIf

   Controlhandle := InitCheckBox( ::ContainerhWnd, Caption, 0, ::ContainerCol, ::ContainerRow, '', 0 , ::nWidth, ::nHeight, nStyle, nStyleEx, ::lRtl )

   ::Register( ControlHandle, ControlName, HelpId,, ToolTip )
   ::SetFont( , , bold, italic, underline, strikeout )

   IF _OOHG_LastFrame() == "TABPAGE"
     ::TabHandle := ::Container:Container:hWnd
   ENDIF

   ::Autosize    := autosize
   ::Caption     := Caption

   ::SetVarBlock( Field, Value )

   ASSIGN ::OnLostFocus VALUE lostfocus TYPE "B"
   ASSIGN ::OnGotFocus  VALUE gotfocus  TYPE "B"
   ASSIGN ::OnChange    VALUE ChangeProcedure TYPE "B"

Return Self

*------------------------------------------------------------------------------*
METHOD Value( uValue ) CLASS TCheckBox
*------------------------------------------------------------------------------*
   IF HB_IsLogical( uValue )
      SendMessage( ::hWnd, BM_SETCHECK, if( uValue, BST_CHECKED, BST_UNCHECKED ), 0 )
      ::DoChange()
   ELSE
      uValue := ( SendMessage( ::hWnd, BM_GETCHECK , 0 , 0 ) == BST_CHECKED )
   ENDIF
RETURN uValue

*------------------------------------------------------------------------------*
METHOD Events_Command( wParam ) CLASS TCheckBox
*------------------------------------------------------------------------------*
Local Hi_wParam := HIWORD( wParam )
   If Hi_wParam == BN_CLICKED
      ::DoChange()
      Return nil
   EndIf
Return ::Super:Events_Command( wParam )





#pragma BEGINDUMP

#include "hbapi.h"
#include "hbvm.h"
#include "hbstack.h"
#include "hbapiitm.h"
#include <windows.h>
#include <commctrl.h>
#include "oohg.h"

static WNDPROC lpfnOldWndProc = 0;

static LRESULT APIENTRY SubClassFunc( HWND hWnd, UINT msg, WPARAM wParam, LPARAM lParam )
{
   return _OOHG_WndProcCtrl( hWnd, msg, wParam, lParam, lpfnOldWndProc );
}

HB_FUNC( INITCHECKBOX )
{
	HWND hwnd;
	HWND hbutton;
   int Style, StyleEx;

   hwnd = HWNDparam( 1 );

   Style = BS_NOTIFY | WS_CHILD | hb_parni( 10 );

   StyleEx = hb_parni( 11 ) | _OOHG_RTL_Status( hb_parl( 12 ) );

   hbutton = CreateWindowEx( StyleEx, "button" , hb_parc(2) ,
	Style ,
	hb_parni(4), hb_parni(5) , hb_parni(8), hb_parni(9) ,
	hwnd,(HMENU)hb_parni(3) , GetModuleHandle(NULL) , NULL ) ;

   lpfnOldWndProc = ( WNDPROC ) SetWindowLong( hbutton, GWL_WNDPROC, ( LONG ) SubClassFunc );

   HWNDret( hbutton );
}

HBRUSH GetTabBrush( HWND hWnd )
{
   HBRUSH hBrush;
   RECT rc;
   HDC hDC;
   HDC hDCMem;
   HBITMAP hBmp;
   HBITMAP hOldBmp;

   GetWindowRect( hWnd, &rc );
   hDC = GetDC( hWnd );
   hDCMem = CreateCompatibleDC( hDC );

   hBmp = CreateCompatibleBitmap( hDC, rc.right - rc.left, rc.bottom - rc.top );

   hOldBmp = (HBITMAP) SelectObject( hDCMem, hBmp );

   SendMessage( hWnd, WM_PRINTCLIENT, (WPARAM) hDCMem,  (LPARAM) PRF_ERASEBKGND | PRF_CLIENT | PRF_NONCLIENT );

   hBrush = CreatePatternBrush( hBmp );

   SelectObject( hDCMem, hOldBmp );

   DeleteObject( hBmp );
   DeleteDC( hDCMem );
   ReleaseDC( hWnd, hDC );
   
   return hBrush;
}

HB_FUNC_STATIC( TCHECKBOX_EVENTS_COLOR )   // METHOD Events_Color( wParam, nDefColor ) CLASS TControl
{
   PHB_ITEM pSelf = hb_stackSelfItem();
   POCTRL oSelf = _OOHG_GetControlInfo( pSelf );
   HDC hdc = ( HDC ) hb_parnl( 1 );
   LONG lBackColor;
   RECT rc;
   LPRECT lprc;

   if( oSelf->lFontColor != -1 )
   {
      SetTextColor( hdc, ( COLORREF ) oSelf->lFontColor );
   }

   _OOHG_Send( pSelf, s_Transparent );
   hb_vmSend( 0 );
   if( hb_parl( -1 ) )
   {
      SetBkMode( hdc, ( COLORREF ) TRANSPARENT );
      hb_retnl( ( LONG ) GetStockObject( NULL_BRUSH ) );
      return;
   }

   lBackColor = ( oSelf->lUseBackColor != -1 ) ? oSelf->lUseBackColor : oSelf->lBackColor;
   if( lBackColor == -1 )
   {
      lBackColor = hb_parnl( 2 );           // If is not into a TAB

      _OOHG_Send( pSelf, s_TabHandle );
      hb_vmSend( 0 );
      
      if( ValidHandler( HWNDparam( -1 ) ) )
      {
         DeleteObject( oSelf->BrushHandle );

         oSelf->BrushHandle = GetTabBrush( HWNDparam( -1 ) );

         SetBkMode( hdc, TRANSPARENT );

         GetWindowRect( oSelf->hWnd, &rc );
         lprc = &rc;
         MapWindowPoints( NULL, HWNDparam( -1 ), (LPPOINT) lprc, 2 );

         SetBrushOrgEx( hdc, -rc.left, -rc.top, NULL );

         hb_retnl( ( LONG ) oSelf->BrushHandle );
         return;
      }
   }

   SetBkColor( hdc, ( COLORREF ) lBackColor );
   if( lBackColor != oSelf->lOldBackColor )
   {
      oSelf->lOldBackColor = lBackColor;
      DeleteObject( oSelf->BrushHandle );
      oSelf->BrushHandle = CreateSolidBrush( lBackColor );
   }

   hb_retnl( ( LONG ) oSelf->BrushHandle );
}

#pragma ENDDUMP
