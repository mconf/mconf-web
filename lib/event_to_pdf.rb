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
    c1_width = 75
    c2_width = 135
    c3_width = 170
    c4_width = 360
    
    pdf.select_font("Helvetica" , { :encondig => "WinAnsiEnconding" } )
    pdf.start_page_numbering(pdf.margin_x_middle, 5, 10, nil, nil, 1)
    
    i1 = "#{RAILS_ROOT}/public/images/cabeceraVCC_pdf.jpg"
    i2 = "#{RAILS_ROOT}/public/images/vcc-logo_pdf.jpg"
    pdf.image i1, :justification => :right, :resize => 1
    pdf.image i2, :justification => :left, :resize => 0.7
    
    write_event_title(pdf,name)
    
    
    days.times do |i|
        
      date = (start_date+i.day).strftime("%A %d %b")

      @entries = agenda.agenda_entries_for_day(i)
    
      unless i == days or i == 0 or @entries.empty?
        pdf.start_new_page  
      end
 
      @entries_array = fragment_entries(@entries)
       
      @entries_array.each do |entries|
           
      if entries == @entries_array[0]
        #First entrie in the day. Its a special case.

        #if entries[0].special_title    #The first entrie in the day has a special title.
        if random_boolean(0)
          pdf.fill_color  Color::RGB::Black
          pdf.text "#{date}", :font_size => 14, :justification => :center
          pdf.text " ", :font_size => 2
        
          #Two types of special titles. To test we will chose one of them randomly.
          if random_boolean(50)
            write_special_title(pdf,c1_width + c2_width,c3_width + c4_width,entries[0],true)
          else
            write_special_title_b(pdf,c1_width + c2_width,c3_width + c4_width,entries[0],true)
          end

          if entries.length > 1
            generate_entrie_table(pdf,c1_width,c2_width,c3_width,c4_width,entries,nil      ,   true,       false)
            #generate_entrie_table(pdf,c1_width,c2_width,c3_width,c4_width,entries,tab_title,heading,first_entrie)
          end
          
        else
          generate_entrie_table(pdf,c1_width,c2_width,c3_width,c4_width,entries,date     ,   true,        true)
        end
            
      else
        #if entries[0].special_title 
        if random_boolean(0)         
          write_special_title_b(pdf,c1_width + c2_width ,c3_width + c4_width,entries[0],true)
            
          if entries.length > 1
            generate_entrie_table(pdf,c1_width,c2_width,c3_width,c4_width,entries,nil,false,false)
          end
            
          else
            generate_entrie_table(pdf,c1_width,c2_width,c3_width,c4_width,entries,nil,true,true)
          end
          
        end 
        
      end 
      
    end     #All Day Ends. PDF finished.
    
    pdf.render
   
  end
  
  private
  
  #Returns a random boolean, only for test.
  #trueProbability is a number in the range (0,100) (%)
  def random_boolean(trueProbability)
    
    @random_boolean = false
    num_aleat = rand(10)

    if num_aleat > (9-(trueProbability/10))
      @random_boolean = true
    end
    
    @random_boolean
    
  end
  
  
  #Fragment the entries of one day.
  #Returns a array of entries, i.e , a array of entrie arrays.
  #It used to fragment the inicial table of one day into two or more tables around the entries with special titles.
  def fragment_entries(entries)
    
    array_entries = []
    entries_temp = []
    
    entries.each do |entrie|    
      
      #if entrie.special_title
      if random_boolean(0)
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
  #First_entrie False if we want to ignore the first row in the table.
  def generate_entrie_table(pdf,c1_width,c2_width,c3_width,c4_width,entries,tab_title,heading,first_entrie)
    
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
      col.width = c1_width
      col.heading = "Hour"
      col.heading.justification = :center 
    }
    
    tab.columns["col2"] = PDF::SimpleTable::Column.new("col2") { 
      |col| 
      col.width = c2_width
      col.heading = "Title" 
      col.heading.justification = :center   
    }
    
    tab.columns["col3"] = PDF::SimpleTable::Column.new("col3") { 
      |col| 
      col.width = c3_width
      col.heading = "Speakers"
      col.heading.justification = :center 
    }
    
    tab.columns["col4"] = PDF::SimpleTable::Column.new("col4") { |col| 
      col.width = c4_width
      col.heading = "Description" 
      col.heading.justification = :center    
    }
    

    data = []
    
      @entries.each do |entrie|
      
        hour =  entrie.start_time.strftime("%H:%M").to_s() + " to " + entrie.end_time.strftime("%H:%M").to_s() 
        
        unless !first_entrie and (entrie == @entries[0])
          add_row(tab,data,hour,entrie.title,entrie.speakers,entrie.description)
        end
 
      end
    
      tab.render_on(pdf)

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


  #Add special title to the pdf. Model 2
  def write_special_title_b(pdf,width_hour,width_title,entrie,hasHour)
      
    vccColor = Color::RGB.new(36, 73, 116)
    pdf.text " ", :font_size => 3
    pdf.select_font("Helvetica", { :encondig => "WinAnsiEnconding" } )

    x = pdf.absolute_left_margin+20    

    #f_rectangle estimated lines occupied by the text.
    title_width = pdf.text_line_width(text_to_iso("#{entrie.title}"), 18)  
    
    if hasHour    
      f_rectangle = (title_width / 590)
    else
      f_rectangle = (title_width / 735)
    end

    #1-4 lines cases are treated specified.
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
 
    bottom_space = pdf.y
    margin_space = 20
      
    #Test if the special title fits in the page.
    if height_rectangle > (bottom_space - margin_space)
      pdf.start_new_page
    end

    last_y = pdf.y

    pdf.fill_color  vccColor
    #rounded_rectangle(x, y, w, h, r)
    #Draw a rounded rectangle with corners (x, y) and (x + w, y - h) and corner radius r. The radius should be significantly smaller than h and w.
    pdf.rounded_rectangle(pdf.absolute_left_margin+20, pdf.y, 735, height_rectangle, 10).close_fill_stroke
    
    pdf.fill_color  Color::RGB::White
    
    #pdf.margins_pt(25, 30, 25, 30)   #pdf.margins_pt(Top, Left, Bottom, Right) previous margins
    
    if hasHour
      hour =  entrie.start_time.strftime("%H:%M").to_s() + " to " + entrie.end_time.strftime("%H:%M").to_s()
        
      #add_text(x, y, text, size = nil, angle = 0, word_space_adjust = 0)
      #Add text to the document at (x, y) location at size and angle. 
      #The word_space_adjust parameter is an internal parameter that should not be used.
      pdf.add_text(x+20, pdf.y-19, text_to_iso("#{hour}"), 14, 0, 0)      
       
      pdf.margins_pt(25, 200, 25, 55)
    else
      pdf.margins_pt(25, 55, 25, 55)
    end

    pdf.text text_to_iso("#{entrie.title}"), :font_size => 18, :justification => :center
    pdf.margins_pt(25, 30, 25, 30)
    pdf.y = last_y - height_rectangle
    pdf.fill_color  Color::RGB::Black
    pdf.text " ", :font_size => 3 

  end
 
 
  #Add special title to the pdf. Model 1
  def write_special_title(pdf,width_hour,width_title,entrie,hasHour)

    pdf.text " ", :font_size => 2
    pdf.select_font("Helvetica-Bold", { :encondig => "WinAnsiEnconding" } )
    
    @specialTable = PDF::SimpleTable.new do |tab|  
    
      data = [] 
    
      if hasHour
    
        hour =  entrie.start_time.strftime("%H:%M").to_s() + " to " + entrie.end_time.strftime("%H:%M").to_s()
    
        tab.column_order = ["col1","col2"]
    
        tab.columns["col1"] = PDF::SimpleTable::Column.new("col1") { 
          |col| 
          col.width = width_hour
          col.justification = :center
        }
    
        tab.columns["col2"] = PDF::SimpleTable::Column.new("col2") { 
          |col| 
          col.width = width_title
          col.justification = :center
        }
    
        data << { "col1" => text_to_iso("#{hour}"), "col2" => text_to_iso("#{entrie.title}") }
    
        pdf.select_font("Helvetica-Bold", { :encondig => "WinAnsiEnconding" } )
        tab.font_size = 13
    
      else  
    
        tab.column_order = ["col1"]
    
        tab.columns["col1"] = PDF::SimpleTable::Column.new("col1") { 
          |col| 
          col.width = width_hour + width_title
          col.justification = :center
        }

        data << { "col1" => text_to_iso("#{entrie.title}") }
    
        tab.font_size = 15
    
      end

      tab.show_lines =:none
      tab.show_headings = false
      tab.orientation = :center
      tab.position = :center
      tab.shade_color = Color::RGB.new(225, 238, 245)
      #tab.line_color = vccColor

      tab.data.replace data  
      tab.text_color = Color::RGB::Black
    
      tab.render_on(pdf)  
   
    end
  
    pdf.select_font("Helvetica" , { :encondig => "WinAnsiEnconding" } )
    pdf.fill_color  Color::RGB::Black
    pdf.text " ", :font_size => 5

  end

end