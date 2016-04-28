module StatusTick

	# Scope Character
	AP = :ap
	MINUTE = :minute
	STATUS = :status

	# Scope: Item
	ITEM_ACTIVATED = :item_activation

	ACTIVATED = :activation
	ACTIVATED_TARGET = :activation_target # When calling these triggers the target must be passed as an additional argument

	LIST = [ACTIVATED, ACTIVATED_TARGET, AP, ITEM_ACTIVATED, MINUTE, STATUS]

	def type_list
		LIST
	end
end