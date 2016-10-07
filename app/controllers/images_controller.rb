class ImagesController < ApplicationController
  before_action :set_image, only: [:show, :edit, :update, :destroy]

  # GET /images
  # GET /images.json
  def index
    @images = Image.all
  end

  # GET /images/1
  # GET /images/1.json
  def show
  end

  # GET /images/new
  def new
    @image = Image.new
  end

  # GET /images/1/edit
  def edit
  end

  # POST /images
  # POST /images.json
  def create
    @image = Image.new(image_params)

    respond_to do |format|
      if @image.save
        format.html { redirect_to @image, notice: 'Image was successfully created.' }
        format.json { render :show, status: :created, location: @image }
        processing_image(@image)
      else
        format.html { render :new }
        format.json { render json: @image.errors, status: :unprocessable_entity }
      end
    end
  end

  # PATCH/PUT /images/1
  # PATCH/PUT /images/1.json
  def update
    respond_to do |format|
      if @image.update(image_params)
        format.html { redirect_to @image, notice: 'Image was successfully updated.' }
        format.json { render :show, status: :ok, location: @image }
      else
        format.html { render :edit }
        format.json { render json: @image.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /images/1
  # DELETE /images/1.json
  def destroy
    @image.destroy
    respond_to do |format|
      format.html { redirect_to images_url, notice: 'Image was successfully destroyed.' }
      format.json { head :no_content }
    end
  end

  private
    def processing_image(image)
      avatar = ChunkyPNG::Image.from_file(image.main_image.path)
      roberts(avatar)
      avatar = ChunkyPNG::Image.from_file(image.main_image.path)
      negative(avatar)
      image.processing_image = Rails.root.join("n.png").open
      image.filter_image = Rails.root.join("rob.png").open
      image.save!
    end

    def roberts(avatar)
      new_image = avatar
      (avatar.width - 1).times do |i|
        (avatar.height - 1).times do |j|
          tmp1 = avatar[i,j] - avatar[i+1,j+1] + 0xff
          tmp2 = avatar[i+1,j] - avatar[i,j+1] + 0xff
          new_image[i, j] = Math.sqrt(tmp1 ** 2 + tmp2 ** 2).to_i
        end
      end
      new_image.save('rob.png')
    end

    def negative(avatar)
      avatar.width.times do |i|
        avatar.height.times do |j|
          avatar[i,j] = negative_pixel(avatar[i,j])
        end
      end
      avatar.save('n.png')
    end

    def negative_pixel(code)
      color_to_negative(code, 0xff000000, 24) | color_to_negative(code, 0x00ff0000, 16) | color_to_negative(code, 0x0000ff00, 8) | 0xff
    end

    def color_to_negative(code, mask, shift)
      (255 - ((code & mask) >> shift)) << shift 
    end
    # Use callbacks to share common setup or constraints between actions.
    def set_image
      @image = Image.find(params[:id])
    end

    # Never trust parameters from the scary internet, only allow the white list through.
    def image_params
      params.require(:image).permit(:main_image, :processing_image, :filter_image)
    end
end
