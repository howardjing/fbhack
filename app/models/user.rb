class User < ActiveRecord::Base
  # Include default devise modules. Others available are:
  # :token_authenticatable, :confirmable,
  # :lockable, :timeoutable and :omniauthable
  require 'set'
  attr_accessor :name, :debts
   # the people you owe money to
  has_many :debts, class_name: 'Debt', foreign_key: 'borrower_id'
  
  devise :database_authenticatable, :registerable,
         :recoverable, :rememberable, :trackable, :validatable

  # Setup accessible (or protected) attributes for your model
  attr_accessible :email, :password, :password_confirmation, :remember_me
  has_many :sent_payments, class_name: 'Payment', foreign_key: 'sender_id'
  has_many :received_payments, class_name: 'Payment', foreign_key: 'receiver_id' 

	def debtors
		debts.keys
	end

	def amount_owed(user)
		debts[user]
	end

	def debts
		@debts || {}
	end

	def to_s
		name
	end
	

	def visited_users
		@visited_users ||= Set.new
	end

	def clear_visited_users
		@visited_users = Set.new
	end


	def indirect_debts(root_user, user, max_amount_owed)  
		# when descending, if we have seen this debtor already, then there is a cycle
		user.debtors.each do |debtor|
			if !visited_users.include?(debtor)
			 visited_users.add(debtor)
			 amount_owed = [max_amount_owed, user.amount_owed(debtor)].min
			 puts "#{root_user} owes #{debtor} $#{amount_owed} through #{user}"
			 indirect_debts(root_user, debtor, amount_owed)
			else 
			 puts "Already seen #{debtor}"
			end
		end
		clear_visited_users
	end

  def balance
    sent_payments.sum(:amount) - received_payments.sum(:amount)
  end

end
