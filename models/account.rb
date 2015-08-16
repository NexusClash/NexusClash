require 'digest/sha2'
module Entity
	class Account
		include Mongoid::Document
		include Unobservable::Support
		include Entity::ObservedFields

		field :username, type: String
		field :password, type: String
		field :salt, type: String

		field :roles, type: Array

		field :authentication_token, type: String

		#observe_fields :username

		index({:username => 1}, :unique => true)

		has_many :characters

		def password=(password)
			self.salt = Digest::SHA2.base64digest(SecureRandom.random_bytes(16))
			self[:password] = Digest::SHA2.base64digest(password + self.salt)
		end

		def password?(password)
			self.password == Digest::SHA2.base64digest(password + self.salt)
		end

		after_find do |document|
			document.roles.map! {|role| role.to_sym}
		end
		after_initialize do |document|
			document.roles = Array.new if document.roles === nil
			document.roles.map! {|role| role.to_sym}
		end

		def has_role?(role)
			self.roles.include?(role.to_sym)
		end

	end
end