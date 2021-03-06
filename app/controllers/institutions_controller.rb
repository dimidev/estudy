class InstitutionsController < ApplicationController
  load_and_authorize_resource except: [:new, :create]

  skip_before_action :authenticate_user!, only: [:new, :create], unless: lambda { Institution.exists? }
  before_action :redirect_if_exists, only: [:new, :create]

  layout 'devise', only: [:new, :create]

  def new
    @institution = Institution.new
    @superadmin = @institution.build_superadmin
  end

  def create
    @institution = Institution.new(institution_params)

    if @institution.save
      sign_in @institution.superadmin, bypass: true
      redirect_to root_path
    else
      render :new
    end
  end

  def show
    add_breadcrumb Institution.model_name.human, institution_path
    add_breadcrumb I18n.t('institutions.show.title')
    @institution = Institution.first

    @phones = @institution.contacts.where(type: 'phone').map(&:value).join(', ')
    @fax = @institution.contacts.where(type: 'fax').map(&:value).join(', ')
    @emails = @institution.contacts.where(type: 'email').map(&:value).join(', ')
  end

  def edit
    add_breadcrumb Institution.model_name.human, :institution_path
    add_breadcrumb I18n.t('institutions.edit.title')
    @institution = Institution.first
  end

  def update
    add_breadcrumb Institution.model_name.human, :institution_path
    add_breadcrumb I18n.t('institutions.edit.title')
    @institution = Institution.first

    if @institution.update_attributes(institution_params)
      redirect_to institution_path, notice: I18n.t('mongoid.success.institutions.update')
    else
      render :edit
    end
  end

  private
  def institution_params
    params.require(:institution).permit(:institution_logo, :delete_img, :title, :foundation_date, :rector,
                                        address_attributes: [:country, :city, :postal_code, :address],
                                        contacts_attributes:[:id, :_destroy, :type, :value],
                                        superadmin_attributes: [:email, :password, :password_confirmation])
  end

  def redirect_if_exists
    redirect_to root_path if Institution.exists?
  end
end
