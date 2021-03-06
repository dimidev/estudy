class AdminsController < ApplicationController
  load_and_authorize_resource :department
  load_and_authorize_resource :admin, through: :department, shallow: true

  def index
    @department = Department.find(params[:department_id])
    add_breadcrumb @department.title, department_admins_path(@department) if current_user.role?(:superadmin)
    add_breadcrumb I18n.t('mongoid.models.admin.other'), department_admins_path(@department)

    respond_to do |format|
      format.html
      format.json do
        render(json: @department.admins.datatable(self, %w(name lastname email)) do |admin|
                 [
                     %{<%= link_to admin.name, admin_path(admin) %>},
                     %{<%= link_to admin.lastname, admin_path(admin) %>},
                     admin.email,
                     %{<% if can? [:update, :destroy], Admin %>
                        <li class="btn-group">
                          <%= link_to fa_icon('cog'), '#', class:'btn btn-sm btn-default dropdown-toggle', data:{toggle:'dropdown'} %>
                          <ul class="dropdown-menu dropdown-center">
                            <li><%= link_to fa_icon('pencil-square-o', text: I18n.t('datatable.edit')), edit_admin_path(admin) %></li>
                            <li><%= link_to fa_icon('trash-o', text: I18n.t('datatable.delete')), admin_path(admin), method: :delete, remote: true, data:{confirm: I18n.t('confirmation.delete')} %></li>
                          </ul>
                        </li>
                      <% end %>}
                 ]
               end)
      end
    end
  end

  def new
    add_breadcrumb I18n.t('mongoid.models.admin.other'), department_admins_path(params[:department_id])
    add_breadcrumb I18n.t('admins.new.title')

    @department = Department.find(params[:department_id])
    @admin = @department.admins.build
    render :edit
  end

  def create
    add_breadcrumb I18n.t('mongoid.models.admin.other'), department_admins_path(params[:department_id])
    add_breadcrumb I18n.t('admins.new.title')
    @department = Department.find(params[:department_id])
    @admin = @department.admins.build(admin_params)

    if @admin.save
      flash[:notice] = t('mongoid.success.users.create', model: Admin.model_name.human, name: @admin.fullname)
      redirect_to department_admins_path(params[:department_id])
    else
      render :edit
    end
  end

  def show
    @admin = Admin.find(params[:id])
    add_breadcrumb I18n.t('mongoid.models.admin.other'), department_admins_path(@admin.department)
    add_breadcrumb I18n.t('admins.show.title')

    @addresses = @admin.addresses
    @phones = @admin.contacts.phones.map(&:value).join(', ')
    @fax = @admin.contacts.fax.map(&:value).join(', ')
    @emails = [@admin.email, @admin.contacts.emails.map(&:value)].flatten.join(', ')
  end

  def edit
    @admin = Admin.find(params[:id])

    add_breadcrumb I18n.t('mongoid.models.admin.other'), department_admins_path(@admin.department)
    add_breadcrumb I18n.t('admins.edit.title')
  end

  def update
    @admin = Admin.find(params[:id])

    add_breadcrumb I18n.t('mongoid.models.admin.other'), department_admins_path(@admin.department)
    add_breadcrumb I18n.t('admins.edit.title')

    if update_resource(@admin, admin_params)
      flash[:notice] = I18n.t('mongoid.success.users.update', model: Admin.model_name.human, name: @admin.fullname)
      redirect_to department_admins_path(@admin.department)
    else
      render :edit
    end
  end

  def destroy
    @admin = Admin.find(params[:id])

    respond_to do |format|
      if @admin.destroy
        message = I18n.t('mongoid.success.users.destroy', model: Admin.model_name.human, name: @admin.fullname)
        format.html { redirect_to department_admins_path(@admin.department), notice: message }
        format.js { flash.now[:notice] = message }
      else
        message = I18n.t('mongoid.errors.users.destroy', model: Admin.model_name.human, name: @admin.fullname)
        format.html { render :edit, alert: message }
        format.js { flash.now[:alert] = message }
      end
    end
  end

  private
  def admin_params
    params.require(:admin).permit(:user_avatar, :delete_img, :email, :password, :password_confirmation,
                                  :name, :lastname, :gender, :birthdate, :nic, :trn, :ssn, :tax_office,
                                  addresses_attributes: [:id, :_destroy, :country, :city, :postal_code, :address, :primary],
                                  contacts_attributes:[:id, :_destroy, :type, :value])
  end

  def update_resource(resource, params)
    if params[:password].present?
      resource.update_attributes(params)
    else
      resource.update_without_password(params)
    end
  end
end
