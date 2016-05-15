module Effect
	class SendMessage < Effect::ActOnTick

		def initialize(parent, message, interval = StatusTick::ITEM_ACTIVATED, scope = BroadcastScope::SELF)
			super parent, interval
			@scope = scope.to_i
			@message = message
		end

		def tick_event(*target)
			source = target[0]
			source = source.stateful if source.is_a? Entity::Status
			source = source.carrier if source.is_a? Entity::Item
			target = super *target
			target = target.stateful if target.is_a? Entity::Status
			target = target.carrier if target.is_a? Entity::Item

			receivers = []
			msg = @message

			case @scope
				when BroadcastScope::SELF
					receivers << target.id
				when BroadcastScope::TARGET
					#TODO: Implement
				when BroadcastScope::TILE
					target.location.characters.each do |char|
						receivers << char.id
					end
				when BroadcastScope::VISIBLE
					game = Firmament::Plane.fetch Instance.plane
					tiles = Set.new
					(-2..2).each do |y|
						(-2..2).each do |x|
							tiles.add game.map(target.location.x + x, target.location.y + y, target.location.z)
						end
					end

					tiles.each do |tile|
						tile.characters.each do |char|
							receivers << char.id
						end
					end
				else
					return BroadcastScope::NONE
			end
			if receivers.length > 0

				msg.gsub! '[target]', target.name_link
				msg.gsub! '[source]', source.name_link
				@parent.temp_effect_vars.keys.each do |key|
					msg.gsub! "[#{key.to_s}]", @parent.temp_effect_vars[key].to_s
				end

				m = Entity::Message.new({characters: receivers, type: MessageType::GENERIC, message: msg})
				m.save
			end
			return BroadcastScope::NONE
		end

		def describe
			"Each #{@interval.to_s}, send '#{@message}' to #{@scope.to_s}."
		end

		def save_state
			['SendMessage', @message, @interval, @scope]
		end
	end
end