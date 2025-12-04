extends Node

@export var debug_tools: bool = false

enum Analytics { ALL, FIREBASE, TENJIN, BYTEBREW }
@export var analytics_turned_on: bool = true

enum PageType { HOME, PROFILE, CUSTOM_GAME, ACHIEVEMENT, INVENTORY,  SHOP}
const PageName: Dictionary = {
	PageType.HOME: "",
	PageType.PROFILE: "Profile_Page",
	PageType.CUSTOM_GAME: "Custom_Game_Page",
	PageType.ACHIEVEMENT: "Achievement_Page",
	PageType.INVENTORY: "Inventory_Page",
	PageType.SHOP: "Shop_Page"
}
const PageButtons: Dictionary = {
	PageType.HOME: "Adventure",
	PageType.PROFILE: "",
	PageType.CUSTOM_GAME: "CustomGame",
	PageType.ACHIEVEMENT: "Quests",
	PageType.INVENTORY: "Inventory",
	PageType.SHOP: "Shop"
}

enum GameMode { NONE, TUTORIAL, LOCAL_PLAY, VS_AI, ONLINE_PLAY, ENDLESS }

enum GameType { STANDARD, SPEEDPLAY }

enum LetterOwnership { POOL, BOARD_ME, BOARD_OPPONENT, ALL }


enum AvatarCharacter { DEFAULT, CAT, DOG, TAPIR, TURKEY, WOMBAT, BAT, BEAR, BUZZARD, CHAMELEON, CHEETAH, DONKEY, DUCK, FLY, 
					   FOX, GAZELLE, GIRAFFE, HAMSTER, HEDGEHOG, HORSE, IGUANA, KANGAROO, KOALA, LEMUR, LIONESS, LOBSTER, 
					   MEERKAT, MOUSE, OTTER, PEACOCK, PENGUIN, RABBIT, RACCOON, REDPANDA, RHINOCEROS, SLOTH, SQUIRREL, 
					   TORTOISE, TOUCAN, UNICORN, WALRUS, WOLF, COW, CHICKEN, SHEEP, MONKEY, TAMARIN, BABOON, PARROT, ZEBRA}

const CurrentUnlockableAvatar: Dictionary = {
	AvatarCharacter.DEFAULT: 1,
	AvatarCharacter.CAT: 1,
	AvatarCharacter.COW: 1,
	AvatarCharacter.CHAMELEON: 1,
	AvatarCharacter.DOG: 1,
	AvatarCharacter.DUCK: 1,
	AvatarCharacter.FLY: 1,
	AvatarCharacter.HAMSTER: 1,
	AvatarCharacter.HORSE: 1,
	AvatarCharacter.KANGAROO: 1,
	AvatarCharacter.SHEEP: 1,
	AvatarCharacter.RABBIT: 1,
	AvatarCharacter.RACCOON: 1,
	AvatarCharacter.MEERKAT: 1,
	AvatarCharacter.MONKEY: 1,
	AvatarCharacter.TAMARIN: 1,
	AvatarCharacter.BABOON: 1,
	AvatarCharacter.PARROT: 1, 
	AvatarCharacter.PEACOCK: 1,
	AvatarCharacter.PENGUIN: 1,
	AvatarCharacter.UNICORN: 1,
	AvatarCharacter.ZEBRA: 1,
}
const AvatarTextures: Dictionary = {
	AvatarCharacter.DEFAULT: preload("res://avatar/unlocked_avatar/Chr_default.png"),
	AvatarCharacter.CAT: preload("res://avatar/unlocked_avatar/Chr_cat.png"),
	AvatarCharacter.DOG: preload("res://avatar/unlocked_avatar/Chr_dog.png"),
	AvatarCharacter.TAPIR: preload("res://avatar/unlocked_avatar/Chr_tapir.png"),
	AvatarCharacter.TURKEY: preload("res://avatar/unlocked_avatar/Chr_turkey.png"),
	AvatarCharacter.WOMBAT: preload("res://avatar/unlocked_avatar/Chr_wombat.png"),
	AvatarCharacter.BAT: preload("res://avatar/unlocked_avatar/Chr_bat.png"),
	AvatarCharacter.BEAR: preload("res://avatar/unlocked_avatar/Chr_bear.png"),
	AvatarCharacter.BUZZARD: preload("res://avatar/unlocked_avatar/Chr_buzzard.png"),
	AvatarCharacter.CHAMELEON: preload("res://avatar/unlocked_avatar/Chr_chameleon.png"),
	AvatarCharacter.CHEETAH: preload("res://avatar/unlocked_avatar/Chr_cheetah.png"),
	AvatarCharacter.DONKEY: preload("res://avatar/unlocked_avatar/Chr_donkey.png"),
	AvatarCharacter.DUCK: preload("res://avatar/unlocked_avatar/Chr_duck.png"),
	AvatarCharacter.FLY: preload("res://avatar/unlocked_avatar/Chr_fly.png"),
	AvatarCharacter.FOX: preload("res://avatar/unlocked_avatar/Chr_fox.png"),
	AvatarCharacter.GAZELLE: preload("res://avatar/unlocked_avatar/Chr_gazelle.png"),
	AvatarCharacter.GIRAFFE: preload("res://avatar/unlocked_avatar/Chr_giraffe.png"),
	AvatarCharacter.HAMSTER: preload("res://avatar/unlocked_avatar/Chr_hamster.png"),
	AvatarCharacter.HEDGEHOG: preload("res://avatar/unlocked_avatar/Chr_hedgehog.png"),
	AvatarCharacter.HORSE: preload("res://avatar/unlocked_avatar/Chr_horse.png"),
	AvatarCharacter.IGUANA: preload("res://avatar/unlocked_avatar/Chr_iguana.png"),
	AvatarCharacter.KANGAROO: preload("res://avatar/unlocked_avatar/Chr_kangaroo.png"),
	AvatarCharacter.KOALA: preload("res://avatar/unlocked_avatar/Chr_koala.png"),
	AvatarCharacter.LEMUR: preload("res://avatar/unlocked_avatar/Chr_lemur.png"),
	AvatarCharacter.LOBSTER: preload("res://avatar/unlocked_avatar/Chr_lobster.png"),
	AvatarCharacter.LIONESS: preload("res://avatar/unlocked_avatar/Chr_lioness.png"),
	AvatarCharacter.MEERKAT: preload("res://avatar/unlocked_avatar/Chr_meerkat.png"),
	AvatarCharacter.MOUSE: preload("res://avatar/unlocked_avatar/Chr_mouse.png"),
	AvatarCharacter.OTTER: preload("res://avatar/unlocked_avatar/Chr_otter.png"),
	AvatarCharacter.PEACOCK: preload("res://avatar/unlocked_avatar/Chr_peacock.png"),
	AvatarCharacter.PENGUIN: preload("res://avatar/unlocked_avatar/Chr_penguin.png"),
	AvatarCharacter.RABBIT: preload("res://avatar/unlocked_avatar/Chr_rabbit.png"),
	AvatarCharacter.RACCOON: preload("res://avatar/unlocked_avatar/Chr_raccoon.png"),
	AvatarCharacter.REDPANDA: preload("res://avatar/unlocked_avatar/Chr_redpanda.png"),
	AvatarCharacter.RHINOCEROS: preload("res://avatar/unlocked_avatar/Chr_rhinoceros.png"),
	AvatarCharacter.SLOTH: preload("res://avatar/unlocked_avatar/Chr_sloth.png"),
	AvatarCharacter.SQUIRREL: preload("res://avatar/unlocked_avatar/Chr_squirrel.png"),
	AvatarCharacter.TORTOISE: preload("res://avatar/unlocked_avatar/Chr_tortoise.png"),
	AvatarCharacter.TOUCAN: preload("res://avatar/unlocked_avatar/Chr_toucan.png"),
	AvatarCharacter.UNICORN: preload("res://avatar/unlocked_avatar/Chr_unicorn.png"),
	AvatarCharacter.WALRUS: preload("res://avatar/unlocked_avatar/Chr_walrus.png"),
	AvatarCharacter.WOLF: preload("res://avatar/unlocked_avatar/Chr_wolf.png"),
	AvatarCharacter.COW: preload("res://avatar/unlocked_avatar/Chr_cow.png"),
	AvatarCharacter.CHICKEN: preload("res://avatar/unlocked_avatar/Chr_chicken.png"),
	AvatarCharacter.SHEEP: preload("res://avatar/unlocked_avatar/Chr_sheep.png"),
	AvatarCharacter.MONKEY: preload("res://avatar/unlocked_avatar/Chr_monkey.png"),
	AvatarCharacter.TAMARIN: preload("res://avatar/unlocked_avatar/Chr_tamarin.png"),
	AvatarCharacter.BABOON: preload("res://avatar/unlocked_avatar/Chr_baboon.png"),
	AvatarCharacter.PARROT: preload("res://avatar/unlocked_avatar/Chr_parrot.png"), 
	AvatarCharacter.ZEBRA: preload("res://avatar/unlocked_avatar/Chr_zebra.png")
}
const AvatarLockedTextures: Dictionary = {
	AvatarCharacter.DEFAULT: preload("res://avatar/unlocked_avatar/Chr_default.png"),
	AvatarCharacter.CAT: preload("res://avatar/locked_avatar/Chr_cat_greyscale.png"),
	AvatarCharacter.DOG: preload("res://avatar/locked_avatar/Chr_dog_greyscale.png"),
	AvatarCharacter.TAPIR: preload("res://avatar/locked_avatar/Chr_tapir_greyscale.png"),
	AvatarCharacter.TURKEY: preload("res://avatar/locked_avatar/Chr_turkey_greyscale.png"),
	AvatarCharacter.WOMBAT: preload("res://avatar/locked_avatar/Chr_wombat_greyscale.png"),
	AvatarCharacter.BAT: preload("res://avatar/locked_avatar/Chr_bat_greyscale.png"),
	AvatarCharacter.BEAR: preload("res://avatar/locked_avatar/Chr_bear_greyscale.png"),
	AvatarCharacter.BUZZARD: preload("res://avatar/locked_avatar/Chr_buzzard_greyscale.png"),
	AvatarCharacter.CHAMELEON: preload("res://avatar/locked_avatar/Chr_chameleon_greyscale.png"),
	AvatarCharacter.CHEETAH: preload("res://avatar/locked_avatar/Chr_cheetah_greyscale.png"),
	AvatarCharacter.DONKEY: preload("res://avatar/locked_avatar/Chr_donkey_greyscale.png"),
	AvatarCharacter.DUCK: preload("res://avatar/locked_avatar/Chr_duck_greyscale.png"),
	AvatarCharacter.FLY: preload("res://avatar/locked_avatar/Chr_fly_greyscale.png"),
	AvatarCharacter.FOX: preload("res://avatar/locked_avatar/Chr_fox_greyscale.png"),
	AvatarCharacter.GAZELLE: preload("res://avatar/locked_avatar/Chr_gazelle_greyscale.png"),
	AvatarCharacter.GIRAFFE: preload("res://avatar/locked_avatar/Chr_giraffe_greyscale.png"),
	AvatarCharacter.HAMSTER: preload("res://avatar/locked_avatar/Chr_hamster_greyscale.png"),
	AvatarCharacter.HORSE: preload("res://avatar/locked_avatar/Chr_horse_greyscale.png"),
	AvatarCharacter.HEDGEHOG: preload("res://avatar/locked_avatar/Chr_hedgehog_greyscale.png"),
	AvatarCharacter.IGUANA: preload("res://avatar/locked_avatar/Chr_iguana_greyscale.png"),
	AvatarCharacter.KANGAROO: preload("res://avatar/locked_avatar/Chr_kangaroo_greyscale.png"),
	AvatarCharacter.KOALA: preload("res://avatar/locked_avatar/Chr_koala_greyscale.png"),
	AvatarCharacter.LEMUR: preload("res://avatar/locked_avatar/Chr_lemur_greyscale.png"),
	AvatarCharacter.LOBSTER: preload("res://avatar/locked_avatar/Chr_lobster_greyscale.png"),
	AvatarCharacter.LIONESS: preload("res://avatar/locked_avatar/Chr_lioness_greyscale.png"),
	AvatarCharacter.MEERKAT: preload("res://avatar/locked_avatar/Chr_meerkat_greyscale.png"),
	AvatarCharacter.MOUSE: preload("res://avatar/locked_avatar/Chr_mouse_greyscale.png"),
	AvatarCharacter.OTTER: preload("res://avatar/locked_avatar/Chr_otter_greyscale.png"),
	AvatarCharacter.PEACOCK: preload("res://avatar/locked_avatar/Chr_peacock_greyscale.png"),
	AvatarCharacter.PENGUIN: preload("res://avatar/locked_avatar/Chr_penguin_greyscale.png"),
	AvatarCharacter.RABBIT: preload("res://avatar/locked_avatar/Chr_rabbit_greyscale.png"),
	AvatarCharacter.RACCOON: preload("res://avatar/locked_avatar/Chr_raccoon_greyscale.png"),
	AvatarCharacter.REDPANDA: preload("res://avatar/locked_avatar/Chr_redpanda_greyscale.png"),
	AvatarCharacter.RHINOCEROS: preload("res://avatar/locked_avatar/Chr_rhinoceros_greyscale.png"),
	AvatarCharacter.SLOTH: preload("res://avatar/locked_avatar/Chr_sloth_greyscale.png"),
	AvatarCharacter.SQUIRREL: preload("res://avatar/locked_avatar/Chr_squirrel_greyscale.png"),
	AvatarCharacter.TORTOISE: preload("res://avatar/locked_avatar/Chr_tortoise_greyscale.png"),
	AvatarCharacter.TOUCAN: preload("res://avatar/locked_avatar/Chr_toucan_greyscale.png"),
	AvatarCharacter.UNICORN: preload("res://avatar/locked_avatar/Chr_unicorn_greyscale.png"),
	AvatarCharacter.WALRUS: preload("res://avatar/locked_avatar/Chr_walrus_greyscale.png"),
	AvatarCharacter.WOLF: preload("res://avatar/locked_avatar/Chr_wolf_greyscale.png"),
	AvatarCharacter.COW: preload("res://avatar/locked_avatar/Chr_cow_greyscale.png"),
	AvatarCharacter.CHICKEN: preload("res://avatar/locked_avatar/Chr_chicken_greyscale.png"),
	AvatarCharacter.SHEEP: preload("res://avatar/locked_avatar/Chr_sheep_greyscale.png"),
	AvatarCharacter.MONKEY: preload("res://avatar/locked_avatar/Chr_monkey_greyscale.png"),
	AvatarCharacter.TAMARIN: preload("res://avatar/locked_avatar/Chr_tamarin_greyscale.png"),
	AvatarCharacter.BABOON: preload("res://avatar/locked_avatar/Chr_baboon_greyscale.png"),
	AvatarCharacter.PARROT: preload("res://avatar/locked_avatar/Chr_parrot_greyscale.png"),
	AvatarCharacter.ZEBRA: preload("res://avatar/locked_avatar/Chr_zebra_greyscale.png")
}
const AvatarNames: Dictionary = {
	AvatarCharacter.DEFAULT: "PLAYER",
	AvatarCharacter.CAT: "QUABBLE",
	AvatarCharacter.DOG: "SQUAB",
	AvatarCharacter.TAPIR: "TAPIR",
	AvatarCharacter.TURKEY: "TURKEY",
	AvatarCharacter.WOMBAT: "WALLICE",
	AvatarCharacter.BAT: "BAT",
	AvatarCharacter.BEAR: "BEAR",
	AvatarCharacter.BUZZARD: "BUZZARD",
	AvatarCharacter.CHAMELEON: "ROBBED",
	AvatarCharacter.CHEETAH: "CHEATING",
	AvatarCharacter.DONKEY: "DONKEY",
	AvatarCharacter.DUCK: "DAFFY",
	AvatarCharacter.FLY: "GRIFFITH",
	AvatarCharacter.FOX: "FURY",
	AvatarCharacter.GAZELLE: "GAZELLE",
	AvatarCharacter.GIRAFFE: "GIRAFFE",
	AvatarCharacter.HAMSTER: "JO",
	AvatarCharacter.HORSE: "MARTHA",
	AvatarCharacter.HEDGEHOG: "HEDGEHOG",
	AvatarCharacter.IGUANA: "IGUANA",
	AvatarCharacter.KANGAROO: "HENRY",
	AvatarCharacter.KOALA: "KILLA",
	AvatarCharacter.LEMUR: "LEMUR",
	AvatarCharacter.LOBSTER: "LOBSTER",
	AvatarCharacter.LIONESS: "QING",
	AvatarCharacter.MEERKAT: "PICE",
	AvatarCharacter.MOUSE: "MUMBLY",
	AvatarCharacter.OTTER: "OTTER",
	AvatarCharacter.PEACOCK: "XAVION",
	AvatarCharacter.PENGUIN: "MUMBLE",
	AvatarCharacter.RABBIT: "JUDY",
	AvatarCharacter.RACCOON: "ROB",
	AvatarCharacter.REDPANDA: "REDPANDA",
	AvatarCharacter.RHINOCEROS: "RHINOCEROS",
	AvatarCharacter.SLOTH: "SLOTH",
	AvatarCharacter.SQUIRREL: "SQUIRREL",
	AvatarCharacter.TORTOISE: "TURBO",
	AvatarCharacter.TOUCAN: "TOUCAN",
	AvatarCharacter.UNICORN: "QUETZALLI",
	AvatarCharacter.WALRUS: "WALRUS",
	AvatarCharacter.WOLF: "WOLF",
	AvatarCharacter.COW: "BOB",
	AvatarCharacter.CHICKEN: "HANSOME",
	AvatarCharacter.SHEEP: "SHAWN",
	AvatarCharacter.MONKEY: "MONIAC",
	AvatarCharacter.TAMARIN: "ROBBING",
	AvatarCharacter.BABOON: "BABOON",
	AvatarCharacter.PARROT: "GANDALF",
	AvatarCharacter.ZEBRA: "ZULEMA"
}

const CoinTexture: Dictionary = {
	"Tier_1": preload("res://shop/textures/coins/UI_coin_1.png"),
	"Tier_2": preload("res://shop/textures/coins/UI_coin_2.png"),
	"Tier_3": preload("res://shop/textures/coins/UI_coin_3.png"),
	"Tier_4": preload("res://shop/textures/coins/UI_coin_4.png"),
	"Tier_5": preload("res://shop/textures/coins/UI_coin_5.png"),
	"Tier_6": preload("res://shop/textures/coins/UI_coin_6.png")
}
const DiamondTexture:Dictionary = {
	"Tier_1": preload("res://shop/textures/diamonds/UI_gem_1.png"),
	"Tier_2": preload("res://shop/textures/diamonds/UI_gem_2.png"),
	"Tier_3": preload("res://shop/textures/diamonds/UI_gem_3.png"),
	"Tier_4": preload("res://shop/textures/diamonds/UI_gem_4.png"),
	"Tier_5": preload("res://shop/textures/diamonds/UI_gem_5.png"),
	"Tier_6": preload("res://shop/textures/diamonds/UI_gem_6.png")
}

enum BoosterType { BLAST, FREEZE, PROTECT, BREAK }
const BoosterAttributes: Dictionary = {
	BoosterType.FREEZE: {
		"Info": {
			"Ref_ID": BoosterType.FREEZE,
			"Color": Color("#1e87f0"),
			"Name": "Freeze",
			"Description": "Freeze opponent's movement",
			"Panel": preload("res://booster/textures/UI_panel_booster_freeze.png"),
			"Panel_Info": preload("res://booster/textures/UI_panel_info_booster_freeze.png"),
			"Tier": {
				1: preload("res://booster/textures/Booster_Freeze_T2.png"),
				2: preload("res://booster/textures/Booster_Freeze_T4.png"),
				3: preload("res://booster/textures/Booster_Freeze_T5.png")
			},
			"Class": {
				1: "Weak",
				2: "Power",
				3: "Unfair"
			},
			"Details": {
				1: "FREEZES THE OPPONENT SO THEY CANNOT MAKE ANY MOVES FOR 3 SECONDS",
				2: "FREEZES THE OPPONENT SO THEY CANNOT MAKE ANY MOVES FOR 5 SECONDS",
				3: "FREEZES THE OPPONENT SO THEY CANNOT MAKE ANY MOVES FOR 7 SECONDS"
			},
			#Probably shouldnt be here, will be moved later
			"Cost":{
				1: 100,
				2: 300,
				3: 15
			},
			"Cost_Type":{
				1: "coins",
				2: "coins",
				3: "diamonds"
			}
		},
		"Stat": {
			"Value": {
				"Tier_1": 0,
				"Tier_2": 0,
				"Tier_3": 0,
				},
			"Duration": {
				"Tier_1": 3,
				"Tier_2": 5,
				"Tier_3": 7,
				}
		}
	},
	BoosterType.BLAST: {
		"Info": {
			"Ref_ID": BoosterType.BLAST,
			"Color": Color("#fe3536"),
			"Name": "Blast",
			"Description": "Destroys an existing word by opponent",
			"Panel": preload("res://booster/textures/UI_panel_booster_blast.png"),
			"Panel_Info": preload("res://booster/textures/UI_panel_info_booster_blast.png"),
			"Tier": {
				1: preload("res://booster/textures/Booster_Blast_T1.png"),
				2: preload("res://booster/textures/Booster_Blast_T2.png"),
				3: preload("res://booster/textures/Booster_Blast_T4.png"),
			},
			"Class": {
				1: "Weak",
				2: "Power",
				3: "Unfair"
			},
			"Details": {
				1: "DESTROYS AN EXISTING 3 LETTER WORD FROM BY OPPONENT(PRIORITIZES LONGER WORDS FIRST)",
				2: "DESTROYS AN EXISTING 4 LETTER WORD FROM BY OPPONENT(PRIORITIZES LONGER WORDS FIRST)",
				3: "DESTROYS AN EXISTING 5 LETTER WORD FROM BY OPPONENT(PRIORITIZES LONGER WORDS FIRST)"
			},
			#Probably shouldnt be here, will be moved later
			"Cost":{
				1: 100,
				2: 300,
				3: 15
			},
			"Cost_Type":{
				1: "coins",
				2: "coins",
				3: "diamonds"
			}
		},
		"Stat": {
			"Value": {
				"Tier_1": 3,
				"Tier_2": 4,
				"Tier_3": 5,
				},
			"Duration": {
				"Tier_1": 0,
				"Tier_2": 0,
				"Tier_3": 0,
				}
		}
	},
	BoosterType.PROTECT: {
		"Info": {
			"Ref_ID": BoosterType.PROTECT,
			"Color": Color("#5f3fff"),
			"Name": "Protect",
			"Description": "Protects formed words from being stolen by opponent",
			"Panel": preload("res://booster/textures/UI_panel_booster_protect.png"),
			"Panel_Info": preload("res://booster/textures/UI_panel_info_booster_protect.png"),
			"Tier": {
				1: preload("res://booster/textures/Booster_Protect_T1.png"),
				2: preload("res://booster/textures/Booster_Protect_T2.png"),
				3: preload("res://booster/textures/Booster_Protect_T3.png"),
			},
			"Class": {
				1: "Weak",
				2: "Power",
				3: "Unfair"
			},
			"Details": {
				1: "PROTECTS FORMED WORDS FROM BEING STOLEN BY OPPONENT FOR 10 SECONDS",
				2: "PROTECTS FORMED WORDS FROM BEING STOLEN BY OPPONENT FOR 20 SECONDS",
				3: "PROTECTS FORMED WORDS FROM BEING STOLEN BY OPPONENT FOR 30 SECONDS"
			},
			#Probably shouldnt be here, will be moved later
			"Cost":{
				1: 100,
				2: 300,
				3: 15
			},
			"Cost_Type":{
				1: "coins",
				2: "coins",
				3: "diamonds"
			}
		},
		"Stat": {
			"Value": {
				"Tier_1": 0,
				"Tier_2": 0,
				"Tier_3": 0,
				},
			"Duration": {
				"Tier_1": 20,
				"Tier_2": 30,
				"Tier_3": 40,
				}
		}
	},
	BoosterType.BREAK: {
		"Info": {
			"Ref_ID": BoosterType.BREAK,
			"Color": Color("#ffd146"),
			"Name": "Break",
			"Description": "Breaks formed opponent words into reusable letters",
			"Panel": preload("res://booster/textures/UI_panel_booster_break.png"),
			"Panel_Info": preload("res://booster/textures/UI_panel_info_booster_break.png"),
			"Tier": {
				1: preload("res://booster/textures/Booster_Break_T1.png"),
				2: preload("res://booster/textures/Booster_Break_T2.png"),
				3: preload("res://booster/textures/Booster_Break_T3.png"),
			},
			"Class": {
				1: "Weak",
				2: "Power",
				3: "Unfair"
			},
			"Details": {
				1: "BREAKS 4 LETTER WORDS FORMED BY OPPONENT",
				2: "BREAKS 5 LETTER WORDS FORMED BY OPPONENT",
				3: "BREAKS 6 LETTER WORDS FORMED BY OPPONENT"
			},
			#Probably shouldnt be here, will be moved later
			"Cost":{
				1: 100,
				2: 300,
				3: 15
			},
			"Cost_Type":{
				1: "coins",
				2: "coins",
				3: "diamonds"
			}
		},
		"Stat": {
			"Value": {
				"Tier_1": 4,
				"Tier_2": 5,
				"Tier_3": 6,
				},
			"Duration": {
				"Tier_1": 0,
				"Tier_2": 0,
				"Tier_3": 0,
				}
		}
	},
}

const AvatarBackgroundTextures: Dictionary = {	
	LetterOwnership.BOARD_ME: preload("res://avatar/avatar_base_blue.png"),
	LetterOwnership.BOARD_OPPONENT: preload("res://avatar/avatar_base_red.png")
}

const currentLevelLimit: int = 47
enum Challenge {SCORE, STEAL, FORM, FORM_WITH, FORM_POINTS, USE_BOOSTER, OVER_WIN, FLAWLESS_WIN, SPECIFIC_WIN}
enum Opponent { QUABBLE, WALLICE, KILLA, QUARREL, MONIAC, HANSOME, MUMBLY, SHAWN, FURY, CHEATING, TURBO, LIONA }
const OpponentList: Dictionary = {
	Opponent.QUABBLE: {
		"Avatar": AvatarTextures[AvatarCharacter.CAT],
		"Avatar_BG": AvatarBackgroundTextures[LetterOwnership.BOARD_OPPONENT],
		"Name": "Quabble",
		"Point_Requirement": 35,
		"Min_Level": 1,
		"Max_Level": 7,
		"Dictionary_Level": "elementary",
		"Difficulty": "tutorial"
	},
	Opponent.WALLICE: {
		"Avatar": AvatarTextures[AvatarCharacter.WOMBAT],
		"Avatar_BG": AvatarBackgroundTextures[LetterOwnership.BOARD_OPPONENT],
		"Name": "Wallice",
		"Point_Requirement": 35,
		"Min_Level": 8,
		"Max_Level": 17,
		"Dictionary_Level": "elementary",
		"Difficulty": "beginner",
		"Challenge": {
			"1": {
				"From": [1, 10],
				"Type": [Challenge.SCORE, Challenge.FORM, Challenge.STEAL],
				"Parameter": [0, 5, 0],
				"Requirement": [35, 1, 1]
			}
		}
	},
	Opponent.KILLA:{
		"Avatar": AvatarTextures[AvatarCharacter.KOALA],
		"Avatar_BG": AvatarBackgroundTextures[LetterOwnership.BOARD_OPPONENT],
		"Name": "Killa",
		"Point_Requirement": 50,
		"Min_Level": 18,
		"Max_Level": 27,
		"Dictionary_Level": "elementary",
		"Difficulty": "medium",
		"Challenge": {
			"1": {
				"From": [1, 3],
				"Type": [Challenge.SCORE, Challenge.FORM, Challenge.STEAL],
				"Parameter": [0, 3, 0],
				"Requirement": [50, 5, 1]
			},
			"2": {
				"From": [4,4],
				"Type": [Challenge.SCORE, Challenge.STEAL, Challenge.STEAL],
				"Parameter": [0, 0, 0],
				"Requirement": [50, 1, 2]
			},
			"3": {
				"From": [5,8],
				"Type": [Challenge.SCORE, Challenge.FORM, Challenge.FORM],
				"Parameter": [0, 4, 5],
				"Requirement": [50, 3, 1]
			},
			"4": {
				"From": [9,10],
				"Type": [Challenge.SCORE, Challenge.FORM_WITH, Challenge.STEAL],
				"Parameter": [0, "J", 4],
				"Requirement": [50, 1, 1]
			}
		}
	},
	Opponent.QUARREL:{
		"Avatar": AvatarTextures[AvatarCharacter.SQUIRREL],
		"Avatar_BG": AvatarBackgroundTextures[LetterOwnership.BOARD_OPPONENT],
		"Name": "Quarrel",
		"Point_Requirement": 50,
		"Min_Level": 28,
		"Max_Level": 37,
		"Dictionary_Level": "elementary",
		"Difficulty": "medium",
		"Challenge": {
			"1": {
				"From": [1, 3],
				"Type": [Challenge.SCORE, Challenge.STEAL, Challenge.FORM_WITH],
				"Parameter": [0, 0, "Q"],
				"Requirement": [50, 2, 1]
			},
			"2": {
				"From": [4,7],
				"Type": [Challenge.SCORE, Challenge.STEAL, Challenge.FORM_WITH],
				"Parameter": [0, 4, "Z"],
				"Requirement": [50, 1, 1]
			},
			"3": {
				"From": [8,9],
				"Type": [Challenge.SCORE, Challenge.OVER_WIN, Challenge.USE_BOOSTER],
				"Parameter": [0, 0, BoosterType.BLAST],
				"Requirement": [50, 60, 2]
			},
			"4": {
				"From": [10,10],
				"Type": [Challenge.SCORE, Challenge.OVER_WIN, Challenge.FLAWLESS_WIN],
				"Parameter": [0, 0, 0],
				"Requirement": [50, 60, 1]
			}
		}
	},
	Opponent.MONIAC:{
		"Avatar": AvatarTextures[AvatarCharacter.MONKEY],
		"Avatar_BG": AvatarBackgroundTextures[LetterOwnership.BOARD_OPPONENT],
		"Name": "MONIAC",
		"Point_Requirement": 50,
		"Min_Level": 38,
		"Max_Level": 47,
		"Dictionary_Level": "secondary",
		"Difficulty": "medium",
		"Challenge": {
			"1": {
				"From": [1, 3],
				"Type": [Challenge.SCORE, Challenge.FORM_POINTS, Challenge.SPECIFIC_WIN],
				"Parameter": [0, 15, 0],
				"Requirement": [50, 2, 55]
			},
			"2": {
				"From": [4,4],
				"Type": [Challenge.SCORE, Challenge.FORM, Challenge.FORM_POINTS],
				"Parameter": [0, 3, 20],
				"Requirement": [50, 5, 1]
			},
			"3": {
				"From": [5,7],
				"Type": [Challenge.SCORE, Challenge.FORM, Challenge.FORM_POINTS],
				"Parameter": [0, 4, 20],
				"Requirement": [50, 3, 1]
			},
			"4": {
				"From": [8,8],
				"Type": [Challenge.SCORE, Challenge.FORM_WITH, Challenge.FLAWLESS_WIN],
				"Parameter": [0, "J", 0],
				"Requirement": [50, 1, 1]
			},
			"5": {
				"From": [9,9],
				"Type": [Challenge.SCORE, Challenge.FORM_WITH, Challenge.FLAWLESS_WIN],
				"Parameter": [0, "Q", 0],
				"Requirement": [50, 1, 1]
			},
			"6": {
				"From": [10,10],
				"Type": [Challenge.SCORE, Challenge.FORM_WITH, Challenge.FLAWLESS_WIN],
				"Parameter": [0, "Z", 0],
				"Requirement": [50, 1, 1]
			}
		}
	},
	Opponent.HANSOME:{
		"Avatar": AvatarTextures[AvatarCharacter.CHICKEN],
		"Avatar_BG": AvatarBackgroundTextures[LetterOwnership.BOARD_OPPONENT],
		"Name": "Hansome",
		"Min_Level": 48,
		"Max_Level": 57,
	},
	Opponent.MUMBLY:{
		"Avatar": AvatarTextures[AvatarCharacter.MOUSE],
		"Avatar_BG": AvatarBackgroundTextures[LetterOwnership.BOARD_OPPONENT],
		"Name": "Mumbly",
		"Min_Level": 58,
		"Max_Level": 67,
	},
	Opponent.SHAWN:{
		"Avatar": AvatarTextures[AvatarCharacter.SHEEP],
		"Avatar_BG": AvatarBackgroundTextures[LetterOwnership.BOARD_OPPONENT],
		"Name": "Shawn",
		"Min_Level": 58,
		"Max_Level": 67,
	},
	Opponent.FURY:{
		"Avatar": AvatarTextures[AvatarCharacter.FOX],
		"Avatar_BG": AvatarBackgroundTextures[LetterOwnership.BOARD_OPPONENT],
		"Name": "Fury",
		"Min_Level": 78,
		"Max_Level": 87,
	},
	Opponent.CHEATING:{
		"Avatar": AvatarTextures[AvatarCharacter.CHEETAH],
		"Avatar_BG": AvatarBackgroundTextures[LetterOwnership.BOARD_OPPONENT],
		"Name": "Cheating",
		"Min_Level": 88,
		"Max_Level": 97,
	},
	Opponent.TURBO:{
		"Avatar": AvatarTextures[AvatarCharacter.TORTOISE],
		"Avatar_BG": AvatarBackgroundTextures[LetterOwnership.BOARD_OPPONENT],
		"Name": "Turbo",
		"Min_Level": 98,
		"Max_Level": 107,
	},
	Opponent.LIONA: {
		"Avatar": AvatarTextures[AvatarCharacter.LIONESS],
		"Avatar_BG": AvatarBackgroundTextures[LetterOwnership.BOARD_OPPONENT],
		"Name": "Liona",
		"Point_Requirement": 85,
		"Min_Level": 108,
		"Max_Level": 118,
		"Dictionary_Level": "",
		"Difficulty": ""
	}
}

const AI_MAX_LEVEL: int = 10
const AI_MIN_LEVEL: int = 1
const _AI_NAMES: String = "res://ai/ai_bot_names.json"
const _AI_SPECS: String = "res://ai/ai_specs.json"

var ai_bot_names: Dictionary = {}
var ai_specs: Dictionary = {}

func _ready():
	ai_bot_names = JSONLoader.load_json(_AI_NAMES)
	ai_specs = JSONLoader.load_json(_AI_SPECS)
