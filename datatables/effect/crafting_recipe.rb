module Effect
	class CraftingRecipe

		def save_state_to_datatable

			cost_string = ''

			@costs.each do |key, val|
				cost_string = "#{cost_string} #{key.to_s}=#{val.to_s},"
			end

			catalyst_string = ''

			@catalysts.each do |key, val|
				catalyst_string = "#{catalyst_string} #{key.to_s}=#{val.to_s},"
			end

			reagent_string = ''

			@reagents.each do |key, val|
				reagent_string = "#{reagent_string} #{key.to_s}=#{val.to_s},"
			end

			output_string = ''

			@outputs.each do |key, val|
				output_string = "#{output_string} #{key.id.to_s * val.to_i},"
			end

			{type: 'CraftingRecipe', text_1: @name, text_2: cost_string.chomp(','), text_3: catalyst_string.chomp(','), text_4: reagent_string.chomp(','), text_5: output_string.chomp(','), text_6: @message}
		end

		def self.save_state_from_datatable(parent, table)

			s_costs = Hash.new{|hash, key| 0}
			input_costs = table[:text_2].split(',')
			input_costs.each do |i_cost|
				i_cost = i_cost.split('=')
				s_costs[i_cost[0].strip.to_sym] = i_cost[1].strip.to_i
			end

			s_catalyst = Hash.new{|hash, key| 0}
			input_catas = table[:text_3].split(',')
			input_catas.each do |i_cata|
				i_cata = i_cata.split('=')
				s_catalyst[i_cata[0].strip.to_sym] = i_cata[1].strip.to_i
			end

			s_reagent = Hash.new{|hash, key| 0}
			input_regs = table[:text_4].split(',')
			input_regs.each do |i_reg|
				i_reg = i_reg.split('=')
				s_reagent[i_reg[0].strip.to_sym] = i_reg[1].strip.to_i
			end

			s_output = Hash.new{|hash, key| 0}
			input_outs = table[:text_5].split(',')
			input_outs.each do |i_out|
				i_out = i_out.strip.to_i
				s_output[i_out] = s_output[i_out] + 1
			end

			if table[:text_1] == '' || (parent.respond_to?(:name) && table[:text_1] == parent.name)
				['CraftingRecipe', s_costs, s_catalyst, s_reagent, s_output, table[:text_6]]
			else
				['CraftingRecipe', s_costs, s_catalyst, s_reagent, s_output, table[:text_6], table[:text_1]]
			end
		end

		def self.datatable_define
			Effect::Base.datatable_setup({
					                             show: ['text_1', 'text_2', 'text_3', 'text_4', 'text_5', 'text_6'],
					                             labels: {text_1: 'Recipe Name', text_2: 'Costs (comma separated) eg. ap=1,mp=2,mo=2 - Supported types: hp,ap,mp,xp,mo,cp', text_3: 'Catalysts (format as above) eg. wood=1,food=2', text_4: 'Reagents (format as above) eg. wood=1,food=2', text_5: 'Outputs (comma separated item type ID #s)', text_6: 'Crafting Message'},
					                             options: {},
					                             values: {text_1: '', text_2: '', text_3: '', text_4: '', text_5: '', text_6: ''}
			                             })
		end

	end
end