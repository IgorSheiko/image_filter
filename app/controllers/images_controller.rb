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
      thumb = Magick::Image.read(image.main_image.path).first
      thumb.format = "PNG"
      thumb.write("png.png")
      avatar = ChunkyPNG::Image.from_file("png.png")
      roberts(avatar)
      avatar = ChunkyPNG::Image.from_file("png.png")
      negative(avatar)
      image.processing_image = Rails.root.join("n.png").open
      image.filter_image = Rails.root.join("rob.png").open
      image.brightness = brightness_calculate(avatar)
      image.save!
    end

    def brightness_calculate(avatar)
      array_brightness = []
       (avatar.width - 1).times do |i|
        (avatar.height - 1).times do |j|
          brightness = 0.3*get_color(avatar[i,j], 0xff000000, 24) + 
          0.59*get_color(avatar[i,j], 0x00ff0000, 16) + 
          0.11*get_color(avatar[i,j], 0x0000ff00, 8)
          array_brightness[brightness.to_i] = 0 unless array_brightness[brightness.to_i] 
          array_brightness[brightness.to_i] += 1
        end
      end
      array_brightness.each_with_index.map{|q,i| [i,q]}
    end

    def roberts(avatar)
      new_image = avatar
      (avatar.width - 1).times do |i|
        (avatar.height - 1).times do |j|
          tmp1 = mask(avatar[i,j],avatar[i+1,j+1])
          tmp2 = mask(avatar[i+1,j],avatar[i,j+1])
          new_image[i, j] = new_pixel(tmp1, tmp2)
        end
      end
      new_image.save('rob.png')
    end

    def mask(pixel1, pixel2)
      [(get_color(pixel1, 0xff000000, 24) - get_color(pixel2, 0xff000000, 24)), 
      (get_color(pixel1, 0x00ff0000, 16) - get_color(pixel2, 0x00ff0000, 16)), 
      (get_color(pixel1, 0x0000ff00, 8) - get_color(pixel2, 0x0000ff00, 8))] 
    end

    def new_pixel(pixel1, pixel2)
      array_color = []
      3.times do |i|
        array_color[i] = correct_color(Math.sqrt(pixel1[i] ** 2 + pixel2[i] ** 2).to_i) 
      end
      array_color[0] << 24 | array_color[1] << 16 | array_color[2] << 8 | 0xff
    end

    def new_color(pixel1, pixel2, code, shift)
      (correct_color(Math.sqrt(get_color(pixel1, code, shift) ** 2 + get_color(pixel2, code, shift) ** 2).to_i)) << shift
    end

    def correct_color(color)
      color > 255 ? 255 : color
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
      (255 - get_color(code, mask, shift)) << shift 
    end

    def get_color(code, mask, shift)
      (code & mask) >> shift
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
