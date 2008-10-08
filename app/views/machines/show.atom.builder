atom_entry(@machine, {'xmlns:gd' => 'http://schemas.google.com/g/2005', 
    'xmlns:sir' => 'http://sir.dit.upm.es/schema', 
  :url => formatted_machine_path(@machine, :atom), :root_url => machine_path(@machine)}) do |entry|
  entry.title(@machine.name)
  entry.summary(@machine.nickname)
  #entry.updated((@machine.content_entries.first.updated_at.to_datetime))

  
  entry.author do |author|
    author.name("SIR")
  end
  
end
