module StatusTick

	# Scope Character
	AP = :ap
	MINUTE = :minute

	# Scope: Item
	ITEM_ACTIVATED = :item_activation

	def type_list
		self.constants true
	end
end