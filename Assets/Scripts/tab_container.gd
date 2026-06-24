extends TabContainer

func _ready():
	var back_button = get_node("../Back")
	if back_button:
		self.focus_neighbor_bottom = back_button.get_path()
		back_button.focus_neighbor_top = self.get_path()
	
	self.focus_mode = Control.FOCUS_ALL
	
	await get_tree().process_frame
	self.grab_focus()

func _gui_input(event):
	# Si le TabContainer a le focus et qu'on appuie sur Gauche/Droite
	if has_focus():
		if event.is_action_pressed("ui_right"):
			# Passe à l'onglet suivant (et boucle si on dépasse)
			current_tab = (current_tab + 1) % get_tab_count()
			accept_event() # Dit à Godot qu'on a géré l'input
		elif event.is_action_pressed("ui_left"):
			# Passe à l'onglet précédent
			current_tab = (current_tab - 1 + get_tab_count()) % get_tab_count()
			accept_event()
