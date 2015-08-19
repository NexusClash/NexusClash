module Pronouns

	def pronoun(type = :subject)

		case type
			when :he, :she, :it, :they, :subject

				case self.gender
					when Gender::MALE
						'he'
					when Gender::FEMALE
						'she'
					when Gender::NEUTER
						'it'
					else #Gender::PLURAL or Gender::EPICENE
						'they'
				end

			when :him, :them, :object

				case self.gender
					when Gender::MALE
						'him'
					when Gender::FEMALE
						'her'
					when Gender::NEUTER
						'it'
					else #Gender::PLURAL or Gender::EPICENE
						'them'
				end

			when :his, :her, :its, :their, :reflexive

				case self.gender
					when Gender::MALE
						'his'
					when Gender::FEMALE
						'her'
					when Gender::NEUTER
						'its'
					else #Gender::PLURAL or Gender::EPICENE
						'their'
				end

			when :hers, :theirs, :possessive_pronoun

				case self.gender
					when Gender::MALE
						'his'
					when Gender::FEMALE
						'hers'
					when Gender::NEUTER
						'its'
					else #Gender::PLURAL or Gender::EPICENE
						'theirs'
				end

			when :himself, :herself, :itself, :themselves, :possessive_determiner

				case self.gender
					when Gender::MALE
						'himself'
					when Gender::FEMALE
						'herself'
					when Gender::NEUTER
						'itself'
					when Gender::EPICENE
						'themself'
					else #Gender::PLURAL
						'themselves'
				end

			else # All the rest are simply whatever they happened to be

				type.to_s

		end
	end

end