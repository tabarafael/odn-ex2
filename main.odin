#+feature dynamic-literals
package main

import "core:fmt"
import rl "vendor:raylib"

SCREEN_X :: 1920
SCREEN_Y :: 1080
TARGET_FPS :: 60
BUTTON_FRAMES: i32 : 3
FONT_SIZE: i32 : 24

Hud_State_Set :: distinct bit_set[Hud_State_Enum;u32]
hud_state: Hud_State_Set = {.Start}

hud_command :: []cstring{"Barracks", "Archery", "Cavalry"}
hud_start :: []cstring{"Start"}
hud_shop :: []cstring{"pork", "upgrade"}
hud_wing :: []cstring{">", "<"}


main :: proc() {
	rl.InitWindow(SCREEN_X, SCREEN_Y, "pwdm")
	rl.SetTargetFPS(TARGET_FPS)
	using rl

	button_texture := LoadTexture("resources/button.png")
	button_wings_texture := LoadTexture("resources/wing.png")

	hud_alignment := Hud_Alignment {
		command_current     = MENU_LEFT_HIDDEN,
		command_destination = MENU_LEFT_HIDDEN,
		shop_current        = SCREEN_X + MENU_THICKNESS,
		shop_destination    = SCREEN_X + MENU_THICKNESS,
	}

	main_menu: #soa[dynamic]Button
	Make_Button(
		&main_menu,
		button_texture,
		hud_start,
		f32(SCREEN_X / 2 - button_texture.width / 2),
		f32(SCREEN_Y / 2 - button_texture.height),
	)

	wings_menu: #soa[dynamic]Button
	Make_Hud_Wings_Button(&wings_menu, button_wings_texture, hud_wing, 0)

	command_menu: #soa[dynamic]Button
	Make_Button(&command_menu, button_texture, hud_command, 0, 0)

	shop_menu: #soa[dynamic]Button
	Make_Button(&shop_menu, button_texture, hud_shop, 0, 0)


	for !rl.WindowShouldClose() {
		Handle_Hud_Position(&hud_state, &hud_alignment)

		mousepoint := GetMousePosition()
		if .Start in hud_state {
			for &button in main_menu {
				button.state = 0

				if CheckCollisionPointRec(mousepoint, button.bounds) {
					button.state = IsMouseButtonDown(.LEFT) ? 2 : 1
					button.action = IsMouseButtonReleased(.LEFT)
				}

				button.source_rec.y = f32(button.state * button.frame_height)

				if button.action {
					hud_state = (hud_state | {.Command}) &~ {.Start}
					clear(&main_menu) // change it to a HIDE
				}
			}
		}
		for &button in command_menu {
			button.state = 0
			button.bounds.x = hud_alignment.command_current

			if CheckCollisionPointRec(mousepoint, button.bounds) {
				button.state = IsMouseButtonDown(.LEFT) ? 2 : 1
				button.action = IsMouseButtonReleased(.LEFT)
			}

			button.source_rec.y = f32(button.state * button.frame_height)

			if button.action {
				fmt.println("action")
			}
		}

		for &button in shop_menu {
			button.state = 0
			button.bounds.x = hud_alignment.shop_current

			if CheckCollisionPointRec(mousepoint, button.bounds) {
				button.state = IsMouseButtonDown(.LEFT) ? 2 : 1
				button.action = IsMouseButtonReleased(.LEFT)
			}

			button.source_rec.y = f32(button.state * button.frame_height)

			if button.action {
				fmt.printfln("action")
			}
		}

		for &button in wings_menu {
			button.state = 0

			if CheckCollisionPointRec(mousepoint, button.bounds) {
				button.state = IsMouseButtonDown(.LEFT) ? 2 : 1
				button.action = IsMouseButtonReleased(.LEFT)
			}

			button.source_rec.y = f32(button.state * button.frame_height)

			if button.action {
				fmt.println("action")
			}
		}

		wings_menu[0].bounds.x = hud_alignment.shop_current - f32(wings_menu[0].texture.width)
		wings_menu[1].bounds.x = hud_alignment.command_current + MENU_THICKNESS
		for &button in wings_menu {
			button.state = 0
			if CheckCollisionPointRec(mousepoint, button.bounds) {
				button.state = IsMouseButtonDown(.LEFT) ? 2 : 1
				button.action = IsMouseButtonReleased(.LEFT)
			}
			button.source_rec.y = f32(button.state * button.frame_height)
		}


		if wings_menu[1].action {
			hud_state = (hud_state ~ {.Command})
		}
		if wings_menu[0].action {
			hud_state = (hud_state ~ {.Shop})
		}


		BeginDrawing()
		ClearBackground(rl.SKYBLUE)


		DrawRectangleV(
			Vector2{hud_alignment.command_current, 0},
			Vector2{MENU_THICKNESS, SCREEN_Y},
			BROWN,
		)
		DrawRectangleV(
			Vector2{hud_alignment.shop_current, 0},
			Vector2{MENU_THICKNESS, SCREEN_Y},
			BROWN,
		)
		Draw_Buttons(&wings_menu)
		Draw_Buttons(&main_menu)
		Draw_Buttons(&command_menu)
		Draw_Buttons(&shop_menu)
		rl.EndDrawing()
	}
}
