extends Node

const Item = preload("res://src/items/Item.tscn")


# Holds item instances
var database = {
#	"id":
#		"name": "Staff of the Cosmic Whole"
#		"properties": 50 
}

var ITEMS = {
	"Steel Dagger": {
		"icon": "res://assets/sprites/items/steel_dagger.png",
		"slot": "Weapon",
	},
	"Dirk": {
		"icon": "res://assets/sprites/items/dirk.png",
		"slot": "Weapon",
	},
	"Wolfskin Armor": {
		"icon": "res://assets/sprites/items/wolfskin_armor.png",
		"slot": "Armor",
	}
}


func add_item(item_id, item_name):
	var item_properties = {
		"name": item_name,
	}
	database[item_id] = item_properties


func get_item(item_id):
	database.get(item_id)
	return database.get(item_id)
	
	
func remove_item(item_id):
	for item in database:
		if item.get_meta("id") == item_id:
			database.remove(item)
			return true
