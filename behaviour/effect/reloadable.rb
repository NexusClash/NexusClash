module Effect
	class Reloadable

		attr_reader :ammo_type
		attr_reader :capacity

		def initialize(parent, ammo_type, capacity)
			@parent = parent
			@ammo_type = ammo_type.to_sym
			@capacity = capacity.to_i
		end

		def name
			'Reload'
		end

		def activate_self_intent(intent)
			intent.name = name
			intent.outcomes << self.method(:reload_callback)
			intent.add_cost :ap, 1
		end

		def reload_callback(action, intent)
			target = intent.target
			character = intent.entity
			case action
				when :possible?
					amount_ammo = nil
					amount_ammo = target.get_tag :ammo if target.respond_to? :get_tag
					amount_ammo = 0 if amount_ammo === nil
					missing_amount = @capacity - amount_ammo
					item = most_efficient_ammo intent.entity, missing_amount
					result = item != nil && intent.entity.ap > 0 && missing_amount > 0
				when :apply_costs
				when :take_action
					amount_ammo = nil
					amount_ammo = target.get_tag :ammo if target.respond_to? :get_tag
					amount_ammo = 0 if amount_ammo === nil
					missing_amount = @capacity - amount_ammo
	        item = most_efficient_ammo intent.entity, missing_amount
	        if item[0] != nil && missing_amount > 0
						item[0].despawn
		        capacity_increase = item[1]
						amount_ammo = target.get_tag(:ammo)
						amount_ammo = 0 if amount_ammo === nil
		        amount_ammo += capacity_increase
		        amount_ammo = @capacity if amount_ammo > @capacity
		        target.set_tag :ammo, amount_ammo
						character.broadcast BroadcastScope::SELF, {packets:[{type: 'inventory', weight: character.weight, weight_max: character.weight_max, list: 'remove', items: [item[0].object_id]}, {type: 'inventory', list: 'update', items: [target.to_h]}]}.to_json
	        end
				when :broadcast_results
					msg_reload = Entity::Message.new({characters: [intent.entity.id], message: "You reload your #{target.name}", type: MessageType::RELOAD})
					msg_reload.save
					intent.entity.broadcast_self BroadcastScope::SELF
			end
			result
		end

		def describe
			"#{@parent.name.to_s} can be reloaded with #{@ammo_type.to_s}s, up to #{@capacity.to_s} capacity."
		end

		def save_state
			['Reloadable', @ammo_type, @capacity]
		end

		private

		def most_efficient_ammo(character, missing_amount)
			closest_under = nil
			closest_under_item = nil
			closest_over = nil
			closest_over_item = nil
			character.items.each do |item|
				item.type_statuses.each do |status|
					status.effects.each do |effect|
						if effect.is_a?(Effect::Ammo) && effect.ammo_type == @ammo_type
							if effect.capacity == missing_amount
								return [item, effect.capacity]
							end
							if effect.capacity <= missing_amount && (closest_under === nil || closest_under > missing_amount - effect.capacity)
								closest_under = missing_amount - effect.capacity
								closest_under_item = item
							end
							if effect.capacity >= missing_amount && (closest_over === nil || closest_over > effect.capacity - missing_amount)
								closest_over = effect.capacity - missing_amount
								closest_over_item = item
							end
						end
					end
				end
			end
			if closest_under === nil || closest_over === nil
				return closest_under_item === nil ? [closest_over_item, closest_over] : [closest_under_item, closest_under]
			end
			[closest_under_item, closest_under]
		end

	end
end