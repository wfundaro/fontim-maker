;****************************************************
;*                                                  *
;*              FONTIM MAKER 1.0.0.0                *
;*                                                  *
;*                    2020 kws                      *
;****************************************************


IncludeFile "src\module_gadget_gradient.pbi"
IncludeFile "src\declaration.pbi"
IncludeFile "src\interface_fm.pbi"
IncludeFile "src\proc.pbi"

scan_file_language() ; on récupère la liste des fichiers langue .lng
OpenWindow_0()     ;ouverture de la fenetre principale
initialisation_bind_event()     ;initialisation des event pour certain gadget
load_template()
SysInfo_Fonts()
load_preference()
initialisation_interface()
change_background_color(1)
init_canvas() ;on dessine le canvas avec la première font système
init_transparent_background_image()

;MAIN LOOP
Repeat  
  event = WaitWindowEvent()  
  mevent = EventMenu()
  tevent = EventType()
  gevent = EventGadget()
  
  Select event
    Case #PB_Event_Menu
      Select mevent
        Case #menu_zoom_reset
          zoom_reset()
        Case #Menu_save
          
        Case #menu_save_as
          
        Case #Menu_quit
          End
        Case #shortcut_add ;if ctrl + add we increase the font size
          calcul_size_font_view(1)
        Case #shortcut_sustract ;if ctrl + substract we decrease the font size
          calcul_size_font_view(-1) 
      EndSelect
    Case #PB_Event_Gadget
      Select gevent
        Case #canvas_character_view
          ;{ event sur affichage caratère
          redraw = 0
          mouse_x = GetGadgetAttribute(#canvas_character_view,#PB_Canvas_MouseX)
          mouse_y = GetGadgetAttribute(#canvas_character_view,#PB_Canvas_MouseY)
          tx_canvas = GadgetWidth(#canvas_character_view)
          ty_canvas = GadgetHeight(#canvas_character_view)
          num_char = get_char_code(mouse_x, mouse_y)
          If tevent = #PB_EventType_LeftButtonDown
            If character(num_char)\selected = 0
              character(num_char)\selected = 1
              mode = 1
            Else
              character(num_char)\selected = 0
              mode = 0
            EndIf
            redraw = 1
          EndIf
          If tevent = #PB_EventType_MouseMove
            Select GetGadgetAttribute(#canvas_character_view, #PB_Canvas_Buttons)
              Case #PB_Canvas_LeftButton            
                character(num_char)\selected = mode
                redraw = 1
              Case #PB_Canvas_MiddleButton
                If zoom\zoom>1.0
                  zoom\posx = (mouse_x / zoom\zoom) - x
                  zoom\posy = (mouse_y / zoom\zoom) - y
                  redraw = 1
                EndIf
            EndSelect
          EndIf
          If tevent = #PB_EventType_MouseWheel
            x = get_convert_position_x(mouse_x)
            y = get_convert_position_y(mouse_y)
            zoom\zoom = zoom\zoom + (GetGadgetAttribute(#canvas_character_view,#PB_Canvas_WheelDelta)/5)
            zoom\posx = (mouse_x / zoom\zoom) - x
            zoom\posy = (mouse_y / zoom\zoom) - y
            If tx_canvas > ty_canvas
              rapport.f = ty_canvas / 640
            Else
              rapport.f = tx_canvas / 480
            EndIf
            If zoom\zoom < rapport
              zoom\zoom = rapport
              zoom\posx = 0
              zoom\posy = 0
            EndIf
            redraw = 1
          EndIf
          If tevent = #PB_EventType_MiddleButtonDown And GetGadgetAttribute(#canvas_character_view,#PB_Canvas_Buttons)& #PB_Canvas_MiddleButton
            If GetGadgetAttribute(#canvas_character_view,#PB_Canvas_Modifiers)& #PB_Canvas_Alt
              zoom_reset()
              redraw = 1
            EndIf
            If GetGadgetAttribute(#canvas_character_view,#PB_Canvas_Modifiers)& #PB_Canvas_Control
              x = getLine(mouse_x)
              y = getColumn(mouse_y)
              If tx_canvas > ty_canvas
                rapport.f = ty_canvas / 640
              Else
                rapport.f = tx_canvas / 480
              EndIf
              If zoom\zoom = rapport*16.0
                zoom\zoom = zoom\memo_zoom
                zoom\posx = zoom\memo_x
                zoom\posy = zoom\memo_y
              Else
                zoom\memo_zoom = zoom\zoom
                zoom\memo_x = zoom\posx
                zoom\memo_y = zoom\posy
                zoom\zoom = rapport*16.0
                zoom\posx = -#CELL_WIDTH*x - 0.5
                zoom\posy = -#CELL_HEIGHT*y - 0.5
              EndIf
              redraw = 1
            EndIf           
            x = get_convert_position_x(mouse_x)
            y = get_convert_position_y(mouse_y)
            zoom\memo_mousex = GetGadgetAttribute(#canvas_character_view,#PB_Canvas_MouseX)
            zoom\memo_mousey = GetGadgetAttribute(#canvas_character_view,#PB_Canvas_MouseY)
          EndIf
          If zoom\posx < -16 * #CELL_WIDTH + tx_canvas/zoom\zoom
            zoom\posx = -16 * #CELL_WIDTH + tx_canvas/zoom\zoom
          EndIf
          If zoom\posy < -16 * #CELL_HEIGHT + ty_canvas/zoom\zoom
            zoom\posy = -16 * #CELL_HEIGHT + ty_canvas/zoom\zoom
          EndIf
          If zoom\posx>0
            zoom\posx=0
          EndIf
          If zoom\posy>0
            zoom\posy = 0
          EndIf
          If redraw = 1
            calcul_size_font_view(0)
            draw_canvas()
          EndIf
          ;}
        Case #entry_font_size
          global_character\size = Val(GetGadgetText(#entry_font_size))
        Case #Combo_font
          calcul_size_font_view(0)
        Case #button_background_color_select
          change_background_color()
        Case #view_background_color
          Select tevent
            Case #PB_EventType_LeftDoubleClick
              change_background_color()
            Case #PB_EventType_RightDoubleClick
              change_background_color(1)
          EndSelect
        Case #gradient_color, #gradient_outline
          If tevent = #pb_event_gradient
            event_gadget(gevent)
          EndIf
        Case #spin_posx_color_circular_gradient, #spin_posy_color_circular_gradient, #spin_size_outline,
             #spin_radius_circular_gradient, #Spin_posx_color_linear_gradient, #Spin_posy_color_linear_gradient,
             #spin_scale_linear_gradient, #Spin_offset_x_outline, #Spin_offset_y_outline,
             #Spin_scale_gradient_outline, #Spin_posx_circular_gradient_outline, #Spin_posy_circular_gradient_outline,
             #Spin_radius_gradient_outline, #Entry_angle_outline, #Entry_alpha_outline, #Entry_angle_color,
             #Entry_alpha_color, #option_gradient_linear, #option_gradient_circular
          If tevent = #PB_EventType_Change
            event_gadget(gevent)
          EndIf
        Case #check_outline_active, #check_outline_over, #check_bold, #check_italic ,
             #check_underline, #spin_offset_x, #spin_offset_y, #track_angle_outline, #Track_alpha_outline,
             #Track_angle_color, #Track_alpha_color
          event_gadget(gevent)
        Case #Button_save_template
          save_template()
        Case #button_add_template
          add_template()
        Case #button_delete_template
          delete_template()
        Case #Combo_template
          If tevent = #PB_EventType_Change
            update_template()
            save_preference()
          EndIf
        Case #check_file_name_text
          If GetGadgetState(#check_file_name_text) = #PB_Checkbox_Checked
            DisableGadget(#entry_file_name_text,1)
          Else
            DisableGadget(#entry_file_name_text,0)
          EndIf
        Case #option_image_export_multiple
          DisableGadget(#Check_export_character_name,0)
          DisableGadget(#check_export_counter_name,0)     
        Case #option_image_export_single
          DisableGadget(#Check_export_character_name,1)
          DisableGadget(#check_export_counter_name,1) 
        Case #check_auto_size
          If GetGadgetState(#check_auto_size)
            DisableGadget(#entry_export_size_x_image,1)
            DisableGadget(#Entry_export_size_y_image,1)
          Else
            DisableGadget(#Entry_export_size_x_image,0)
            DisableGadget(#Entry_export_size_y_image,0)
          EndIf
        Case #button_visualization
          open_visualization(image_creation())          
      EndSelect
  EndSelect  
Until event = #PB_Event_CloseWindow
; IDE Options = PureBasic 5.72 (Windows - x64)
; CursorPosition = 134
; FirstLine = 30
; Folding = -
; EnableXP