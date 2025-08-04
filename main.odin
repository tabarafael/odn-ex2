#+feature dynamic-literals
package main

import "core:fmt"
import rl "vendor:raylib"

SCREEN_X :: 1280
SCREEN_Y :: 720
TARGET_FPS :: 60
BUTTON_FRAMES: i32 : 3
HUD_SPEED: f32 : 10

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
Hud_State_Set :: distinct bit_set[Hud_State_Enum;u32]
hud_state: Hud_State_Set = {.Start}


Button :: struct {
	texture:      rl.Texture2D,
	source_rec:   rl.Rectangle,
	bounds:       rl.Rectangle,
	state:        i32,
	frame_height: i32,
	action:       bool,
	menu_group:   Button_Group,
}

hud_alignment: f32 = 0
hud_destination: f32 = 0

main :: proc() {
	rl.InitWindow(SCREEN_X, SCREEN_Y, "pwdm")
	rl.SetTargetFPS(TARGET_FPS)
	using rl

	button_soa: #soa[dynamic]Button
	Make_Button(&button_soa)


	//button position


	for !rl.WindowShouldClose() {
		move_hud()
		mousepoint := GetMousePosition()
		for &button in button_soa {
			button.state = 0 // TODO change this to a bitset
			button.bounds.x = hud_alignment

			if CheckCollisionPointRec(mousepoint, button.bounds) {
				button.state = IsMouseButtonDown(.LEFT) ? 2 : 1
				button.action = IsMouseButtonReleased(.LEFT)
			}

			button.source_rec.y = f32(button.state * button.frame_height)

			if button.action {
				hud_destination = 500
			}

		}
		BeginDrawing()
		ClearBackground(rl.SKYBLUE)

		for &button in button_soa {
			DrawTextureRec(
				button.texture,
				button.source_rec,
				Vector2{button.bounds.x, button.bounds.y},
				WHITE,
			)
		}
		rl.EndDrawing()
	}
}

Make_Button :: proc(buttons: ^#soa[dynamic]Button) {
	for x in 0 ..< 5 {
		button_texture := rl.LoadTexture("resources/button.png")
		frame_height := button_texture.height / BUTTON_FRAMES
		b := Button {
			texture      = button_texture,
			source_rec   = rl.Rectangle{0, 0, f32(button_texture.width), f32(frame_height)},
			bounds       = rl.Rectangle {
				0,
				f32(frame_height * i32(x)),
				f32(button_texture.width),
				f32(frame_height),
			},
			frame_height = frame_height,
			menu_group   = .left_menu,
		}
		append_soa(buttons, b)
	}
}

move_hud :: proc() {
	fmt.println(hud_alignment, hud_destination)
	if hud_alignment != hud_destination {
		if hud_alignment < hud_destination {
			hud_alignment += HUD_SPEED
		}
		if hud_alignment > hud_destination {
			hud_alignment -= HUD_SPEED
		}
	}
}
