﻿
Procedure initialisation_bind_event()
  BindGadgetEvent(#option_gradient_circular, @update_option_gradient_color())
  BindGadgetEvent(#option_gradient_linear, @update_option_gradient_color())
  BindGadgetEvent(#option_linear_gradient_outline, @update_option_gradient_outline())
  BindGadgetEvent(#option_circular_gradient_outline, @update_option_gradient_outline())
  ForEach language()
    BindMenuEvent(#menu, #menu_language + ListIndex(language()), @change_language())  
  Next
  BindEvent(#PB_Event_SizeWindow, @resize_window())
EndProcedure

Procedure init_canvas()
  SelectElement(font_system(),GetGadgetState(#Combo_font))
  With global_character
    \fontName = font_system()
    \offset_x = GetGadgetState(#spin_offset_x)
    \offset_y = GetGadgetState(#spin_offset_y)
    \size = Val(GetGadgetText(#entry_font_size))
    \style = #PB_Font_HighQuality
    If GetGadgetState(#check_bold) : \style|#PB_Font_Bold : EndIf
    If GetGadgetState(#check_italic) : \style|#PB_Font_Italic : EndIf
    If GetGadgetState(#check_underline) : \style|#PB_Font_Underline : EndIf
    ;******** récupération des infos gradient color
    \color\alpha = GetGadgetState(#Track_alpha_color)
    \color\angle = Radian(GetGadgetState(#Track_angle_color))
    \color\circular_gradient_posx = GetGadgetState(#spin_posx_color_circular_gradient)
    \color\circular_gradient_posy = GetGadgetState(#spin_posy_color_circular_gradient)
    \color\linear = GetGadgetState(#option_gradient_linear)
    \color\linear_gradient_posx = GetGadgetState(#Spin_posx_color_linear_gradient)
    \color\linear_gradient_posy = GetGadgetState(#Spin_posy_color_linear_gradient)
    \color\radius = GetGadgetState(#spin_radius_circular_gradient)
    \color\scale = GetGadgetState(#spin_scale_linear_gradient) / 100.0
    AddElement(\color\cursor())
    gradient::FirstElement_cursor(#gradient_color)
    \color\cursor()\active = gradient::get_cursor_state()
    \color\cursor()\position = gradient::get_cursor_position()
    color = gradient::get_cursor_color()
    alpha_color = GetGadgetState(#Track_alpha_color)
    \color\cursor()\color = RGBA(Red(color),Green(color),Blue(color),Alpha(color) * (alpha_color/255.0))
    ;******** récupération des infos gradient outline
    \outline\active = GetGadgetState(#check_outline_active)
    \outline\alpha = GetGadgetState(#Track_alpha_outline)
    \outline\angle = Radian(GetGadgetState(#Track_angle_outline))
    \outline\circular_gradient_posx = GetGadgetState(#Spin_posx_circular_gradient_outline)
    \outline\circular_gradient_posy = GetGadgetState(#Spin_posy_circular_gradient_outline)
    \outline\width = GetGadgetState(#spin_size_outline)
    \outline\linear = GetGadgetState(#option_linear_gradient_outline)
    \outline\offset_x = GetGadgetState(#Spin_offset_x_outline)
    \outline\offset_y = GetGadgetState(#Spin_offset_y_outline)
    \outline\over = GetGadgetState(#check_outline_over)
    \outline\radius = GetGadgetState(#Spin_radius_gradient_outline)
    \outline\scale = GetGadgetState(#Spin_scale_gradient_outline) / 100.0
    AddElement(\outline\cursor())
    
    \outline\cursor()\active = gradient::get_cursor_state()
    \outline\cursor()\position = gradient::get_cursor_position()
    color = gradient::get_cursor_color()
    alpha_outline = GetGadgetState(#Track_alpha_outline)
    \outline\cursor()\color = RGBA(Red(color),Green(color),Blue(color),Alpha(color) * (alpha_outline/255.0))
  EndWith
  calcul_size_font_view(0)
EndProcedure

Procedure init_transparent_background_image()
  CreateImage(#transparent_background_image, #SIZE_WORK_IMAGE, #SIZE_WORK_IMAGE, 32)
  StartVectorDrawing(ImageVectorOutput(#transparent_background_image))
  pas = 7
  For y = 0 To (#SIZE_WORK_IMAGE / pas)
    For x = 0 To (#SIZE_WORK_IMAGE / pas)
      If invert
        bcolor = RGBA(255,255,255,255)
      Else
        bcolor = RGBA(180,180,180,255)
      EndIf
      AddPathBox(x * pas, y*pas, pas, pas)
      VectorSourceColor(bcolor)
      FillPath()
      invert = 1!invert
    Next x
    invert = 1!invert
  Next y  
  StopVectorDrawing()
EndProcedure

;-POSITION AND CHARACTER IN CANVAS
Procedure.i getLine(mouse_x)
  ProcedureReturn Int((mouse_x - (zoom\posx * zoom\zoom)) / (#CELL_WIDTH * zoom\zoom))
EndProcedure

Procedure.i getColumn(mouse_y)
  ProcedureReturn Int((mouse_y - (zoom\posy * zoom\zoom)) / (#CELL_HEIGHT * zoom\zoom))
EndProcedure

Procedure.q get_convert_position_x(mouse_x)
  ProcedureReturn (mouse_x - (zoom\posx * zoom\zoom)) / (zoom\zoom)  
EndProcedure

Procedure.q get_convert_position_y(mouse_y)
  ProcedureReturn (mouse_y - (zoom\posy * zoom\zoom)) / (zoom\zoom)  
EndProcedure

Procedure.i get_char_code(mouse_x, mouse_y)
  ProcedureReturn ((getColumn(mouse_y) * 16) + getLine(mouse_x))
EndProcedure

;-INTERFACE MODIF
Procedure resize_window()
  wx = WindowWidth(#Window_0)
  wy = WindowHeight(#Window_0)
  ResizeGadget(#panel_font, wx - GadgetWidth(#panel_font)-5 , #PB_Ignore,#PB_Ignore,#PB_Ignore)
  ResizeGadget(#Panel_export, wx - GadgetWidth(#Panel_export)-5 , #PB_Ignore,#PB_Ignore,#PB_Ignore)
  ResizeGadget(#canvas_character_view, #PB_Ignore, #PB_Ignore , wx - 320 , wy - GadgetY(#canvas_character_view) - 10 - MenuHeight()) 
  zoom\zoom = GadgetWidth(#canvas_character_view) / 480.0
  draw_canvas()
  calcul_size_font_view(0)
EndProcedure

Procedure zoom_reset()
  tx_canvas = GadgetWidth(#canvas_character_view)
  ty_canvas = GadgetHeight(#canvas_character_view)
  If tx_canvas > ty_canvas
    zoom\zoom = ty_canvas / 640
  Else
    zoom\zoom = tx_canvas / 480
  EndIf
  zoom\posx = 0
  zoom\posy = 0
  draw_canvas()
EndProcedure

Procedure update_option_gradient_color()
  If EventGadget() = #option_gradient_linear
    HideGadget(#spin_posx_color_circular_gradient,1)
    HideGadget(#spin_posy_color_circular_gradient,1)
    HideGadget(#spin_radius_circular_gradient,1)
    HideGadget(#label_radius_circular_gradient,1)
    HideGadget(#spin_scale_linear_gradient,0)
    HideGadget(#label_scale_linear_gradient,0)
    HideGadget(#Spin_posx_color_linear_gradient,0)
    HideGadget(#Spin_posy_color_linear_gradient,0)
    If gradient::get_number_cursor(#gradient_color) > 1
      DisableGadget(#track_angle_color,0)
      DisableGadget(#entry_angle_color,0)
      DisableGadget(#label_angle_color,0)
    EndIf
  Else
    HideGadget(#spin_posx_color_circular_gradient,0)
    HideGadget(#spin_posy_color_circular_gradient,0)
    HideGadget(#spin_radius_circular_gradient,0)
    HideGadget(#label_radius_circular_gradient,0)
    HideGadget(#spin_scale_linear_gradient,1)
    HideGadget(#label_scale_linear_gradient,1)
    HideGadget(#Spin_posx_color_linear_gradient,1)
    HideGadget(#Spin_posy_color_linear_gradient,1)
    DisableGadget(#track_angle_color,1)
    DisableGadget(#entry_angle_color,1)
    DisableGadget(#label_angle_color,1)
  EndIf
  global_character\color\linear = GetGadgetState(#option_gradient_linear)
  draw_canvas(2)
EndProcedure

Procedure update_option_gradient_outline()
  If EventGadget() = #option_linear_gradient_outline
    HideGadget(#Spin_posx_circular_gradient_outline,1)
    HideGadget(#label_position_gradient_outline,1)
    HideGadget(#Spin_posy_circular_gradient_outline,1)
    HideGadget(#Spin_radius_gradient_outline,1)
    HideGadget(#label_radius_gradient_outline,1)
    HideGadget(#Spin_scale_gradient_outline,0)
    HideGadget(#label_scale_gradient_outline,0)
    HideGadget(#track_angle_outline,0)
    HideGadget(#entry_angle_outline,0)
    HideGadget(#label_angle_outline,0)
  Else
    HideGadget(#Spin_posx_circular_gradient_outline,0)
    HideGadget(#label_position_gradient_outline,0)
    HideGadget(#Spin_posy_circular_gradient_outline,0)
    HideGadget(#Spin_radius_gradient_outline,0)
    HideGadget(#label_radius_gradient_outline,0)
    HideGadget(#Spin_scale_gradient_outline,1)
    HideGadget(#label_scale_gradient_outline,1)
    HideGadget(#track_angle_outline,1)
    HideGadget(#entry_angle_outline,1)
    HideGadget(#label_angle_outline,1)
  EndIf
  global_character\outline\linear = GetGadgetState(#option_linear_gradient_outline)
  draw_canvas(2)  
EndProcedure
;- ***** EFFET COLOR *****
Procedure.l fx_luminosite(color, Echelle.f) ; Eclaicir ou foncer une color
  Protected r, g, b
  
  r = Red(color)
  g = Green(color)
  b = Blue(color)
  alpha = Alpha(color)
  r * Echelle
  g * Echelle
  b * Echelle
  
  If r > 255 : r = 255 : EndIf
  If g > 255 : g = 255 : EndIf
  If b > 255 : b = 255 : EndIf
  
  ProcedureReturn RGBA(r, g, b, alpha)
EndProcedure

Procedure change_background_color(mode=0)
  If mode = 0
    color = ColorRequester(background_color\color)
  Else
    color = RGB(125,125,125)
  EndIf
  If color>-1
    r = Red(color)
    g = Green(color)
    b = Blue(color)
    background_color\color = RGBA(r, g, b, 255)
    StartDrawing(CanvasOutput(#view_background_color))
    Box(0, 0, 50, 40, background_color\color)
    StopDrawing()
    If r > 200 Or g > 200 Or b > 200
      background_color\selected_cell  = fx_luminosite(background_color\color, 0.4)
    Else
      If r<10 : r = 40 : EndIf
      If g<10 : g = 40 : EndIf
      If b<10 : b = 40 : EndIf
      background_color\selected_cell  = fx_luminosite(RGBA(r, g, b, 255), 1.6)
    EndIf  
    draw_canvas()
  EndIf
EndProcedure

;-***** PREFERENCE *****
Procedure load_preference()
  If OpenPreferences("prefs\Preferences.prefs")
    language$ = ReadPreferenceString("Language","")
    ForEach language()
      If language()\file = language$
        ;SetMenuItemState(#menu,#menu_language + ListIndex(language()), 1)
        *current_language = language()
        change_language()
        Break
      EndIf
    Next
    SetGadgetState(#Combo_template,ReadPreferenceInteger("Template",0))
    ClosePreferences()
  EndIf
  PostEvent(#PB_Event_Menu, #Window_0 , #menu_language + ListIndex(language()) )
  update_template()
EndProcedure

Procedure save_preference()
  If OpenPreferences("prefs\Preferences.prefs")
    WritePreferenceString("Language",language()\file)
    WritePreferenceInteger("Template",GetGadgetState(#Combo_template))
    ClosePreferences()
  EndIf
EndProcedure

;- ***** LANGUAGE *****
Procedure scan_file_language()
  Protected dir
  ClearList(language())
  dir = ExamineDirectory(#PB_Any,"localization\","*.lng")
  If dir
    While NextDirectoryEntry(dir)
      AddElement(language())
      language()\file = DirectoryEntryName(dir)   
    Wend    
    FinishDirectory(dir) 
  EndIf
  ForEach language()
    OpenPreferences("localization\" + language()\file)
    PreferenceGroup("localisation")
    language()\name = ReadPreferenceString("name","")
    ClosePreferences()
  Next 
EndProcedure

Procedure change_language()
  Protected index.i = EventMenu()
  If index >= #menu_language
    ForEach language()
      SetMenuItemState(#menu, #menu_language + ListIndex(language()),0)
    Next
    SelectElement(language(),index - #menu_language)
    *current_language = language()
    SetMenuItemState(#menu,index,1)
    OpenPreferences("localization\" + language()\file)
    PreferenceGroup("Menu")
    SetMenuTitleText(#menu,0,"&"+ReadPreferenceString("file","File"))
    SetMenuItemText(#menu,#menu_load,ReadPreferenceString("open","Open"))
    SetMenuItemText(#menu,#Menu_save,"&"+ReadPreferenceString("save","Save"))
    SetMenuItemText(#menu,#menu_save_as,ReadPreferenceString("save_as","Save as"))
    SetMenuItemText(#menu,#Menu_quit,"&"+ReadPreferenceString("quit","Quit") )
    SetMenuTitleText(#menu,1,ReadPreferenceString("zoom","Zoom"))
    label_reset_zoom.s = ReadPreferenceString("reset_zoom","Reset Zoom")
    SetMenuItemText(#menu,#menu_zoom_reset,StringField(label_reset_zoom,1, "|") + Chr(9) + StringField(label_reset_zoom,2, "|"))
    SetMenuTitleText(#menu,2,ReadPreferenceString("language","Language"))
    SetMenuItemText(#menu,#Menu_help,ReadPreferenceString("help","Help"))
    SetMenuItemText(#menu,#Menu_about,ReadPreferenceString("about","About"))    
    PreferenceGroup("Gadget")
    SetGadgetText(#frame_background_color,ReadPreferenceString("frame_background_color","Back color And info font size"))
    SetGadgetText(#button_background_color_select,ReadPreferenceString("button_background_color_select","Back color"))
    SetGadgetItemText(#panel_font,0,ReadPreferenceString("font","Font"))
    SetGadgetText(#label_font_size,ReadPreferenceString("font_size","Size font"))
    SetGadgetText(#check_bold,ReadPreferenceString("bold","Bold"))
    SetGadgetText(#check_italic, ReadPreferenceString("italic","Italic"))
    SetGadgetText(#check_underline,ReadPreferenceString("underline","Underline"))
    SetGadgetText(#label_font_offset,ReadPreferenceString("offset","X <- Offset -> Y"))
    SetGadgetItemText(#panel_font, 1, ReadPreferenceString("panel_color","Color"))
    SetGadgetText(#option_gradient_linear,ReadPreferenceString("linear","Linear"))
    SetGadgetText(#option_gradient_circular,ReadPreferenceString("circular","Circular"))
    SetGadgetText(#label_scale_linear_gradient,ReadPreferenceString("scale","Scale"))
    SetGadgetText(#label_radius_circular_gradient,ReadPreferenceString("radius","Radius")) 
    SetGadgetText(#label_angle_color, ReadPreferenceString("angle","Angle"))
    SetGadgetText(#label_alpha_color,ReadPreferenceString("alpha","Alpha"))
    SetGadgetText(#label_position_color_gradient,ReadPreferenceString("position_gradient","X <- Gradient position -> Y"))
    SetGadgetItemText(#panel_font, 2, ReadPreferenceString("outline","Outline"))
    SetGadgetText(#check_outline_active,ReadPreferenceString("active","Active"))
    SetGadgetText(#check_outline_over,ReadPreferenceString("over","Over"))
    SetGadgetText(#label_size_outline,ReadPreferenceString("width","Width"))
    SetGadgetText(#option_linear_gradient_outline,ReadPreferenceString("linear","Linear"))
    SetGadgetText(#option_circular_gradient_outline,ReadPreferenceString("circular","Circular"))
    SetGadgetText(#label_scale_gradient_outline,ReadPreferenceString("scale","Scale"))
    SetGadgetText(#label_radius_gradient_outline,ReadPreferenceString("radius","Radius"))
    SetGadgetText(#label_offset_outline,ReadPreferenceString("offset","X <- Offset -> Y"))
    SetGadgetText(#label_angle_outline,ReadPreferenceString("angle","Angle"))
    SetGadgetText(#label_position_gradient_outline,ReadPreferenceString("position_gradient","X <- Gradient position -> Y"))
    SetGadgetText(#label_alpha_outline,ReadPreferenceString("alpha","Alpha"))
    SetGadgetItemText(#Panel_font,3,ReadPreferenceString("effect","effect"))
    SetGadgetItemText(#Panel_export,0,ReadPreferenceString("panel_export_image","Image export"))
    SetGadgetText(#Frame_format_image,ReadPreferenceString("frame_format_image","Format of the exported image"))
    SetGadgetText(#check_auto_size,ReadPreferenceString("size_auto","Automatic size"))
    SetGadgetText(#check_image_with_background,ReadPreferenceString("img_w_back","Image With backcolor"))
    SetGadgetText(#frame_mode_image_export,ReadPreferenceString("frame_mode_export","Export mode"))
    SetGadgetText(#option_image_export_single,ReadPreferenceString("opt_img_single","A unique image"))
    SetGadgetText(#option_image_export_multiple,ReadPreferenceString("opt_img_multi","One image per character"))
    SetGadgetText(#check_export_character_name,ReadPreferenceString("check_char_name","Character in name (FileA,FileB...)"))
    SetGadgetText(#check_export_counter_name,ReadPreferenceString("check_file_counter","Add counter (File1, File2,...)"))
    SetGadgetText(#frame_image_file_name,ReadPreferenceString("frame_img_filename","Image file name"))
    ;SetGadgetText(#Entry_nom_fichier_image,ReadPreferenceString(
    SetGadgetText(#button_visualization,ReadPreferenceString("button_visualization","Visualization"))
    SetGadgetText(#button_export,ReadPreferenceString("button_export","Export"))
    SetGadgetItemText(#Panel_export,1,ReadPreferenceString("panel_export_data","Data export"))
    SetGadgetText(#frame_data_export_template,ReadPreferenceString("frame_template","Template"))
    SetGadgetText(#Button_save_template,ReadPreferenceString("button_save_template","Save"))
    SetGadgetText(#button_add_template,ReadPreferenceString("button_add_template","New"))
    SetGadgetText(#button_delete_template,ReadPreferenceString("button_delete_template","Delete"))
    SetGadgetText(#frame_data_output,ReadPreferenceString("frame_output_data","Export Format"))
    SetGadgetText(#label_info_format_data_001,ReadPreferenceString("info_format_data_001","EX :  name_%i,%x,%y,%sizex,%sizey"))
    SetGadgetText(#label_info_format_data_002,ReadPreferenceString("info_format_data_002","%i  -> To add an increment"))
    SetGadgetText(#label_info_format_data_003,ReadPreferenceString("info_format_data_003","%asc -> Adds the ascii character value"))
    SetGadgetText(#label_info_format_data_004,ReadPreferenceString("info_format_data_004","%chr -> character"))
    SetGadgetText(#label_info_format_data_005,ReadPreferenceString("info_format_data_005","%x %y -> Position of the character in the image"))
    SetGadgetText(#label_info_format_data_006,ReadPreferenceString("info_format_data_006","%sizex %sizey-> Size character in image"))
    SetGadgetText(#frame_data_name,ReadPreferenceString("frame_data_filename","Name of the Data file"))
    SetGadgetText(#check_file_name_text,ReadPreferenceString("check_name_as_image","Same name As image file(s)"))
    SetGadgetText(#label_image_name,ReadPreferenceString("label_info_file_img","%image -> Adds the name of the image"))
    If GetGadgetText(#entry_file_name_text) = ""
      SetGadgetText(#entry_file_name_text,"%image subimages.txt")
    EndIf   
    language_text("label_info_size_font") = ReadPreferenceString("label_info_size_font","Size font in view : ")
    SetGadgetText(#label_font_size_view,language_text("label_info_size_font") + Str(font_size_in_view * zoom\zoom))
    PreferenceGroup("Tooltip")    
    GadgetToolTip(#view_background_color, ReadPreferenceString("view_background_color","Background color in the display below"))
    GadgetToolTip(#button_background_color_select, ReadPreferenceString("button_background_color","Change background color"))
    GadgetToolTip(#label_font_size_view,ReadPreferenceString("label_info_size_font_tooltip","Font size in the display below"))
    GadgetToolTip(#spin_radius_circular_gradient, ReadPreferenceString("spin_radius_circular_gradient","Modifies radius of the gradient"))
    GadgetToolTip(#entry_angle_color, ReadPreferenceString("angle_gradient","Rotates the gradient"))
    GadgetToolTip(#track_angle_color, ReadPreferenceString("angle_gradient","Rotates the gradient"))
    GadgetToolTip(#check_outline_over,ReadPreferenceString("check_over_outline","If checked, the outline will be over the text"))
    GadgetToolTip(#check_image_with_background,ReadPreferenceString("Check_img_with_back","If no checked back image is transparent"))
    GadgetToolTip(#Button_save_template,ReadPreferenceString("button_save_template","Save selected template"))
    GadgetToolTip(#button_add_template,ReadPreferenceString("button_add_template","Save as a new template"))
    GadgetToolTip(#button_delete_template,ReadPreferenceString("button_delete_template","Delete selected template"))
    ClosePreferences()
  EndIf
  ;save_preference()
EndProcedure

;- ***** TEMPLATE *****
Procedure update_template()
  SelectElement(list_template(),GetGadgetState(#Combo_template))
  With list_template()
    SetGadgetState(#option_text_file,\text_file)
    SetGadgetState(#option_json_file,1!\text_file)
    SetGadgetText(#entry_format_data,\text_format_export)
    SetGadgetText(#entry_file_name_text,\text_export_name)
    SetGadgetState(#check_file_name_text,\check_image_name)
  EndWith
EndProcedure

Procedure load_template(nom.s="")
  Protected file.i, head$, check.b
  file = ReadFile(#PB_Any,"template\template.tfm")
  If file
    ClearGadgetItems(#Combo_template)
    ClearList(list_template())
    While Eof(file)=0
      head$ = ReadString(file)
      If head$<>""
        AddElement(list_template())
        With list_template()
          \name = StringField(head$,1,"|")
          \text_file = Val(StringField(head$,2,"|"))
          \text_format_export = StringField(head$,3,"|")
          \text_export_name = StringField(head$,4,"|")
          \check_image_name = Val(StringField(head$,5,"|"))
          AddGadgetItem(#Combo_template,-1,\name)
        EndWith
      EndIf
    Wend
    CloseFile(file)
    If nom<>""
      For i=0 To CountGadgetItems(#Combo_template)-1
        If GetGadgetItemText(#Combo_template,i) = nom
          SetGadgetState(#Combo_template,i)
          ProcedureReturn 1
        EndIf
      Next
    Else
      SetGadgetState(#Combo_template,0)
    EndIf
    update_template()
  EndIf  
EndProcedure

Procedure _save_file_template(entry$="")
  Protected file.i
  SortStructuredList(list_template(), #PB_Sort_Ascending, OffsetOf(_template_data\name),TypeOf(_template_data\name))
  ;on passe à la sauvegarde des templates
  file = CreateFile(#PB_Any,"template\template.tfm")
  If file
    ForEach list_template()
      With list_template()
        WriteStringN(file, RemoveString(\name,"|") + "|" +
                           Str(\text_file) + "|" +
                           RemoveString(\text_format_export,"|") + "|" +
                           RemoveString(\text_export_name,"|") + "|" + 
                           Str(\check_image_name))
      EndWith
    Next
    CloseFile(file)
    load_template(entry$)
  EndIf  
EndProcedure

Procedure save_template()
  With list_template()
    \text_file = GetGadgetState(#option_text_file)
    \text_format_export = GetGadgetText(#entry_format_data)
    \text_export_name = GetGadgetText(#entry_file_name_text)
    \check_image_name = GetGadgetState(#check_file_name_text)
    _save_file_template(\name)  
  EndWith
EndProcedure

Procedure add_template()
  Protected titre$, text$
  OpenPreferences("localization\" + language()\file)
  PreferenceGroup("Template")
  titre$ = ReadPreferenceString("input_template_title","Add template")
  text$ = ReadPreferenceString("input_template_text","Enter template name :")
  ClosePreferences()
  entry$ = InputRequester(titre$,text$,"")
  If entry$=""
    ProcedureReturn 0
  EndIf
  ;on ajoute le template à la liste des template
  AddElement(list_template())
  With list_template()
    \name = entry$
    save_template()
  EndWith
EndProcedure

Procedure delete_template()
  Protected index.i = GetGadgetState(#Combo_template)
  SelectElement(list_template(),index)
  DeleteElement(list_template())
  _save_file_template()
EndProcedure
;-***** CHARACTERE GLOBAL ***********
Procedure calcul_size_font_view(mode=2)
  ;{ Calcul de la meilleure size pour afficher le texte en fonction du mode
  Select mode
    Case -1 ;on diminue la size de la police affiché de 1
      font_size_in_view -1
    Case 0 ;on calcule la meilleure size pour l'affichage dans le canvas
      SelectElement(font_system(),GetGadgetState(#Combo_font))
      global_character\fontName = font_system()
      font_size_in_view = 64
      cal_lg.f =0
      cal_ht.f = 0
      ;LoadFont(0,font_system(),font_size_in_view,style)
      LoadFont(#font_global_canvas,font_system(),font_size_in_view,global_character\style)
      StartVectorDrawing(CanvasVectorOutput(#canvas_character_view))
      VectorFont(FontID(0))
      ;DrawingMode(#PB_2DDrawing_Transparent)
      For i=0 To 255
        If VectorTextWidth(Chr(i))>cal_lg
          cal_lg = VectorTextWidth(Chr(i),#PB_VectorText_Visible)
        EndIf
        If VectorTextHeight(Chr(i))>cal_ht
          cal_ht = VectorTextHeight(Chr(i),#PB_VectorText_Visible)
        EndIf
      Next      
      StopVectorDrawing()
      cal_lg = cal_lg/28
      cal_ht = cal_ht/38
      If cal_lg>cal_ht : font_size_in_view = (font_size_in_view/cal_lg) : EndIf
      If cal_lg<cal_ht : font_size_in_view = (font_size_in_view/cal_ht) : EndIf
    Case 1 ;on augmente la size de la police de 1
      font_size_in_view +1
  EndSelect
  ;}
  LoadFont(#font_global_canvas, font_system(), font_size_in_view, global_character\style)
  SetGadgetText(#label_font_size_view, language_text("label_info_size_font") + Str(font_size_in_view * zoom\zoom))
  draw_canvas()
EndProcedure

Procedure event_gadget(gadget.i)
  Protected color.i, coeff1.q = 30.0, coeff2.q = 100.0
  Select gadget
    Case #Spin_posx_color_linear_gradient
      global_character\color\linear_gradient_posx = GetGadgetState(#Spin_posx_color_linear_gradient)/coeff1
    Case #Spin_posy_color_linear_gradient
      global_character\color\linear_gradient_posy = GetGadgetState(#Spin_posy_color_linear_gradient)/coeff1
    Case #spin_scale_linear_gradient
      global_character\color\scale = GetGadgetState(#spin_scale_linear_gradient) / coeff2
    Case #spin_posx_color_circular_gradient
      global_character\color\circular_gradient_posx = GetGadgetState(#spin_posx_color_circular_gradient)/coeff1
    Case #spin_posy_color_circular_gradient
      global_character\color\circular_gradient_posy = GetGadgetState(#spin_posy_color_circular_gradient)/coeff1
    Case #spin_radius_circular_gradient
      global_character\color\radius = GetGadgetState(#spin_radius_circular_gradient)
    Case #spin_size_outline
      global_character\outline\width = GetGadgetState(#spin_size_outline)
    Case #Spin_offset_x_outline
      global_character\outline\offset_x = GetGadgetState(#Spin_offset_x_outline) / coeff2
    Case #Spin_offset_y_outline
      global_character\outline\offset_y = GetGadgetState(#Spin_offset_y_outline) / coeff2
    Case #Spin_posx_circular_gradient_outline
      global_character\outline\circular_gradient_posx = GetGadgetState(#Spin_posx_circular_gradient_outline)/coeff1
    Case #Spin_posy_circular_gradient_outline
      global_character\outline\circular_gradient_posy = GetGadgetState(#Spin_posy_circular_gradient_outline)/coeff1
    Case #Spin_radius_gradient_outline
      global_character\outline\radius = GetGadgetState(#Spin_radius_gradient_outline)
    Case #Spin_scale_gradient_outline
      global_character\outline\scale = GetGadgetState(#Spin_scale_gradient_outline) / coeff2
    Case #Check_outline_active
      global_character\outline\active = GetGadgetState(#Check_outline_active)
    Case #check_outline_over
      global_character\outline\over = GetGadgetState(#check_outline_over)
    Case #Track_angle_outline
      SetGadgetText(#Entry_angle_outline,Str(GetGadgetState(#Track_angle_outline)))
      global_character\outline\angle = Radian(GetGadgetState(#Track_angle_outline))
    Case #Entry_angle_outline
      If Val(GetGadgetText(#Entry_angle_outline))>359
        SetGadgetText(#Entry_angle_outline,"359")
      EndIf            
      SetGadgetState(#Track_angle_outline,Val(GetGadgetText(#Entry_angle_outline)))
      global_character\outline\angle = Radian(GetGadgetState(#Track_angle_outline))
    Case #check_bold
      If GetGadgetState(#check_bold) 
        global_character\style|#PB_Font_Bold
      Else
        global_character\style!#PB_Font_Bold
      EndIf
      LoadFont(#font_global_canvas,font_system(),font_size_in_view,global_character\style)
    Case #check_italic
      If GetGadgetState(#check_italic)
        global_character\style|#PB_Font_Italic
      Else
        global_character\style!#PB_Font_Italic
      EndIf
      LoadFont(#font_global_canvas,font_system(),font_size_in_view,global_character\style)
    Case #check_underline
      If GetGadgetState(#check_underline)
        global_character\style|#PB_Font_Underline
      Else
        global_character\style!#PB_Font_Underline
      EndIf
      LoadFont(#font_global_canvas,font_system(),font_size_in_view,global_character\style)
    Case #spin_offset_x
      global_character\offset_x = GetGadgetState(#spin_offset_x)/coeff1
    Case #spin_offset_y
      global_character\offset_y = GetGadgetState(#spin_offset_y)/coeff1
    Case #Entry_alpha_outline
      If Val(GetGadgetText(#Entry_alpha_outline))>255
        SetGadgetText(#Entry_alpha_outline,"255")
      EndIf            
      SetGadgetState(#Track_alpha_outline,Val(GetGadgetText(#Entry_alpha_outline)))
      global_character\outline\alpha = Radian(GetGadgetState(#Track_alpha_outline))
    Case #Track_alpha_outline
      SetGadgetText(#Entry_alpha_outline,Str(GetGadgetState(#Track_alpha_outline)))
      global_character\outline\alpha = GetGadgetState(#Track_alpha_outline)
    Case #Track_angle_color
      SetGadgetText(#Entry_angle_color,Str(GetGadgetState(#Track_angle_color)))
      global_character\color\angle = Radian(GetGadgetState(#Track_angle_color))
    Case #Entry_angle_color
      If Val(GetGadgetText(#Entry_angle_color))>359
        SetGadgetText(#Entry_angle_color,"359")
      EndIf            
      SetGadgetState(#Track_angle_color,Val(GetGadgetText(#Entry_angle_color)))
      global_character\color\angle = Radian(GetGadgetState(#Track_angle_color))
    Case #Entry_alpha_color
      If Val(GetGadgetText(#Entry_alpha_color))>255
        SetGadgetText(#Entry_alpha_color,"255")
      EndIf            
      SetGadgetState(#Track_alpha_color,Val(GetGadgetText(#Entry_alpha_color)))
      global_character\color\alpha = GetGadgetState(#Track_alpha_color)
    Case #Track_alpha_color
      SetGadgetText(#Entry_alpha_color,Str(GetGadgetState(#Track_alpha_color)))
      global_character\color\alpha = GetGadgetState(#Track_alpha_color)
    Case #gradient_color
      nb_curseur = gradient::get_number_cursor(#gradient_color)
      gradient::FirstElement_cursor(#gradient_color)
      ClearList(global_character\color\cursor())
      For i=0 To nb_curseur - 1
        AddElement(global_character\color\cursor())
        global_character\color\cursor()\active = gradient::get_cursor_state()
        global_character\color\cursor()\position = gradient::get_cursor_position()
        global_character\color\cursor()\color = gradient::get_cursor_color()
        gradient::next_cursor()
      Next i
      If nb_curseur = 1
        DisableGadget(#spin_scale_linear_gradient,1)
        DisableGadget(#spin_radius_circular_gradient,1)
        DisableGadget(#Spin_posx_color_linear_gradient,1)
        DisableGadget(#Spin_posy_color_linear_gradient,1)
        DisableGadget(#spin_posx_color_circular_gradient,1)
        DisableGadget(#spin_posy_color_circular_gradient,1)
        DisableGadget(#label_angle_color,1)
        DisableGadget(#entry_angle_color,1)
        DisableGadget(#track_angle_color,1)
      Else
        DisableGadget(#spin_scale_linear_gradient,0)
        DisableGadget(#spin_radius_circular_gradient,0)
        DisableGadget(#Spin_posx_color_linear_gradient,0)
        DisableGadget(#Spin_posy_color_linear_gradient,0)
        DisableGadget(#spin_posx_color_circular_gradient,0)
        DisableGadget(#spin_posy_color_circular_gradient,0)
        If Not GetGadgetState(#option_gradient_circular)
          DisableGadget(#label_angle_color,0)
          DisableGadget(#entry_angle_color,0)
          DisableGadget(#track_angle_color,0)
        EndIf
      EndIf
    Case #gradient_outline
      nb_curseur = gradient::get_number_cursor(#gradient_outline)
      gradient::FirstElement_cursor(#gradient_outline)
      ClearList(global_character\outline\cursor())
      For i=0 To nb_curseur - 1
        AddElement(global_character\outline\cursor())
        global_character\outline\cursor()\active = gradient::get_cursor_state()
        global_character\outline\cursor()\position = gradient::get_cursor_position()
        global_character\outline\cursor()\color = gradient::get_cursor_color()
        gradient::next_cursor()
      Next i 
      If nb_curseur = 1
        DisableGadget(#spin_scale_gradient_outline,1)
        DisableGadget(#spin_radius_gradient_outline,1)
        DisableGadget(#Spin_posx_circular_gradient_outline,1)
        DisableGadget(#Spin_posy_circular_gradient_outline,1)
        DisableGadget(#label_angle_outline,1)
        DisableGadget(#entry_angle_outline,1)
        DisableGadget(#track_angle_outline,1)
      Else
        DisableGadget(#spin_scale_gradient_outline,0)
        DisableGadget(#spin_radius_gradient_outline,0)
        DisableGadget(#Spin_posx_circular_gradient_outline,0)
        DisableGadget(#Spin_posy_circular_gradient_outline,0)    
        If Not GetGadgetState(#option_circular_gradient_outline)
          DisableGadget(#label_angle_outline,0)
          DisableGadget(#entry_angle_outline,0)
          DisableGadget(#track_angle_outline,0)
        EndIf
      EndIf
  EndSelect
  draw_canvas()
EndProcedure

;-***** VISUALISATION *****
Procedure open_visualization(image.l)
  If IsImage(image)
    width = ImageWidth(image)
    height = ImageHeight(image)
    window_visu = OpenWindow(#PB_Any,0,0,width+10,height+10,"Visualisation",#PB_Window_ScreenCentered|#PB_Window_SystemMenu)
    gadgetimage = ImageGadget(#PB_Any,5,5,width,height,ImageID(image))
    AddKeyboardShortcut(window_visu,#PB_Shortcut_Escape,#ESC)
    
    Repeat 
      event = WaitWindowEvent()
      If event = #PB_Event_Menu And EventMenu() = #ESC
        event = #PB_Event_CloseWindow
      EndIf
    Until event = #PB_Event_CloseWindow
    FreeGadget(gadgetimage)
    RemoveKeyboardShortcut(window_visu, #PB_Shortcut_All)
    CloseWindow(window_visu)
    FreeImage(image)
  EndIf
EndProcedure

;-***** DRAW CANVAS *****
Procedure draw_character(char$, x, y, character_width.i, character_height.i, linear_gradient.b, gradient_posx.d, gradient_posy.d, radius.i, angle.f, scale.f, alpha.i, nb_cursor_color, color1)
  If nb_cursor_color = 1 ;un seul curseur donc color unique
                         ;color1 = global_character\color\cursor()\color
    VectorSourceColor(RGBA(Red(color1),Green(color1),Blue(color1),Alpha(color1) * (alpha/255.0)))
  EndIf      
  If nb_cursor_color>1 ;nous avons un degradé car plus d'un curseur
    If linear_gradient = #PB_Checkbox_Unchecked;dégradé circulaire
      VectorSourceCircularGradient(x + (character_width/2), y + (character_height/2), radius, gradient_posx, gradient_posy)
    Else
      cx.d = x + gradient_posx + (character_width/2)
      cy.d = y + gradient_posy + (character_height/2)
      segment = Sqr((character_width * character_width) + (character_height * character_height))
      segment = (segment/2 + (segment * scale))
      x1.d = cx + segment * Cos(angle + #PI)
      y1.d = cy + segment * Sin(angle + #PI)
      x2.d = cx + segment * Cos(angle)
      y2.d = cy + segment * Sin(angle)
      VectorSourceLinearGradient(x1,y1,x2,y2)
    EndIf
    ForEach global_character\color\cursor()
      If global_character\color\cursor()\active = #True
        color = global_character\color\cursor()\color
        color = RGBA(Red(color),Green(color),Blue(color),Alpha(color) * (alpha/255.0))
        VectorSourceGradientColor(color,global_character\color\cursor()\position)
      EndIf
    Next
    VectorSourceGradientColor(color, 1.0)      
  EndIf
  MovePathCursor(x, y)
  DrawVectorText(char$)   
EndProcedure

Procedure draw_canvas(mode=2) 
  ;recherche de la police sélectionnée
  SelectElement(font_system(),GetGadgetState(#Combo_font))
  StartVectorDrawing(CanvasVectorOutput(#canvas_character_view))
  ;DrawingMode(#PB_2DDrawing_AlphaChannel)
  ;Box(0,0,480,640,RGB(125,125,125))
  If zoom\zoom>1.0 ;zoom donc on change le scale
    ScaleCoordinates(zoom\zoom,zoom\zoom)
    TranslateCoordinates(zoom\posx,zoom\posy)
  EndIf
  ;fond du canvas
  AddPathBox(0,0,GadgetWidth(#canvas_character_view),GadgetHeight(#canvas_character_view))
  VectorSourceColor(RGBA(80,80,80,255))
  FillPath()
  AddPathBox(0,0,480,640)
  VectorSourceColor(background_color\color)
  FillPath()
  ;on récupère les données générales pour éco cycle processeur
  If Not IsFont(#font_global_canvas)
    LoadFont(#font_global_canvas, font_system(), font_size_in_view, global_character\style)
  EndIf
  nb_cursor_color = ListSize(global_character\color\cursor()) ;gradient::get_number_cursor(#gradient_color)
  nb_curseur_outline = ListSize(global_character\outline\cursor()) ;gradient::get_number_cursor(#gradient_outline)
  If ListSize(global_character\color\cursor())>0
    FirstElement(global_character\color\cursor())
    color1 = global_character\color\cursor()\color
  EndIf
  If ListSize(global_character\outline\cursor())>0
    FirstElement(global_character\outline\cursor())
    color_outline1 = global_character\outline\cursor()\color
  EndIf
  VectorFont(FontID(#font_global_canvas)) ;on charge la font en vector
                                          ;parcours de tous les caractères
  For y=0 To 15
    For x=0 To 15
      If character((16*y)+x)\selected = #True     ;fond de la case si sélection
        AddPathBox(x*#CELL_WIDTH, y*#CELL_HEIGHT, #CELL_WIDTH, #CELL_HEIGHT)
        VectorSourceColor(background_color\selected_cell)
        FillPath()
        AddPathBox(x*#CELL_WIDTH + 1,y*#CELL_HEIGHT+ 1,28,38)
        VectorSourceColor(RGBA(255,255,255,100))
        StrokePath(2)
      EndIf
      decal_x.d = (#CELL_WIDTH-VectorTextWidth(Chr((16*y)+x)))/2 + global_character\offset_x ;position du caractère dans la case
      decal_y.d = (#CELL_HEIGHT-VectorTextHeight(Chr((16*y)+x)))/2 + global_character\offset_y
      height = VectorTextHeight(Chr((16*y)+x)) / 2
      If global_character\outline\over <> #PB_Checkbox_Checked ; outline au dessous du texte      
        draw_outline(x, y, decal_x, decal_y, global_character\offset_x, global_character\offset_y, height, global_character\outline\angle,
                     global_character\outline\width, nb_curseur_outline, color_outline1)
      EndIf      
;                   If nb_cursor_color = 1 ;un seul curseur donc color unique
;                                           ;color1 = global_character\color\cursor()\color
;                     VectorSourceColor(RGBA(Red(color1),Green(color1),Blue(color1),Alpha(color1) * (global_character\color\alpha/255.0)))
;                   EndIf        
;                   If nb_cursor_color>1 ;nous avons un degradé car plus d'un curseur
;                     If global_character\color\linear = #PB_Checkbox_Unchecked;dégradé circulaire
;                       VectorSourceCircularGradient(x*#CELL_WIDTH + 15 + global_character\offset_x, y*#CELL_HEIGHT + decal_y + height + global_character\offset_y,
;                                                    global_character\color\radius,global_character\color\circular_gradient_posx,global_character\color\circular_gradient_posy)
;                     EndIf
;                     If global_character\color\linear = #PB_Checkbox_Checked ;dégradé linéaire
;                                                                             ;orientation du degrade en fonction de l'angle
;                       If global_character\color\angle  > 0
;                         cx.d = x*#CELL_WIDTH + 15 + global_character\color\linear_gradient_posx
;                         cy.d = y*#CELL_HEIGHT + 20 + global_character\color\linear_gradient_posy
;                         x1.d = cx + (20 - (#CELL_WIDTH*global_character\color\scale))*Cos(global_character\color\angle + #PI)
;                         y1.d = cy + (20 - (#CELL_HEIGHT*global_character\color\scale))*Sin(global_character\color\angle + #PI)
;                         x2.d = cx + (20 + (#CELL_WIDTH*global_character\color\scale))*Cos(global_character\color\angle)
;                         y2.d = cy + (20 + (#CELL_HEIGHT*global_character\color\scale))*Sin(global_character\color\angle)            
;                       EndIf
;                       If global_character\color\angle  = 0 
;                         x1.d = x*#CELL_WIDTH + global_character\color\linear_gradient_posx - (#CELL_WIDTH*global_character\color\scale)
;                         y1.d = y*#CELL_HEIGHT + global_character\color\linear_gradient_posy
;                         x2.d = x*#CELL_WIDTH + #CELL_WIDTH + global_character\color\linear_gradient_posx + (#CELL_WIDTH*global_character\color\scale)
;                         y2.d = y*#CELL_HEIGHT + global_character\color\linear_gradient_posy
;                       EndIf
;                       VectorSourceLinearGradient(x1,y1,x2,y2)
;                     EndIf
;                     ForEach global_character\color\cursor()
;                       If global_character\color\cursor()\active = #True
;                         color = global_character\color\cursor()\color
;                         color = RGBA(Red(color),Green(color),Blue(color),Alpha(color) * (global_character\color\alpha/255.0))
;                         VectorSourceGradientColor(color,global_character\color\cursor()\position)
;                       EndIf
;                     Next
;                     VectorSourceGradientColor(color, 1.0)      
;                   EndIf
;                   MovePathCursor(x*#CELL_WIDTH + decal_x, y*#CELL_HEIGHT + decal_y)
;                   DrawVectorText(Chr((16*y)+x)) 
      
      
      If global_character\color\linear = #PB_Checkbox_Unchecked
        gradient_posx.d = global_character\color\circular_gradient_posx
        gradient_posy.d = global_character\color\circular_gradient_posy
      Else
        gradient_posx = global_character\color\linear_gradient_posx
        gradient_posy = global_character\color\linear_gradient_posy      
      EndIf
      draw_character(Chr((16*y)+x), x*#CELL_WIDTH + decal_x, y*#CELL_HEIGHT + decal_y,
                     VectorTextWidth(Chr((16*y)+x), #PB_VectorText_Visible), VectorTextHeight(Chr((16*y)+x)),
                     global_character\color\linear, gradient_posx, gradient_posy,
                     global_character\color\radius,
                     global_character\color\angle, 
                     global_character\color\scale, 
                     global_character\color\alpha, 
                     nb_cursor_color, 
                     color1)
      
      If global_character\outline\over = #PB_Checkbox_Checked ; outline over   
        draw_outline(x, y, decal_x, decal_y, global_character\outline\offset_x, global_character\outline\offset_y,
                     height, global_character\outline\angle, global_character\outline\width,
                     nb_curseur_outline, color_outline1)
      EndIf        
    Next x
  Next y
  
  For i=0 To 15
    MovePathCursor(#CELL_WIDTH*i,0)
    AddPathLine(#CELL_WIDTH*i,640)
    MovePathCursor(0,#CELL_HEIGHT*i)
    AddPathLine(480,#CELL_HEIGHT*i)
  Next i
  VectorSourceColor(RGBA(0,0,0,255))
  StrokePath(1)
  StopVectorDrawing() 
EndProcedure

Procedure draw_outline(x, y, decal_x.d, decal_y.d, offset_x.d, offset_y.d, height, angle_degrade_outline.f, size_outline, nb_curseur_outline, color_outline1)    
  If GetGadgetState(#Check_outline_active) = #PB_Checkbox_Checked  ;outline active   
    If nb_curseur_outline = 1
      MovePathCursor(x*#CELL_WIDTH + decal_x + global_character\outline\offset_x, y*#CELL_HEIGHT + decal_y + global_character\outline\offset_y)
      AddPathText(Chr((16*y)+x))
      ;color = gradient::get_cursor_color()
      VectorSourceColor(RGBA(Red(color_outline1),Green(color_outline1),Blue(color_outline1),Alpha(color_outline1) * (global_character\outline\alpha/255.0)))
      StrokePath(size_outline)
    EndIf  
    If nb_curseur_outline > 1
      If global_character\outline\linear = 0 ;dégradé circulaire
        position_x = x*#CELL_WIDTH + 15 + offset_x
        position_y = y*#CELL_HEIGHT + height + offset_y
        VectorSourceCircularGradient(position_x,position_y, global_character\outline\radius, global_character\outline\circular_gradient_posx,global_character\outline\circular_gradient_posy)
      EndIf
      If global_character\outline\linear = 1
        ;orientation du degrade en fonction de l'angle
        If angle_degrade_outline  > 0
          cx.d = x*#CELL_WIDTH + 15 + global_character\outline\circular_gradient_posx
          cy.d = y*#CELL_HEIGHT + 20 + global_character\outline\circular_gradient_posy
          decal_scale = #CELL_WIDTH * global_character\outline\scale
          x1.d = cx + (20+size_outline + decal_scale)*Cos(angle_degrade_outline + #PI)
          y1.d = cy + (20+size_outline + decal_scale)*Sin(angle_degrade_outline + #PI)
          x2.d = cx + (20+size_outline + decal_scale)*Cos(angle_degrade_outline)
          y2.d = cy + (20+size_outline + decal_scale)*Sin(angle_degrade_outline)
        EndIf  
        If angle_degrade_outline = 0 
          x1.d = x*#CELL_WIDTH + global_character\outline\circular_gradient_posx - (#CELL_WIDTH * global_character\outline\scale)
          y1.d = y*#CELL_HEIGHT + global_character\outline\circular_gradient_posy
          x2.d = x*#CELL_WIDTH + #CELL_WIDTH + global_character\outline\circular_gradient_posx + (#CELL_WIDTH * global_character\outline\scale)
          y2.d = y*#CELL_HEIGHT + global_character\outline\circular_gradient_posy
        EndIf
        VectorSourceLinearGradient(x1,y1,x2,y2)
      EndIf      
      ForEach global_character\outline\cursor()
        If global_character\outline\cursor()\active = #True
          color = global_character\outline\cursor()\color
          color = RGBA(Red(color),Green(color),Blue(color),Alpha(color) * (global_character\outline\alpha/255.0))
          VectorSourceGradientColor(color,global_character\outline\cursor()\position)
        EndIf
      Next        
      VectorSourceGradientColor(color, 1.0)
      MovePathCursor(x*#CELL_WIDTH + decal_x + global_character\outline\offset_x, y*#CELL_HEIGHT + decal_y + global_character\outline\offset_y)
      AddPathText(Chr((16*y)+x))
      StrokePath(size_outline)         
    EndIf
  EndIf
EndProcedure

;-***** CREATE OUTPUT IMAGE *****
Procedure.l image_creation(mode = 0) ;mode visu = 0 à l'export on met mode 1 pour ne pas avoir de fond
  Protected tx_img_sortie.i, ty_img_sortie.i
  Protected size_police.i, style.i, id_font.i, work_image.i, image_mask.i 
  id_font = LoadFont(#PB_Any,GetGadgetText(#Combo_font), global_character\size, global_character\style)
  If IsFont(id_font)
    ClearList(export_data())
    ;on modifie le style en fonction des checkbox
    style = #PB_Font_HighQuality
    If GetGadgetState(#check_bold) : style|#PB_Font_Bold : EndIf
    If GetGadgetState(#check_italic) : style|#PB_Font_Italic : EndIf
    If GetGadgetState(#check_underline) : style|#PB_Font_Underline : EndIf
    work_image = CreateImage(#PB_Any, #SIZE_WORK_IMAGE, #SIZE_WORK_IMAGE, 32)
    nb_cursor_color = ListSize(global_character\color\cursor()) ;gradient::get_number_cursor(#gradient_color)
    nb_curseur_outline = ListSize(global_character\outline\cursor()) ;gradient::get_number_cursor(#gradient_outline)
    If ListSize(global_character\color\cursor())>0
      FirstElement(global_character\color\cursor())
      color1 = global_character\color\cursor()\color
    EndIf
    If ListSize(global_character\outline\cursor())>0
      FirstElement(global_character\outline\cursor())
      color_outline1 = global_character\outline\cursor()\color
    EndIf
    StartVectorDrawing(ImageVectorOutput(work_image))
    If GetGadgetState(#check_image_with_background) = #PB_Checkbox_Checked
      AddPathBox(0, 0, #SIZE_WORK_IMAGE, #SIZE_WORK_IMAGE)
      VectorSourceColor(background_color\color)
      FillPath()
    ElseIf mode = 0
      DrawVectorImage(ImageID(#transparent_background_image), 255)
    EndIf
    
    VectorFont(FontID(id_font))
    nb_character = 0
    For i=0 To 255 ;on compte le nombre de caractère sélectionné
      If character(i)\selected = 1
        nb_character+1
        If character_width_max < VectorTextWidth(Chr(i), #PB_VectorText_Visible)
          character_width_max = VectorTextWidth(Chr(i), #PB_VectorText_Visible)
        EndIf
        If character_height_max < VectorTextHeight(Chr(i))
          character_height_max = VectorTextHeight(Chr(i))
        EndIf
      EndIf
    Next  
    If GetGadgetState(#check_auto_size)
      limit_line = character_width_max * Round(Sqr(nb_character), #PB_Round_Up)      
      ;       max_width_line = (limit_line / character_width_max) * character_width_max
      ;       max_height_line = ((limit_line / character_height_max) * character_height_max) + character_height_max   
    Else
      limit_line = Val(GetGadgetText(#entry_export_size_x_image))
    EndIf    
    char_x = 0
    char_y = 0
    max_width_line = 0
    For i=0 To 255
      If character(i)\selected
        char$ = Chr(i)
        char_width = VectorTextWidth(char$, #PB_VectorText_Visible)
        char_height = VectorTextHeight(char$)
        char_baseline = VectorTextHeight(char$, #PB_VectorText_Baseline)        
        If char_x + char_width > limit_line
          char_x = 0
          char_y + character_height_max
        EndIf
        If global_character\color\linear = #PB_Checkbox_Unchecked
          gradient_posx.d = global_character\color\circular_gradient_posx
          gradient_posy.d = global_character\color\circular_gradient_posy
        Else
          gradient_posx = global_character\color\linear_gradient_posx
          gradient_posy = global_character\color\linear_gradient_posy      
        EndIf
        draw_character(char$, char_x - VectorTextWidth(char$, #PB_VectorText_Visible|#PB_VectorText_Offset), char_y,
                       char_width, char_height,
                       global_character\color\linear, (global_character\size / font_size_in_view) * gradient_posx, (global_character\size / font_size_in_view) * gradient_posy,
                       (global_character\size / font_size_in_view) * global_character\color\radius,
                       global_character\color\angle, 
                       global_character\color\scale, 
                       global_character\color\alpha, 
                       nb_cursor_color, 
                       color1)
        
        If global_character\outline\over = #PB_Checkbox_Checked ; outline over   
          draw_outline(x, y, decal_x, decal_y, global_character\outline\offset_x, global_character\outline\offset_y,
                       height, global_character\outline\angle, global_character\outline\width,
                       nb_curseur_outline, color_outline1)
        EndIf       
        If mode
          AddElement(export_data())
          export_data()\character = i
          export_data()\posx = char_x
          export_data()\posy = char_y
          export_data()\tx = char_width
          export_data()\ty = char_height
          export_data()\baseline = char_baseline
        EndIf
        char_x + char_width + 1
        If max_width_line < char_x
          max_width_line = char_x 
        EndIf
      EndIf
    Next    
    StopVectorDrawing()
    image_export = GrabImage(work_image,#PB_Any, 0, 0, max_width_line, char_y + character_height_max)
    FreeImage(work_image)
    FreeFont(id_font)
    ProcedureReturn image_export
  EndIf
  ProcedureReturn -1
EndProcedure

;-***** ENUMERATION FONT SYSTEM *****
;{ procédure d'énumération des polices système
Procedure EnumFontFamProc(*lpelf.ENUMLOGFONT, *lpntm.NEWTEXTMETRIC, FontType, lParam)
  AddElement(font_system())
  font_system()= PeekS(@*lpelf\elfLogFont\lfFaceName[0])
  ProcedureReturn 1 
EndProcedure 

Procedure SysInfo_Fonts() 
  hWnd = GetDesktopWindow_() 
  hDC = GetDC_(hWnd) 
  EnumFontFamilies_(hDC, 0, @EnumFontFamProc(), 0) 
  ReleaseDC_ (hWnd, hDC)
  SortList(font_system(),#PB_Sort_Ascending)
EndProcedure ;}

; IDE Options = PureBasic 5.72 (Windows - x64)
; CursorPosition = 992
; FirstLine = 960
; Folding = ------
; EnableXP