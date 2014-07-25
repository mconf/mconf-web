# Finds all Invitation objects not sent yet and ready to be sent and sends them.
class Invitations
  @queue = :invitations

  def self.perform
    all_invitations
  end

  def self.all_invitations
    invitations = Invitation.where :sent => false, :ready => true

    invitations.each do |invitation|
      result = invitation.send_invitation
      invitation.sent = true
      invitation.result = result
      invitation.save!
    end
  end

end
