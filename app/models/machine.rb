class Machine < ActiveRecord::Base
  has_many :events, :through => :participants
  has_many :participants
  has_and_belongs_to_many :users
  
  validates_presence_of :name, :nickname
  
  validates_uniqueness_of :name, :nickname
  
  def self.atom_parser(data)

    e = Atom::Entry.parse(data)
    resultado = {}
    machine = {}
    machine[:name] = e.title.to_s
    machine[:nickname] = e.summary.to_s
    resultado[:machine] = machine
    if r = e.get_elem(e.to_xml, "http://sir.dit.upm.es/schema", "assign_to_everybody")
    resultado[:assign_to_everybody] = r.text
    end
    
    { :machine => machine}     
  end
  
end
