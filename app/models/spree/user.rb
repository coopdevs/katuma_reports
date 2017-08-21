module Spree
  class User < ActiveRecord::Base
    self.table_name = 'spree_users'

    devise :database_authenticatable, :token_authenticatable, :registerable, :recoverable,
           :rememberable, :trackable, :validatable, :encryptable, encryptor: 'authlogic_sha512'

    attr_accessible :email, :password, :password_confirmation, :remember_me

    attr_readonly(*column_names) # Required to block update_attribute and update_column

    def readonly?
      if Rails.env.test?
        false
      else
        true
      end
    end

    def destroy
      raise ActiveRecord::ReadOnlyRecord
    end

    def delete
      raise ActiveRecord::ReadOnlyRecord
    end
  end
end
