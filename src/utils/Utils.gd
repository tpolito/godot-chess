extends Node

func get_rank_file_from_vector(vector: Vector2) -> String:
	var file_dict = {
		0: 'a',
		1: 'b',
		2: 'c',
		3: 'd',
		4: 'e',
		5: 'f',
		6: 'g',
		7: 'h'
	}
	
	var rank_dict = {
		0: 8,
		1: 7,
		2: 6,
		3: 5,
		4: 4,
		5: 3,
		6: 2,
		7: 1
		
	}
	
	var file = file_dict[int(vector.x)]
	var rank = rank_dict[int(vector.y)]
	
	return str(file) + str(rank)

func get_vector_from_rank_file(rankfile):
	var x_dict = {
		'a': 0,
		'b': 1,
		'c': 2,
		'd': 3,
		'e': 4,
		'f': 5,
		'g': 6,
		'h': 7
	}
	
	var y_dict = {
		1: 7,
		2: 6,
		3: 5,
		4: 4,
		5: 3,
		6: 2,
		7: 1,
		8: 0
	}
	
	var file = rankfile[0]
	var rank = int(rankfile[1])
	var x = x_dict[file]
	var y = y_dict[rank]
	
	return Vector2(x,y)

func get_cords_from_mouse() -> Vector2:
	var mouse_pos = get_viewport().get_mouse_position()
	var cords = Vector2(floor(mouse_pos.x / 8), floor(mouse_pos.y / 8))
	
	return cords

# Vector from index
func get_point_from_index(i: int) -> Vector2:
	return Vector2(i % 8, floor(i / 8))

func get_index_from_point(point: Vector2) -> float:
	return point.x + (point.y * 8)

func place_piece_at_rankfile(rankfile: String, piece: Piece) -> void:
	var vector = Utils.get_vector_from_rank_file(rankfile)
	var pos = Vector2((vector.x * 8) + 4, (vector.y * 8) + 4)
	piece.position = pos

func place_piece_at_vector(vector: Vector2, piece: Piece) -> void:
	var pos = Vector2((vector.x * 8) + 4, (vector.y * 8) + 4)
	piece.position = pos

func get_piece_at_index(index: int, node: Node) -> Piece:
	var piece_to_find = null
	for piece in node.get_children():
		var piece_index = piece.index_on_board
		if piece_index == index:
			piece_to_find = piece
	return piece_to_find

func delete_children(node: Node) -> void:
	for n in node.get_children():
		n.queue_free()

func is_even(n: int) -> bool:
	if n % 2 > 0:
		return false
	return true
