extends Node

const Pawn = preload("res://src/entities/Pawn.tscn")
const Knight = preload("res://src/entities/Knight.tscn")
const Bishop = preload("res://src/entities/Bishop.tscn")
const Rook = preload("res://src/entities/Rook.tscn")
const Queen = preload("res://src/entities/Queen.tscn")
const King = preload("res://src/entities/King.tscn")

export(Color) var light_color
export(Color) var dark_color
export(String) var starting_fen = 'rnbqkbnr/pppppppp/8/8/8/8/PPPPPPPP/RNBQKBNR w KQkq - 0 1'

func _ready() -> void:
	draw_board()
	place_pieces(starting_fen)

func _process(delta: float) -> void:
	if(Input.is_action_just_pressed("mouse_left")):
		var cords = Utils.get_cords_from_mouse()
		var test = Utils.get_rank_file_from_vector(cords)
		print(Utils.get_vector_from_rank_file(test))

func draw_board() -> void:
	for y in 8:
		for x in 8:
			var square = ColorRect.new()
			square.color = dark_color if (y + x) % 2 != 0 else light_color
			square.rect_min_size = Vector2(8,8)
			$Grid.add_child(square)

func place_pieces(fen: String) -> void:
	var fen_pieces = fen.split(' ', true, 1)[0]
	var pieces_dict = {
		'k': King,
		'p': Pawn,
		'n': Knight,
		'b': Bishop,
		'r': Rook,
		'q': Queen
	}
	var file := 0
	var rank := 0
	for c in fen_pieces:
		if c == '/':
			file = 0;
			rank += 1
		else:
			if c.is_valid_integer():
				file += int(c)
			elif c != ' ':
				var is_light = (c == c.to_upper())
				var piece = pieces_dict[c.to_lower()].instance()
				piece.is_light = is_light
				$Pieces.add_child(piece)
				var rankfile = Utils.get_rank_file_from_vector(Vector2(file, rank))
				Utils.place_piece_at_rankfile(rankfile, piece)
				file += 1
