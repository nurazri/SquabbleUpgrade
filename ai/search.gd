extends Node2D


func search_words_to_form(length: int, form_array: Array, attempt_array: Array, time: float) -> Array:
	if form_array.is_empty():
		var picked_letter_id: int = _pick_random_letter_id_from(Globals.LetterOwnership.POOL)
		if picked_letter_id > -1 and attempt_array.find(picked_letter_id) < 0: # if picked letter exists and is not already in attempt_array
			attempt_array.append(picked_letter_id)
			
			return _validate_letter_ids_in_form_attempt(length, form_array, attempt_array, time)
	return form_array


func search_words_to_respell(length: int, respell_array: Array, _respell_temp: Dictionary, _respell_next: Dictionary, _time: float) -> Array:
	if respell_array.is_empty():
		var picked_letter_id: int = _pick_random_letter_id_from(Globals.LetterOwnership.ALL)
		if picked_letter_id > -1:
			var picked_word: Array = WordList.spawned_letters[picked_letter_id]["word"]
			if picked_word.size() < length:
				if _respell_temp[str(length)].size() < length:
					if _respell_temp[str(length)].is_empty() and not picked_word.is_empty():
						_respell_temp[str(length)] = picked_word.duplicate(true)
					elif not _respell_temp[str(length)].is_empty() and picked_word.is_empty():
						if not picked_letter_id in _respell_temp[str(length)]:
							_respell_temp[str(length)].append(picked_letter_id)
				else:
					randomize()
					var r: int = randi() % _respell_temp[str(length)].size()
					var id: int = _respell_temp[str(length)][r]
					
					if not WordList.spawned_letters.has(id):
						_respell_temp[str(length)].clear()
						_respell_next[str(length)].clear()
					else:
						if not id in _respell_next[str(length)]:
							_respell_next[str(length)].append(id)
						
						if _respell_next[str(length)].size() == length:
							respell_array = _respell_next[str(length)].duplicate(true)
#							get_matching_words(respell_array)
#							if respell_array.size() == length:
#								print("[AI] searching " + str(length) + "-letter word to respell: " + WordList.get_string_from_ids(respell_array))

		var word: String = WordList.get_string_from_ids(respell_array)
		if word.length() == length:
			if not WordList.is_valid_word(word, {}, true):
				respell_array.clear()
				for t in _respell_temp:
					_respell_temp[t].clear()
				for n in _respell_next:
					_respell_next[n].clear()
	
	for letters in respell_array:
		if WordList.spawned_letters[letters]["node"]._boost_protected:
			respell_array.clear()
			break
	
	return respell_array


func _pick_random_letter_id_from(who: int) -> int:
	var words: Dictionary = WordList.get_spawned_letters_owned_by(who)
	var word_keys: Array = words.keys()
	
	randomize()
	if not word_keys.is_empty():
		var random_index: int = word_keys[randi() % word_keys.size()]
		if words.has(random_index):
			var random_pick: int = words[random_index]["id"]
			return random_pick
			
	return -1


#Stolen from godot forums
func get_matching_words(available_letters: Array) -> Array:
	var result : Array = []
	for word in WordList._word_list_ai:
		var check_array : Array = available_letters.duplicate()
		var is_match : bool = true
		for letter in word.to_upper():
			var letter_pos = check_array.find(letter)
			if letter_pos == -1:
				is_match = false
				break
			else:
				check_array.remove(letter_pos)
				if is_match: result.append(word)
				
	return result


func _validate_letter_ids_in_form_attempt(length: int, form_array: Array, attempt_array: Array, time: float, _respell: bool = false) -> Array:
	# Check if every letter appended to attempt_array still exists
	for picked in attempt_array:
		if not WordList.spawned_letters.has(picked): # if not, clear attempt_array and start all over again
			attempt_array.clear()
			break
			
	if not attempt_array.is_empty():
		var word: String = WordList.get_string_from_ids(attempt_array) # get the word string from letter ids in attempt_array
		if word.length() == length and WordList.is_valid_word(word, {}, true): # check if the word string has the searched length and is also valid
			form_array = attempt_array.duplicate(true) # found a possible word to form, so make a deep copy of attempt_array and put it in form_array
			attempt_array.clear() # clear attempt_array but form_array still has the letter ids due to deep copy, then get ready to look for the next length-letter word			
			print("[AI] found latest " + str(length) + "-letter word " + str(form_array) + " " + word + " at " + str(time))			
		elif word.length() > length:
			attempt_array.clear()
	return form_array
	
