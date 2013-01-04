module Mconf
  VERSION = "0.7".freeze

  # get the current git branch
  @@branch = nil
  def self.application_branch
    unless @@branch
      branch = %x[git symbolic-ref HEAD 2> /dev/null ]
      branch =~ /([^\/]*)$/
      branch = $1.strip!
      @@branch = branch || "<no-ref>"
    end
    @@branch
  end

  # get the current revision from git
  @@revision = nil
  @@revision_full = false
  def self.application_revision(full=false)
    unless @@revision or @@revision_full != full
      revision = %x[git rev-list HEAD --max-count=1]
      revision.strip!
      @@revision = revision.blank? ? "<no-ref>" : revision

      revision.slice!(6..-1) unless full
      @@revision = revision.blank? ? "<no-ref>" : revision
    end
    @@revision
  end

end
