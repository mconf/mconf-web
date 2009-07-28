class EventInvitation < Admission
  belongs_to :event
  validates_presence_of :email

  before_create :generate_code

  def to_param
    code
  end

  private

  def generate_code #:nodoc:
    self.code = Digest::SHA1.hexdigest( Time.now.to_s.split(//).sort_by {rand}.join )
  end
end