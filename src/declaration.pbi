;-DECLARE
Declare quit()
Declare change_language()
Declare add_template()
Declare update_template()
Declare delete_template()
Declare draw_canvas(mode=2)
Declare draw_outline(x, y, decal_x.d, decal_y.d, offset_x.d, offset_y.d, hauteur, angle_degrade_contour.f, size_contour, nb_curseur_contour, couleur_contour1)
Declare update_option_gradient_color()
Declare update_option_gradient_outline()
Declare update_option_character_gradient_color()
Declare update_option_character_gradient_outline()
Declare resize_window()
Declare calcul_size_font_view(mode=2)

#transparent_background_image = 51
#SIZE_WORK_IMAGE = 4096
#CELL_WIDTH = 30
#CELL_HEIGHT = 40

Enumeration #PB_Event_FirstCustomValue
  #pb_event_gradient  
EndEnumeration

;-STRUCTURE
Structure _template_data
  name.s
  text_file.b
  text_format_export.s
  check_image_name.i
  text_export_name.s
EndStructure

Structure _zoom
  posx.d
  posy.d
  zoom.f
  memo_zoom.f
  memo_x.d
  memo_y.d
  memo_mousex.i
  memo_mousey.i
EndStructure

Structure _char_export
  character.b
  posx.i
  posy.i
  tx.i
  ty.i
  baseline.i
EndStructure

Structure _cursor
  position.f
  color.i
  active.b
EndStructure

Structure _character_color
  linear.b
  radius.i
  scale.f
  linear_gradient_posx.d
  linear_gradient_posy.d
  circular_gradient_posx.d
  circular_gradient_posy.d
  angle.f
  alpha.i
  List cursor._cursor()
EndStructure

Structure _character_outline Extends _character_color
  active.b
  over.b
  ;linear.b
  ;radius.i
  ;scale.i
  width.i
  offset_x.d
  offset_y.d
  ;angle.f
  ;alpha.i
  ;circular_gradient_posx.d
  ;circular_gradient_posy.d
  ;List cursor._cursor()
EndStructure

Structure _global_character
  fontName.s
  size.i
  style.i
  offset_x.d
  offset_y.d
  color._character_color
  outline._character_outline
EndStructure

Structure _character
  selected.b
  modification.b  
EndStructure

Structure _language
  name.s
  file.s
EndStructure

Structure _color_canvas_view_character
  color.i
  selected_cell.i
EndStructure

Structure _extension_file
  txt.s
  json.s
EndStructure

Global NewList font_system.s() ;system font list
Global NewList list_template._template_data() ;list of template data
Global Dim character._character(256)              ;selected character
Global zoom._zoom                                 ; variable pour le zoom de l'affichage
Global background_color._color_canvas_view_character ;couleur du fond dans l'affichage principal
Global font_size_in_view.i
Global NewList language._language() ;list of language files
Global *current_language
Global NewMap language_text.s()
Global global_character._global_character
Global extension_file._extension_file
Global NewList export_data._char_export()
zoom\posx = 0
zoom\posy = 0
zoom\zoom = 1.0

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
; IDE Options = PureBasic 5.72 (Windows - x64)
; CursorPosition = 17
; Folding = -
; EnableXP