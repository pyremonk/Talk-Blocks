extends Node

var story = {}
var outputText = []
var outputChoices = []
var curOutputTextIndex = 0
var panel

func _ready():
	# Open JSON file and load to a string to parse
	var file = File.new()
	file.open("res://main.json", file.READ)
	var text = file.get_as_text()
	
	# Load parse result into story dictionary
	story = JSON.parse(text).result
	
	file.close()
	
	panel = get_node("/root/Game/DialogueUI/Panel")
	
	panel.get_node("ContinueButton").connect("pressed", self, "continue_dialogue")
	
	# DEBUG
	start_dialogue("Engineering")

# Starts dialogue from a given block in the story dictionary
func start_dialogue(blockName): # TODO: Add option to provide target dialoguePanel
	
	reset_dialogue()
	
	if get_block(blockName):
		# If there is no dialogue in the outputText, we will check if there are choices to display
		if !outputText.empty():
			# Display dialogue panel
			panel.show()
			# Display first line of dialogue in the current text index
			display_dialogue()
		else:
			# If there are no choices,  close out the dialogue stream
			if !outputChoices.empty():
				display_choices()
			else:
				end_dialogue()
	else:
		print("Block " + blockName + " not found.")

# TODO Update in the future to provide panel and text as params
func display_dialogue():
	# Set text of dialogue panel using curOutputTextIndex
	panel.get_node("Text").text = outputText[curOutputTextIndex]["dialogue"]

func continue_dialogue():
	# check if the dialogue has a set
		# if so, set the flag in storyFlag var
	
	# check if the dialogue has a nextBlock
		# set nextDialogueBlock to nextBlock
		# if so clear_dialogue() and start_dialogue(nextDialogueBlock)
		# pass/return
	
	# check if there is more dialogue to display (curOutputTextIndex + 1 < text.size())
		# if so, increment curOutputTextIndex
		# clear current text, hide continuebutton
		# set next text using curOutputTextIndex
		# show continuebutton (kinda hokey)
	# elif the this the last dialogue (curOutputTextIndex + 1 = text.size()) & there are choices
		# hide continuebutton
		# display_choices()
	# elif this is the last dialogue
		# end_dialogue()
	pass

# I see only FOUR CHOICES!
func display_choices():
	# loop through choices and create buttons with a name plus the choice index
	# connect the buttons to _on_button_pressed here
	pass

func choice_selected():
	# figure out what choice was selected by getting the name of the button pressed and converting using int()
	# check if choice has a set
		# set the variable in the storyFlags global
	# check for nextBlock
		# start_dialogue(nextBlock)
	# else
		# end_dialogue()
	pass 

func end_dialogue():
	reset_dialogue()
	panel.hide()
	pass

func reset_dialogue():
	outputChoices.clear()
	outputText.clear()
	curOutputTextIndex = 0

# Grabs the block from the story dictionary and stores the text and choices into output arrays
func get_block(blockName):
	
	if story["blocks"].has(blockName):
		
		get_block_text(blockName)
		get_block_choices(blockName)
		return true
	else:
		return false

# Grabs any text in a block and udpates the outputText array		
func get_block_text(blockName):
	
	var text = []
	
	# Check for text in block
	if story["blocks"][blockName].has("text"):
		
		text = story["blocks"][blockName]["text"]
		
		# Store applicable text into outputText array
		for i in text.size():
			
			var conditionsMet = true
			
			# Check if the text has ifConditions
			if text[i].has("ifConditions"):
				
				# Loop through ifConditions, break if condition not met
				for ifConditionIndex in text[i]["ifConditions"].size():
					
					var conditionName = text[i]["ifConditions"][ifConditionIndex]
					
					if $"/root/Global".storyFlags.find(conditionName) == -1 :
						print("ifCondition: '" + conditionName + "' not met.")
						conditionsMet = false
					else:
						print("ifCondition: '" + conditionName + "' was met.")
			
			# Check if the text has ifNotConditions
			if conditionsMet && text[i].has("ifNotConditions"):
				
				# Loop through ifNotConditions, break if condition met
				for ifNotConditionIndex in text[i]["ifNotConditions"].size():
					
					var conditionName = text[i]["ifNotConditions"][ifNotConditionIndex]
					
					if $"/root/Global/".storyFlags.find(conditionName) >= 0:
						print("ifNotCondition: '" + conditionName + "' not met.")
						conditionsMet = false
					else:
						print("ifNotCondition: '" + conditionName + "' was met.")
			
			# Add text to outputText array
			if conditionsMet:
				outputText.append(text[i])
			
			# Check if text has nextBlock, if so, stop processing the rest of the text items
			# If a text has a nextBlock, this denotes that dialogue should move to the next block defined
			# after the player continues
			if conditionsMet && text[i].has("nextBlock"):
				break

# Grabs any choices in the block and updates the outputChoices array
func get_block_choices(blockName):
	
	var choices = []
	
	# Check for choices in block
	if story["blocks"][blockName].has("choices"):
		
		choices = story["blocks"][blockName]["choices"]
		
		# Store applicable choices into outputChoices array
		for i in choices.size():
			
			var conditionsMet = true
			
			# Check if the text has ifConditions
			if choices[i].has("ifConditions"):
				
				# Loop through ifConditions, break if condition not met
				for ifConditionIndex in choices[i]["ifConditions"].size():
					
					var conditionName = choices[i]["ifConditions"][ifConditionIndex]
					
					if $"/root/Global".storyFlags.find(conditionName) == -1 :
						print("ifCondition: '" + conditionName + "' not met.")
						conditionsMet = false
					else:
						print("ifCondition: '" + conditionName + "' was met.")
			
			# Check if the choices has ifNotConditions
			if conditionsMet && choices[i].has("ifNotConditions"):
				
				# Loop through ifNotConditions, break if condition met
				for ifNotConditionIndex in choices[i]["ifNotConditions"].size():
					
					var conditionName = choices[i]["ifNotConditions"][ifNotConditionIndex]
					
					if $"/root/Global/".storyFlags.find(conditionName) >= 0:
						print("ifNotCondition: '" + conditionName + "' not met.")
						conditionsMet = false
					else:
						print("ifNotCondition: '" + conditionName + "' was met.")
			
			# Add text to outputText array
			if conditionsMet:
				outputChoices.append(choices[i])