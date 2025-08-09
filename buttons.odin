package main

import rl "vendor:raylib"


Button :: struct {
	texture:      rl.Texture2D,
	label:        cstring,
	source_rec:   rl.Rectangle,
	bounds:       rl.Rectangle,
	state:        i32, // TODO change this to a bitset
	frame_height: i32,
	action:       bool,
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
		}
		append_soa(buttons_soa, b)
	}
}

Make_Hud_Wings_Button :: proc(
	buttons_soa: ^#soa[dynamic]Button,
	button_texture: rl.Texture2D,
	buttons: []cstring,
	hud_alignment_y: f32,
) {
	for x, idx in buttons {
		frame_height := button_texture.height / BUTTON_FRAMES
		b := Button {
			label        = x,
			texture      = button_texture,
			source_rec   = rl.Rectangle{0, 0, f32(button_texture.width), f32(frame_height)},
			bounds       = rl.Rectangle {
				0,
				hud_alignment_y,
				f32(button_texture.width),
				f32(frame_height),
			},
			frame_height = frame_height,
		}
		append_soa(buttons_soa, b)
	}
}
