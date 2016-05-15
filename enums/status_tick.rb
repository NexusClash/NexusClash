module StatusTick

	# Scope Character
	AP = :ap
	MINUTE = :minute
	STATUS = :status

	# Scope: Item
	ITEM_ACTIVATED = :item_activation

	# Scope: Status
	ACTIVATED = :activation
	ACTIVATED_TARGET = :activation_target # When calling these triggers the target must be passed as an additional argument
	ACTIVATED_SOURCE = :activation_source # When calling these triggers the target must be passed as an additional argument
	STATUS_CREATED = :status_created


	LIST = [ACTIVATED, STATUS_CREATED, ACTIVATED_SOURCE, ACTIVATED_TARGET, AP, ITEM_ACTIVATED, MINUTE, STATUS]

	def type_list
		LIST
	end
end