class CoursesController < ApplicationController
  def index
    add_breadcrumb I18n.t('courses.index.title')

    respond_to do |format|
      format.html
      format.json do
        render(json: StudiesProgramme.find(params[:studies_programme_id]).courses.order_by(semester: :asc).datatable(self, %w(title semester ects hours)) do |course|
                 [
                     course.semester,
                     course.title,
                     I18n.t("enumerize.course.course_type.#{course.course_type}"),
                     course.ects,
                     course.hours,
                     %{<div class="btn-group">
                        <%= link_to fa_icon('cog'), '#', class:'btn btn-sm btn-default dropdown-toggle', data:{toggle:'dropdown'} %>
                        <ul class="dropdown-menu dropdown-center">
                          <li><%= link_to fa_icon('pencil-square-o', text: I18n.t('datatable.edit')), edit_course_path(course), remote: true %></li>
                          <li><%= link_to fa_icon('trash-o', text: I18n.t('datatable.delete')), course_path(course), method: :delete, remote: true, data:{confirm: 'Are you sure ?'} %></li>
                        </ul>
                      </div>}
                 ]
               end)
      end
    end
  end

  def new
    @studies_programme = StudiesProgramme.find(params[:studies_programme_id])
    @course = @studies_programme.courses.build

    respond_to do |format|
      format.js { render 'courses/js/new' }
    end
  end

  def create
    @studies_programme = StudiesProgramme.find(params[:studies_programme_id])
    @course = @studies_programme.courses.build(course_params)

    respond_to do |format|
      if @course.save
        message = I18n.t('mongoid.success.models.course.create', title: @course.title)
        flash.now[:notice] = message
        format.js { render 'courses/js/save' }
      else
        message = I18n.t('mongoid.errors.models.course.create', title: @course.title)
        flash.now[:alert] = message
        format.js { render 'courses/js/save' }
      end
    end
  end

  def edit
    @course = Course.find(params[:id])

    respond_to do |format|
      format.js{render 'courses/js/edit'}
    end
  end

  def update
    @course = Course.find(params[:id])

    respond_to do |format|
      if @course.update_attributes(course_params)
        message = I18n.t('mongoid.success.models.course.update', title: @course.title)
        flash.now[:notice] = message
        format.js { render 'courses/js/save' }
      else
        message = I18n.t('mongoid.errors.models.course.update', title: @course.title)
        flash.now[:alert] = message
        format.js { render 'courses/js/save' }
      end
    end
  end

  def destroy
    @course = Course.find(params[:id])

    respond_to do |format|
      if @course.destroy
        message = I18n.t('mongoid.success.models.course.destroy', title: @course.title)
        flash.now[:notice] = message
        format.js { render 'courses/js/destroy' }
      else
        message = I18n.t('mongoid.errors.models.course.destroy', title: @course.title)
        flash.now[:alert] = message
        format.js { render 'courses/js/destroy' }
      end
    end
  end

  private
  def course_params
    params.require(:course).permit(:title, :description, :course_type, :semester, :ects, :hours,
                                   courses_attributes:[:id, :_destroy, :title, :course_part, :percent, :hours])
  end
end