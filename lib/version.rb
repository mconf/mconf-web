module Vcc
  VERSION = "0.3".freeze

  # get the current git branch
  @@branch = nil
  def self.application_branch
    begin
      unless @@branch
        branch = %x[git symbolic-ref HEAD]
        branch =~ /([^\/]*)$/
        @@branch = $1.strip!
      end
    rescue Exception
      @@branch = "<no-ref>"
    end
    @@branch
  end

  # get the current revision from git
  @@revision = nil
  @@revision_full = false
  def self.application_revision(full=false)
    begin
      unless @@revision or @@revision_full != full
        @@revision = %x[git rev-list HEAD --max-count=1]
        @@revision.strip!
        @@revision.slice!(6..-1) unless full
        @@revision_full = full
      end
    rescue Exception
      @@revision = "<no-ref>"
    end
    @@revision
  end

end
