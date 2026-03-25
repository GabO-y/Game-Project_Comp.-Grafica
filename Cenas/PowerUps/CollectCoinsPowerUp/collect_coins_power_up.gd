extends PowerUp

class_name CollectCoinsPowerUp

func apply():
	Globals.item_manager.items_node.child_entered_tree.connect(
		func(item):
			item.setup_state(Item.ItemState.CHASING)
	)
