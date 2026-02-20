# == Schema Information
#
# Table name: contest_effect
#
#  id         :bigint           not null, primary key
#  appeal     :integer
#  jam        :integer
#  created_at :datetime         not null
#  updated_at :datetime         not null
#
class PokeContestEffect < ApplicationRecord
  self.table_name = "contest_effect"
end
