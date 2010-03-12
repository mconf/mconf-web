class JoinRequest < Admission
  validates_presence_of :candidate_id, :candidate_type

end
