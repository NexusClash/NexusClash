module Entity
	module ObservedFields
		def self.included(base)
			base.extend(ClassMethods)
			#base.instance_variable_set :@changelist, Array.new
		end

		def publish_alterations
			raise_event(:altered, self, @changelist) unless @changelist === nil or @changelist.length == 0
			@changelist = Array.new
		end

		module ClassMethods

			def observe_fields(*args)
				args.each do |arg|
					arg = arg.to_s
					method_name = (arg + '=').to_sym
					arg = arg.to_sym
					send :define_method, method_name do |value|
						self[arg] = value
						@changelist = Array.new if @changelist === nil
						@changelist << arg.to_sym
					end
				end
			end
		end

	end
end