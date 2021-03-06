class CoursesController < ApplicationController
  def index
    add_breadcrumb I18n.t('courses.index.title')

    respond_to do |format|
      format.html
      format.json do
        render(json: StudiesProgram.find(params[:studies_program_id]).courses.datatable(self, %w(semester title course_type ects hours)) do |course|
                 [
                     course.semester,
                     %{<%= link_to course.title, course_path(course), remote: true %>},
                     course.course_type_text,
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

  # FIXME chain_courses, the last course has only id and not exists as course
  def new
    @studies_program = StudiesProgram.find(params[:studies_program_id])
    @chain_courses = @studies_program.courses
    @course = @studies_program.courses.build

    respond_to do |format|
      format.js { render 'courses/js/edit' }
    end
  end

  # FIXME chain_courses, the last course has only id and not exists as course
  def create
    @studies_program = StudiesProgram.find(params[:studies_program_id])
    @course = @studies_program.courses.build(course_params)

    respond_to do |format|
      if @course.save
        flash.now[:notice] = I18n.t('mongoid.success.courses.create', title: @course.title)
        format.js { render 'courses/js/save' }
      else
        @chain_courses = @studies_program.courses
        format.js { render 'courses/js/save' }
      end
    end
  end

  def edit
    @course = Course.find(params[:id])
    @chain_courses = @course.studies_program.courses.ne(id: @course)

    respond_to do |format|
      format.js{render 'courses/js/edit'}
    end
  end

  def show
    @course = Course.find(params[:id])
    respond_to do |format|
      format.js{render 'courses/js/show'}
    end
  end

  def update
    @course = Course.find(params[:id])

    respond_to do |format|
      if @course.update_attributes(course_params)
        flash.now[:notice] = I18n.t('mongoid.success.courses.update', title: @course.title)
        format.js { render 'courses/js/save' }
      else
        @chain_courses = @course.studies_program.courses.ne(id: @course)
        format.js { render 'courses/js/save' }
      end
    end
  end

  def destroy
    @course = Course.find(params[:id])

    respond_to do |format|
      if @course.destroy
        flash.now[:notice] = I18n.t('mongoid.success.courses.destroy', title: @course.title)
        format.js { render 'courses/js/destroy' }
      else
        flash.now[:alert] = I18n.t('mongoid.errors.courses.destroy', title: @course.title)
        format.js { render 'courses/js/destroy' }
      end
    end
  end

  private
  def course_params
    params.require(:course).permit(:title, :course_type, :semester, :ects, :hours, :chain_course_id,
                                   child_courses_attributes:[:id, :_destroy, :course_part, :percent, :hours, :attendances_limit])
  end
end
