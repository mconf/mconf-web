class Profile < ActiveRecord::Base
  belongs_to :user

  acts_as_taggable
  has_logo
  
  validates_presence_of :name, :lastname, :phone, :city, :country,:organization
 
  def authorizes?(agent, action_objective)
    return true if agent.superuser? || agent == user

    case action_objective
    when :read
      user.stages.map(&:actors).flatten.include?(agent)
    else
      false
    end
  end
  
  def self.atom_parser(data)

    e = Atom::Entry.parse(data)
      
      profile = {}
      profile[:name] = e.title.to_s
      profile[:lastname] = e.get_elem(e.to_xml, "http://sir.dit.upm.es/schema", "lastname").text
      profile[:address] = e.get_elem(e.to_xml, "http://sir.dit.upm.es/schema", "address").text
      profile[:city] = e.get_elem(e.to_xml, "http://sir.dit.upm.es/schema", "city").text
      profile[:zipcode] = e.get_elem(e.to_xml, "http://sir.dit.upm.es/schema", "zipcode").text
      profile[:province] = e.get_elem(e.to_xml, "http://sir.dit.upm.es/schema", "province").text
      profile[:country] = e.get_elem(e.to_xml, "http://sir.dit.upm.es/schema", "country").text
      
      e.get_elems(e.to_xml, "http://schemas.google.com/g/2005", "phoneNumber").each do |times|
        type = times.attribute('rel').to_s.sub('http://schemas.google.com/g/2005#', '')
        if type == "home"
          profile[:phone] = times.text 
        else
          profile[type.to_sym] = times.text
        end 
      end

      org = e.get_elem(e.to_xml, "http://schemas.google.com/g/2005", "organization")
      profile[:organization] = org.each_element_with_text('orgName')[0].text

            
    resultado = {}
    
    resultado[:profile] = profile
    
    return resultado     
  end   
  
end
