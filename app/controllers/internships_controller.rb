class InternshipsController < ApplicationController
  def new
  	if user_signed_in?
      @liste=Company.all.order(created_at: :asc).map {|c| [c.name, c.id]}      
  		@internship=Internship.new
  	end
  end

  def create
  	if user_signed_in?
	  	@internship=Internship.new internship_params
      @internship.user_id=current_user.id
    
      if internship_params[:comp]=="Autre"
        redirect_to "/"
      else
        @internship.comp=Company.find(internship_params[:comp]).name
        @internship.id_compagny=internship_params[:comp]
        @internship.save

        if @internship.persisted?
          flash[:alert_success] = "Fiche enregistrée"
          redirect_to "/internships/#{@internship.id}"
        end

      end
    end
  end

  def destroy
    if user_signed_in?
      @internship = Internship.find params[:id]
      @internship.destroy
        if @internship.destroyed?
          flash[:alert] = "Fiche supprimée"
          redirect_to "/"
        end
    end

    if admin_signed_in?
      @internship = Internship.find params[:id]
      @internship.destroy
        if @internship.destroyed?
          flash[:alert] = "Fiche supprimée"
          redirect_to "/"
        end
    end
  end

  def edit
    if user_signed_in?
      @internship = Internship.find params[:id]
      @liste=Company.all.order(created_at: :asc).map {|c| [c.name, c.id]}
    end
  end

  def update
    if user_signed_in?
      @internship = Internship.find(params[:id])
      
      @internship.comp=Company.find(internship_params[:comp]).name
          
      @internship.id_compagny=internship_params[:comp]

      respond_to do |f|
        if @internship.update internship_params
          @internship.update :comp => Company.find(internship_params[:comp]).name
          f.html { redirect_to(@internship,
                        :alert => 'La fiche a été mise à jour') }
          f.xml  { head :ok }
          
        else
          f.html { render :action => "edit" }
          f.xml  { render :xml => @internship.errors,
                        :status => :unprocessable_entity }
        end
        if @internship.persisted?
          flash[:alert] = "Fiche mise à jour"
        end
      end

    end
  end
  
  def show
    if user_signed_in?
      @internship = Internship.find params[:id]
      @creator=User.find(@internship.user_id)    
      if Company.exists?(@internship.id_compagny)
        @company=Company.find(@internship.id_compagny)
      else
        @liste=Company.all.order(created_at: :asc).map {|c| [c.name, c.id]}
      end
    end
  end

  def show_all
    if user_signed_in?
      @internship = Internship.all.paginate(:page => params[:page], :per_page => 5)
    end
  end

  def search
    puts params[:type]

    @company_1 = Company.where("name like ?", '%' +params[:mot]+'%').paginate(:page => params[:page], :per_page => 5)
    @internship_1 = Internship.where("comp like ?", '%' +params[:mot]+'%').paginate(:page => params[:page], :per_page => 5)

    @internship_2 = Internship.where("field like ?", '%' +params[:mot]+'%').paginate(:page => params[:page], :per_page => 5)
    @company_2 = Company.where("field like ?", '%' +params[:mot]+'%').paginate(:page => params[:page], :per_page => 5)
    
  end

  def signal
    if user_signed_in?
      @internship = Internship.find_by_id(params[:id])
      @internship.update :signaled => true
      flash[:alert]="La fiche a été signalée aux administrateurs"

      redirect_to "/"

    end
  end

  def unsignal
    if admin_signed_in?
      @internship = Internship.find_by_id(params[:id])
      @internship.update_attributes(:signaled => 'false')
      flash[:alert]="Le signalement a été enlevé"

      redirect_to "/"
    end
  end

  protected
  def internship_params
  	params.require(:internship).permit(:comp, :field, :supervisor, :commentary, :period, :schoolyear)
  end

  

end
