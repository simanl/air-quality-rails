class Admin::JobProcessorController < AdminController
  def show
  end

  def enqueue
    job_class = enqueue_params[:class].safe_constantize

    respond_to do |format|
      if job_class && job_class.perform_later
        format.html { redirect_to admin_job_processor_path, notice: 'The job was successfully enqueued.' }
        format.json { head :accepted }
      else
        format.html { redirect_to admin_job_processor_path, notice: 'Something went wrong when enqueueing the job.' }
        format.json { head :unprocessable_entity }
      end
    end
  end

  private

    def enqueue_params
      params.require(:job).permit(:class)
    end
end
