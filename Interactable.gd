extends Area2D

export(NodePath) var DialoguePanel
export(String) var StartingBlock


func _input_event(viewport, event, shape_idx):
	if (event is InputEventMouseButton && event.pressed):
		print("Click!")
		get_node("/root/Game/DialogueManager").start_dialogue(StartingBlock)
	
