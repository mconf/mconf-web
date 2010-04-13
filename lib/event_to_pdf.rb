require 'pdf/writer'
require 'pdf/simpletable' #To manage tables. 
require 'iconv'

module EventToPdf
  
  #Method to generate the agenda of the event in PDF.
  def to_pdf
       
    pdf = PDF::Writer.new(:paper => "A4", :orientation => :landscape )
   
    #Create a gradient, at the top right corner.
    r1 = 25
    30.step(-1, -3) do |xw|
      tone = 1.0 - (xw / 40.0) * 0.2  #Parameter to control the brightness of the gradient.
      color = 0x400ee3  #Parameter to change the color of the gradient.
      pdf.stroke_style(PDF::Writer::StrokeStyle.new(xw))
      pdf.stroke_color(Color::RGB.from_fraction(tone,3250,color))
      pdf.circle_at(850, 650, r1).stroke
      r1 += xw
    end

    pdf.margins_pt(25, 30, 25, 30)   #pdf.margins_pt(Top, Left, Bottom, Right)

    #Parameters of the the table.  
    @c1_width = 75
    @c2_width = 135
    @c3_width = 170
    @c4_width = 360
    
    pdf.select_font("Helvetica" , { :encondig => "WinAnsiEnconding" } )
    pdf.start_page_numbering(pdf.margin_x_middle, 5, 10, nil, nil, 1)
    
    i1 = "#{RAILS_ROOT}/public/images/cabeceraVCC_pdf.jpg"
    i2 = "#{RAILS_ROOT}/public/images/vcc-logo_pdf.jpg"
    pdf.image i1, :justification => :right, :resize => 1
    pdf.image i2, :justification => :left, :resize => 0.7
    
    write_event_title(pdf,name)
    
    days.times do |i|
        
      date = (start_date+i.day).strftime("%A %d %b")
      
      #Array of entries and dividers.
      @entries = agenda.contents_for_day(i+1)
    
      unless i == days or i == 0 or @entries.empty?
        pdf.start_new_page  
      end
 
      #Array of entrie arrays and array who contains a single divider.
      @entries_array = fragment_entries(@entries)      
      
      heads = true
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
        
        generate_entrie_table(pdf,entries,nil,heads)
        
        end
    
      end 
      
    end     #All Day Ends. PDF finished.
    
    pdf.render
   
  end
  
  private
  
  #Calculate the height of the table generate with the entries array.
  def getTableHeight(entries,heading)
     
    pdf_test = PDF::Writer.new(:paper => "A4", :orientation => :landscape )
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
    margin_space = 25
    
    if isSpecialTitle(actual_entry)
      
      headings = false
      
      height_rectangle = getRectangleHeight(false,actual_entry)
       
      #Test if need a new page before print special title.
      first_row_entrie = []
      first_row_entrie << next_entries[0]  
      height_table = getTableHeight(first_row_entrie,headings)
      height_total = height_table + height_rectangle
      
      if height_total > (bottom_space - margin_space)
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
    
    pdf_test = PDF::Writer.new(:paper => "A4", :orientation => :landscape )
    pdf_test.select_font("Helvetica", { :encondig => "WinAnsiEnconding" } )  
    title_width = pdf_test.text_line_width(text_to_iso("#{divider.title}"), 18)  
    
    if hasHour    
      f_rectangle = (title_width / 590)
    else
      f_rectangle = (title_width / 735)
    end

    if f_rectangle < 5
      f_rectangle = f_rectangle.ceil
    else
      f_rectangle = f_rectangle + 1
    end
      
    case f_rectangle
      when 0
        f_rectangle = 1
        h = 29
      when 1
        h = 29
      when 2
        h = 26
      when 3
        h = 24
      when 4
        h = 22
    else
        h = 22
    end

    height_rectangle = h*f_rectangle
    
    return height_rectangle
  end
  
  
  def isSpecialTitle(entry)  
    if entry == nil
      return false
    else
      return  !(entry.class == AgendaEntry)
    end  
  end


  #Fragment the entries of one day.
  #It used to fragment the inicial table of one day into two or more tables around the entries with special titles.
  #Returns an array of entrie arrays and arrays that contains a single divider.
  #Format example: {[Entrie_Array[]][Divider][Entrie_Array[]][Divider][Divider][Entrie_Array[]]]}
  #An element that contains an array of entries its never preceded by another element that contains an array of entries too.
  #An element that contains an array that contains a divider always have only one element.
  def fragment_entries(entries)
    
    array_entries = []
    entries_temp = []
    
    entries.each do |entrie|    
      
      unless entrie.class == AgendaEntry
        
        unless entries_temp.empty?
          array_entries << entries_temp
          entries_temp = []
        end
        
        entries_temp << entrie
        array_entries << entries_temp
        entries_temp = []
        
      else
        entries_temp << entrie
          
        if entrie==entries[entries.length-1]
          array_entries << entries_temp
        end
        
      end
      
    end

    array_entries
   
  end
     
  #Generate and fill a table with the dates contained in entries.
  #tab_title Title of the table. Nil if we want the table without title.
  #heading True to show the table heading.
  def generate_entrie_table(pdf,entries,tab_title,heading)
  
    @entries = entries
    
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

    tab.column_order = ["col1","col2","col3","col4"]
    
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
    
      @entries.each do |entrie|
      
        hour =  entrie.start_time.strftime("%H:%M").to_s() + " to " + entrie.end_time.strftime("%H:%M").to_s() 
        add_row(tab,data,hour,entrie.title,entrie.speakers,entrie.description)       
 
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
  
  def text_to_iso(text)
    c = Iconv.new('ISO-8859-15//IGNORE//TRNSLIT', 'UTF-8')
    c.iconv(text)
  end
  
  
  #Write the event title. Decrement font-size in function of the title's lenght.
  def write_event_title(pdf,event_name)
   
    pdf.text " ", :font_size => 12
    
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
   
    pdf.text " ", :font_size => 30

  end


  #Add special title to the pdf.
  def write_special_title(pdf,width_hour,width_title,divider,hasHour)
      
    vccColor = Color::RGB.new(36, 73, 116)
    pdf.text " ", :font_size => 3
    pdf.select_font("Helvetica", { :encondig => "WinAnsiEnconding" } )

    x = pdf.absolute_left_margin+20    

    height_rectangle = getRectangleHeight(false,divider)
 
    bottom_space = pdf.y
    margin_space = 20
      
    #Test if the special title fits in the page.
    if height_rectangle > (bottom_space - margin_space)
      pdf.start_new_page
    end

    pdf.y = pdf.y - 3
    last_y = pdf.y

    pdf.fill_color!  vccColor
    #rounded_rectangle(x, y, w, h, r)
    #Draw a rounded rectangle with corners (x, y) and (x + w, y - h) and corner radius r. The radius should be significantly smaller than h and w.
    rectangle = pdf.rounded_rectangle(pdf.absolute_left_margin+20, pdf.y, 735, height_rectangle, 15)
    rectangle.stroke_color!(Color::RGB::White)  
    rectangle.close_fill_stroke
    
    pdf.fill_color!  Color::RGB::White
    
    #pdf.margins_pt(25, 30, 25, 30)   #pdf.margins_pt(Top, Left, Bottom, Right) previous margins
    
    if hasHour
      hour =  divider.start_time.strftime("%H:%M").to_s() + " to " + divider.end_time.strftime("%H:%M").to_s()
        
      #add_text(x, y, text, size = nil, angle = 0, word_space_adjust = 0)
      #Add text to the document at (x, y) location at size and angle. 
      #The word_space_adjust parameter is an internal parameter that should not be used.
      pdf.add_text(x+20, pdf.y-19, text_to_iso("#{hour}"), 14, 0, 0)      
       
      pdf.margins_pt(25, 200, 25, 55)
    else
      pdf.margins_pt(25, 55, 25, 55)
    end

    pdf.text text_to_iso("#{divider.title}"), :font_size => 18, :justification => :center
    pdf.margins_pt(25, 30, 25, 30)
    pdf.y = last_y - height_rectangle - 1
    pdf.fill_color!  Color::RGB::Black
    pdf.text " ", :font_size => 3 

  end

end