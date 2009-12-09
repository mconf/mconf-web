require 'pdf/writer'
require 'pdf/simpletable' #Necesario para hacer tablas. 
require 'iconv'

class AgendasController < ApplicationController
  before_filter :space!
  before_filter :event
  
  # GET /agenda/edit
  def edit
    @agenda_entry = AgendaEntry.new
  end
  
  
  def generate_pdf_b
    
    #Obtención de parámetros.
    @event
    @space
    
    @agenda = @event.agenda
    
   pdf = PDF::Writer.new(:paper => "A4", :orientation => :portrait )
   
   pdf.margins_pt(25, 30, 25, 30)
#pdf.margins_pt(Top, Left, Bottom, Right)

   
   pdf.select_font "Times-Roman"
   pdf.select_font ("Helvetica" , { :encondig => "WinAnsiEnconding" } )
   pdf.start_page_numbering(pdf.margin_x_middle, 5, 10, nil, nil, 1)


  #i0 = "#{RAILS_ROOT}/public/images/bola_global_peque.jpg"
  i1 = "#{RAILS_ROOT}/public/images/cabeceraVCC.jpg"
  #pdf.image i0, :justification => :right, :resize => 1
  pdf.image i1, :justification => :right, :resize => 1

   
   
   pdf.text " ", :font_size => 18
   pdf.text t('agenda.title'), :font_size => 30, :justification => :center
   pdf.text @event.name, :font_size => 30, :justification => :center
   pdf.text " ", :font_size => 18

 
   @event.days.times do |i|
   
   pdf.text "Dia " + i.to_s(), :font_size => 16, :justification => :left
   
   pdf.text " ", :font_size => 12  
   
    @entries = @agenda.agenda_entries_for_day(i)
    
      @entries.each do |entrie|
      
        pdf.text entrie.start_time.strftime("%H:%M").to_s() + " to " + entrie.end_time.strftime("%H:%M").to_s(), :font_size => 12
        pdf.text entrie.title, :font_size => 14
        pdf.text "-------------------------------------------------------------------------------------------------"
        
        
        pdf.text "<b>" + t('agenda.entry.speakers')    + "</b>" + ": " + entrie.speakers, :font_size => 12
        pdf.text "<b>" + t('agenda.entry.description') + "</b>" + ": " + entrie.description
        
        if entrie.record
          pdf.text "<b>" + t('agenda.entry.record') + "</b>" + ": " + t('agenda.entry.yes_record')
        else
          pdf.text "<b>" + t('agenda.entry.record') + "</b>" + ": " + t('agenda.entry.no_record')
        end

        linea_pdf(pdf)
 
      end
    
   
#    create_table :agenda_entries do |t|
#      t.integer :agenda_id
#      t.string :title
#      t.text :description
#      t.string :speakers
#      t.datetime :start_time
#      t.datetime :end_time
#      t.boolean :record
#      t.timestamps
#    end
   
   
   pdf.text " ", :font_size => 18
   
   end


   #0.step(315, 45) do |angle|
      #pdf.add_text(pdf.margin_x_middle, pdf.margin_y_middle, "#{angle}o".rjust(8), 12, angle)
 # end
  
   #pdf.add_text(470, 820, "Virtual Conference Centre", 10, 0)
   
   pdf.save_as("agenda_" + @event.name + ".pdf") 
   
  end
 
 
  def generate_pdf
    
    #Obtención de parámetros.
    @event
    @space
    
    @agenda = @event.agenda
    
   pdf = PDF::Writer.new(:paper => "A4", :orientation => :landscape )
   
    #Creamos un degradada en la esquina superior derecha.
    r1 = 25
    30.step(-1, -3) do |xw|
      tone = 1.0 - (xw / 40.0) * 0.2
      pdf.stroke_style(PDF::Writer::StrokeStyle.new(xw))
      pdf.stroke_color(Color::RGB.from_fraction(tone,3250,0x400ee3))
      pdf.circle_at(850, 650, r1).stroke
      r1 += xw
   end

   pdf.margins_pt(25, 30, 25, 30)   #pdf.margins_pt(Top, Left, Bottom, Right)

   
   pdf.select_font "Times-Roman"
   pdf.select_font ("Helvetica" , { :encondig => "WinAnsiEnconding" } )
   pdf.start_page_numbering(pdf.margin_x_middle, 5, 10, nil, nil, 1)

  i1 = "#{RAILS_ROOT}/public/images/cabeceraVCC_pdf.jpg"
  i2 = "#{RAILS_ROOT}/public/images/vcc-logo_pdf.jpg"
  pdf.image i1, :justification => :right, :resize => 1
  pdf.image i2, :justification => :left, :resize => 0.7

    
   pdf.text t('agenda.title'), :font_size => 30, :justification => :center
   pdf.text @event.name, :font_size => 30, :justification => :center
   pdf.text " ", :font_size => 35
 

 
  @event.days.times do |i|
    
    unless i == @event.days or i == 0
      pdf.start_new_page
    end
       
#    pdf.text "Dia " + (i+1).to_s(), :font_size => 20, :justification => :center
#    pdf.text(" ")
   
    #date = "Dia " + (i+1).to_s()
    date = (@event.start_date+i.day).strftime("%A %d %b")

    @entries = @agenda.agenda_entries_for_day(i)
 
  #Construimos la tabla.
  
    c1_width = 75
    c2_width = 135
    c3_width = 170
    c4_width = 360
 
#  PDF::SimpleTable.new do |tab|
#    tab.column_order = ["col1"]
#    
#    tab.columns["col1"] = PDF::SimpleTable::Column.new("col1") { 
#      |col| 
#      col.width = c1_width + c2_width + c3_width + c4_width
#    }
#    
#    tab.show_lines =:all
#    tab.show_headings = false
#    tab.orientation = :center
#    tab.position = :center
#    tab.shade_color = Color::RGB::Grey90
#    
#    data = []
#    titulo = "Dia1"
#    data << { "col1" => text_to_iso("#{titulo}") }
#    tab.data.replace data
#    tab.render_on(pdf)
#    
#  end
 
  PDF::SimpleTable.new do |tab|
    
    tab.title = date
    tab.title_color = Color::RGB::Black
    tab.title_font_size = 14
    tab.title_gap = 8
    #tab.title.justificacion = :left

    tab.row_gap = 3
    
    tab.show_lines =:all
    tab.show_headings = true
    tab.bold_headings = true
    tab.shade_headings  = true
    tab.heading_font_size = 11
    tab.orientation = :center
    tab.position = :center
    tab.minimum_space = 50
    tab.shade_heading_color = Color::RGB.new(134,154,184)
    tab.shade_color = Color::RGB::Grey90



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

          add_row(tab,data,hour,entrie.title,entrie.speakers,entrie.description)
 
        end
    
      tab.render_on(pdf)
    
    end   #Terminamos de construir la tabla PDF

#    linea_pdf(pdf)

  end     #Pasamos a otro dia.

   nombre = "agenda_" + @event.name + ".pdf"
   send_data pdf.render, :filename => "#{nombre}", :type => "application/pdf"
   #pdf.save_as("agenda_" + @event.name + ".pdf") 
   
  end
  
  
  
  private
  
  def event
    @event = Event.find(params[:event_id])
  end
  
  def space!
    @space = Space.find_by_permalink(params[:space_id])
  end
  
  def linea_pdf(pdf)  
       pdf.text(" ")
       
       x = pdf.absolute_left_margin
       w = pdf.absolute_right_margin - x
       y = pdf.y
       h = 1  
       pdf.rectangle(x, y, w, h).fill
       
       pdf.text(" ")
  end
  
  def add_row(tab,data,hour,title,speakers,description)       
        data << { "col1" => text_to_iso("#{hour}"), "col2" => text_to_iso("#{title}"), 
        "col3" => text_to_iso("#{speakers}"), "col4" => text_to_iso("#{description}") }
        tab.data.replace data      
  end
  
  def text_to_iso(text)
    c = Iconv.new('ISO-8859-15//IGNORE//TRNSLIT', 'UTF-8')
    c.iconv(text)
  end
  
=begin
  # GET /agendas
  # GET /agendas.xml
  def index
    @agendas = Agenda.all

    respond_to do |format|
      format.html # index.html.erb
      format.xml  { render :xml => @agendas }
    end
  end

  # GET /agendas/1
  # GET /agendas/1.xml
  def show
    @agenda = Agenda.find(params[:id])

    respond_to do |format|
      format.html # show.html.erb
      format.xml  { render :xml => @agenda }
    end
  end

  # GET /agendas/new
  # GET /agendas/new.xml
  def new
    @agenda = Agenda.new

    respond_to do |format|
      format.html # new.html.erb
      format.xml  { render :xml => @agenda }
    end
  end

  # GET /agendas/1/edit
  def edit
    @agenda = Agenda.find(params[:id])
  end

  # POST /agendas
  # POST /agendas.xml
  def create
    @agenda = Agenda.new(params[:agenda])

    respond_to do |format|
      if @agenda.save
        flash[:notice] = 'Agenda was successfully created.'
        format.html { redirect_to(@agenda) }
        format.xml  { render :xml => @agenda, :status => :created, :location => @agenda }
      else
        format.html { render :action => "new" }
        format.xml  { render :xml => @agenda.errors, :status => :unprocessable_entity }
      end
    end
  end

  # PUT /agendas/1
  # PUT /agendas/1.xml
  def update
    @agenda = Agenda.find(params[:id])

    respond_to do |format|
      if @agenda.update_attributes(params[:agenda])
        flash[:notice] = 'Agenda was successfully updated.'
        format.html { redirect_to(@agenda) }
        format.xml  { head :ok }
      else
        format.html { render :action => "edit" }
        format.xml  { render :xml => @agenda.errors, :status => :unprocessable_entity }
      end
    end
  end

  # DELETE /agendas/1
  # DELETE /agendas/1.xml
  def destroy
    @agenda = Agenda.find(params[:id])
    @agenda.destroy

    respond_to do |format|
      format.html { redirect_to(agendas_url) }
      format.xml  { head :ok }
    end
  end
=end
end
