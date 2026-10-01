class_name ItemEnums
extends RefCounted

## Enums & maps for items.


# Enumerates high-level categories of which an item can be.
enum Category {
	MISC,
	IMPORTANT,
	POTION,
	FOOD,
	WEAPON,
	SHIELD,
	HEAD,
	CHEST,
	LEGS,
	FEET,
	RING,
	NECK,
	TRINKET
}

# Enumerates rarity levels for items.
enum Rarity {
	COMMON,
	MAGIC,
	RARE,
	VERYRARE,
	LEGENDARY,
	IMPORTANT
}

# Maps Rarity enum to a colour. 
static var rarity_colour : Dictionary[Rarity, Color] = {
	Rarity.COMMON: Color.WHITE_SMOKE,
	Rarity.MAGIC: Color.LIME_GREEN,
	Rarity.RARE: Color.CORNFLOWER_BLUE,
	Rarity.VERYRARE: Color.REBECCA_PURPLE,
	Rarity.LEGENDARY: Color.DARK_ORANGE,
	Rarity.IMPORTANT: Color.BURLYWOOD
}
