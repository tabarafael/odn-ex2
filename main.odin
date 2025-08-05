#+feature dynamic-literals
package main

import "core:fmt"
import rl "vendor:raylib"


SCREEN_X :: 1920
SCREEN_Y :: 1080
TARGET_FPS :: 60
BUTTON_FRAMES: i32 : 3
HUD_SPEED: f32 : 20
FONT_SIZE: i32 : 24

Button_Group :: enum {
	left_menu,
	right_menu,
}

Hud_State_Enum :: enum {
	None,
	Start,
	Command,
	Shop,
}

Button :: struct {
	texture:      rl.Texture2D,
	label:        cstring,
	source_rec:   rl.Rectangle,
	bounds:       rl.Rectangle,
	state:        i32,
	frame_height: i32,
	action:       bool,
	menu_group:   Button_Group,
}

Hud_State_Set :: distinct bit_set[Hud_State_Enum;u32]
hud_state: Hud_State_Set = {.Start}

hud_command :: []cstring{"Barracks", "Archery", "Cavalry"}
hud_start :: []cstring{"Start"}


hud_alignment_command: f32 = -500
hud_destination_command: f32 = hud_alignment_command // start the same

main :: proc() {
	rl.InitWindow(SCREEN_X, SCREEN_Y, "pwdm")
	rl.SetTargetFPS(TARGET_FPS)
	using rl

	button_texture := rl.LoadTexture("resources/button.png")

	main_menu: #soa[dynamic]Button
	Button_Make_Main_Menu(&main_menu, button_texture)

	command_menu: #soa[dynamic]Button
	Make_Button(&command_menu, button_texture, hud_command, hud_alignment_command, 0)

	for !rl.WindowShouldClose() {
		Hud_Move(&hud_alignment_command, &hud_destination_command)
		mousepoint := GetMousePosition()
		if .Start in hud_state {
			for &button in main_menu {
				button.state = 0 // TODO change this to a bitset

				if CheckCollisionPointRec(mousepoint, button.bounds) {
					button.state = IsMouseButtonDown(.LEFT) ? 2 : 1
					button.action = IsMouseButtonReleased(.LEFT)
				}

				button.source_rec.y = f32(button.state * button.frame_height)

				if button.action {
					hud_destination_command = 0
					hud_state = (hud_state | {.Command}) &~ {.Start}
					clear(&main_menu)
				}

			}
		}
		if .Command in hud_state {
			for &button in command_menu {
				button.state = 0 // TODO change this to a bitset
				button.bounds.x = hud_alignment_command

				if CheckCollisionPointRec(mousepoint, button.bounds) {
					button.state = IsMouseButtonDown(.LEFT) ? 2 : 1
					button.action = IsMouseButtonReleased(.LEFT)
				}

				button.source_rec.y = f32(button.state * button.frame_height)

				if button.action {
					hud_destination_command = 500
				}

			}
		}
		BeginDrawing()
		ClearBackground(rl.SKYBLUE)
		Draw_Buttons(&command_menu)
		Draw_Buttons(&main_menu)
		rl.EndDrawing()
	}
}


Draw_Buttons :: proc(button_soa: ^#soa[dynamic]Button) {
	for &button in button_soa {
		rl.DrawTextureRec(
			button.texture,
			button.source_rec,
			rl.Vector2{button.bounds.x, button.bounds.y},
			rl.WHITE,
		)

		rl.DrawText(
			button.label,
			i32(button.texture.width / 2) -
			rl.MeasureText(button.label, FONT_SIZE) / 2 +
			i32(button.bounds.x),
			i32(button.bounds.y) - FONT_SIZE / 2 + button.frame_height / 2,
			FONT_SIZE,
			rl.WHITE,
		)
	}
}


Button_Make_Main_Menu :: proc(buttons: ^#soa[dynamic]Button, button_texture: rl.Texture2D) {
	frame_height := button_texture.height / BUTTON_FRAMES
	b := Button {
		label        = "START",
		texture      = button_texture,
		source_rec   = rl.Rectangle{0, 0, f32(button_texture.width), f32(frame_height)},
		bounds       = rl.Rectangle {
			f32(SCREEN_X / 2 - button_texture.width / 2),
			f32(SCREEN_Y / 2 - frame_height / 2),
			f32(button_texture.width),
			f32(frame_height),
		},
		frame_height = frame_height,
		menu_group   = .left_menu,
	}
	append_soa(buttons, b)
}

Make_Button :: proc(
	buttons_soa: ^#soa[dynamic]Button,
	button_texture: rl.Texture2D,
	buttons: []cstring,
	hud_alignment_x: f32,
	hud_alignment_y: f32,
) {
	for x, idx in buttons {
		frame_height := button_texture.height / BUTTON_FRAMES
		b := Button {
			label        = x,
			texture      = button_texture,
			source_rec   = rl.Rectangle{0, 0, f32(button_texture.width), f32(frame_height)},
			bounds       = rl.Rectangle {
				hud_alignment_x,
				hud_alignment_y + f32(frame_height * i32(idx)),
				f32(button_texture.width),
				f32(frame_height),
			},
			frame_height = frame_height,
			menu_group   = .left_menu,
		}
		append_soa(buttons_soa, b)
	}
}

Hud_Move :: proc(location, destination: ^f32) {
	if location^ != destination^ {
		if location < destination {
			location^ += HUD_SPEED
		}
		if location > destination {
			location^ -= HUD_SPEED
		}
	}
}
