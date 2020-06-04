DeclareModule gradient
  ;-DECLARE GLOBAL
  Declare new(hwnd, gadget, posx, posy, tx, ty)
  Declare.i get_number_cursor(gadget)
  Declare FirstElement_cursor(gadget)
  Declare next_cursor()
  Declare previous_cursor()
  Declare.f get_cursor_position()
  Declare.b get_cursor_state()
  Declare.i get_cursor_color()
  Declare.b add_cursor(gadget, position.f, color.i, state = 1)
  Declare disable_gradient(gadget, state)
EndDeclareModule

Module gradient
  ;-DECLARE PRIVATE
  Declare draw(gadget)
  Declare manage_event()
  
  Enumeration 1
    #cursor_color
    #cursor_state
    #add_cursor
    #move_cursor
  EndEnumeration
  
  Enumeration 65536
    #pb_event_gradient  
  EndEnumeration
  
  Structure _cursor   ;cursor structure
    position.f
    color.i
    active.b
  EndStructure
  
  Structure _gradient
    hwnd.i
    state.b
    List cursor._cursor()   ;List containing cursor
  EndStructure
  
  Global NewList gradient_gadget._gradient()   ;list containing object gradient
  Global *cursor_selection
  Global event_status.i
  Global event_move.b
  Global event_wheel.b
  
  Macro Red(color)
    color & $FF
  EndMacro
  Macro Green(color)
    color >> 8 & $FF  
  EndMacro
  Macro Blue(color)
    color >> 16 & $FF
  EndMacro
  Macro Alpha(color)
    color >> 24 & $FF
  EndMacro
    
  Procedure new(hwnd, gadget, posx, posy, sx, sy)         ;creating gradient gadget
    Protected ret.i
    AddElement(gradient_gadget()) ; add a gradient gadget
    ret = CanvasGadget(gadget, posx, posy, sx, sy, #PB_Canvas_Keyboard)
    If gadget = #PB_Any : gadget = ret: EndIf
    SetGadgetData(gadget, @gradient_gadget())   ;we store the address of the current element of the list in the canvas gadget
    gradient_gadget()\hwnd = hwnd
    gradient_gadget()\state = 1
    AddElement(gradient_gadget()\cursor())       ;add a cursor for the position zero. Initial cursor
    gradient_gadget()\cursor()\position = 0.0
    gradient_gadget()\cursor()\color = RGBA(255, 255, 255, 255)
    gradient_gadget()\cursor()\active = 1
    *cursor_selection = @gradient_gadget()\cursor()
    BindEvent(#PB_Event_Gadget, @manage_event(), hwnd, gadget)
    draw(gadget)
    ProcedureReturn gadget 
  EndProcedure
  
  Procedure disable_gradient(gadget, state)
    ChangeCurrentElement(gradient_gadget(),GetGadgetData(gadget))
    gradient_gadget()\state = 1!state
    DisableGadget(gadget, state)
  EndProcedure
  
  Procedure.b add_cursor(gadget, position.f, color.i, state = 1)
    If IsGadget(gadget)
      ChangeCurrentElement( gradient_gadget(), GetGadgetData(gadget) )
      AddElement( gradient_gadget()\cursor() )
      gradient_gadget()\cursor()\active = state
      gradient_gadget()\cursor()\position = position
      gradient_gadget()\cursor()\color = color
      draw(gadget)
      ProcedureReturn #True
    EndIf
    ProcedureReturn #False
  EndProcedure
  
  Procedure.b get_cursor_state()
    ProcedureReturn gradient_gadget()\cursor()\active  
  EndProcedure
  
  Procedure.f get_cursor_position()
    ProcedureReturn gradient_gadget()\cursor()\position
  EndProcedure
  
  Procedure.i get_cursor_color()
    ProcedureReturn gradient_gadget()\cursor()\color
  EndProcedure
  
  Procedure.i get_number_cursor(gadget)
    ChangeCurrentElement( gradient_gadget(), GetGadgetData(gadget) )
    ProcedureReturn ListSize( gradient_gadget()\cursor() )
  EndProcedure
  
  Procedure FirstElement_cursor(gadget)
    ChangeCurrentElement( gradient_gadget(), GetGadgetData(gadget) )
    FirstElement( gradient_gadget()\cursor() )  
  EndProcedure
  
  Procedure next_cursor()
    NextElement( gradient_gadget()\cursor() )
  EndProcedure
  
  Procedure previous_cursor()
    PreviousElement( gradient_gadget()\cursor() )
  EndProcedure
  
  Procedure draw(gadget)
    SortStructuredList( gradient_gadget()\cursor(), #PB_Sort_Ascending, OffsetOf(_cursor\position), TypeOf(_cursor\position) )
    Protected sx, sy, posx, posy
    sx = GadgetWidth(gadget)
    sy = GadgetHeight(gadget)
    StartDrawing( CanvasOutput(gadget) )
    Box(0, 0, sx, sy, RGB(220, 220, 220) )
    Box(1, 1, sx - 2, sy - 2, RGB(255, 255, 255) )
    Box(5, 0, sx - 10, sy - 30, RGB(0, 0, 0) )
    pas = 7
    For y = 1 To sy - 31
      For x = 6 To sx - 7
        If invert
          color = RGB(255, 255, 255)
        Else
          color = RGB(180, 180, 180)
        EndIf
        wbox = pas
        hbox = pas
        If x + pas >= sx - 7
          wbox = (sx - 6) - x
        EndIf
        If y + pas >= sy - 31
          hbox = (sy - 31) - y
        EndIf
        Box(x, y, wbox, hbox, color)
        invert = 1!invert
        x + pas - 1
      Next
      y + pas - 1
      ;invert = 1!invert
    Next
    
    DrawingMode(#PB_2DDrawing_Gradient|#PB_2DDrawing_AlphaBlend)
    FirstElement(gradient_gadget()\cursor())
    With gradient_gadget()
      For k = 0 To ListSize( \cursor() ) - 1
        Select k
          Case 0
            BackColor( \cursor()\color )
            FrontColor( \cursor()\color )
          Default
            If \cursor()\active
              ;               If Alpha(\cursor()\color) = 0
              ;                 Repeat
              ;                   PreviousElement(\cursor())  
              ;                 Until \cursor()\actif = 1
              ;                 color = RGBA(Red(\cursor()\color),Green(\cursor()\color),Blue(\cursor()\color),0)
              ;                 Repeat
              ;                   NextElement(\cursor())  
              ;                 Until \cursor()\actif = 1 
              ;                 GradientColor(\cursor()\position,color)
              ;                 FrontColor(\cursor()\color)
              ;               Else
              GradientColor( \cursor()\position, \cursor()\color )
              FrontColor( \cursor()\color )  
              ;               EndIf
            EndIf
        EndSelect
        NextElement( \cursor() )
      Next k  
    EndWith
    LinearGradient(6, 0, sx - 6, 0)
    Box(6, 1, sx - 12, sy - 32)
    ;-DRAW CURSORS
    DrawingMode(#PB_2DDrawing_Default)
    ForEach gradient_gadget()\cursor()
      posx = ( GadgetWidth(gadget) - 12 ) * gradient_gadget()\cursor()\position + 6
      posy = GadgetHeight(gadget) - 30
      If @gradient_gadget()\cursor() = *cursor_selection  : color = RGB(200, 200, 200) : EndIf
      If @gradient_gadget()\cursor() <> *cursor_selection : color = RGB(0, 0, 0)       : EndIf
      For u = 0 To 5
        Line(posx - u, posy + u + 1, (u * 2) + 1, 1, color)
      Next
      LineXY(posx - 5, posy + 6, posx, posy, RGB(0, 0, 0) )
      LineXY(posx, posy, posx + 5, posy + 6, RGB(0, 0, 0) )
      Box(posx - 5, posy + 6, 11, 12, 0)
      Box(posx - 4, posy + 7, 9, 10, gradient_gadget()\cursor()\color )
      Circle(posx, posy + 23, 4, RGB(0, 0, 0) )
      Circle(posx, posy + 23, 3, gradient_gadget()\cursor()\color )
      If gradient_gadget()\cursor()\active = 0
        Circle(posx, posy + 23, 3, RGB(50, 50, 50) )
        Line(posx - 5, posy + 23, 11 ,1, RGB(255, 20, 20) )
        Line(posx - 5, posy + 24, 11 ,1, RGB(255, 20, 20) )
      EndIf
    Next
    ;draw info text
    If event_wheel > 0
      ChangeCurrentElement(gradient_gadget()\cursor(), *cursor_selection)
      alpha$ = Str( Alpha(gradient_gadget()\cursor()\color) )
      posx = ( (GadgetWidth(gadget) - 12) * gradient_gadget()\cursor()\position + 6 ) - TextWidth(alpha$) / 2
      If posx < 6
        posx = 6
      EndIf
      If posx > sx - TextWidth(alpha$)
        posx = sx - TextWidth(alpha$)
      EndIf
      DrawText(posx, sy - 50, Alpha$, RGB(0, 0, 0), RGB(255, 255, 255) )
      event_wheel = 0
    EndIf
    
    If 1!gradient_gadget()\state
      DrawingMode(#PB_2DDrawing_AlphaBlend)
      Box(0, 0, sx, sy, RGBA(125, 125, 125, 125) )
    EndIf
    StopDrawing()
    PostEvent(#PB_Event_Gadget, gradient_gadget()\hwnd, gadget, #pb_event_gradient)
  EndProcedure
  
  Procedure mouse_info(gadget, mousex, mousey)
    Protected sx, posy_cursor, posx_cursor
    sx = GadgetWidth(gadget) - 12
    posy_cursor = GadgetHeight(gadget) - 30
    event_status = -1
    If mousey > posy_cursor
      event_status = #add_cursor
      LastElement( gradient_gadget()\cursor() )
      For elem = 0 To ListSize( gradient_gadget()\cursor() ) - 1
        With gradient_gadget()\cursor()
          posx_cursor = (\position * sx) + 6
          If mousex > posx_cursor - 6 And MouseX < posx_cursor + 6
            If mousey > posy_cursor And mousey < posy_cursor + 17
              event_status = #cursor_color
              SetGadgetAttribute(gadget, #PB_Canvas_Cursor, #PB_Cursor_Hand)
              ProcedureReturn gradient_gadget()\cursor()
            EndIf
            distance = Pow( (posx_cursor - mousex),2) + Pow(((posy_cursor + 23) - mousey), 2 )
            If distance <= 4*4
              If ListIndex(gradient_gadget()\cursor()) > 0
                SetGadgetAttribute(gadget, #PB_Canvas_Cursor, #PB_Cursor_Hand)
                event_status = #cursor_state
                ProcedureReturn gradient_gadget()\cursor()
              EndIf
            EndIf
            SetGadgetAttribute(gadget, #PB_Canvas_Cursor, #PB_Cursor_Default)
            event_status = 0
            ProcedureReturn -1
          EndIf
        EndWith        
        PreviousElement( gradient_gadget()\cursor() )  
      Next elem
      If event_move = 0
        SetGadgetAttribute(gadget, #PB_Canvas_Cursor, #PB_Cursor_Cross)
      EndIf
      ProcedureReturn -1
    EndIf
    SetGadgetAttribute(gadget, #PB_Canvas_Cursor, #PB_Cursor_Default)
    ProcedureReturn -1
  EndProcedure
  
  Procedure manage_event()
    Protected gadget, tevent, mousex, mousey, mouse_info
    gadget = EventGadget()
    tevent = EventType()
    ChangeCurrentElement(gradient_gadget(), GetGadgetData(gadget))
    ;If gradient_gadget()\state
    mousex = GetGadgetAttribute(gadget, #PB_Canvas_MouseX)
    mousey = GetGadgetAttribute(gadget, #PB_Canvas_MouseY)
    mouse_info = mouse_info(gadget, mousex, mousey)
    Select tevent
      Case #PB_EventType_RightClick
        If event_status = #cursor_color
          If ListIndex(gradient_gadget()\cursor()) > 0
            DeleteElement(gradient_gadget()\cursor())
            *cursor_selection = -1
            draw(gadget)
          EndIf
        EndIf
      Case #PB_EventType_LeftDoubleClick
        If event_status = #cursor_color
          ChangeCurrentElement(gradient_gadget()\cursor(), *cursor_selection)
          posx_cursor = (GadgetWidth(gadget) - 12) * gradient_gadget()\cursor()\position + 6
          mem_alpha = Alpha(gradient_gadget()\cursor()\color)
          StartDrawing( CanvasOutput(gadget) )
          color_request = Point(posx_cursor, 5)
          StopDrawing()
          color = ColorRequester(color_request)
          If color > -1
            color = RGBA(Red(color), Green(color), Blue(color), mem_alpha)
            ChangeCurrentElement(gradient_gadget()\cursor(), *cursor_selection)
            gradient_gadget()\cursor()\color = color
            draw(gadget)
          EndIf
        EndIf
      Case #PB_EventType_LeftButtonUp
        event_status = -1
        event_move = 0
      Case #PB_EventType_LeftButtonDown
        modifiers = GetGadgetAttribute(gadget, #PB_Canvas_Modifiers)
        If modifiers=#PB_Canvas_Control Or modifiers = #PB_Canvas_Alt Or modifiers = #PB_Canvas_Shift
          If *cursor_selection > -1 And mouse_info > -1 And *cursor_selection <> mouse_info
            ChangeCurrentElement(gradient_gadget()\cursor(), *cursor_selection)
            color1 = gradient_gadget()\cursor()\color
            ChangeCurrentElement(gradient_gadget()\cursor(), mouse_info)
            color2 = gradient_gadget()\cursor()\color
            If modifiers = #PB_Canvas_Control
              gradient_gadget()\cursor()\color = color1
            EndIf
            If modifiers = #PB_Canvas_Alt
              gradient_gadget()\cursor()\color = color1
              ChangeCurrentElement(gradient_gadget()\cursor(), *cursor_selection)
              gradient_gadget()\cursor()\color = color2
            EndIf
            If modifiers = #PB_Canvas_Shift
              ChangeCurrentElement(gradient_gadget()\cursor(), *cursor_selection)
              gradient_gadget()\cursor()\color = color2  
            EndIf
            draw(gadget)
          EndIf
        Else
          *cursor_selection = mouse_info
          Select event_status
            Case #add_cursor
              If mousex > 5
                AddElement(gradient_gadget()\cursor())
                gradient_gadget()\cursor()\position = mousex / (GadgetWidth(gadget) - 2)
                gradient_gadget()\cursor()\active = 1
                *cursor_selection = gradient_gadget()\cursor()
                StartDrawing( CanvasOutput(gadget) )
                color = Point(mousex, 10)
                gradient_gadget()\cursor()\color = RGBA(Red(color), Green(color), Blue(color), 255)
                StopDrawing()
                draw(gadget)
              EndIf
            Case #cursor_color, #cursor_state
              If mouse_info > -1
                ChangeCurrentElement(gradient_gadget()\cursor(), *cursor_selection)                
                If event_status = #cursor_color : event_move = 1 : EndIf
                If event_status = #cursor_state
                  gradient_gadget()\cursor()\active!1
                  event_move = 0
                EndIf
                draw(gadget)
              EndIf    
          EndSelect
        EndIf
      Case #PB_EventType_MouseMove
        If GetGadgetAttribute(gadget, #PB_Canvas_Buttons) = #PB_Canvas_LeftButton And *cursor_selection > -1 And event_move
          ChangeCurrentElement(gradient_gadget()\cursor(), *cursor_selection)
          If ListIndex(gradient_gadget()\cursor()) > 0
            position_cursor.f = (mousex-6) / (GadgetWidth(gadget) - 12)
            If position_cursor > 1.0
              position_cursor = 1.0
            EndIf
            If position_cursor < 0.001
              position_cursor = 0.001
            EndIf
            gradient_gadget()\cursor()\position = position_cursor
            draw(gadget)
          EndIf
        EndIf
      Case #PB_EventType_MouseWheel
        If event_status = #cursor_color Or event_status = #cursor_state
          event_wheel = 1
          *cursor_selection = mouse_info
          ChangeCurrentElement(gradient_gadget()\cursor(), *cursor_selection)
          wm = GetGadgetAttribute(gadget, #PB_Canvas_WheelDelta)
          If GetGadgetAttribute(gadget, #PB_Canvas_Modifiers) = #PB_Canvas_Shift
            wm * 10
          EndIf
          With gradient_gadget()\cursor()
            niv_alpha = Alpha(\color) + wm
            If niv_alpha > 255 : niv_alpha = 255 : EndIf
            If niv_alpha < 0    : niv_alpha = 0   : EndIf
            \color = RGBA(Red(\color), Green(\color), Blue(\color), niv_alpha)
          EndWith
          draw(gadget)
        EndIf
    EndSelect
    ;EndIf
  EndProcedure
  
EndModule

; IDE Options = PureBasic 5.72 (Windows - x64)
; CursorPosition = 214
; FirstLine = 315
; Folding = ----
; EnableXP