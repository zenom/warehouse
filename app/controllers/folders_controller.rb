class FoldersController < ApplicationController
  before_filter :get_folders, :only => [:index]
  before_filter :get_folder, :only => [:edit, :update, :destroy]
  def index
  end
  
  def new
    @folder = Folder.new
  end
  
  def create
    @folder = Folder.new(params[:folder])

    respond_to do |format|
      if @folder.save
        format.html { redirect_to(folders_path, :notice => 'Folder was successfully created.') }
      else
        format.html { render :action => "new" }
      end
    end
  end
  
  
  def update
    respond_to do |format|
      if @folder.update_attributes(params[:folder])
        format.html { redirect_to(folders_path, :notice => 'Folder was successfully updated.') }
      else
        format.html { render :action => "edit" }
      end
    end
  end
  
  def destroy
    @folder.destroy
  end
  
  private
    def get_folders
      @folders = Folder.all
    end
    
    def get_folder
      @folder = Folder.find(params[:id])
    end
end
