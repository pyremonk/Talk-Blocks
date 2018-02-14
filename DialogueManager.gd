extends Node

# TODO ITEMS
# - Add ability to setNextBlock for the target object that started a dialogue?
# - Update portraits
# - Make panel a param so there is a base if not provided or use the one provided
# - Make better choice buttons (have interface to provide an instance rather than create them on the fly)

var story = {}
var outputText = []
var outputChoices = []
var curOutputTextIndex = 0
var curBlock
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

# Starts dialogue from a given block in the story dictionary
func start_dialogue(blockName): # TODO: Add option to provide target dialoguePanel
	
	reset_dialogue()
	
	curBlock = blockName
	
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

# TODO Update in the future to provide panel as param
func display_dialogue():
	# Check for title and set
	if outputText[curOutputTextIndex].has("title"):
		panel.get_node("Title").text = outputText[curOutputTextIndex]["title"]
	else:
		panel.get_node("Title").text = ""
	
	# Set text of dialogue panel using curOutputTextIndex
	panel.get_node("Text").text = outputText[curOutputTextIndex]["dialogue"]
	panel.get_node("ContinueButton").show()

func continue_dialogue():
	# check if the dialogue has a set
	if outputText[curOutputTextIndex].has("set"):
		# if so, set the flag in storyFlag var
		set_flags(outputText[curOutputTextIndex]["set"])
	
	# check if the dialogue has a nextBlock
	if outputText[curOutputTextIndex].has("nextBlock"):
		start_dialogue(outputText[curOutputTextIndex]["nextBlock"])
		return
	
	# check if there is more dialogue to display (curOutputTextIndex + 1 < text.size())
	if (curOutputTextIndex + 1) < outputText.size():
		# if so, increment curOutputTextIndex
		curOutputTextIndex += 1
		
		# set next text using curOutputTextIndex
		# show continuebutton (kinda hokey)
		display_dialogue()
	# elif the this the last dialogue (curOutputTextIndex + 1 = text.size()) & there are choices
	elif (curOutputTextIndex + 1) == outputText.size() && !outputChoices.empty():
		panel.get_node("ContinueButton").show()
		display_choices()
	# else this is the last dialogue
	else:
		end_dialogue()

# I see only FOUR CHOICES!
func display_choices():
	
	panel.get_node("ContinueButton").hide()
	
	# loop through choices and create buttons with a name plus the choice index
	# connect the buttons to _on_button_pressed here
	for i in outputChoices.size():
		
		var choiceButton = Button.new()
		choiceButton.set_name("ChoiceButton" + str(i))
		panel.add_child(choiceButton)
		choiceButton.rect_position = Vector2(450, 10 + 75 * i)
		choiceButton.rect_size = Vector2(200, 50)
		choiceButton.connect("pressed", self, "choice_selected", [choiceButton])
		
		var choiceLabel = Label.new()
		choiceLabel.set_name("ChoiceLabel" + str(i))
		panel.get_node("ChoiceButton" + str(i)).add_child(choiceLabel)
		choiceLabel.rect_position = Vector2(10, 10)
		choiceLabel.rect_size = Vector2(200, 50)
		choiceLabel.autowrap = true
		choiceLabel.text = outputChoices[i]["option"]

func choice_selected(choiceButton):
	# figure out what choice was selected by getting the name of the button pressed and converting using int()
	var choiceIndex = int(choiceButton.name)
	
	# check if choice has a set
	if outputChoices[choiceIndex].has("set"):
		# set the variable in the storyFlags global
		set_flags(outputChoices[choiceIndex]["set"])
	
	# clear choices
	for i in outputChoices.size():
		#panel.get_node("ChoiceButton" + str(i)).set_hidden(false)
		panel.get_node("ChoiceButton" + str(i)).queue_free()
	
	# check for nextBlock
	if outputChoices[choiceIndex].has("nextBlock"):
		start_dialogue(outputChoices[choiceIndex]["nextBlock"])
	else:
		end_dialogue() 

func set_flags(flags):
	for i in flags.size():
			# check if var is already set, if not, set it
			if !$"/root/Global/".storyFlags.has(flags[i]):
				$"/root/Global/".storyFlags.append(flags[i])
				print("[" + curBlock + "] Set: " + flags[i] + " in storyFlags")

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
						print("[" + curBlock + "] Text ifCondition: '" + conditionName + "' not met.")
						conditionsMet = false
					else:
						print("[" + curBlock + "] Text ifCondition: '" + conditionName + "' was met.")
			
			# Check if the text has ifNotConditions
			if conditionsMet && text[i].has("ifNotConditions"):
				
				# Loop through ifNotConditions, break if condition met
				for ifNotConditionIndex in text[i]["ifNotConditions"].size():
					
					var conditionName = text[i]["ifNotConditions"][ifNotConditionIndex]
					
					if $"/root/Global/".storyFlags.find(conditionName) >= 0:
						print("[" + curBlock + "] Text ifNotCondition: '" + conditionName + "' not met.")
						conditionsMet = false
					else:
						print("[" + curBlock + "] Text ifNotCondition: '" + conditionName + "' was met.")
			
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
						print("[" + curBlock + "] Choice ifCondition: '" + conditionName + "' not met.")
						conditionsMet = false
					else:
						print("[" + curBlock + "] Choice ifCondition: '" + conditionName + "' was met.")
			
			# Check if the choices has ifNotConditions
			if conditionsMet && choices[i].has("ifNotConditions"):
				
				# Loop through ifNotConditions, break if condition met
				for ifNotConditionIndex in choices[i]["ifNotConditions"].size():
					
					var conditionName = choices[i]["ifNotConditions"][ifNotConditionIndex]
					
					if $"/root/Global/".storyFlags.find(conditionName) >= 0:
						print("[" + curBlock + "] Choice ifNotCondition: '" + conditionName + "' not met.")
						conditionsMet = false
					else:
						print("[" + curBlock + "] Choice ifNotCondition: '" + conditionName + "' was met.")
			
			# Add text to outputText array
			if conditionsMet:
				outputChoices.append(choices[i])