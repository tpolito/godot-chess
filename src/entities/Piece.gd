extends Node2D
class_name Piece

onready var sprite = $Sprite

export(Texture) var light_sprite
export(Texture) var dark_sprite
export(bool) var is_light
export(int) var index_on_board
export(String) var fen_symbol

func _ready() -> void:
	sprite.texture = light_sprite if is_light else dark_sprite
