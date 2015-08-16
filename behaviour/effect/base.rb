module Effect
	class Base

		def self.regenerate(parent, object)
			object = object.clone
			type = object.shift
			object.unshift(parent)
			type = Effect.const_get type
			type.new *object
		end

		def self.effect_list
			['Regen', 'Weapon', 'WeaponBuff', 'SkillPrerequisite', 'SkillPurchasable', 'CustomText']
		end
	end
end