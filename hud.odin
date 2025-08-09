package main

import "core:fmt"


MENU_THICKNESS: f32 : 300
MENU_LEFT_HIDDEN: f32 : -MENU_THICKNESS
MENU_RIGHT_HIDDEN: f32 : SCREEN_X
MENU_LEFT_SHOWING: f32 : 0
MENU_RIGHT_SHOWING: f32 : SCREEN_X - MENU_THICKNESS
MENU_SPEED: f32 : 20

Hud_Alignment :: struct {
	command_current:     f32,
	command_destination: f32,
	shop_current:        f32,
	shop_destination:    f32,
}

Hud_State_Enum :: enum {
	None,
	Start,
	Command,
	Shop,
}

Handle_Hud_Position :: proc(hud_state: ^Hud_State_Set, hud: ^Hud_Alignment) {
	if .Start in hud_state {
		// just hide everything
		hud.command_current = MENU_LEFT_HIDDEN
		hud.command_destination = MENU_LEFT_HIDDEN
		hud.shop_current = MENU_RIGHT_HIDDEN
		hud.shop_destination = MENU_RIGHT_HIDDEN
	}
	if .Command in hud_state {
		// align left
		hud.command_destination = MENU_LEFT_SHOWING
	} else {
		hud.command_destination = MENU_LEFT_HIDDEN
	}
	if .Shop in hud_state {
		// align right
		hud.shop_destination = MENU_RIGHT_SHOWING
	} else {
		hud.shop_destination = MENU_RIGHT_HIDDEN
	}
	if .None in hud_state {
		hud.command_destination = MENU_LEFT_HIDDEN
		hud.shop_destination = MENU_RIGHT_HIDDEN
	}
	// move hud
	Hud_Move_Current_position(&hud.command_current, &hud.command_destination)
	Hud_Move_Current_position(&hud.shop_current, &hud.shop_destination)
}


Hud_Move_Current_position :: proc(current, destination: ^f32) {
	distance := destination^ - current^ // TODO: there must be some math to do this
	if distance != 0 { 	// some distance
		if distance > 0 { 	// positive distance
			if distance < MENU_SPEED { 	// distance is lower than our speed
				current^ = destination^ // just set to destination
			} else {current^ += MENU_SPEED} 	// move hud
		} else { 	// distance is negative, so speed must be negative
			if distance > -MENU_SPEED { 	// distance is smaller than negative, so, bigger :weird:
				current^ = destination^ // move to destination
			} else {current^ -= MENU_SPEED}
		}
	}
}
