
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
    \color\scale = GetGadgetState(#spin_scale_linear_gradient) / #COEFF_2
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
    \outline\width = GetGadgetState(#spin_size_outline) / #COEFF_2
    \outline\linear = GetGadgetState(#option_linear_gradient_outline)
    \outline\offset_x = GetGadgetState(#Spin_offset_x_outline)
    \outline\offset_y = GetGadgetState(#Spin_offset_y_outline)
    \outline\over = GetGadgetState(#check_outline_over)
    \outline\radius = GetGadgetState(#Spin_radius_gradient_outline)
    \outline\scale = GetGadgetState(#Spin_scale_gradient_outline) / #COEFF_2
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
      AddPathBox(x * pas, y * pas, pas, pas)
      VectorSourceColor(bcolor)
      FillPath()
      invert = 1!invert
    Next x
    invert = 1!invert
  Next y  
  StopVectorDrawing()
EndProcedure

;-POSITION AND CHARACTER IN CANVAS
Procedure.i getColumn(mouse_x)
  ProcedureReturn Int((mouse_x - (zoom\posx * zoom\zoom)) / (#CELL_WIDTH * zoom\zoom))
EndProcedure

Procedure.i getLine(mouse_y)
  ProcedureReturn Int((mouse_y - (zoom\posy * zoom\zoom)) / (#CELL_HEIGHT * zoom\zoom))
EndProcedure

Procedure.d get_convert_position_x(mouse_x)
  ProcedureReturn (mouse_x - (zoom\posx * zoom\zoom)) / (zoom\zoom)  
EndProcedure

Procedure.d get_convert_position_y(mouse_y)
  ProcedureReturn (mouse_y - (zoom\posy * zoom\zoom)) / (zoom\zoom)  
EndProcedure

Procedure.i get_char_code(column, line)
  ProcedureReturn ((line * 16) + column)
EndProcedure

;-INTERFACE MODIF
Procedure resize_window()
  wx = WindowWidth(#Window_0)
  wy = WindowHeight(#Window_0)
  ResizeGadget(#panel_font, wx - GadgetWidth(#panel_font)-5 , #PB_Ignore,#PB_Ignore,#PB_Ignore)
  ResizeGadget(#Panel_export, wx - GadgetWidth(#Panel_export)-5 , #PB_Ignore,#PB_Ignore,#PB_Ignore)
  ResizeGadget(#canvas_character_view, #PB_Ignore, #PB_Ignore , wx - 320 , wy - GadgetY(#canvas_character_view) - 10 - MenuHeight()) 
  zoom\zoom = GadgetWidth(#canvas_character_view) / #CHARACTER_VIEW_WIDTH
  draw_canvas()
  calcul_size_font_view(0)
EndProcedure

Procedure zoom_reset()
  tx_canvas = GadgetWidth(#canvas_character_view)
  ty_canvas = GadgetHeight(#canvas_character_view)
  If tx_canvas > ty_canvas
    zoom\zoom = ty_canvas / #CHARACTER_VIEW_HEIGHT
  Else
    zoom\zoom = tx_canvas / #CHARACTER_VIEW_WIDTH
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
    SetGadgetText(#check_square_end, ReadPreferenceString("check_square_end", "Square end"))
    SetGadgetText(#check_round_end, ReadPreferenceString("check_round_end", "Round end"))
    SetGadgetText(#check_diagonal_corner, ReadPreferenceString("check_diagonal_corner", "Diagonal corner"))
    SetGadgetText(#check_rounded_corner, ReadPreferenceString("check_rounded_corner", "Rounded corner"))
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
    GadgetToolTip(#check_square_end, ReadPreferenceString("check_square_end","Square End of outline"))
    GadgetToolTip(#check_round_end, ReadPreferenceString("check_round_end","Round End of outline"))
    GadgetToolTip(#check_diagonal_corner, ReadPreferenceString("check_diagonal_corner","Corner of diagonal outline"))
    GadgetToolTip(#check_rounded_corner, ReadPreferenceString("check_rounded_corner","Corner of rounded outline"))
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
;-***** CHARACTER GLOBAL ***********
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

Procedure get_outline_path_option()
  path_end = #PB_Path_Default
  corner = #PB_Path_Default
  If GetGadgetState(#check_square_end) = #PB_Checkbox_Checked
    path_end = #PB_Path_SquareEnd
  EndIf
  If GetGadgetState(#check_round_end) = #PB_Checkbox_Checked
    path_end = #PB_Path_RoundEnd
  EndIf
  If GetGadgetState(#check_diagonal_corner) = #PB_Checkbox_Checked
    corner = #PB_Path_DiagonalCorner
  EndIf
  If GetGadgetState(#check_rounded_corner) = #PB_Checkbox_Checked
    corner = #PB_Path_RoundCorner
  EndIf
  global_character\outline\path_option = path_end | corner
  ProcedureReturn global_character\outline\path_option
EndProcedure

Procedure event_gadget(gadget.i)
  Protected color.i
  Select gadget
    Case #Spin_posx_color_linear_gradient
      global_character\color\linear_gradient_posx = GetGadgetState(#Spin_posx_color_linear_gradient) / #COEFF_1
    Case #Spin_posy_color_linear_gradient
      global_character\color\linear_gradient_posy = GetGadgetState(#Spin_posy_color_linear_gradient) / #COEFF_1
    Case #spin_scale_linear_gradient
      global_character\color\scale = GetGadgetState(#spin_scale_linear_gradient) / #COEFF_2
    Case #spin_posx_color_circular_gradient
      global_character\color\circular_gradient_posx = GetGadgetState(#spin_posx_color_circular_gradient) / #COEFF_1
    Case #spin_posy_color_circular_gradient
      global_character\color\circular_gradient_posy = GetGadgetState(#spin_posy_color_circular_gradient) / #COEFF_1
    Case #spin_radius_circular_gradient
      global_character\color\radius = GetGadgetState(#spin_radius_circular_gradient)
    Case #spin_size_outline
      global_character\outline\width = GetGadgetState(#spin_size_outline) / #COEFF_2
    Case #Spin_offset_x_outline
      global_character\outline\offset_x = GetGadgetState(#Spin_offset_x_outline) / #COEFF_2
    Case #Spin_offset_y_outline
      global_character\outline\offset_y = GetGadgetState(#Spin_offset_y_outline) / #COEFF_2
    Case #Spin_posx_circular_gradient_outline
      global_character\outline\circular_gradient_posx = GetGadgetState(#Spin_posx_circular_gradient_outline) / #COEFF_1
    Case #Spin_posy_circular_gradient_outline
      global_character\outline\circular_gradient_posy = GetGadgetState(#Spin_posy_circular_gradient_outline) / #COEFF_1
    Case #Spin_radius_gradient_outline
      global_character\outline\radius = GetGadgetState(#Spin_radius_gradient_outline)
    Case #Spin_scale_gradient_outline
      global_character\outline\scale = GetGadgetState(#Spin_scale_gradient_outline) / #COEFF_2
    Case #Check_outline_active
      global_character\outline\active = GetGadgetState(#Check_outline_active)
    Case #check_outline_over
      global_character\outline\over = GetGadgetState(#check_outline_over)
    Case #check_square_end
      If GetGadgetState(#check_square_end) = #PB_Checkbox_Checked And GetGadgetState(#check_round_end) = #PB_Checkbox_Checked 
        SetGadgetState(#check_round_end, #PB_Checkbox_Unchecked)
      EndIf
      get_outline_path_option()
    Case #check_round_end
      If GetGadgetState(#check_round_end) = #PB_Checkbox_Checked And GetGadgetState(#check_square_end) = #PB_Checkbox_Checked 
        SetGadgetState(#check_square_end, #PB_Checkbox_Unchecked)  
      EndIf
      get_outline_path_option()
    Case #check_diagonal_corner
      If GetGadgetState(#check_diagonal_corner) = #PB_Checkbox_Checked And GetGadgetState(#check_rounded_corner) = #PB_Checkbox_Checked 
        SetGadgetState(#check_rounded_corner, #PB_Checkbox_Unchecked)  
      EndIf
      get_outline_path_option()
    Case #check_rounded_corner
      If GetGadgetState(#check_rounded_corner) = #PB_Checkbox_Checked And GetGadgetState(#check_diagonal_corner) = #PB_Checkbox_Checked 
        SetGadgetState(#check_diagonal_corner, #PB_Checkbox_Unchecked)  
      EndIf
      get_outline_path_option()
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
      global_character\offset_x = GetGadgetState(#spin_offset_x) / #COEFF_1
    Case #spin_offset_y
      global_character\offset_y = GetGadgetState(#spin_offset_y) / #COEFF_1
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

Procedure copy_character_array( Array copy_char._character(1) )
  For i = 0 To 255
    copy_char(i)\value = i
    copy_char(i)\selected = character(i)\selected
  Next
EndProcedure

Procedure copy_selected_character_to_array( Array copy_select_char._character(1) )
  nb_elem = 0
  For i = 0 To 255
    If character(i)\selected
      copy_select_char(nb_elem)\selected = character(i)\selected
      copy_select_char(nb_elem)\value = i
      nb_elem + 1
    EndIf
  Next
  ReDim copy_select_char(nb_elem)
  ProcedureReturn nb_elem
EndProcedure

;-***** VISUALISATION *****
Procedure keyboard_resize_visualization(window.i, direction)
  Protected x.i = 0, y.i = 0
  Select direction
    Case #VISUALIZATION_SHORTCUT_LEFT
      x - 1  
    Case #VISUALIZATION_SHORTCUT_RIGHT
      x + 1
    Case #VISUALIZATION_SHORTCUT_UP
      y - 1
    Case #VISUALIZATION_SHORTCUT_DOWN        
      y + 1
  EndSelect
  If x + y <> 0
    ResizeWindow(window, #PB_Ignore, #PB_Ignore, WindowWidth(window) + x, WindowHeight(window) + y)
  EndIf
EndProcedure

Procedure open_visualization()
  Dim copy_char._character(256)
  ;copy_character_array(copy_char())
  copy_selected_character_to_array(copy_char())
  image = image_creation(copy_char())
  If IsImage(image)
    width = ImageWidth(image)
    height = ImageHeight(image)
    window_visu = OpenWindow(#PB_Any, 0, 0, width + 10, height + 10, "Auto size " + Str(width) + " : " + Str(height), #PB_Window_ScreenCentered|#PB_Window_SystemMenu|#PB_Window_SizeGadget)
    gadgetimage = ImageGadget(#PB_Any, 5, 5, width, height, ImageID(image))
    AddKeyboardShortcut(window_visu, #PB_Shortcut_Escape, #VISUALIZATION_SHORTCUT_ESC)
    AddKeyboardShortcut(window_visu, #PB_Shortcut_Control | #PB_Shortcut_Left, #VISUALIZATION_SHORTCUT_LEFT)
    AddKeyboardShortcut(window_visu, #PB_Shortcut_Control | #PB_Shortcut_Right, #VISUALIZATION_SHORTCUT_RIGHT)
    AddKeyboardShortcut(window_visu, #PB_Shortcut_Control | #PB_Shortcut_Up, #VISUALIZATION_SHORTCUT_UP)
    AddKeyboardShortcut(window_visu, #PB_Shortcut_Control | #PB_Shortcut_Down, #VISUALIZATION_SHORTCUT_DOWN)
    StickyWindow(window_visu, #True)
    DisableWindow(#Window_0, #True)
    end_of_visu.b = #False
    Repeat 
      event = WaitWindowEvent()
      Select event
        Case #PB_Event_Menu
          Select EventMenu()
            Case #VISUALIZATION_SHORTCUT_ESC
              end_of_visu = #True
            Case #VISUALIZATION_SHORTCUT_LEFT
              keyboard_resize_visualization(window_visu, #VISUALIZATION_SHORTCUT_LEFT)
            Case #VISUALIZATION_SHORTCUT_RIGHT
              keyboard_resize_visualization(window_visu, #VISUALIZATION_SHORTCUT_RIGHT)
            Case #VISUALIZATION_SHORTCUT_UP
              keyboard_resize_visualization(window_visu, #VISUALIZATION_SHORTCUT_UP)
            Case #VISUALIZATION_SHORTCUT_DOWN
              keyboard_resize_visualization(window_visu, #VISUALIZATION_SHORTCUT_DOWN)
          EndSelect
        Case #PB_Event_CloseWindow
          end_of_visu = #True
        Case #PB_Event_SizeWindow
          SetGadgetState(#check_auto_size, #PB_Checkbox_Unchecked)
          DisableGadget(#entry_export_size_x_image, #False)
          DisableGadget(#entry_export_size_y_image, #False)
          new_width = WindowWidth(window_visu) - 10
          new_height = WindowHeight(window_visu) - 10
          ResizeGadget(gadgetimage, #PB_Ignore, #PB_Ignore, new_width, new_height)
          SetGadgetText(#entry_export_size_x_image, Str(new_width))
          SetGadgetText(#entry_export_size_y_image, Str(new_height))
          If IsImage(image)
            FreeImage(image)
          EndIf
          image = image_creation(copy_char(), #MODE_AUTO_RESIZE)
          SetGadgetState(gadgetimage, ImageID(image))
          ResizeWindow(window_visu, #PB_Ignore, #PB_Ignore, ImageWidth(image) + 10, ImageHeight(image) + 10 )
          SetWindowTitle(window_visu,  "Auto size " + Str(width) + " : " + Str(height) + " new " + Str(GadgetWidth(gadgetimage)) + " : " + Str(GadgetHeight(gadgetimage)) )
      EndSelect      
    Until end_of_visu = #True
    FreeGadget(gadgetimage)
    RemoveKeyboardShortcut(window_visu, #PB_Shortcut_All)
    RemoveKeyboardShortcut(window_visu, #VISUALIZATION_SHORTCUT_LEFT)
    RemoveKeyboardShortcut(window_visu, #VISUALIZATION_SHORTCUT_RIGHT)
    RemoveKeyboardShortcut(window_visu, #VISUALIZATION_SHORTCUT_UP)
    RemoveKeyboardShortcut(window_visu, #VISUALIZATION_SHORTCUT_DOWN)
    CloseWindow(window_visu)
    If IsImage(image)
      FreeImage(image)
    EndIf
    FreeArray(copy_char())
    DisableWindow(#Window_0, #False)
    SetActiveWindow(#Window_0)
  EndIf
EndProcedure

;-***** DRAW CANVAS *****
Procedure prepare_char(x.d, y.d, character_width.d, character_height.d, linear_gradient.b, gradient_posx.d, gradient_posy.d, radius.i, angle.f, scale.f, alpha.i, List cursor._cursor(), nb_cursor_color, color1)
  If nb_cursor_color = 1 ;one cursor no gradient
    VectorSourceColor( RGBA( Red(color1), Green(color1), Blue(color1), Alpha(color1) * (alpha / 255.0) ) )
  ElseIf nb_cursor_color > 1 ;gradient
    mid_width = character_width / 2
    mid_height = character_height / 2
    If linear_gradient = #PB_Checkbox_Unchecked ;circular gradient
      VectorSourceCircularGradient(x + mid_width, y + mid_height, radius, gradient_posx, gradient_posy)
    Else
      cx.d = x + gradient_posx + mid_width
      cy.d = y + gradient_posy + mid_height
      segment = Sqr((character_width * character_width) + (character_height * character_height))
      segment = (segment/2 + (segment * scale))
      x1.d = cx + segment * Cos(angle + #PI)
      y1.d = cy + segment * Sin(angle + #PI)
      x2.d = cx + segment * Cos(angle)
      y2.d = cy + segment * Sin(angle)
      VectorSourceLinearGradient(x1,y1,x2,y2)
    EndIf
    ForEach cursor()
      If cursor()\active = #True
        color = cursor()\color
        color = RGBA( Red(color), Green(color), Blue(color), Alpha(color) * (alpha  /255.0) )
        VectorSourceGradientColor(color, cursor()\position)
      EndIf
    Next
    VectorSourceGradientColor(color, 1.0)      
  EndIf
  MovePathCursor(x, y)
EndProcedure

Procedure draw_character(char$, x.d, y.d, character_width.d, character_height.d, linear_gradient.b, gradient_posx.d, gradient_posy.d, radius.i, angle.f, scale.f, alpha.i, nb_cursor_color, color1)
  prepare_char(x, y, character_width.d, character_height.d,
               linear_gradient.b, gradient_posx.d, gradient_posy.d, 
               radius.i, angle.f, scale.f, 
               alpha.i, global_character\color\cursor(), nb_cursor_color, color1)
  DrawVectorText(char$)   
EndProcedure

Procedure draw_canvas(mode=2) 
  Protected char$, char.i, character_width.d, character_height.d, gradient_posx.d, gradient_posy.d, outline_gradient_posx.d, outline_gradient_posy.d, decal_x.d, decal_y.d
  ;select font
  SelectElement(font_system(),GetGadgetState(#Combo_font))
  StartVectorDrawing(CanvasVectorOutput(#canvas_character_view))
  If zoom\zoom>1.0 ;zoom
    ScaleCoordinates(zoom\zoom,zoom\zoom)
    TranslateCoordinates(zoom\posx,zoom\posy)
  EndIf
  ;background drawing
  AddPathBox(0,0,GadgetWidth(#canvas_character_view),GadgetHeight(#canvas_character_view))
  VectorSourceColor(RGBA(80,80,80,255))
  FillPath()
  AddPathBox(0, 0, #CHARACTER_VIEW_WIDTH, #CHARACTER_VIEW_HEIGHT)
  VectorSourceColor(background_color\color)
  FillPath()
  If Not IsFont(#font_global_canvas)
    LoadFont(#font_global_canvas, font_system(), font_size_in_view, global_character\style)
  EndIf
  nb_cursor_color = ListSize(global_character\color\cursor())       ;gradient::get_number_cursor(#gradient_color)
  nb_curseur_outline = ListSize(global_character\outline\cursor())  ;gradient::get_number_cursor(#gradient_outline)
  If ListSize(global_character\color\cursor())>0
    FirstElement(global_character\color\cursor())
    color1 = global_character\color\cursor()\color
    If global_character\color\linear = #PB_Checkbox_Unchecked
      gradient_posx = global_character\color\circular_gradient_posx
      gradient_posy = global_character\color\circular_gradient_posy
    Else
      gradient_posx = global_character\color\linear_gradient_posx
      gradient_posy = global_character\color\linear_gradient_posy      
    EndIf
  EndIf
  If ListSize(global_character\outline\cursor())>0
    FirstElement(global_character\outline\cursor())
    color_outline1 = global_character\outline\cursor()\color
    If global_character\color\linear = #PB_Checkbox_Unchecked
      outline_gradient_posx = global_character\outline\circular_gradient_posx
      outline_gradient_posy = global_character\outline\circular_gradient_posy
    Else
      outline_gradient_posx = global_character\outline\linear_gradient_posx
      outline_gradient_posy = global_character\outline\linear_gradient_posy      
    EndIf
  EndIf
  VectorFont(FontID(#font_global_canvas))
  For y=0 To 15
    For x=0 To 15
      char = get_char_code(x, y)
      char$ = Chr(char)
      If character(char)\selected = #True    ;If selected cell change background color
        AddPathBox(x * #CELL_WIDTH, y * #CELL_HEIGHT, #CELL_WIDTH, #CELL_HEIGHT)
        VectorSourceColor(background_color\selected_cell)
        FillPath()
        AddPathBox(x * #CELL_WIDTH + 1, y * #CELL_HEIGHT + 1, 28, 38)
        VectorSourceColor( RGBA(255, 255, 255, 100) )
        StrokePath(2)
      EndIf
      character_width = VectorTextWidth(char$, #PB_VectorText_Visible)
      character_height = VectorTextHeight(char$)
      decal_x = (#CELL_WIDTH - character_width) / 2 + global_character\offset_x ;character position in cell
      decal_y = (#CELL_HEIGHT - character_height) / 2 + global_character\offset_y
      If global_character\outline\over <> #PB_Checkbox_Checked And GetGadgetState(#Check_outline_active) = #PB_Checkbox_Checked; outline under character
        draw_outline(char$, x * #CELL_WIDTH + decal_x + global_character\outline\offset_x, y * #CELL_HEIGHT + decal_y + global_character\outline\offset_y, 
                     character_width, character_height, 
                     global_character\outline\linear, outline_gradient_posx, outline_gradient_posy,
                     global_character\outline\scale, global_character\outline\radius, global_character\outline\angle,
                     global_character\outline\width, global_character\outline\path_option,
                     global_character\outline\alpha, nb_curseur_outline, color_outline1)
      EndIf      
      draw_character(char$, x * #CELL_WIDTH + decal_x, y * #CELL_HEIGHT + decal_y,
                     character_width, character_height,
                     global_character\color\linear, gradient_posx, gradient_posy,
                     global_character\color\radius,
                     global_character\color\angle, 
                     global_character\color\scale, 
                     global_character\color\alpha, 
                     nb_cursor_color, 
                     color1)
      
      If global_character\outline\over = #PB_Checkbox_Checked And GetGadgetState(#Check_outline_active) = #PB_Checkbox_Checked; outline over character 
        draw_outline(char$, x * #CELL_WIDTH + decal_x + global_character\outline\offset_x, y * #CELL_HEIGHT + decal_y + global_character\outline\offset_y, 
                     character_width, character_height, 
                     global_character\outline\linear, outline_gradient_posx, outline_gradient_posy,
                     global_character\outline\scale, global_character\outline\radius, global_character\outline\angle,
                     global_character\outline\width, global_character\outline\path_option,
                     global_character\outline\alpha, nb_curseur_outline, color_outline1)
      EndIf        
    Next x
  Next y
  
  For i=0 To 15
    MovePathCursor(#CELL_WIDTH * i, 0)
    AddPathLine(#CELL_WIDTH * i, #CHARACTER_VIEW_HEIGHT)
    MovePathCursor(0, #CELL_HEIGHT * i)
    AddPathLine(#CHARACTER_VIEW_WIDTH, #CELL_HEIGHT * i)
  Next i
  VectorSourceColor( RGBA(0, 0, 0, 255) )
  StrokePath(1)
  StopVectorDrawing() 
EndProcedure

Procedure draw_outline(char$, x.d, y.d, character_width.i, character_height.i, linear_gradient.b, gradient_posx.d, gradient_posy.d, scale.f, radius.i, angle_degrade_outline.f, size_outline.d, path_option.i, alpha.i, nb_curseur_outline, color_outline1)
  prepare_char(x, y, character_width, character_height,
               linear_gradient, gradient_posx, gradient_posy, 
               radius, angle_degrade_outline, scale, 
               alpha, global_character\outline\cursor(), nb_curseur_outline, color_outline1)
  AddPathText(char$)
  StrokePath(size_outline, path_option)
EndProcedure

;-***** CREATE OUTPUT IMAGE *****
Procedure character_distribution_calculation(Array copy_char._character(1), *nb_char_per_line)
  nb_character_per_line = PeekI(*nb_char_per_line)
  count_char = 1
  max_width_line = 0
  width_line = 0
  max_height_line = 0
  height_line = 0
  For i=0 To ArraySize( copy_char() ) - 1    
    If copy_char(i)\selected = 1
      If count_char > nb_character_per_line
        count_char = 1
        width_line = 0
        height_line = height_line + max_height_line
        max_height_line = 0
      EndIf
      width_line = width_line + copy_char(i)\width_in_image + 1
      If max_height_line < copy_char(i)\height_in_image
        max_height_line = copy_char(i)\height_in_image
      EndIf      
      If max_width_line < width_line
        max_width_line = width_line
      EndIf
      count_char + 1
    EndIf
  Next
  
  ratio.f = height_line / (max_width_line + 0.0)
  If  ratio > 1.1
    nb_character_per_line + ((ratio - 1) * 10)
  ElseIf ratio < 0.9
    nb_character_per_line - 1
  ElseIf ratio < 0.8
    nb_character_per_line - 2
  EndIf 
  
  PokeI(*nb_char_per_line, nb_character_per_line)
  ProcedureReturn max_width_line
EndProcedure

Procedure prepare_position_element(Array copy_char._character(1))
  nb_character = 0
    For i=0 To ArraySize(copy_char() ) - 1   ;on compte le nombre de caractère sélectionné
      If copy_char(i)\selected = 1
        nb_character + 1
        copy_char(i)\offset_x_outline_in_image = (global_character\outline\offset_x * ratio_font)
        copy_char(i)\offset_y_outline_in_image = (global_character\outline\offset_y * ratio_font)
        ;calc offset X for drawing character
        copy_char(i)\offset_x_in_image = size_outline - copy_char(i)\offset_x_outline_in_image
        ;if offset < 0 , character start at 0
        If copy_char(i)\offset_x_in_image < 0
          copy_char(i)\offset_x_in_image = 0 
        EndIf
        copy_char(i)\offset_x_in_image - VectorTextWidth(Chr(i), #PB_VectorText_Visible|#PB_VectorText_Offset)
        copy_char(i)\width_in_image = size_outline*1.8 + Abs(copy_char(i)\offset_x_outline_in_image) + VectorTextWidth(Chr(i), #PB_VectorText_Visible)
        copy_char(i)\left_offset = copy_char(i)\offset_x_in_image
        
        copy_char(i)\offset_y_in_image = size_outline - copy_char(i)\offset_y_outline_in_image
        If copy_char(i)\offset_y_in_image < 0
          copy_char(i)\offset_y_in_image = 0
        EndIf
        copy_char(i)\top_offset = VectorTextHeight(Chr(i), #PB_VectorText_Visible | #PB_VectorText_Offset) - copy_char(i)\offset_y_in_image
        copy_char(i)\offset_y_in_image - VectorTextHeight(Chr(i), #PB_VectorText_Visible | #PB_VectorText_Offset)
        copy_char(i)\height_in_image = size_outline*1.8 + Abs(copy_char(i)\offset_y_outline_in_image) + VectorTextHeight(Chr(i), #PB_VectorText_Visible)
      EndIf
    Next
    ProcedureReturn nb_character
EndProcedure

Procedure.l image_creation(Array copy_char._character(1), mode = #MODE_VISUALIZATION) ; visualization, auto resize, export
  Protected gradient_posx.d, gradient_posy.d, outline_gradient_posx.d, outline_gradient_posy.d
  Protected id_font.i, work_image.i
  Protected size_outline.d = 0.0, ratio_font.d, nb_character_per_line.i = 0
  id_font = LoadFont(#PB_Any,GetGadgetText(#Combo_font), global_character\size, global_character\style)
  If IsFont(id_font)
    ClearList(export_data())
    work_image = CreateImage(#PB_Any, #SIZE_WORK_IMAGE, #SIZE_WORK_IMAGE, 32)
    nb_cursor_color = ListSize(global_character\color\cursor()) ;gradient::get_number_cursor(#gradient_color)
    nb_curseur_outline = ListSize(global_character\outline\cursor()) ;gradient::get_number_cursor(#gradient_outline)
    If ListSize(global_character\color\cursor())>0
      FirstElement(global_character\color\cursor())
      color1 = global_character\color\cursor()\color
      If global_character\color\linear = #PB_Checkbox_Unchecked
        gradient_posx = global_character\color\circular_gradient_posx
        gradient_posy = global_character\color\circular_gradient_posy
      Else
        gradient_posx = global_character\color\linear_gradient_posx
        gradient_posy = global_character\color\linear_gradient_posy      
      EndIf
    EndIf
    If ListSize(global_character\outline\cursor())>0
      FirstElement(global_character\outline\cursor())
      color_outline1 = global_character\outline\cursor()\color
      If global_character\color\linear = #PB_Checkbox_Unchecked
        outline_gradient_posx = global_character\outline\circular_gradient_posx
        outline_gradient_posy = global_character\outline\circular_gradient_posy
      Else
        outline_gradient_posx = global_character\outline\linear_gradient_posx
        outline_gradient_posy = global_character\outline\linear_gradient_posy      
      EndIf
    EndIf
    ratio_font = global_character\size / font_size_in_view
    If GetGadgetState(#Check_outline_active) = #PB_Checkbox_Checked
      size_outline = global_character\outline\width * ratio_font
    EndIf
    StartVectorDrawing(ImageVectorOutput(work_image))    
    VectorFont(FontID(id_font))
    nb_character = prepare_position_element(copy_char())
    If GetGadgetState(#check_auto_size) = #PB_Checkbox_Checked
      nb_character_per_line = Round(nb_character / Round(Sqr(nb_character), #PB_Round_Nearest), #PB_Round_Up)
      For u=0 To 5
        limit_line = character_distribution_calculation(copy_char(), @nb_character_per_line)
      Next  
    Else
      nb_character_per_line = 0
      limit_line = Val(GetGadgetText(#entry_export_size_x_image))
    EndIf
    
    ;         SortStructuredArray(copy_char(), #PB_Sort_Ascending , OffsetOf(_character\width_in_image), TypeOf(_character\width_in_image))
    ;         SortStructuredArray(copy_char(), #PB_Sort_Ascending , OffsetOf(_character\height_in_image), TypeOf(_character\height_in_image))
    
    If GetGadgetState(#check_image_with_background) = #PB_Checkbox_Checked
      AddPathBox(0, 0, #SIZE_WORK_IMAGE, #SIZE_WORK_IMAGE)
      VectorSourceColor(background_color\color)
      FillPath()
    ElseIf mode < #MODE_EXPORT
      DrawVectorImage(ImageID(#transparent_background_image), 255)
    EndIf
    char_x = 0
    char_y = 0
    point_x = 0
    point_y = 0
    max_width_line = 0
    char_in_line = 1
    For i=0 To ArraySize( copy_char() ) - 1
      If copy_char(i)\selected
        char$ = Chr(copy_char(i)\value)
        If nb_character_per_line = 0
          If point_x + copy_char(i)\width_in_image > limit_line
            point_x = 0    
            point_y = point_y + max_character_height_in_line + 1
            max_character_height_in_line = 0
          EndIf
        Else          
          If char_in_line > nb_character_per_line
            If point_x + copy_char(i)\width_in_image > limit_line
              char_in_line = 1
              point_x = 0
              point_y = point_y + max_character_height_in_line + 1
              max_character_height_in_line = 0
            EndIf
          EndIf         
        EndIf
        
        If max_character_height_in_line < copy_char(i)\height_in_image
          max_character_height_in_line =  copy_char(i)\height_in_image 
        EndIf
        char_x = point_x + copy_char(i)\offset_x_in_image
        char_y = point_y + copy_char(i)\offset_y_in_image
        If global_character\outline\over = #PB_Checkbox_Unchecked And GetGadgetState(#Check_outline_active) = #PB_Checkbox_Checked ; outline under   
          draw_outline(char$, char_x + copy_char(i)\offset_x_outline_in_image, char_y + copy_char(i)\offset_y_outline_in_image, 
                       copy_char(i)\width_in_image, copy_char(i)\height_in_image, 
                       global_character\outline\linear, outline_gradient_posx * ratio_font, outline_gradient_posy * ratio_font,
                       global_character\outline\scale, global_character\outline\radius * ratio_font, global_character\outline\angle,
                       size_outline, global_character\outline\path_option,
                       global_character\outline\alpha, nb_curseur_outline, color_outline1)          
        EndIf
        
        If mode < #MODE_EXPORT
          AddPathBox(point_x, point_y,copy_char(i)\width_in_image, copy_char(i)\height_in_image)
          VectorSourceColor(RGBA(255,0,0,255))
          DashPath(3, 6)
        EndIf        
        
        draw_character(char$, char_x, char_y, copy_char(i)\width_in_image, copy_char(i)\height_in_image,
                       global_character\color\linear, gradient_posx * ratio_font, gradient_posy * ratio_font,
                       global_character\color\radius * ratio_font,
                       global_character\color\angle, 
                       global_character\color\scale, 
                       global_character\color\alpha, 
                       nb_cursor_color, 
                       color1) 
                
        If global_character\outline\over = #PB_Checkbox_Checked And GetGadgetState(#Check_outline_active) = #PB_Checkbox_Checked ; outline over 
          draw_outline(char$, char_x + copy_char(i)\offset_x_outline_in_image, char_y + copy_char(i)\offset_y_outline_in_image, 
                       copy_char(i)\width_in_image, copy_char(i)\height_in_image, 
                       global_character\outline\linear, outline_gradient_posx * ratio_font, outline_gradient_posy * ratio_font,
                       global_character\outline\scale, global_character\outline\radius * ratio_font, global_character\outline\angle,
                       size_outline, global_character\outline\path_option,
                       global_character\outline\alpha, nb_curseur_outline, color_outline1)
        EndIf      
        
        If mode = #MODE_EXPORT
          AddElement(export_data())
          export_data()\character = i
          ;position in image
          export_data()\posx = point_x
          export_data()\posy = point_y
          ;size
          export_data()\sx = copy_char(i)\width_in_image
          export_data()\sy = copy_char(i)\height_in_image
          ;offset character for correctly positionning in game/application
          export_data()\offset_x = copy_char(i)\left_offset
          export_data()\offset_y = copy_char(i)\top_offset
        EndIf
        point_x = point_x + copy_char(i)\width_in_image + 1
        char_in_line + 1
        If max_width_line < point_x
          max_width_line = point_x 
        EndIf
      EndIf
    Next
    StopVectorDrawing()
    If GetGadgetState(#check_auto_size) = #PB_Checkbox_Checked
      width_image_export = max_width_line
      height_image_export = point_y + max_character_height_in_line      
    Else
      If mode = #MODE_AUTO_RESIZE
        height_image_export = point_y + max_character_height_in_line
      Else
        height_image_export = Val(GetGadgetText(#entry_export_size_y_image))
      EndIf
      width_image_export = limit_line
    EndIf
    image_export = GrabImage(work_image,#PB_Any, 0, 0, width_image_export, height_image_export)
    FreeImage(work_image)
    FreeFont(id_font)
    ProcedureReturn image_export
  EndIf
  ProcedureReturn -1
EndProcedure

;-***** EXPORT IMAGE AND DATA *****
Procedure export()
  
EndProcedure


;-***** SYSTEM FONT ENUMERATION *****
;{ system font enumeration procedure
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
; CursorPosition = 1031
; FirstLine = 1031
; Folding = --------
; EnableXP