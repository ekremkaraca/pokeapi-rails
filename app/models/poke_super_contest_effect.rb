# == Schema Information
#
# Table name: super_contest_effect
#
#  id         :bigint           not null, primary key
#  appeal     :integer
#  created_at :datetime         not null
#  updated_at :datetime         not null
#
class PokeSuperContestEffect < ApplicationRecord
  self.table_name = "super_contest_effect"
end
