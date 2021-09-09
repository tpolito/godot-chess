extends Node2D
class_name Piece

onready var sprite = $Sprite

export(Texture) var light_sprite
export(Texture) var dark_sprite
export(bool) var is_light
export(String) var starting_rankfile = 'a1'

func _ready() -> void:
	sprite.texture = light_sprite if is_light else dark_sprite
	
