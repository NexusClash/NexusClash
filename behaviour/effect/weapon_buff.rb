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
			alter = false

			if @name != nil && @name == intent.weapon.name && (@family == :all || @family == intent.weapon.family) then
				alter = true
			else
				if @name == nil &&  (@family == :all || @family == intent.weapon.family)
					alter = true
				end
			end

			if alter

				intent.damage += @damage
				intent.hit_chance += @hit_chance

				intent.debug self

			end
			return intent
		end

		def describe
			msg = ''
			msg = "Increases damage dealt by #{@family} weapons#{ @name === nil ? '' : " named #{@name}" } by #{@damage}" if @damage > 0
			msg = "Decreases damage dealt by #{@family} weapons#{ @name === nil ? '' : " named #{@name}" } by #{@damage}" if @damage < 0
			msg << '.' if @damage != 0 && @hit_chance == 0
			msg << ' and ' if @damage != 0 && @hit_chance != 0
			msg = "#{ msg == '' ? 'I' : 'i' }ncreases hit chance#{ msg == '' ? " of #{@family} weapons#{ @name === nil ? '' : " named #{@name}" }" : '' } by #{@hit_chance}%." if @hit_chance > 0
			msg = "#{ msg == '' ? 'D' : 'd' }ecreases hit chance#{ msg == '' ? " of #{@family} weapons#{ @name === nil ? '' : " named #{@name}" }" : '' } by #{@hit_chance}%." if @hit_chance < 0
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