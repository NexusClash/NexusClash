module Effect
	class ExplosiveMurderManualActivation

		attr_reader :name

		def initialize(parent, costs = nil, name = nil)
			@parent = parent
			@targets = [:self]
			@costs = Hash.new{|hash, key| 0}
			unless costs === nil
				costs.each do |cost, delta|
					@costs[cost.to_sym] = delta
				end
			end
			@name = name
			@name = @parent.name if @name === nil

			unserialise
		end

		def unserialise
			@character = @parent
			@character = @parent.stateful if @character.is_a? Entity::Status
			@character = @parent.carrier if @character.is_a? Entity::Item

			@explosive_murder = nil
			active_explode_ability = @character.respond_to?(:transient_tags) && @character.transient_tags.key?(:can_manual_explosive_murder)

			if @character.respond_to?(:each_applicable_effect) && !active_explode_ability
				@character.each_applicable_effect do |effect|
					if effect.is_a? Effect::ExplosiveMurder
						@explosive_murder = effect
						break
					end
				end

				if @explosive_murder != nil && !active_explode_ability
					define_singleton_method :activate_self_intent do |*args|
						voluntary_explosion_intent *args
					end
					@character.transient_tags[:can_manual_explosive_murder] = true
				end
			end
		end

		def can_target?(tar)
			tar == :self
		end

		def voluntary_explosion_intent(intent)
			# Count copies of effect
			count = -1
			if @character.respond_to? :each_applicable_effect
				@character.each_applicable_effect do |effect|
					if effect.is_a? Effect::ExplosiveMurderManualActivation
						count += 1
					end
				end
			else
				count = 0
			end

			intent.name = "#{name} (#{@costs[:ap]}AP, #{@costs[:mp] - count}MP)"
			@costs.each do |cost, delta|
				delta -= count if cost == :mp # Reduce MP cost if multiple copies of ability
				intent.add_cost cost, delta
			end
		end

		def tick_activation(*_)
			@explosive_murder.send(:explosive_murder, nil, true)
		end

		def describe
			"#{@parent.name.to_s} has an activated ability called #{@name} costing #{@costs[:ap].to_s} AP + #{@costs[:mp].to_s} MP, minus 1 MP for each additional copy of itself"
		end

		def save_state
			if @name === @parent.name
				[self.class.name, @costs]
			else
				[self.class.name, @costs, @name]
			end

		end
	end
end
