﻿Enumeration FormWindow
  #Window_0
EndEnumeration

Enumeration FormMenu
  #menu
  #menu_load
  #menu_save
  #menu_save_as
  #menu_quit
  #menu_zoom_reset
  #menu_help
  #menu_about

    ;-ShortCut
  #shortcut_add
  #shortcut_sustract
  
  ; language menu last because updated according to the files found
  #menu_language
  
EndEnumeration

Enumeration FormGadget
  #frame_background_color
  #view_background_color
  #button_background_color_select
  #label_font_size_view
  #canvas_character_view
  #panel_font
  #Combo_font
  #entry_font_size
  #label_font_size
  #check_bold
  #check_italic
  #check_underline
  #spin_offset_x
  #label_font_offset
  #spin_offset_y
  #option_gradient_linear
  #option_gradient_circular
  #spin_scale_linear_gradient
  #label_scale_linear_gradient
  #spin_radius_circular_gradient
  #label_radius_circular_gradient
  #gradient_color
  #spin_posx_color_linear_gradient
  #label_position_color_gradient
  #spin_posy_color_linear_gradient
  #spin_posx_color_circular_gradient
  #spin_posy_color_circular_gradient
  #label_angle_color
  #entry_angle_color
  #track_angle_color
  #label_alpha_color
  #entry_alpha_color
  #track_alpha_color
  #check_outline_active
  #check_outline_over
  #label_size_outline
  #spin_size_outline
  #check_square_end
  #check_round_end
  #check_diagonal_corner
  #check_rounded_corner
  #gradient_outline
  #option_linear_gradient_outline
  #option_circular_gradient_outline
  #spin_scale_gradient_outline
  #label_scale_gradient_outline
  #spin_radius_gradient_outline
  #label_radius_gradient_outline
  #spin_offset_x_outline
  #label_offset_outline
  #spin_offset_y_outline
  #label_angle_outline
  #entry_angle_outline
  #track_angle_outline
  #spin_posx_circular_gradient_outline
  #label_position_gradient_outline
  #spin_posy_circular_gradient_outline
  #label_alpha_outline
  #entry_alpha_outline
  #track_alpha_outline
  #panel_export
  #frame_format_image
  #check_auto_size
  #entry_export_size_x_image
  #label_export_image_x
  #entry_export_size_y_image
  #combo_image_output_format
  #check_image_with_background
  #frame_mode_image_export
  #option_image_export_single
  #option_image_export_multiple
  #Container_option_image_per_character
  #Option_export_character_name
  #Option_export_image_counter
  #frame_image_file_name
  #entry_image_file_name
  #button_Visualization
  #button_export
  #frame_data_export_template
  #Combo_template
  #Button_save_template
  #button_add_template
  #button_delete_template
  #frame_data_output
  #option_text_file
  #option_json_file
  #entry_format_data
  #label_info_format_data_001
  #label_info_format_data_002
  #label_info_format_data_003
  #label_info_format_data_004
  #label_info_format_data_005
  #label_info_format_data_006
  #frame_data_name
  #check_file_name_text
  #label_image_name
  #entry_data_file_name
EndEnumeration

Enumeration Font
  #font_global_canvas
  #font_character_canvas
EndEnumeration

Procedure OpenWindow_0(x = 0, y = 0, width = 810, height = 790)
  OpenWindow(#Window_0, x, y, width, height, "FONTIM MAKER 1.0", #PB_Window_SystemMenu | #PB_Window_MinimizeGadget | #PB_Window_MaximizeGadget | #PB_Window_SizeGadget | #PB_Window_TitleBar | #PB_Window_ScreenCentered)
  CreateMenu(0, WindowID(#Window_0))
  MenuTitle("File")
  MenuItem(#menu_load, "open")
  MenuItem(#menu_save, "Save")
  MenuItem(#menu_save_as, "Save as...")
  MenuBar()
  MenuItem(#menu_quit, "Quit")
  MenuTitle("Zoom")
  MenuItem(#menu_zoom_reset, "Reset Zoom")
  MenuTitle("Language")
  ForEach language()
    MenuItem(#menu_language + ListIndex(language()), language()\name)  
  Next
  MenuTitle("Fontim")
  MenuItem(#menu_help, "Help")
  MenuItem(#menu_about, "About")
  
  FrameGadget(#frame_background_color, 10, 10, 480, 75, "background color and font size information")
  CanvasGadget(#view_background_color, 150, 35, 50, 35, #PB_Canvas_Border)
  ButtonGadget(#button_background_color_select, 20, 45, 120, 20, "background Color")
  TextGadget(#label_font_size_view, 230, 45, 250, 20, "")
  CanvasGadget(#canvas_character_view, 10, 100, 480, 640, #PB_Canvas_Border | #PB_Canvas_ClipMouse | #PB_Canvas_Keyboard)
  PanelGadget(#panel_font, 510, 10, 290, 275)
  AddGadgetItem(#panel_font, -1, "Font")
  ComboBoxGadget(#Combo_font, 20, 20, 250, 25)
  StringGadget(#entry_font_size, 30, 70, 50, 20, "16", #PB_String_Numeric)
  TextGadget(#label_font_size, 90, 70, 190, 20, "Font Size")
  CheckBoxGadget(#check_bold, 30, 100, 50, 20, "Bold")
  CheckBoxGadget(#check_italic, 30, 130, 60, 20, "Italic")
  CheckBoxGadget(#check_underline, 30, 160, 70, 20, "underline")
  SpinGadget(#spin_offset_x, 35, 200, 60, 25, -999, 999, #PB_Spin_Numeric)
  TextGadget(#label_font_offset, 100, 205, 90, 20, "X <- Offset -> Y", #PB_Text_Center)
  SpinGadget(#spin_offset_y, 205, 200, 60, 25, -999, 999, #PB_Spin_Numeric)
  AddGadgetItem(#panel_font, -1, "Color")
  OptionGadget(#option_gradient_linear, 10, 10, 60, 20, "Linear")
  SetGadgetState(#option_gradient_linear, 1)
  OptionGadget(#option_gradient_circular, 80, 10, 70, 20, "Circular")
  SpinGadget(#spin_scale_linear_gradient, 170, 10, 50, 20, -50, 100, #PB_Spin_Numeric)
  TextGadget(#label_scale_linear_gradient, 230, 10, 50, 20, "Scale")
  SpinGadget(#spin_radius_circular_gradient, 170, 10, 50, 20, 1, 500, #PB_Spin_Numeric)
  HideGadget(#spin_radius_circular_gradient, 1)
  TextGadget(#label_radius_circular_gradient, 230, 10, 50, 20, "Radius")
  HideGadget(#label_radius_circular_gradient, 1)
  ;CanvasGadget(#gradient_color, 10, 30, 270, 70)
  gradient::new(#Window_0, #gradient_color, 10, 38, 270, 82)
  SpinGadget(#spin_posx_color_linear_gradient, 10, 130, 50, 20, -999, 999, #PB_Spin_Numeric)
  TextGadget(#label_position_color_gradient, 65, 130, 160, 20, "X <- Gradient position -> Y", #PB_Text_Center)
  SpinGadget(#spin_posy_color_linear_gradient, 230, 130, 50, 20, -999, 999, #PB_Spin_Numeric)
  SpinGadget(#spin_posx_color_circular_gradient, 10, 130, 50, 20, -999, 999, #PB_Spin_Numeric)
  HideGadget(#spin_posx_color_circular_gradient, 1)
  SpinGadget(#spin_posy_color_circular_gradient, 230, 130, 50, 20, -999, 999, #PB_Spin_Numeric)
  HideGadget(#spin_posy_color_circular_gradient, 1)
  TextGadget(#label_angle_color, 10, 170, 50, 20, "Angle")
  StringGadget(#entry_angle_color, 65, 170, 35, 20, "0", #PB_String_Numeric)
  TrackBarGadget(#track_angle_color, 110, 170, 160, 20, 0, 359)
  TextGadget(#label_alpha_color, 10, 210, 50, 20, "Alpha")
  StringGadget(#entry_alpha_color, 65, 210, 35, 20, "255", #PB_String_Numeric)
  TrackBarGadget(#track_alpha_color, 110, 210, 160, 20, 0, 255)
  AddGadgetItem(#panel_font, -1, "Outline")
  CheckBoxGadget(#check_outline_active, 20, 5, 50, 20, "Actif")
  CheckBoxGadget(#check_outline_over, 100, 5, 55, 20, "Over")
  TextGadget(#label_size_outline, 170, 8, 45, 20, "Width", #PB_Text_Right)
  SpinGadget(#spin_size_outline, 220, 5, 60, 20, 1, 2000, #PB_Spin_Numeric)
  CheckBoxGadget(#check_square_end, 20, 28, 120, 20, "Square end")
  CheckBoxGadget(#check_round_end, 20, 50, 120, 20, "Round end")
  CheckBoxGadget(#check_diagonal_corner, 160, 28, 120, 20, "Diagonal corner")
  CheckBoxGadget(#check_rounded_corner, 160, 50, 120, 20, "Rounded corner")
  ;CanvasGadget(#gradient_outline, 10, 75, 270, 50)
  gradient::new(#Window_0, #gradient_outline, 10, 75, 270, 50)
  OptionGadget(#option_linear_gradient_outline, 10, 130, 65, 20, "Linear")
  SetGadgetState(#option_linear_gradient_outline, 1)
  OptionGadget(#option_circular_gradient_outline, 80, 130, 80, 20, "Circular")
  SpinGadget(#spin_scale_gradient_outline, 170, 130, 50, 20, -50, 100, #PB_Spin_Numeric)
  TextGadget(#label_scale_gradient_outline, 230, 130, 50, 20, "Scale")
  SpinGadget(#spin_radius_gradient_outline, 170, 130, 50, 20, 1, 500, #PB_Spin_Numeric)
  HideGadget(#spin_radius_gradient_outline, 1)
  TextGadget(#label_radius_gradient_outline, 230, 133, 50, 20, "Radius")
  HideGadget(#label_radius_gradient_outline, 1)
  SpinGadget(#spin_offset_x_outline, 10, 160, 50, 20, -999, 999, #PB_Spin_Numeric)
  TextGadget(#label_offset_outline, 65, 160, 160, 20, "X <- offset Outline -> Y", #PB_Text_Center)
  SpinGadget(#spin_offset_y_outline, 230, 160, 50, 20, -999, 999, #PB_Spin_Numeric)
  TextGadget(#label_angle_outline, 10, 190, 50, 20, "Angle")
  StringGadget(#entry_angle_outline, 65, 190, 35, 20, "0", #PB_String_Numeric)
  TrackBarGadget(#track_angle_outline, 110, 190, 160, 20, 0, 359)
  SpinGadget(#spin_posx_circular_gradient_outline, 10, 190, 50, 20, -999, 999, #PB_Spin_Numeric)
  HideGadget(#spin_posx_circular_gradient_outline, 1)
  TextGadget(#label_position_gradient_outline, 70, 192, 150, 20, "X <- Gradient position -> Y", #PB_Text_Center)
  HideGadget(#label_position_gradient_outline, 1)
  SpinGadget(#spin_posy_circular_gradient_outline, 230, 190, 50, 20, -999, 999, #PB_Spin_Numeric)
  HideGadget(#spin_posy_circular_gradient_outline, 1)
  TextGadget(#label_alpha_outline, 10, 220, 50, 20, "Alpha")
  StringGadget(#entry_alpha_outline, 65, 220, 35, 20, "255", #PB_String_Numeric)
  TrackBarGadget(#track_alpha_outline, 110, 220, 160, 20, 0, 255)
  AddGadgetItem(#panel_font, -1, "Effect")
  CloseGadgetList()
  PanelGadget(#panel_export, 510, 290, 290, 470)
  AddGadgetItem(#panel_export, -1, "Export image")
  FrameGadget(#frame_format_image, 10, 18, 270, 100, "Format of the exported image")
  CheckBoxGadget(#check_auto_size, 20, 48, 130, 20, "Automatic size")
  SetGadgetState(#check_auto_size, #PB_Checkbox_Checked)
  StringGadget(#entry_export_size_x_image, 160, 48, 40, 20, "", #PB_String_Numeric)
  TextGadget(#label_export_image_x, 205, 50, 20, 20, "X", #PB_Text_Center)
  StringGadget(#entry_export_size_y_image, 230, 48, 40, 20, "", #PB_String_Numeric)
  ComboBoxGadget(#combo_image_output_format, 20, 78, 100, 30)
  AddGadgetItem(#combo_image_output_format, -1, "PNG", 0, 1)
  AddGadgetItem(#combo_image_output_format, -1, "JPEG")
  AddGadgetItem(#combo_image_output_format, -1, "BMP")
  CheckBoxGadget(#check_image_with_background, 130, 78, 145, 30, "Img with background")
  FrameGadget(#frame_mode_image_export, 10, 128, 270, 140, "Export mode")
  OptionGadget(#option_image_export_single, 20, 150, 250, 20, "A Single image")
  SetGadgetState(#option_image_export_single, 1)
  OptionGadget(#option_image_export_multiple, 20, 175, 250, 20, "One image per character")
  ContainerGadget(#Container_option_image_per_character, 20, 198, 250, 60, #PB_Container_BorderLess)
  OptionGadget(#Option_export_character_name, 10, 5, 230, 25, "Character in name (FileA,FileB...)")
  GadgetToolTip(#Option_export_character_name, "Add character in name (FileA, FileB,...)")
  OptionGadget(#Option_export_image_counter, 10, 35, 230, 25, "Add counter (File1, File2,...)")
  GadgetToolTip(#Option_export_image_counter, "Add increment to image filename")
  SetGadgetState(#Option_export_image_counter, 1)
  CloseGadgetList()
  FrameGadget(#frame_image_file_name, 10, 280, 270, 70, "Image file name")
  StringGadget(#entry_image_file_name, 20, 310, 250, 25, "image")
  ButtonGadget(#button_Visualization, 20, 380, 110, 40, "Visualization")
  ButtonGadget(#button_export, 160, 380, 110, 40, "Export")
  AddGadgetItem(#panel_export, -1, "Export data")
  FrameGadget(#frame_data_export_template, 10, 8, 270, 100, "Template")
  ComboBoxGadget(#Combo_template, 20, 35, 250, 20)
  ButtonGadget(#Button_save_template, 20, 68, 70, 30, "Save")
  GadgetToolTip(#Button_save_template, "Save selected template")
  ButtonGadget(#button_add_template, 110, 68, 70, 30, "New")
  GadgetToolTip(#button_add_template, "Save as a new template")
  ButtonGadget(#button_delete_template, 200, 68, 70, 30, "Delete")
  GadgetToolTip(#button_delete_template, "Delete selected template")
  FrameGadget(#frame_data_output, 10, 120, 270, 208, "Export format")
  OptionGadget(#option_text_file, 30, 140, 80, 20, "Text")
  SetGadgetState(#option_text_file, 1)
  OptionGadget(#option_json_file, 120, 140, 80, 20, "JSON")
  StringGadget(#entry_format_data, 20, 170, 250, 25, "%asc:%x:%y:%sizex:%sizey:%ox:%oy")
  TextGadget(#label_info_format_data_001, 20, 200, 250, 20, "%ox, %oy -> offsetX, offsetY")
  TextGadget(#label_info_format_data_002, 20, 220, 250, 20, "%i  -> to add an increment")
  TextGadget(#label_info_format_data_003, 20, 240, 250, 20, "%asc -> add character value")
  TextGadget(#label_info_format_data_004, 20, 260, 250, 20, "%chr -> character")
  TextGadget(#label_info_format_data_005, 20, 280, 250, 20, "%x %y -> position of the character in image")
  TextGadget(#label_info_format_data_006, 20, 300, 250, 20, "%sizex %sizey-> character size in image")
  FrameGadget(#frame_data_name, 10, 330, 270, 107, "Data file name")
  CheckBoxGadget(#check_file_name_text, 20, 355, 250, 20, "Same name as image(s) file(s)")
  TextGadget(#label_image_name, 20, 382, 250, 20, "%image -> add image name")
  StringGadget(#entry_data_file_name, 20, 408, 250, 25, "%image subimages.txt")
  CloseGadgetList()
EndProcedure

Procedure initialisation_interface() 
  ;fill the font comboBox
  WindowBounds(#Window_0,800,#PB_Ignore,#PB_Ignore,#PB_Ignore)
  ForEach font_system()
    AddGadgetItem(#Combo_font,-1,font_system())
  Next
  SetGadgetState(#Combo_font,0)
  SetGadgetState(#combo_image_output_format,0)
  SetGadgetState(#option_image_export_single, 1)
  DisableGadget(#Option_export_character_name,1)
  DisableGadget(#Option_export_image_counter,1)
  DisableGadget(#entry_export_size_x_image,1)
  DisableGadget(#entry_export_size_y_image,1)
  SetGadgetState(#Track_alpha_color,255)
  SetGadgetState(#Track_alpha_outline,255)
  SetGadgetState(#option_gradient_linear,1)
  
  ;- reset all spin
  SetGadgetState(#spin_posx_color_circular_gradient,0)
  SetGadgetState(#spin_posy_color_circular_gradient,0)
  SetGadgetState(#spin_offset_x,0)
  SetGadgetState(#spin_offset_y,0)
  SetGadgetText(#entry_font_size,"16")
  SetGadgetState(#spin_size_outline,1)
  SetGadgetState(#spin_posx_color_linear_gradient,0)
  SetGadgetState(#spin_posy_color_linear_gradient,0)
  SetGadgetState(#Spin_offset_x_outline,0)
  SetGadgetState(#Spin_posx_circular_gradient_outline,0)
  SetGadgetState(#Spin_offset_y_outline,0)
  SetGadgetState(#Spin_posy_circular_gradient_outline,0)
  SetGadgetState(#Spin_radius_gradient_outline,18)
  SetGadgetState(#spin_radius_circular_gradient,18)
  SetGadgetState(#Spin_scale_gradient_outline,0)
  SetGadgetState(#spin_scale_linear_gradient,0)
  
  StartDrawing(CanvasOutput(#view_background_color))  
  Box(0,0,50,40,RGB(125,125,125))
  StopDrawing()
  
  AddKeyboardShortcut(#Window_0,#PB_Shortcut_Control | #PB_Shortcut_Add, #shortcut_add)
  AddKeyboardShortcut(#Window_0,#PB_Shortcut_Control | #PB_Shortcut_Subtract, #shortcut_sustract)
EndProcedure


; IDE Options = PureBasic 5.72 (Windows - x64)
; CursorPosition = 305
; FirstLine = 250
; Folding = -
; EnableXP