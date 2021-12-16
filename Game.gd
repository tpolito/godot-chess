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

var selected_piece
var holding_piece = false

var number_squares_to_edge = []
var dir_offsets = [-8, 8, -1, 1, -9, 9, -7, 7]
var knight_offsets = [-15,-17,-6,10,-10,6,15,17]

func _ready() -> void:
	draw_board() # Draw tiles
	generate_empty_board()
	pre_load_move_data()
	set_board_from_fen(starting_fen)
	place_pieces(board_state)

func _process(_delta: float) -> void:
	move_piece()
	# Debug Stuff
#	if(Input.is_action_just_pressed("mouse_right")):
#		var index = Utils.get_index_from_point(Utils.get_cords_from_mouse())
#		print('Index: ', index)
#		var point = Utils.get_point_from_index(index)
#		print('y:', point.y, ', x:', point.x)
#		print(number_squares_to_edge[index])
	if(Input.is_action_just_pressed("ui_accept")):
		generate_moves()
	if(Input.is_action_just_pressed("debug_reset")):
		get_tree().reload_current_scene()

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

func pre_load_move_data() -> void:
	for y in 8:
		for x in 8:
			number_squares_to_edge.append([])
			var num_north: int = y
			var num_south: int= 7 - y
			var num_west: int = 7 - x
			var num_east: int = x
			var tile_index: int = x + (y  * 8)
			number_squares_to_edge[tile_index] = []

			number_squares_to_edge[tile_index] = [
				num_north,
				num_south,
				num_east,
				num_west,
				min(num_north, num_west), #north west
				min(num_south, num_east), #south east
				min(num_north, num_east), #north east 
				min(num_south, num_west) # south west
			]

func generate_moves() -> Array:
	var moves = []
	reset_board() #DEBUG
	for tile in 64:
		var piece = Utils.get_piece_at_index(tile, $Pieces)
		if piece != null:
			var fen = piece.fen_symbol.to_lower()
			# Bishop + Queen
			# if fen == "b" or fen == "q": 
				# moves += generate_diagonal_moves(tile, piece)
			# Rook + Queen
			# if fen == "r" or fen == "q":
				# moves += generate_cardinal_moves(tile, piece)
			# Knight
			# if fen == "n":
				# moves += generate_knight_moves(tile, piece)
			# Pawn
			if fen == "p":
				moves += generate_pawn_moves(tile, piece)
			# King
#			if fen == "k":
#				moves += generate_king_moves(tile, piece)
	return moves

func generate_diagonal_moves(starting_tile: int, piece: Piece):
	var slideing_moves = []
	# This checks the 
	for dir in range(4,8):
		for n in number_squares_to_edge[starting_tile][dir]:
			var target_tile = starting_tile + dir_offsets[dir] * (n + 1)
			var piece_at_target_tile = Utils.get_piece_at_index(target_tile, $Pieces)
			
			# Target is off the board
			if target_tile < 0 or target_tile > 63:
				break
			# Target is a friendly piece, and we stop moving in this direction
			if piece_at_target_tile != null:
				if piece_at_target_tile.is_light == piece.is_light:
					break
			
			var move = [starting_tile, target_tile]
			slideing_moves += [move]
			color_tile(move[1], $Grid, Color.darkgreen) # DEBUG
			
			# Capture
			if piece_at_target_tile != null:
				if piece.is_light != piece_at_target_tile.is_light:
					break
	return slideing_moves

func generate_cardinal_moves(starting_tile: int, piece: Piece):
	var cardinal_moves = []
	for dir in range(4):
		for n in number_squares_to_edge[starting_tile][dir]:
			var target_tile = starting_tile + dir_offsets[dir] * (n + 1)
			var piece_at_target_tile = Utils.get_piece_at_index(target_tile, $Pieces)
			
			# Target is off the board
			if target_tile < 0 or target_tile > 63:
				break
			# Target is a friendly piece, and we stop moving in this direction
			if piece_at_target_tile != null:
				if piece_at_target_tile.is_light == piece.is_light:
					break
			
			var move = [starting_tile, target_tile]
			cardinal_moves += [move]
			color_tile(move[1], $Grid, Color.darkgreen) # DEBUG
			
			# Capture
			if piece_at_target_tile != null:
				if piece_at_target_tile.is_light != piece.is_light:
					break
	return cardinal_moves

func generate_knight_moves(starting_tile: int, piece: Piece):
	var knight_moves = []
	for dir in range(knight_offsets.size()):
		var target_tile = starting_tile + knight_offsets[dir]
		var target_vector = Utils.get_point_from_index(target_tile)
		var starting_vector = Utils.get_point_from_index(starting_tile)
		var piece_at_target_tile = Utils.get_piece_at_index(target_tile, $Pieces)
		
		# Target is off the board
		if target_tile < 0 or target_tile > 63:
			continue
		
		# Check and make sure they are not moving ouside their range
		if target_vector.x > (starting_vector.x + 2) or target_vector.x < (starting_vector.x - 2):
			continue
		if target_vector.y > (starting_vector.y + 2) or target_vector.y < (starting_vector.y - 2):
			continue
		# Target is a friendly piece, and we stop moving in this direction 
		if piece_at_target_tile != null:
			if piece_at_target_tile.is_light == piece.is_light:
				continue
		
		var move = [starting_tile, target_tile]
		knight_moves += [move]
		color_tile(move[1], $Grid, Color.darkgreen) # DEBUG
		
		# Capture
		if piece_at_target_tile != null:
			if piece_at_target_tile.is_light != piece.is_light:
				continue
	return knight_moves

func generate_pawn_moves(starting_tile: int, piece: Piece):
	var pawn_moves = []
	# var can_double_move = true
	var pawn_offsets = [-7,-8,-9] if piece.is_light else [7,8,9]

	for n in range(pawn_offsets.size()):
		var is_even = Utils.is_even(pawn_offsets[n])# if we are checking an even number than we know we are moving not capturing
		var target_tile = starting_tile + pawn_offsets[n]
		var target_vector = Utils.get_point_from_index(target_tile)
		var starting_vector = Utils.get_point_from_index(starting_tile)
		var piece_at_target = Utils.get_piece_at_index(target_tile, $Pieces)

		# Target is not on the board
		if target_tile < 0 or target_tile > 63:
			continue
		# Pawns cannot capture infront of them, so if there is a piece in front of us we cannot move 
		if piece_at_target != null and is_even:
			continue
		
		if target_vector.x > (starting_vector.x + 1) or target_vector.x < (starting_vector.x - 1):
			continue
		if target_vector.y > (starting_vector.y + 1) or target_vector.y < (starting_vector.y - 1):
			continue
		
		var move = [starting_tile, target_tile]
		pawn_moves += [move]
		color_tile(move[1], $Grid, Color.darkgreen)
	return pawn_moves

func generate_king_moves(starting_tile: int, piece: Piece):
	pass

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

func move_piece() -> void:
	if(Input.is_action_just_pressed("mouse_left") and holding_piece == false):
		# Pick up clicked on piece
		var index = Utils.get_index_from_point(Utils.get_cords_from_mouse())
		selected_piece = Utils.get_piece_at_index(index, $Pieces)
		if selected_piece != null:
			holding_piece = true
		else:
			holding_piece = false
	elif Input.is_action_just_pressed("mouse_left") and holding_piece == true:
		var index = Utils.get_index_from_point(Utils.get_cords_from_mouse())
		# When holding a piece get the piece at the new clicked location, null if empty tile
		var piece_at_click = Utils.get_piece_at_index(index, $Pieces)
		# If the tile is not empty
		if piece_at_click != null:
			# Check if pieces match color if so swap the currently selected piece
			if selected_piece.is_light == piece_at_click.is_light:
				swap_held_piece(piece_at_click)
			else:
				place_piece(selected_piece, index)
				# Clear and re-draw the board with the piece in its new position
				Utils.delete_children($Pieces)
				place_pieces(board_state)
				selected_piece = null
				holding_piece = false
		else:
			# If the clicked tile is empty, place the piece there
			place_piece(selected_piece, index)
			# Clear and re-draw the board with the piece in its new position
			Utils.delete_children($Pieces)
			place_pieces(board_state)
			selected_piece = null
			holding_piece = false

func place_piece(piece: Piece, new_index: int) -> void:
	var prev_index = piece.index_on_board
	board_state[prev_index] = '.'
	board_state[new_index] = piece.fen_symbol

func swap_held_piece(piece: Piece) -> void:
	selected_piece = piece

func color_tile(i: int, node: Node, color: Color) -> void:
	var rect = node.get_children()[i]
	rect.color = color

func reset_board() -> void:
	var children = $Grid.get_children()
	for y in 8:
		for x in 8:
			var index: int = x + (y  * 8)
			var rect = children[index]
			rect.color = dark_color if (y + x) % 2 != 0 else light_color
