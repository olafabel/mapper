#NoTrayIcon
#include <GUIConstantsEx.au3>
;#include <AutoItConstants.au3>

Opt( "MustDeclareVars" , 1 )

Dim $Color_Red    = 0xff0000
Dim $Color_Green  = 0x00ff00
Dim $Color_Blue   = 0x0000ff
Dim $Color_Yellow = 0xffff00

Dim $Button[2]
Dim $ButtonMount[2]
Dim $ButtonUmount[2]
Dim $ButtonColor[2]
Dim $ButtonPColor[2]

Dim $DieMapperIniDatei, $DieInfo, $DieSektions, $DieAnzahlMaps
Dim $idx, $Server, $Resource, $Drive, $Enabled, $User, $Password
Dim $ButtonRefresh, $msg, $TimeBegin, $TimeDiff, $TimeTest
Dim $size, $CordX, $CordY, $PingTimeout
Dim $ButtonMountAll, $ButtonUmountAll

$CordX = -1
$CordY = -1

$DieMapperIniDatei = @ScriptDir & "\" & "mapper.ini"

$DieInfo   = "Mapper 2019.01.26"
$TimeTest  = 3000 ; Vorbelegung
$TimeBegin = TimerInit()

While 1
   If FileExists( $DieMapperIniDatei ) Then
      $DieSektions = IniReadSectionNames( $DieMapperIniDatei )
      $DieAnzahlMaps = $DieSektions[0]
   Else
      $DieAnzahlMaps = 0
   EndIf

   If $DieAnzahlMaps < 2 Then
      MsgBox(0, $DieInfo, "Keine Einträge in " & $DieMapperIniDatei & " vorhanden!" )
      Exit
   EndIf

   ReDim $Button[$DieAnzahlMaps + 2]
   ReDim $ButtonMount[$DieAnzahlMaps + 2]
   ReDim $ButtonUmount[$DieAnzahlMaps + 2]
   ReDim $ButtonPColor[$DieAnzahlMaps + 2]
   ReDim $ButtonColor[$DieAnzahlMaps + 2]

   $CordX    = IniRead( $DieMapperIniDatei, "Global", "PosX",   "-1" )
   $CordY    = IniRead( $DieMapperIniDatei, "Global", "PosY",   "-1" )
   $TimeTest = IniRead( $DieMapperIniDatei, "Global", "CheckTimeout", "3000" )

   GUICreate($DieInfo, 500, 15 + (( $DieAnzahlMaps - 1 + 1) * 30), $CordX, $CordY  )
   GUISetIcon("shell32.dll", 10)

   For $idx = 2 To $DieAnzahlMaps
      $Server      = IniRead( $DieMapperIniDatei, $idx - 1, "Server",   "" )
      $Resource    = IniRead( $DieMapperIniDatei, $idx - 1, "Resource", "" )
      $Drive       = IniRead( $DieMapperIniDatei, $idx - 1, "Drive",    "" )
      $Enabled     = IniRead( $DieMapperIniDatei, $idx - 1, "Enabled",  "True" )
      $PingTimeout = IniRead( $DieMapperIniDatei, $idx - 1, "PingTimeout", 0 )
      $User        = IniRead( $DieMapperIniDatei, $idx - 1, "User ",    "default" )
      $Password    = IniRead( $DieMapperIniDatei, $idx - 1, "Password", "default" )

      If $PingTimeout = 0 Then
         $ButtonColor[$idx] = GUICtrlCreateButton( "", 10, 10 + (($idx - 2) * 30), 10, 25 )
         $Button[$idx]      = GUICtrlCreateButton( $User & " @ \\" & $Server & "\" & $Resource & " -> " & $Drive & ":\", 10+15, 10 + (($idx - 2) * 30), 370-15, 25 )

         GUICtrlSetState($ButtonColor[$idx], $GUI_DISABLE)
      Else
         $ButtonPColor[$idx] = GUICtrlCreateButton( "", 10, 10 + (($idx - 2) * 30), 10, 25 )
         $ButtonColor[$idx]  = GUICtrlCreateButton( "", 25, 10 + (($idx - 2) * 30), 10, 25 )
         $Button[$idx]       = GUICtrlCreateButton( $User & " @ \\" & $Server & "\" & $Resource & " -> " & $Drive & ":\", 10+30, 10 + (($idx - 2) * 30), 370-15-15, 25 )

         GUICtrlSetState($ButtonPColor[$idx], $GUI_DISABLE)
         GUICtrlSetState($ButtonColor[$idx],  $GUI_DISABLE)
      EndIf

      If $PingTimeout > 0 Then
         $Server = IniRead( $DieMapperIniDatei, $idx - 1, "Server", "" )

         If $Server<> "" Then
            GUICtrlSetBkColor( $ButtonPColor[$idx], $Color_Yellow) ; Yellow
            If Ping($Server, $PingTimeout) = 0 Then
               GUICtrlSetBkColor( $ButtonPColor[$idx], $Color_Red) ; Red
            Else
               GUICtrlSetBkColor( $ButtonPColor[$idx], $Color_Green) ; Green
            EndIf
         EndIf
      EndIf

      If DriveMapGet($Drive & ":") = "" Then
         GUICtrlSetBkColor( $ButtonColor[$idx], $Color_Red) ; Red
         ;GUICtrlSetBkColor( $ButtonColor[$idx], $Color_Blue) ; Blue
      Else
         GUICtrlSetBkColor( $ButtonColor[$idx], $Color_Green) ; Green
      EndIf

      $ButtonMount[$idx]  = GUICtrlCreateButton( "Add " & $Drive & ":\",  385, 10 + (($idx - 2) * 30), 50, 25 )
      $ButtonUmount[$idx] = GUICtrlCreateButton( "Del " & $Drive & ":\", 440, 10 + (($idx - 2) * 30), 50, 25 )

      If StringUpper($Enabled) = "FALSE" Then
         GUICtrlSetState($ButtonMount[$idx],  $GUI_DISABLE)
         GUICtrlSetState($ButtonUmount[$idx], $GUI_DISABLE)
      EndIf

   Next

   $ButtonRefresh   = GUICtrlCreateButton( "Refresh", 10, 10 + (($idx - 2) * 30), 370, 25 )
   $ButtonMountAll  = GUICtrlCreateButton( "Add all",  385, 10 + (($idx - 2) * 30), 50, 25 )
   $ButtonUmountAll = GUICtrlCreateButton( "Del all", 440, 10 + (($idx - 2) * 30), 50, 25 )

   GUISetState()

   While 1
      $msg = GUIGetMsg()

      If $msg = 0 or $msg = -11 Then
         ContinueLoop 
      EndIf      

      ;ConsoleWrite("msg = " & $msg & @CRLF)

      $TimeDiff = TimerDiff($TimeBegin)

      If $TimeDiff > $TimeTest Then

         For $idx = 2 To $DieAnzahlMaps

            $PingTimeout = IniRead( $DieMapperIniDatei, $idx - 1, "PingTimeout", 0 )

            If $PingTimeout > 0 Then
               $Server = IniRead( $DieMapperIniDatei, $idx - 1, "Server", "" )

               If $Server<> "" Then
                  GUICtrlSetBkColor( $ButtonPColor[$idx], $Color_Yellow) ; Yellow
                  If Ping($Server, $PingTimeout) = 0 Then
                     GUICtrlSetBkColor( $ButtonPColor[$idx], $Color_Red) ; Red
                  Else
                     GUICtrlSetBkColor( $ButtonPColor[$idx], $Color_Green) ; Green
                  EndIf
               EndIf
            EndIf

            $Drive = IniRead( $DieMapperIniDatei, $idx - 1, "Drive", "" )

            If DriveMapGet($Drive & ":") = "" Then
               GUICtrlSetBkColor( $ButtonColor[$idx], $Color_Red) ; Red
               ;GUICtrlSetBkColor( $ButtonColor[$idx], $Color_Blue) ; Blue
            Else
               GUICtrlSetBkColor( $ButtonColor[$idx], $Color_Green) ; Green
            EndIf
         Next

         $TimeBegin = TimerInit()
      EndIf
      

      If $msg = $GUI_EVENT_CLOSE Then
         $size  = WinGetPos($DieInfo)
         $CordX = $size[0]
         $CordY = $size[1]

         IniWrite( $DieMapperIniDatei, "Global", "PosX", $CordX )
         IniWrite( $DieMapperIniDatei, "Global", "PosY", $CordY )

         Exit(0)
      EndIf

      If $msg = $ButtonRefresh Then
         $size  = WinGetPos($DieInfo)
         $CordX = $size[0]
         $CordY = $size[1]

         IniWrite( $DieMapperIniDatei, "Global", "PosX", $CordX )
         IniWrite( $DieMapperIniDatei, "Global", "PosY", $CordY )

         ExitLoop
      EndIf

      If $msg = $ButtonMountAll Then
         For $idx = 2 To $DieAnzahlMaps
            $Server   = IniRead( $DieMapperIniDatei, $idx - 1, "Server",   "default" )
            $Resource = IniRead( $DieMapperIniDatei, $idx - 1, "Resource", "default" )
            $Drive    = IniRead( $DieMapperIniDatei, $idx - 1, "Drive",    "default" )
            $User     = IniRead( $DieMapperIniDatei, $idx - 1, "User ",    "default" )
            $Password = IniRead( $DieMapperIniDatei, $idx - 1, "Password",    "default" )
            GUICtrlSetBkColor( $ButtonColor[$idx], $Color_Yellow)
            DriveMapAdd($Drive & ":", "\\" & $Server & "\" & $Resource, 0, $User, $Password)

            If DriveMapGet($Drive & ":") = "" Then
               GUICtrlSetBkColor( $ButtonColor[$idx], $Color_Red) ; Red
            Else
               GUICtrlSetBkColor( $ButtonColor[$idx], $Color_Green) ; Green
            EndIf
         Next
         ;ExitLoop
      EndIf

      If $msg = $ButtonUmountAll Then
         For $idx = 2 To $DieAnzahlMaps
            $Drive    = IniRead( $DieMapperIniDatei, $idx - 1, "Drive",    "default" )
            GUICtrlSetBkColor( $ButtonColor[$idx], $Color_Yellow)
            DriveMapDel($Drive & ":")

            If DriveMapGet($Drive & ":") = "" Then
               GUICtrlSetBkColor( $ButtonColor[$idx], $Color_Red) ; Red
            Else
               GUICtrlSetBkColor( $ButtonColor[$idx], $Color_Green) ; Green
            EndIf
         Next
         ;ExitLoop
      EndIf

      For $idx = 2 To $DieAnzahlMaps

         If $msg = $ButtonMount[$idx] Then
            $Server   = IniRead( $DieMapperIniDatei, $idx - 1, "Server",   "default" )
            $Resource = IniRead( $DieMapperIniDatei, $idx - 1, "Resource", "default" )
            $Drive    = IniRead( $DieMapperIniDatei, $idx - 1, "Drive",    "default" )
            $User     = IniRead( $DieMapperIniDatei, $idx - 1, "User ",    "default" )
            $Password = IniRead( $DieMapperIniDatei, $idx - 1, "Password",    "default" )
            GUICtrlSetBkColor( $ButtonColor[$idx], $Color_Yellow)
            DriveMapAdd($Drive & ":", "\\" & $Server & "\" & $Resource, 0, $User, $Password)

            If DriveMapGet($Drive & ":") = "" Then
               GUICtrlSetBkColor( $ButtonColor[$idx], $Color_Red) ; Red
            Else
               GUICtrlSetBkColor( $ButtonColor[$idx], $Color_Green) ; Green
            EndIf

         EndIf

         If $msg = $ButtonUmount[$idx] Then
            $Drive    = IniRead( $DieMapperIniDatei, $idx - 1, "Drive",    "default" )
            GUICtrlSetBkColor( $ButtonColor[$idx], $Color_Yellow)
            DriveMapDel($Drive & ":")

            If DriveMapGet($Drive & ":") = "" Then
               GUICtrlSetBkColor( $ButtonColor[$idx], $Color_Red) ; Red
            Else
               GUICtrlSetBkColor( $ButtonColor[$idx], $Color_Green) ; Green
            EndIf
         EndIf
      Next

   WEnd

   GUIDelete()

WEnd
