extends TextureButton

export(NodePath) var DialoguePanel
export(String) var StartingBlock


func _on_TalkToMe_pressed():
	get_node("/root/Game/DialogueManager").start_dialogue(StartingBlock)
