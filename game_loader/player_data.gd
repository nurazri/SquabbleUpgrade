extends Node2D


var default_player_data: Dictionary = {
	"settings": {
		"is_muted_music": false,
		"is_muted_sfx": false
	},
	"avatar": Globals.AvatarCharacter.DEFAULT,
	"owned_avatars": { 
		str(Globals.AvatarCharacter.DEFAULT): 1,
		str(Globals.AvatarCharacter.CAT): 1,
	},
	"booster_owned": {
		str(Globals.BoosterType.BLAST): {
			"1": 0,
			"2": 0,
			"3": 0
		},
		str(Globals.BoosterType.FREEZE): {
			"1": 0,
			"2": 0,
			"3": 0
		},
		str(Globals.BoosterType.PROTECT): {
			"1": 0,
			"2": 0,
			"3": 0
		},
		str(Globals.BoosterType.BREAK): {
			"1": 0,
			"2": 0,
			"3": 0
		},
	},
	"booster_parameters": {
		str(Globals.BoosterType.BLAST):{
			"Discovered": 0,
			"Discovered_Tier_1": 0,
			"Discovered_Tier_2": 0,
			"Discovered_Tier_3": 0
		},
		str(Globals.BoosterType.FREEZE):{
			"Discovered": 0,
			"Discovered_Tier_1": 0,
			"Discovered_Tier_2": 0,
			"Discovered_Tier_3": 0
		},
		str(Globals.BoosterType.PROTECT):{
			"Discovered": 0,
			"Discovered_Tier_1": 0,
			"Discovered_Tier_2": 0,
			"Discovered_Tier_3": 0
		},
		str(Globals.BoosterType.BREAK):{
			"Discovered": 0,
			"Discovered_Tier_1": 0,
			"Discovered_Tier_2": 0,
			"Discovered_Tier_3": 0
		},
	},
	"is_first_time": true,
	"completed_tutorial": false,
	"disable_ads": false,
	"has_rated": false,
	"last_logged_in": {
		"day": 0,
		"month": 0,
		"year": 0,
		"hour": 0,
		"minute": 0
	},
	"tutorial_intro": 1,
	"current_level": 1,
	"squabble_name": "",
	"unlocked_booster_slot": [0, 0, 0, 0],
	"equipped_booster_type": [-1, -1, -1, -1],
	"equipped_booster_level": [-1, -1, -1, -1],
	"best_word_list": [],
	"level_progression":{
		"1": {
			"completion": 1,
			"rating": 0,
			"rewardtype": {
				"2": "coins",
				"3": "diamonds"
			},
			"rewardamount": {
				"2": 100,
				"3": 5
			}
		},
		"2": {
			"completion": 0,
			"rating": 0,
			"rewardtype": {
				"2": "coins",
				"3": "diamonds"
			},
			"rewardamount": {
				"2": 100,
				"3": 5
			}
		},
		"3": {
			"completion": 0,
			"rating": 0,
			"rewardtype": {
				"2": "coins",
				"3": "diamonds"
			},
			"rewardamount": {
				"2": 100,
				"3": 5
			}
		},
		"4": {
			"completion": 0,
			"rating": 0,
			"rewardtype": {
				"2": "coins",
				"3": "diamonds"
			},
			"rewardamount": {
				"2": 100,
				"3": 5
			}
		},
		"5": {
			"completion": 0,
			"rating": 0,
			"rewardtype": {
				"2": "coins",
				"3": "diamonds"
			},
			"rewardamount": {
				"2": 100,
				"3": 5
			}
		},
		"6": {
			"completion": 0,
			"rating": 0,
			"rewardtype": {
				"2": "coins",
				"3": "diamonds"
			},
			"rewardamount": {
				"2": 100,
				"3": 5
			}
		},
		"7": {
			"completion": 0,
			"rating": 0,
			"rewardtype": {
				"2": "coins",
				"3": "diamonds"
			},
			"rewardamount": {
				"2": 100,
				"3": 5
			}
		},
		"8": {
			"completion": 0,
			"rating": 0,
			"rewardtype": {
				"2": "coins",
				"3": "coins"
			},
			"rewardamount": {
				"2": 50,
				"3": 100
			}
		},
		"9": {
			"completion": 0,
			"rating": 0,
			"rewardtype": {
				"2": "coins",
				"3": "coins"
			},
			"rewardamount": {
				"2": 50,
				"3": 100
			}
		},
		"10": {
			"completion": 0,
			"rating": 0,
			"rewardtype": {
				"2": "coins",
				"3": "booster"
			},
			"rewardamount": {
				"2": 50,
				"3": 1
			},
			"extra": {
				"type": Globals.BoosterType.FREEZE,
				"tier": 1
			}
		},
		"11": {
			"completion": 0,
			"rating": 0,
			"rewardtype": {
				"2": "coins",
				"3": "coins"
			},
			"rewardamount": {
				"2": 50,
				"3": 100
			}
		},
		"12": {
			"completion": 0,
			"rating": 0,
			"rewardtype": {
				"2": "coins",
				"3": "coins"
			},
			"rewardamount": {
				"2": 50,
				"3": 100
			}
		},
		"13": {
			"completion": 0,
			"rating": 0,
			"rewardtype": {
				"2": "coins",
				"3": "booster"
			},
			"rewardamount": {
				"2": 50,
				"3": 1
			},
			"extra": {
				"type": Globals.BoosterType.FREEZE,
				"tier": 1
			}
		},
		"14": {
			"completion": 0,
			"rating": 0,
			"rewardtype": {
				"2": "coins",
				"3": "booster"
			},
			"rewardamount": {
				"2": 50,
				"3": 1
			},
			"extra": {
				"type": Globals.BoosterType.FREEZE,
				"tier": 2
			}
		},
		"15": {
			"completion": 0,
			"rating": 0,
			"rewardtype": {
				"2": "coins",
				"3": "booster"
			},
			"rewardamount": {
				"2": 50,
				"3": 1
			},
			"extra": {
				"type": Globals.BoosterType.FREEZE,
				"tier": 2
			}
		},
		"16": {
			"completion": 0,
			"rating": 0,
			"rewardtype": {
				"2": "coins",
				"3": "coins"
			},
			"rewardamount": {
				"2": 50,
				"3": 100
			},
		},
		"17": {
			"completion": 0,
			"rating": 0,
			"rewardtype": {
				"2": "coins",
				"3": "booster"
			},
			"rewardamount": {
				"2": 50,
				"3": 2
			},
			"extra": {
				"type": Globals.BoosterType.FREEZE,
				"tier": 2
			}
		},
		"18": {
			"completion": 0,
			"rating": 0,
			"rewardtype": {
				"2": "coins",
				"3": "coins"
			},
			"rewardamount": {
				"2": 50,
				"3": 100
			}
		},
		"19": {
			"completion": 0,
			"rating": 0,
			"rewardtype": {
				"2": "coins",
				"3": "coins"
			},
			"rewardamount": {
				"2": 50,
				"3": 100
			}
		},
		"20": {
			"completion": 0,
			"rating": 0,
			"rewardtype": {
				"2": "coins",
				"3": "coins"
			},
			"rewardamount": {
				"2": 50,
				"3": 100
			}
		},
		"21": {
			"completion": 0,
			"rating": 0,
			"rewardtype": {
				"2": "coins",
				"3": "booster"
			},
			"rewardamount": {
				"2": 50,
				"3": 1
			},
			"extra": {
				"type": Globals.BoosterType.FREEZE,
				"tier": 1
			}
		},
		"22": {
			"completion": 0,
			"rating": 0,
			"rewardtype": {
				"2": "coins",
				"3": "coins"
			},
			"rewardamount": {
				"2": 50,
				"3": 100
			}
		},
		"23": {
			"completion": 0,
			"rating": 0,
			"rewardtype": {
				"2": "coins",
				"3": "booster"
			},
			"rewardamount": {
				"2": 50,
				"3": 1
			},
			"extra": {
				"type": Globals.BoosterType.FREEZE,
				"tier": 1
			}
		},
		"24": {
			"completion": 0,
			"rating": 0,
			"rewardtype": {
				"2": "coins",
				"3": "booster"
			},
			"rewardamount": {
				"2": 50,
				"3": 2
			},
			"extra": {
				"type": Globals.BoosterType.FREEZE,
				"tier": 2
			}
		},
		"25": {
			"completion": 0,
			"rating": 0,
			"rewardtype": {
				"2": "coins",
				"3": "booster"
			},
			"rewardamount": {
				"2": 50,
				"3": 2
			},
			"extra": {
				"type": Globals.BoosterType.FREEZE,
				"tier": 2
			}
		},
		"26": {
			"completion": 0,
			"rating": 0,
			"rewardtype": {
				"2": "coins",
				"3": "coins"
			},
			"rewardamount": {
				"2": 50,
				"3": 100
			}
		},
		"27": {
			"completion": 0,
			"rating": 0,
			"rewardtype": {
				"2": "coins",
				"3": "diamonds"
			},
			"rewardamount": {
				"2": 300,
				"3": 50
			}
		},
		"28": {
			"completion": 0,
			"rating": 0,
			"rewardtype": {
				"2": "coins",
				"3": "booster"
			},
			"rewardamount": {
				"2": 100,
				"3": 1
			},
			"extra": {
				"type": Globals.BoosterType.FREEZE,
				"tier": 1
			}
		},
		"29": {
			"completion": 0,
			"rating": 0,
			"rewardtype": {
				"2": "coins",
				"3": "booster"
			},
			"rewardamount": {
				"2": 100,
				"3": 1
			},
			"extra": {
				"type": Globals.BoosterType.FREEZE,
				"tier": 1
			}
		},
		"30": {
			"completion": 0,
			"rating": 0,
			"rewardtype": {
				"2": "coins",
				"3": "booster"
			},
			"rewardamount": {
				"2": 100,
				"3": 1
			},
			"extra": {
				"type": Globals.BoosterType.BLAST,
				"tier": 1
			}
		},
		"31": {
			"completion": 0,
			"rating": 0,
			"rewardtype": {
				"2": "coins",
				"3": "booster"
			},
			"rewardamount": {
				"2": 100,
				"3": 1
			},
			"extra": {
				"type": Globals.BoosterType.BLAST,
				"tier": 1
			}
		},
		"32": {
			"completion": 0,
			"rating": 0,
			"rewardtype": {
				"2": "coins",
				"3": "booster"
			},
			"rewardamount": {
				"2": 100,
				"3": 1
			},
			"extra": {
				"type": Globals.BoosterType.FREEZE,
				"tier": 1
			}
		},
		"33": {
			"completion": 0,
			"rating": 0,
			"rewardtype": {
				"2": "coins",
				"3": "booster"
			},
			"rewardamount": {
				"2": 100,
				"3": 1
			},
			"extra": {
				"type": Globals.BoosterType.BLAST,
				"tier": 1
			}
		},
		"34": {
			"completion": 0,
			"rating": 0,
			"rewardtype": {
				"2": "coins",
				"3": "booster"
			},
			"rewardamount": {
				"2": 100,
				"3": 1
			},
			"extra": {
				"type": Globals.BoosterType.BLAST,
				"tier": 2
			}
		},
		"35": {
			"completion": 0,
			"rating": 0,
			"rewardtype": {
				"2": "coins",
				"3": "diamonds"
			},
			"rewardamount": {
				"2": 100,
				"3": 10
			}
		},
		"36": {
			"completion": 0,
			"rating": 0,
			"rewardtype": {
				"2": "coins",
				"3": "diamonds"
			},
			"rewardamount": {
				"2": 100,
				"3": 10
			}
		},
		"37": {
			"completion": 0,
			"rating": 0,
			"rewardtype": {
				"2": "coins",
				"3": "booster"
			},
			"rewardamount": {
				"2": 300,
				"3": [2,1]
			},
			"extra": {
				"type": [Globals.BoosterType.BLAST,Globals.BoosterType.BLAST],
				"tier": [2,1]
			}
		},
		"38": {
			"completion": 0,
			"rating": 0,
			"rewardtype": {
				"2": "coins",
				"3": "booster"
			},
			"rewardamount": {
				"2": 150,
				"3": 1
			},
			"extra": {
				"type": Globals.BoosterType.PROTECT,
				"tier": 1
			}
		},
		"39": {
			"completion": 0,
			"rating": 0,
			"rewardtype": {
				"2": "coins",
				"3": "booster"
			},
			"rewardamount": {
				"2": 150,
				"3": 1
			},
			"extra": {
				"type": Globals.BoosterType.FREEZE,
				"tier": 1
			}
		},
		"40": {
			"completion": 0,
			"rating": 0,
			"rewardtype": {
				"2": "coins",
				"3": "booster"
			},
			"rewardamount": {
				"2": 150,
				"3": 1
			},
			"extra": {
				"type": Globals.BoosterType.BLAST,
				"tier": 1
			}
		},
		"41": {
			"completion": 0,
			"rating": 0,
			"rewardtype": {
				"2": "coins",
				"3": "booster"
			},
			"rewardamount": {
				"2": 150,
				"3": 1
			},
			"extra": {
				"type": Globals.BoosterType.BLAST,
				"tier": 1
			}
		},
		"42": {
			"completion": 0,
			"rating": 0,
			"rewardtype": {
				"2": "coins",
				"3": "booster"
			},
			"rewardamount": {
				"2": 150,
				"3": 1
			},
			"extra": {
				"type": Globals.BoosterType.FREEZE,
				"tier": 2
			}
		},
		"43": {
			"completion": 0,
			"rating": 0,
			"rewardtype": {
				"2": "coins",
				"3": "booster"
			},
			"rewardamount": {
				"2": 150,
				"3": 1
			},
			"extra": {
				"type": Globals.BoosterType.BREAK,
				"tier": 1
			}
		},
		"44": {
			"completion": 0,
			"rating": 0,
			"rewardtype": {
				"2": "coins",
				"3": "booster"
			},
			"rewardamount": {
				"2": 150,
				"3": 1
			},
			"extra": {
				"type": Globals.BoosterType.BLAST,
				"tier": 2
			}
		},
		"45": {
			"completion": 0,
			"rating": 0,
			"rewardtype": {
				"2": "coins",
				"3": "diamonds"
			},
			"rewardamount": {
				"2": 150,
				"3": 10
			}
		},
		"46": {
			"completion": 0,
			"rating": 0,
			"rewardtype": {
				"2": "coins",
				"3": "diamonds"
			},
			"rewardamount": {
				"2": 150,
				"3": 10
			}
		},
		"47": {
			"completion": 0,
			"rating": 0,
			"rewardtype": {
				"2": "coins",
				"3": "booster"
			},
			"rewardamount": {
				"2": 300,
				"3": [1,2]
			},
			"extra": {
				"type": [Globals.BoosterType.PROTECT, Globals.BoosterType.BREAK],
				"tier": [1,1]
			}
		},
		"48": {
			"completion": 0,
			"rating": 0,
		}
	}
}

var default_player_achievements: Dictionary = {
	#Win Achievements
	"achievement_perfect_win": { 
		"trophy_title":"You Shall Not Score!", 
		"trophy_description":"Opponent scores ZERO!", 
		"points": 0, 
		"requirement": {
			"1": 1,
			"2": 5,
			"3": 10	
		},
		"rewardtype": {
			"1": "gold",
			"2": "gem",
			"3": "avatar"
		},
		"rewardamount": {
			"1": 1000,
			"2": 100,
			"3": Globals.AvatarCharacter.PARROT
		},
		"rewardstatus": {
			"1": 0,
			"2": 0,
			"3": 0
		}
	},
	
	#Form words Achievements
	"achievement_form_3": { 
		"trophy_title":"3 Letter Streak", 
		"trophy_description":"Form 3 letter words", 
		"points": 0, 
		"requirement": {
			"1": 50,
			"2": 100,
			"3": 200
		},
		"rewardtype": {
			"1": "gold",
			"2": "gem",
			"3": "avatar"
		},
		"rewardamount": {
			"1": 100,
			"2": 10,
			"3": Globals.AvatarCharacter.COW
		},
		"rewardstatus": {
			"1": 0,
			"2": 0,
			"3": 0
		}
	},
	"achievement_form_4": { 
		"trophy_title":"4 Letter Freak", 
		"trophy_description":"Form 4 letter words", 
		"points": 0, 
		"requirement": {
			"1": 25,
			"2": 50,
			"3": 100
		},
		"rewardtype": {
			"1": "gold",
			"2": "gem",
			"3": "avatar"
		},
		"rewardamount": {
			"1": 300,
			"2": 30,
			"3": Globals.AvatarCharacter.MEERKAT
		},
		"rewardstatus": {
			"1": 0,
			"2": 0,
			"3": 0
		}
	},
	"achievement_form_5": { 
		"trophy_title":"5 Letter Frenzy", 
		"trophy_description":"Form 5 letter words", 
		"points": 0, 
		"requirement": {
			"1": 10,
			"2": 20,
			"3": 30
		},
		"rewardtype": {
			"1": "gold",
			"2": "gem",
			"3": "avatar"
		},
		"rewardamount": {
			"1": 600,
			"2": 60,
			"3": Globals.AvatarCharacter.KANGAROO
		},
		"rewardstatus": {
			"1": 0,
			"2": 0,
			"3": 0
		}
	},
	"achievement_form_6": { 
		"trophy_title":"6 Letter Specialist", 
		"trophy_description":"Form 6 letter words", 
		"points": 0, 
		"requirement": {
			"1": 5,
			"2": 10,
			"3": 30
		},
		"rewardtype": {
			"1": "gold",
			"2": "gem",
			"3": "avatar"
		},
		"rewardamount": {
			"1": 1000,
			"2": 100,
			"3": Globals.AvatarCharacter.PENGUIN
		},
		"rewardstatus": {
			"1": 0,
			"2": 0,
			"3": 0
		}
	},
	"achievement_form_7": { 
		"trophy_title":"7 Letter Savant", 
		"trophy_description":"Form 7 letter words", 
		"points": 0, 
		"requirement": {
			"1": 3,
			"2": 6,
			"3": 10
		},
		"rewardtype": {
			"1": "gold",
			"2": "gem",
			"3": "avatar"
		},
		"rewardamount": {
			"1": 2000,
			"2": 200,
			"3": Globals.AvatarCharacter.FLY
		},
		"rewardstatus": {
			"1": 0,
			"2": 0,
			"3": 0
		}
	},
	
	#Steal words achievement
	"achievement_steal_3": { 
		"trophy_title":"Robin Crook", 
		"trophy_description":"Steal 3 letter words", 
		"points": 0, 
		"requirement": {
			"1": 25,
			"2": 50,
			"3": 100
		},
		"rewardtype": {
			"1": "gold",
			"2": "gem",
			"3": "avatar"
		},
		"rewardamount": {
			"1": 200,
			"2": 20,
			"3": Globals.AvatarCharacter.RACCOON
		},
		"rewardstatus": {
			"1": 0,
			"2": 0,
			"3": 0
		}
	},
	"achievement_steal_4": { 
		"trophy_title":"Robin Hood", 
		"trophy_description":"Steal 4 letter words", 
		"points": 0, 
		"requirement": {
			"1": 10,
			"2": 20,
			"3": 30
		},
		"rewardtype": {
			"1": "gold",
			"2": "gem",
			"3": "avatar"
		},
		"rewardamount": {
			"1": 600,
			"2": 60,
			"3": Globals.AvatarCharacter.TAMARIN
		},
		"rewardstatus": {
			"1": 0,
			"2": 0,
			"3": 0
		}
	},
	"achievement_steal_5": { 
		"trophy_title":"LUPIN!", 
		"trophy_description":"Steal 5 letter words", 
		"points": 0, 
		"requirement": {
			"1": 5,
			"2": 10,
			"3": 20
		},
		"rewardtype": {
			"1": "gold",
			"2": "gem",
			"3": "avatar"
		},
		"rewardamount": {
			"1": 1000,
			"2": 100,
			"3": Globals.AvatarCharacter.CHAMELEON
		},
		"rewardstatus": {
			"1": 0,
			"2": 0,
			"3": 0
		}
	},
	
	#Use booster achievement
	"achievement_use_booster_1": {
		"trophy_title":"Help Is Good", 
		"trophy_description":"Use Level 1 Boosters", 
		"points": 0, 
		"requirement": {
			"1": 10,
			"2": 20,
			"3": 30
		},
		"rewardtype": {
			"1": "gold",
			"2": "gem",
			"3": "avatar"
		},
		"rewardamount": {
			"1": 500,
			"2": 50,
			"3": Globals.AvatarCharacter.DOG
		},
		"rewardstatus": {
			"1": 0,
			"2": 0,
			"3": 0
		}
	},
	"achievement_use_booster_2": {
		"trophy_title":"Power To The Winner", 
		"trophy_description":"Use Level 2 Boosters", 
		"points": 0, 
		"requirement": {
			"1": 10,
			"2": 20,
			"3": 30
		},
		"rewardtype": {
			"1": "gold",
			"2": "gem",
			"3": "avatar"
		},
		"rewardamount": {
			"1": 1000,
			"2": 100,
			"3": Globals.AvatarCharacter.DUCK
		},
		"rewardstatus": {
			"1": 0,
			"2": 0,
			"3": 0
		}
	},
	"achievement_use_booster_3": {
		"trophy_title":"Cheating is OK", 
		"trophy_description":"Use Level 3 Boosters", 
		"points": 0, 
		"requirement": {
			"1": 5,
			"2": 10,
			"3": 20
		},
		"rewardtype": {
			"1": "gold",
			"2": "gem",
			"3": "avatar"
		},
		"rewardamount": {
			"1": 2000,
			"2": 200,
			"3": Globals.AvatarCharacter.SHEEP
		},
		"rewardstatus": {
			"1": 0,
			"2": 0,
			"3": 0
		}
	},
	
	#Form word with requirement achievement
	"achievement_form_with_j": { 
		"trophy_title":"Jack of many J's", 
		"trophy_description":"Form words with the \"J\" tile", 
		"points": 0, 
		"requirement": {
			"1": 10,
			"2": 20,
			"3": 40	
		},
		"rewardtype": {
			"1": "gold",
			"2": "gem",
			"3": "avatar"
		},
		"rewardamount": {
			"1": 800,
			"2": 80,
			"3": Globals.AvatarCharacter.RABBIT
		},
		"rewardstatus": {
			"1": 0,
			"2": 0,
			"3": 0
		}
	},
	"achievement_form_with_x": { 
		"trophy_title":"X-Factor", 
		"trophy_description":"Form words with the \"X\" tile", 
		"points": 0, 
		"requirement": {
			"1": 10,
			"2": 20,
			"3": 40	
		},
		"rewardtype": {
			"1": "gold",
			"2": "gem",
			"3": "avatar"
		},
		"rewardamount": {
			"1": 800,
			"2": 80,
			"3": Globals.AvatarCharacter.PEACOCK
		},
		"rewardstatus": {
			"1": 0,
			"2": 0,
			"3": 0
		}
	},
	"achievement_form_with_q": { 
		"trophy_title":"Queen of Q's", 
		"trophy_description":"Form words with the \"Q\" tile", 
		"points": 0, 
		"requirement": {
			"1": 10,
			"2": 20,
			"3": 40	
		},
		"rewardtype": {
			"1": "gold",
			"2": "gem",
			"3": "avatar"
		},
		"rewardamount": {
			"1": 1000,
			"2": 100,
			"3": Globals.AvatarCharacter.UNICORN
		},
		"rewardstatus": {
			"1": 0,
			"2": 0,
			"3": 0
		}
	},
	"achievement_form_with_z": { 
		"trophy_title":"ZZZealot", 
		"trophy_description":"Form words with the \"Z\" tile", 
		"points": 0, 
		"requirement": {
			"1": 10,
			"2": 20,
			"3": 40	
		},
		"rewardtype": {
			"1": "gold",
			"2": "gem",
			"3": "avatar"
		},
		"rewardamount": {
			"1": 1000,
			"2": 100,
			"3": Globals.AvatarCharacter.ZEBRA
		},
		"rewardstatus": {
			"1": 0,
			"2": 0,
			"3": 0
		}
	},
	
	#Misc achievement
	"achievement_watch_ads": {
		"trophy_title":"TV Time", 
		"trophy_description":"Watch Ads", 
		"points": 0, 
		"requirement": {
			"1": 10,
			"2": 20,
			"3": 30
		},
		"rewardtype": {
			"1": "gold",
			"2": "gem",
			"3": "avatar"
		},
		"rewardamount": {
			"1": 1000,
			"2": 100,
			"3": Globals.AvatarCharacter.HAMSTER
		},
		"rewardstatus": {
			"1": 0,
			"2": 0,
			"3": 0
		}
	},
	"achievement_replay_level": {
		"trophy_title":"AGAIN!", 
		"trophy_description":"Replay Levels", 
		"points": 0, 
		"requirement": {
			"1": 5,
			"2": 10,
			"3": 20
		},
		"rewardtype": {
			"1": "gold",
			"2": "gem",
			"3": "avatar"
		},
		"rewardamount": {
			"1": 500,
			"2": 50,
			"3": Globals.AvatarCharacter.HORSE
		},
		"rewardstatus": {
			"1": 0,
			"2": 0,
			"3": 0
		}
	},
}

var current_logins_data: Dictionary = {
	"gpgs_signed_in": false,	
}

var default_player_document: Dictionary = {
	"coins": 0,
	"diamonds": 0,
	"level": 0,
	"title": "Noob",
	"owned_avatars":{
		str(Globals.AvatarCharacter.WOMBAT): 1,
		str(Globals.AvatarCharacter.DOG): 1,
		str(Globals.AvatarCharacter.CAT): 1,
		str(Globals.AvatarCharacter.TAPIR): 1,
		str(Globals.AvatarCharacter.TURKEY): 1
	},
	"achievement_progress":{
		"achievement_perfect_win": 0,
		"achievement_form_3": 0,
		"achievement_form_4": 0,
		"achievement_form_5": 0,
		"achievement_form_6": 0,
		"achievement_form_7": 0,
		"achievement_steal_3": 0,
		"achievement_steal_4": 0,
		"achievement_steal_5": 0,
		"achievement_use_booster_1":0,
		"achievement_use_booster_2":0,
		"achievement_use_booster_3":0,
		"achievement_form_with_j": 0,
		"achievement_form_with_x": 0,
		"achievement_form_with_q": 0,
		"achievement_form_with_z": 0,
		"achievement_watch_ads":0,
		"achievement_replay_level":0
	},
	"achievement_status":{
		"achievement_perfect_win": 0,
		"achievement_form_3": 0,
		"achievement_form_4": 0,
		"achievement_form_5": 0,
		"achievement_form_6": 0,
		"achievement_form_7": 0,
		"achievement_steal_3": 0,
		"achievement_steal_4": 0,
		"achievement_steal_5": 0,
		"achievement_use_booster_1":0,
		"achievement_use_booster_2":0,
		"achievement_use_booster_3":0,
		"achievement_form_with_j": 0,
		"achievement_form_with_x": 0,
		"achievement_form_with_q": 0,
		"achievement_form_with_z": 0,
		"achievement_watch_ads":0,
		"achievement_replay_level":0
	}
}
