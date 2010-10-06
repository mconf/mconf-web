require 'pdf/writer'
require 'pdf/simpletable' #To manage tables. 
require 'iconv'

#GLOBAL2RAMA
module EventToPdf
  
  #Method to generate the agenda of the event in PDF.
  def to_pdf(small_version)
      
    unless needsGenerate(small_version)
      return
    end
       
    pdf = PDF::Writer.new(:paper => "A4", :orientation => :portrait )
   
    #Create a gradient, at the top right corner.
    r1 = 25
    30.step(-1, -3) do |xw|
      tone = 1.0 - (xw / 40.0) * 0.2  #Parameter to control the brightness of the gradient.
      color = 0x400ee3  #Parameter to change the color of the gradient.
      pdf.stroke_style(PDF::Writer::StrokeStyle.new(xw))
      pdf.stroke_color(Color::RGB.from_fraction(tone,3250,color))
      pdf.circle_at(pdf.page_width+20, pdf.page_height+50, r1).stroke
      r1 += xw
    end

    #Parameters of the the table.
     if small_version == "true"
       @c1_width = 80
       @c2_width = 250
       @c3_width = 250
       @c4_width = 0
     else
       @c1_width = 80
       @c2_width = 120
       @c3_width = 120
       @c4_width = 260
     end

    pdf.select_font("Helvetica" , { :encondig => "WinAnsiEnconding" } )
    pdf.start_page_numbering(pdf.margin_x_middle, 5, 10, nil, nil, 1)
    
    #Paint head images
    pdf.margins_pt(5, 1, 5, 1)  #pdf.margins_pt(Top, Left, Bottom, Right)
    
    pdf.y = pdf.page_height
    i1 = "#{RAILS_ROOT}/public/images/pdf/vcc_cabecera_pdf_beta.jpg"
    i2 = "#{RAILS_ROOT}/public/images/pdf/vcc_logo_pdf_beta.jpg"
    pdf.image i1, :justification => :right, :resize => 1
    pdf.image i2, :justification => :left, :resize => 0.7
    
    
    pdf.margins_pt(5, 25, 5, 15)  #pdf.margins_pt(Top, Left, Bottom, Right)
    
    write_event_title(pdf,name)
    
    days.times do |i|
        
      date = (start_date+i.day).strftime("%A %d %b")
      
      #Array of entries and dividers.
      @entries = agenda.contents_for_day(i+1)
    
      unless i == days or i == 0 or @entries.empty?
        pdf.start_new_page  
      end
 
      #Array of entrie arrays and array who contains a single divider.
      @entries_array = fragment_entries(adaptor_to_newVersion(@entries),i)
  
      heads = true
      last_is_special = false;
      nPage =  -1
       
      @entries_array.each do |entries|
             
        if entries == @entries_array[0]
          
          pdf.fill_color!  Color::RGB::Black
          pdf.text "#{date}", :font_size => 14, :justification => :center
          
          unless isSpecialTitle(entries[0])
            pdf.text " ", :font_size => 5, :justification => :center         
          end

        end       

        if isSpecialTitle(entries[0])
          
          index_next_entry = @entries_array.index(entries) + 1
          actual_entry = entries[0]
          
          next_entry = []
          
          if(@entries_array[index_next_entry] != nil)
            next_entry = @entries_array[index_next_entry]         
            
            unless isSpecialTitle(next_entry[0])
              
              #Case: SpecialTitle(actual_entry) -> Table(next_entry)
              
              #Return the quantity of rows that fits in the actual page of the document.
              nRows = getTableRows(pdf,actual_entry,next_entry,false)
              
              if nRows == 0
                pdf.start_new_page
              elsif nRows < next_entry.length
                
                entrie_fragment_a = []
                entrie_fragment_b = @entries_array.delete_at(index_next_entry)
                
                nRows.times do |i|
                  entrie_fragment_a << entrie_fragment_b[i]
                  entrie_fragment_b.delete_at(i)    
                end
  
                @entries_array.insert(index_next_entry, entrie_fragment_a) 
                @entries_array.insert(index_next_entry+1, entrie_fragment_b)
                
              end
              
            end
              
            
          end      
          
          if (last_is_special)
            if pdf.current_page_number() == 1
              pdf.y = pdf.y + 0
            else
             pdf.y = pdf.y + 2
            end
          end
          
          last_is_special = true
          write_special_title(pdf,@c1_width + @c2_width,@c3_width + @c4_width,entries[0],false)
          
        else
      
          if (getTableRows(pdf,nil,entries,false) == 0)
            pdf.start_new_page
          end
          
          if(pdf.current_page_number() == nPage)
            heads = false
          else
            heads = true
            nPage = pdf.current_page_number()
          end
          
          if ((heads) && (last_is_special))
            pdf.y = pdf.y - 3
          end
          
          last_is_special = false
          generate_entrie_table(pdf,entries,nil,heads)
          
          if heads == true && pdf.current_page_number() != nPage
            #Generate table with heads that start a new page (heads include automatically).
            nPage = pdf.current_page_number() #heads = false
          end
        
        end
    
      end 
      
    end     #All Day Ends. PDF finished.
    
    if small_version == "true"
      name = "agenda_" + permalink + "_small.pdf"
    else
      name = "agenda_" + permalink + ".pdf"
    end  
    
    FileUtils.mkdir_p("#{RAILS_ROOT}/public/pdf/#{permalink}")
    File.open("#{RAILS_ROOT}/public/pdf/#{permalink}/#{name}", "wb") { |f| f.write pdf.render }
    
    pdf.render
   
  end
  
  
  private
  
  #Calculate if one entry fits in one page.
  def isLongEntry(entry,heading)
     
    entries = [] 
    entries << entry      
    pdf_test = PDF::Writer.new(:paper => "A4", :orientation => :portrait  )
    pdf_test.margins_pt(5, 25, 5, 15)  #pdf.margins_pt(Top, Left, Bottom, Right)
  
    generate_entrie_table(pdf_test,entries,nil,heading)
    
    return (pdf_test.current_page_number()!=1)

  end
  
  #Calculate if one entrie fits in a page.
  def getTableHeight(entries,heading)
     
    pdf_test = PDF::Writer.new(:paper => "A4", :orientation => :portrait )
    init_y = pdf_test.y
    
    generate_entrie_table(pdf_test,entries,nil,heading)
    
    final_y = pdf_test.y
    nPageEnd = pdf_test.current_page_number()
    
    height_table = (nPageEnd-1) * pdf_test.page_height + (init_y - final_y)
    
    return height_table
  end
  
  #Calculate how many rows can be write in the actual page of the pdf document.
  #Return -1 if the first entrie of the table is more high than the pdf page.
  def getTableRows(pdf,actual_entry,next_entries,hasHour)
    
    unless next_entries[0].class == AgendaEntry
      return nil
    end
    
    headings = true
    bottom_space = pdf.y
    margin_space_special = 30
    margin_space = 10
    
    if isSpecialTitle(actual_entry)
      
      headings = false
      
      height_rectangle = getRectangleHeight(hasHour,actual_entry)
       
      #Test if need a new page before print special title.
      first_row_entrie = []
      first_row_entrie << next_entries[0]  
      height_table = getTableHeight(first_row_entrie,headings)
      height_total = height_table + height_rectangle
      
      if height_total > (bottom_space - margin_space_special)
        return 0
      end
      
    else  
      height_rectangle = 0
    end
    
    
    #Normal cases
    
    maxRow = 0 
    entries_test = []
    
    next_entries.length.times do |i|
      
      entries_test << next_entries[i]
      
      height_table = getTableHeight(entries_test, headings) 
      height_total = height_table + height_rectangle       
  
      if height_total < (bottom_space - margin_space)
        maxRow = i+1
      else
          return maxRow       
      end
     
    end

    return maxRow  

  end
  
  #Calculate the height of the rectangle.
  def getRectangleHeight(hasHour,divider)
    
    pdf_test = PDF::Writer.new(:paper => "A4", :orientation => :portrait )
    pdf_test.select_font("Helvetica", { :encondig => "WinAnsiEnconding" } )  
    
#    nLines = divider.divider.gsub(/[^<]*(<br>)/, "a").length; //Return the ocurrences of <br>
    lines_content = divider.divider.split("<br/>");
    
    height_rectangle = 0
    
    lines_content.each do |l|
      title_width = pdf_test.text_line_width(text_to_iso(l), 15)
      
      if hasHour
        #Actually not used.
        f_rectangle = (title_width / 490)
      else
        f_rectangle = (title_width / 590)
      end

      f_rectangle = f_rectangle.ceil
      h = 18

      height_rectangle = height_rectangle + h*f_rectangle
      
    end
   
    h_margen = 5
   
    return height_rectangle + h_margen
  end
  
  
  def isSpecialTitle(entry)
    
    if entry != nil && entry.divider != nil
      return true
    else
      return false;
    end

  end


  # Adapt the new format of the entries to the old format.
  # More information of old format in the documentation of fragment_entries method.
  # (Example) 
  # Format received: [Special A][B][C][Special D][E]
  # Format returned; [Divider A][A][B][C][Divider D][D][E]
  # In other words, traduce [Special X] to [Divider X]+[X]
  # [Special X] = entrie with divider field != nil, and the corresponding fields of description,speakers,start_time,...
  # [Divider X] = entrie with divider field != nil, the other fields of this entrie NOT BE USED.
  # [X] = entrie with divider field == nil. The other fields be used normally.
  def adaptor_to_newVersion(entries)
    
    entries_new = []
    
    entries.each do |entrie|
      
      if(isSpecialTitle(entrie))
        entrie_a = AgendaEntry.new
        entrie_a.title = ""
        entrie_a.speakers = ""
        entrie_a.description = ""
        entrie_a.start_time = entrie.start_time
        entrie_a.end_time = entrie.end_time
        entrie_a.divider = entrie.divider
        
        entrie.divider = nil
        
        entries_new << entrie_a
        entries_new << entrie
      else
        entries_new << entrie;
      end
    
    end
 
  entries_new

  end

  #Fragment the entries of one day.
  #It used to fragment the inicial table of one day into two or more tables around the entries with special titles.
  #Returns an array of entrie arrays and arrays that contains a single divider.
  #Format example: {[Entrie_Array[]][Divider][Entrie_Array[]][Divider][Divider][Entrie_Array[]]]}
  #An element that contains an array of entries its never preceded by another element that contains an array of entries too.
  #An element that contains an array that contains a divider always have only one element.
  #Fragment individual entries application limit description.
  def fragment_entries(entries,day)
    
    array_entries = []
    entries_temp = []
    
    entries.each do |entrie|    
      
      if isSpecialTitle(entrie)
        
        unless entries_temp.empty?
          array_entries << entries_temp
          entries_temp = []
        end
        
        entries_temp << entrie
        array_entries << entries_temp
        entries_temp = []
        
      else
        
        ##Select maxLenght##
 
        if entrie == entries[0] and day == 0
          maxLength = 2700
        else
          
          #index_previous_entry will be 0 at least.
          index_previous_entry = entries.index(entrie) - 1
          
          if isSpecialTitle(entries[index_previous_entry])
            
            if index_previous_entry == 0 and day == 0
              maxLength = 2600
            elsif index_previous_entry == 0
              maxLength = 3200
            else
              maxLength = 3300
            end
            
          else    
            maxLength = 3300      
          end
          
        end
        ##maxLenght selected##
        
        fragment_entries_by_description = fragment_entrie_by_description(entrie,maxLength,true)
        
        fragment_entries_by_description.each do |entrie_fragment_by_description|
          entries_temp << entrie_fragment_by_description
        end  
          
        if entrie==entries[entries.length-1]
          array_entries << entries_temp
        end
        
      end
      
    end

    array_entries
   
  end
  
  #Fragment long entries that not fit in one page into two or more short entries.    
  def fragment_entrie_by_description(entrie,maxLength,first)
  
    fragment_entries_by_description = []
    subfragment_entries_by_description = []
    index_length = 1
    
    #Analice if the entrie fits in one page.
    if isLongEntry(entrie,true)
       
        
        if first
         
          #Remove the multiples \n.
          entrie.description = entrie.description.gsub(/([\n])+/, "\n")
            
            unless isLongEntry(entrie, true)
              fragment_entries_by_description << entrie
              return fragment_entries_by_description
            end
     
          #Remove simple \n.
          entrie.description = entrie.description.gsub(/([\n])+/, "")
          
          unless isLongEntry(entrie, true)
            fragment_entries_by_description << entrie
            return fragment_entries_by_description
          end 
        
        end   
            
             
        #Copy the entrie, and cuts the description.
        entrie_a = AgendaEntry.new
        entrie_a.start_time = entrie.start_time
        entrie_a.end_time = entrie.end_time
        entrie_a.title = entrie.title
        entrie_a.speakers = entrie.speakers
        
        aux = entrie.description
   
        #Set the index_lenght at the min value to ensure that the entry fits in one page.
        while aux.length > maxLength          
            index_length = index_length + 1
            aux = entrie.description[0,maxLength-index_length]
        end
        
#        Try to cut in a space. (10 caracteres checked)       
        10.times do    
          
          if(entrie.description[maxLength-index_length] == 32) #Whitespace
            break
          end
          
          index_length = index_length + 1
        end
        
                
        #Cuts the string.
        
        #Test if the additional row has very low length. 
        if entrie.description[maxLength-index_length,entrie.description.length].length < 10
          entrie_a.description = entrie.description[0,entrie.description.length]
         
          if isLongEntry(entrie_a, true)
            return fragment_entrie_by_description(entrie,maxLength-100,first)
          else
            fragment_entries_by_description << entrie_a
            return fragment_entries_by_description;
          end
        
        end
          
        entrie_a.description = entrie.description[0,maxLength-index_length] + "..."
        
        #Real comprobation
        if isLongEntry(entrie_a, true)
          return fragment_entrie_by_description(entrie,maxLength-100,first)
        end

        fragment_entries_by_description << entrie_a
        
        entrie.description = "..." + entrie.description[maxLength-index_length,entrie.description.length]
   
        if first
          entrie.title = entrie.title + "\n(Cont)"
          first = false;
        end
        
        subfragment_entries_by_description = fragment_entrie_by_description(entrie,3400,false)
         
        subfragment_entries_by_description.each do |subfragment|
          fragment_entries_by_description << subfragment
        end
     
    else
     
      fragment_entries_by_description << entrie
      
    end
    
    fragment_entries_by_description
      
  end
     
  #Generate and fill a table with the dates contained in entries.
  #tab_title Title of the table. Nil if we want the table without title.
  #heading True to show the table heading.
  def generate_entrie_table(pdf,entries,tab_title,heading)
   
#    @entries = entries
    
    PDF::SimpleTable.new do |tab|
    
    if tab_title
      tab.title = tab_title
      tab.title_color = Color::RGB::Black
      tab.title_font_size = 14
      tab.title_gap = 8
    end 

    tab.row_gap = 3
    
    tab.show_lines =:all
    tab.show_headings = heading
    tab.bold_headings = true
    tab.shade_headings  = true
    tab.heading_font_size = 11
    tab.orientation = :center
    tab.position = :center
    tab.minimum_space = 50
    tab.shade_heading_color = Color::RGB.new(134,154,184)
    tab.shade_color = Color::RGB::Grey90
    tab.text_color = Color::RGB::Black

    if(@c4_width == 0)
      #if small_version
      tab.column_order = ["col1","col2","col3"]
    else
      tab.column_order = ["col1","col2","col3","col4"]
    end   
    
    tab.columns["col1"] = PDF::SimpleTable::Column.new("col1") { 
      |col| 
      col.width = @c1_width
      col.heading = "Hour"
      col.heading.justification = :center 
    }
    
    tab.columns["col2"] = PDF::SimpleTable::Column.new("col2") { 
      |col| 
      col.width = @c2_width
      col.heading = "Title" 
      col.heading.justification = :center   
    }
    
    tab.columns["col3"] = PDF::SimpleTable::Column.new("col3") { 
      |col| 
      col.width = @c3_width
      col.heading = "Speakers"
      col.heading.justification = :center 
    }
    
    tab.columns["col4"] = PDF::SimpleTable::Column.new("col4") { |col| 
      col.width = @c4_width
      col.heading = "Description" 
      col.heading.justification = :center    
    }
    

    data = []
    
      entries.each do |entrie|

        hour =  entrie.start_time.strftime("%H:%M").to_s() + " to " + entrie.end_time.strftime("%H:%M").to_s()
        
        if(@c4_width == 0)
          #if small_version
          add_row_without_description(tab,data,hour,entrie.title,entrie.speakers)
        else
          add_row(tab,data,hour,entrie.title,entrie.speakers,entrie.description) 
        end

      end
    
      tab.render_on(pdf)
      
      pdf.fill_color!  Color::RGB::Black

    end
  
  end
  
  
  #Method to add a row in the table tab.
  def add_row(tab,data,hour,title,speakers,description)       
    data << { "col1" => text_to_iso("#{hour}"), "col2" => text_to_iso("#{title}"), 
    "col3" => text_to_iso("#{speakers}"), "col4" => text_to_iso("#{description}") }
    tab.data.replace data      
  end
  
  def add_row_without_description(tab,data,hour,title,speakers)       
    data << { "col1" => text_to_iso("#{hour}"), "col2" => text_to_iso("#{title}"), 
    "col3" => text_to_iso("#{speakers}") }
    tab.data.replace data      
  end
  
  def text_to_iso(text)
    c = Iconv.new('ISO-8859-15//IGNORE//TRNSLIT', 'UTF-8')
    c.iconv(text)
  end
  
  
  #Write the event title. Decrement font-size in function of the title's lenght.
  def write_event_title(pdf,event_name)
   
    pdf.text " ", :font_size => 6
    
    #If the lenght is in the range (function_lenght_min,function_lenght_max), applying a function 
    #to decrement one font-size point every "function_scale" letters added.
    function_lenght_max = 45
    function_lenght_min = 9
    function_scale = 2
   
    font_size_event_title_max = 33
    font_size_event_title_min = font_size_event_title_max - ((function_lenght_max-function_lenght_min)/function_scale)
   
    font_size_event_title = font_size_event_title_max
   
    if event_name.length > function_lenght_max
      font_size_event_title = font_size_event_title_min
    else 
      if event_name.length > function_lenght_min    
        dif = (event_name.length - function_lenght_min)/function_scale
        font_size_event_title -= dif
      end
    end
   
    pdf.select_font("Helvetica-Bold", { :encondig => "WinAnsiEnconding" } )
    pdf.text text_to_iso(event_name), :font_size => font_size_event_title, :justification => :center
    pdf.select_font("Helvetica" , { :encondig => "WinAnsiEnconding" } )
   
    pdf.text " ", :font_size => 25

  end


  #Add special title to the pdf.
  def write_special_title(pdf,width_hour,width_title,divider,hasHour)
      
    vccColor = Color::RGB.new(36, 73, 116)
#    pdf.text " ", :font_size => 3
    pdf.select_font("Helvetica", { :encondig => "WinAnsiEnconding" } )   

    height_rectangle = getRectangleHeight(hasHour,divider)
 
    bottom_space = pdf.y
    margin_space = 20
      
    #Test if the special title fits in the page.
    if height_rectangle > (bottom_space - margin_space)
      pdf.start_new_page
    end
  
    #First page.
    if pdf.current_page_number() == 1
      pdf.y = pdf.y + 1
    end
    
    pdf.y = pdf.y - 3
    last_y = pdf.y

    pdf.fill_color!  vccColor
    #rounded_rectangle(x, y, w, h, r)
    #Draw a rounded rectangle with corners (x, y) and (x + w, y - h) and corner radius r. The radius should be significantly smaller than h and w.
    rectangle = pdf.rounded_rectangle(pdf.absolute_left_margin-20, pdf.y, pdf.page_width-10, height_rectangle, 15)
    rectangle.stroke_color!(Color::RGB::White)  
    rectangle.close_fill_stroke
    
    pdf.fill_color!  Color::RGB::White
    
    #pdf.margins_pt(5, 25, 5, 15)   #pdf.margins_pt(Top, Left, Bottom, Right) previous margins
    
    pdf.margins_pt(5, 1, 5, 1)
    

    pdf.text text_to_iso("#{divider.divider}").gsub(/<br\/>/, "\n"), :font_size => 15, :justification => :center
    pdf.margins_pt(5, 25, 5, 15)
    
    
    if pdf.current_page_number() == 1
      margin_bottom = 2
    else
      margin_bottom = 1
    end    
    
    pdf.y = last_y - height_rectangle + margin_bottom
    pdf.fill_color!  Color::RGB::Black

  end

  #Check if the agenda needs to be generate.
  def needsGenerate(small_version)
    
    if small_version == "true"
      
      name = "agenda_" + permalink + "_small.pdf"
      isFile = File.exist?("#{RAILS_ROOT}/public/pdf/#{permalink}/#{name}")
  
      if !(isFile) or !(generate_pdf_small_at) or generate_pdf_small_at < agenda.updated_at
        update_attribute(:generate_pdf_small_at, Time.now)
        return true;
      end
      
    else
       
      name = "agenda_" + permalink + ".pdf"
      isFile = File.exist?("#{RAILS_ROOT}/public/pdf/#{permalink}/#{name}")
  
      if !(isFile) or !(generate_pdf_at) or generate_pdf_at < agenda.updated_at
        update_attribute(:generate_pdf_at, Time.now)
        return true;
      end
  
    end

    return false;
    
  end

end