module StatusTick

	# Scope Character
	AP = :ap
	MINUTE = :minute
	STATUS = :status

	# Scope: Item
	ITEM_ACTIVATED = :item_activation

	LIST = [AP, ITEM_ACTIVATED, MINUTE, STATUS]

	def type_list
		LIST
	end
end