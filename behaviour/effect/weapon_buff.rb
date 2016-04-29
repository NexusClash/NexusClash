module Effect
	class WeaponBuff

		attr_reader :family
		attr_reader :hit_chance
		attr_reader :damage
		attr_reader :parent

		def initialize(parent, family = :all, hit_chance = 0, damage = 0, name = nil)
			@parent = parent
			@family = family.to_sym
			@hit_chance = hit_chance.to_i
			@damage = damage.to_i
			@name = name
		end

		def alter_attack_intent(intent)
			if (@family == :all || @family == intent.weapon.family) && (@name == nil || @name == intent.weapon.name)
				intent.damage += @damage
				intent.hit_chance += @hit_chance
				intent.debug self
			end
			return intent
		end

		def describe
			msg = ''
			hmsg = ''
			if @hit_chance != 0
				hmsg = "#{@hit_chance > 0 ? 'increases' : 'decreases'} hit chance of #{@family} weapons#{ @name === nil ? '' : " named #{@name}" }  by #{@hit_chance.abs}%."
			end
			if @damage != 0
				hmsg.capitalize!
				msg = "#{@damage > 0 ? 'Increases' : 'Decreases'} damage dealt by #{@family} weapons#{ @name === nil ? '' : " named #{@name}" } by #{@damage.abs}"
				msg << '. ' if @hit_chance == 0
				msg << ' and ' if @damage != 0
			end
			msg << hmsg
			return msg
		end

		#	def initialize(parent, family = :any, hit_chance = 0, damage = 0, name = nil)

		def save_state

			if @name === nil
				if @damage == 0
					if @hit_chance == 0
						if @family == :all
							['WeaponBuff'] #lol
						else
							['WeaponBuff', @family.to_s]
						end
					else
						['WeaponBuff', @family.to_s, @hit_chance]
					end
				else
					['WeaponBuff', @family.to_s, @hit_chance, @damage]
				end
			else
				['WeaponBuff', @family.to_s, @hit_chance, @damage, @name]
			end
		end

	end
end