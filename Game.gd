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

var board_state = []

func _ready() -> void:
	draw_board() # Draw tiles
	generate_empty_board()
	set_board_from_fen(starting_fen)
	place_pieces(board_state)

func _process(delta: float) -> void:
	if(Input.is_action_just_pressed("mouse_left")):
		print(Utils.get_cords_from_mouse())
	if(Input.is_action_just_pressed("ui_accept")):
		print(get_board_state() == board_state)

func draw_board() -> void:
	for y in 8:
		for x in 8:
			var square = ColorRect.new()
			square.color = dark_color if (y + x) % 2 != 0 else light_color
			square.rect_min_size = Vector2(8,8)
			$Grid.add_child(square)

func generate_empty_board() -> void:
	for x in 64:
		board_state.append([])
		board_state[x] = '.'

func set_board_from_fen(fen: String) -> void:
	var fen_pieces = fen.split(' ', true, 1)[0]
	var i := 0
	for c in fen_pieces:
		match c:
			"/":
				pass
			"1", "2", "3", "4", "5", "6", "7", "8":
				i += int(c)
			_:
				board_state[i] = c
				i += 1

func place_pieces(board: Array) -> void:
	var pieces_dict = {
		'k': King,
		'p': Pawn,
		'n': Knight,
		'b': Bishop,
		'r': Rook,
		'q': Queen
	}
	var i = 0
	for c in board:
		if c == '.':
			i += 1
		else:
			var is_light = (c == c.to_upper())
			var piece = pieces_dict[c.to_lower()].instance()
			piece.is_light = is_light
			piece.index_on_board = i
			piece.fen_symbol = c
			$Pieces.add_child(piece)
			var point = Utils.get_point_from_index(i)
			Utils.place_piece_at_vector(point, piece)
			i += 1

func get_board_state() -> Array:
	var board = []
	for x in 64:
		board.append([])
		board[x] = '.'
	
	for piece in $Pieces.get_children():
		var piece_index = piece.index_on_board
		board[piece_index] = piece.fen_symbol
	return board
