module StatusTick

	# Scope Character
	AP = :ap
	MINUTE = :minute
	STATUS = :status

	# Scope: Item
	ITEM_ACTIVATED = :item_activation

	ACTIVATED = :activation

	LIST = [ACTIVATED, AP, ITEM_ACTIVATED, MINUTE, STATUS]

	def type_list
		LIST
	end
end