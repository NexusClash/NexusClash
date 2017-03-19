module Effect
	class SpellAttackFromScroll < SpellAttack

		def initialize(parent, damage_type)
      super
		end

		def weapon_intent(intent)
      super
      intent.add_cost :scroll_consumption, self.method(:consume_scroll)
      return intent
		end

		def consume_scroll(action, intent)
			case action
				when :possible?
					return true
				when :apply_costs
          item = scroll
          unless item.nil?
            item.despawn
						intent.append_message "Your scroll has been consumed."
            return
          end
          puts 'Failed to consume the scroll!!!'
			end
		end

    def scroll
      scroll = parent
      until scroll.is_a?(Entity::Item) or scroll.nil?
        scroll = scroll.respond_to?(:parent) ? scroll.parent : nil
      end
      scroll
    end

		def describe
      super + " (This consumes the scroll)"
		end

		def save_state
			['SpellAttackFromScroll', @damage_type]
		end
	end
end
