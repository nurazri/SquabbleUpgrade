extends Node2D

const _PATH_TO_FILTERED_WORD_LIST: String = "res://words_dictionary_processed.json"
const _PATH_TO_WORD_LIST: String = "res://words_dictionary.json"


func _ready() -> void:
	var _word_list: Dictionary = JSONLoader.load_json(_PATH_TO_WORD_LIST)
	save_filtered_word_list(filter(_word_list))
	get_tree().quit()
	

func filter(word_list: Dictionary) -> Dictionary:
	# warning-ignore:return_value_discarded
	var pass1: Dictionary
	for word in word_list:
		var count: int = 0
		for w in word:
			if _is_vowel(w):
				count += 1
				if count > 2:					
					break
			else:
				count = 0
		if count <= 2:
			pass1[word] = 1
	
	# warning-ignore:return_value_discarded
	var pass2: Dictionary
	for word in pass1:
		var count: int = 0
		for w in word:
			if not _is_vowel(w):
				count += 1
		if (count < 3 and word.substr(1, 1).to_lower() == "y") or not count == word.length():
			pass2[word] = 1
	
	var exceptions = [
		"by", 
		"cymry", "cyst", "cry", "crypt", "crypts", 
		"dyn", "dry",
		"fly", "flyby", "flybys", "flysch", "fry",
		"gym", "gymsl", "gypsy", "glycyl", "glycyls", "glyph", "glyphs",
		"hymn", "hymns",		
		"lymph", "lymphs", "lymphy", "lynch", "lynx",
		"my", "myrrh", "myrrhy", "myrrhs", "myst", "myth", "myths",
		"nymph", "nymphs", 
		"pygmy", "pry", "psych", "psychs",
		"rhymy", "rhythm", "rhythms",
		"scyth", "shy", "shyly", "sky", "sylph", "sylphs", 
		"sync", "syncs", "sly", "spry", "spryly",
		"thy", "try",
		"why", "wynn", "wynns", "wynd", "wynds", "wry", "wryly"
	]
	for e in exceptions:
		pass2[e] = 1
		
	var removed = [
		"ac", "adv", "afb", "aix", "ako", "alc", "alo", "avg", "avn", "ald", "aud", "aux",
		"borh",
		"ca", "cid", "cif", "cfi", "civ", "cpu", "cul", "copr", "cto",
		"dca", "divi", "dob",
		"emf", "enc", "epa", "err", "esp", "ext", 
		"faq", "fei", "ffa", "fu",
		"ge", "gez", "gov",
		"hsi", "hud",
		"ide", "ign", "ihi", "ihs", "im", "imi", "impf", "itd", "ios", "iq", "iv", "iyo",
		"jon", "juv",
		"kil",
		"lak", "lif", "liq", "liz",
		"mal", "meo",
		"naf", "nea", "nov",
		"oct",
		"pul", 
		"qaf", "qto",
		"rea", "reit", "req"," rio", "rte",
		"taa", "tez", "tji", "tob", "tu", "tlo", "twi",
		"uji", "umu", "unp", "urf",
		"xvi",
		"vai", "vii",
		"wi", "wei", "wun", "wut", "wup",
		"yat", "yee", "yi", "yoy", "yuh",
	]	
		
	for r in removed:
		pass2.erase(r)
		
	# for word in pass2:
	# 	var count: int = 0
	# 	for w in word:
	# 		if _is_vowel(w):
	# 			count += 1		
	# 	if not count == word.length():
	# 		pass3[word] = 1

	return pass2
	
	
func save_filtered_word_list(filtered: Dictionary) -> void:
	JSONLoader.save_json(filtered, _PATH_TO_FILTERED_WORD_LIST)


func _is_vowel(c: String) -> bool:
	c = c.to_lower()
	return c == "a" or c == "e" or c == "i" or c == "o" or c == "u"
