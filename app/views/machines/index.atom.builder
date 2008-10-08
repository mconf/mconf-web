    atom_feed({'xmlns:gd' => 'http://schemas.google.com/g/2005', 
    'xmlns:sir' => 'http://sir.dit.upm.es/schema'}) do |feed|
      feed.title("Machines")
      #feed.updated((@machines.first.created_at unless @machines.first==nil))

      for machine in @machines
        feed.entry(machine, :url => machine_path(machine)) do |entry|
          entry.title(machine.name)
       #   entry.updated((machine.methods.to_s))
          entry.summary(machine.nickname)
               

          entry.author do |author|
            author.name("SIR")
          end
        end
      end
    end
