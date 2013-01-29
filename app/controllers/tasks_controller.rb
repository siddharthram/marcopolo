
class TasksController < ApplicationController
  include HTTParty
  format :json
  base_uri 'http://default-environment-jrcyxn2kkh.elasticbeanstalk.com'
  # GET /tasks
  # GET /tasks.json
  def index
    #@tasks = Task.all
    # insert call here to server
    #@tasks = [ 
     # ["1", "http://rafalab.jhsph.edu/simplystats/dongle-capitalism.jpg", "open"],
     # ["2", "http://williamkaminsky.files.wordpress.com/2006/06/whiteboard2.jpg", "open"]
    #]
    response = HTTParty.get('http://default-environment-jrcyxn2kkh.elasticbeanstalk.com/task/open
')
    #@tasks = Array.new
    #i = 0
    response.parsed_response.each do |k, v|
      v.each do |a|
        puts "" + a.to_s
        


        if !Task.exists?(:xim_id  => a["serverUniqueRequestId"])
          t = Task.new
          t.xim_id = a["serverUniqueRequestId"]
         t.imageurl = a["imageUrl"]
          puts "SAVING T.... " + t.to_s
          t.save
        end
        #t= Array.new
        #t= [
        ##    a["serverUniqueRequestId"], 
        #    a["imageUrl"],
        #    0
        #  ]
        #  @tasks << t
        #i=i+1
      end
    end
    @tasks = Task.all
    respond_to do |format|
      format.html # index.html.erb
      format.json { render json: @tasks }
    end
  end

  # GET /tasks/1
  # GET /tasks/1.json
  def show
    @task = Task.find(params[:id])

    respond_to do |format|
      format.html # show.html.erb
      format.json { render json: @task }
    end
  end

  # GET /tasks/new
  # GET /tasks/new.json
  def new
    @task = Task.new

    respond_to do |format|
      format.html # new.html.erb
      format.json { render json: @task }
    end
  end

  # GET /tasks/1/edit
  def edit
    #@task = Task.find(params[:id])
    puts "**********Task id is" + params[:id]
    @task = Task.find_by_xim_id(params[:id])
    #@task.xim_id = params[:id].to_i
    # FIXME - hard coded image for now

  end

  # POST /tasks
  # POST /tasks.json
  def create
    puts "CREATING..."
    @task = Task.new(params[:task])

    respond_to do |format|
      if @task.save
        format.html { redirect_to @task, notice: 'Task was successfully created.' }
        format.json { render json: @task, status: :created, location: @task }
      else
        format.html { render action: "new" }
        format.json { render json: @task.errors, status: :unprocessable_entity }
      end
    end
  end

  # PUT /tasks/1
  # PUT /tasks/1.json
  def update

    puts "UPDATING...."
    @task = Task.find(params[:id])
    output = @task.output

    options = {
      :body => {
        :serverUniqueRequestId => @task.xim_id,
        :output => output
      }
    }

    r = HTTParty.post('http://default-environment-jrcyxn2kkh.elasticbeanstalk.com/task/submit', options)
    puts "response ======" + r.to_s





    #puts "OUTPUT...." + output
    respond_to do |format|
      if @task.update_attributes(params[:task])
        format.html { redirect_to @task, notice: 'Task was successfully updated.' }
        format.json { head :no_content }
      else
        format.html { render action: "edit" }
        format.json { render json: @task.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /tasks/1
  # DELETE /tasks/1.json
  def destroy
    @task = Task.find(params[:id])
    @task.destroy

    respond_to do |format|
      format.html { redirect_to tasks_url }
      format.json { head :no_content }
    end
  end
end