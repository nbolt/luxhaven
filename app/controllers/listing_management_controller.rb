class ListingManagementController < ApplicationController
  skip_before_filter :verify_authenticity_token
  
  expose(:paragraph) { Paragraph.find params[:id] }
  expose(:listing) { Listing.find params[:id] }
  expose(:image) { Image.find params[:id] }
  expose(:room) { Room.find params[:id] }

  def update_paragraph
    paragraph.content = params[:content]
    paragraph.order = params[:order]
    paragraph.save
    render nothing: true
  end

  def update_alignment
    paragraph.image.update_attribute :align, params[:alignment]
    render nothing: true
  end

  def update_version
    paragraph.image.update_attribute :version, params[:version]
    render nothing: true
  end

  def remove_paragraph
    paragraph.destroy
    render nothing: true
  end

  def remove_paragraph_image
    paragraph.image.destroy
    render nothing: true
  end

  def remove_header_image
    listing.update_attribute :remove_header_image, true
    render nothing: true
  end

  def remove_search_image
    listing.update_attribute :remove_search_image, true
    render nothing: true
  end

  def remove_image
    image.destroy
    render nothing: true
  end

  def new_image
    listing.images.push Image.create(image: params[:image])
    render nothing: true
  end

  def new_paragraph_image
    paragraph.image = ParagraphImage.create(image: params[:image])
    render nothing: true
  end

  def new_header_image
    listing.update_attribute :header_image, params[:image]
    render nothing: true
  end

  def new_search_image
    listing.update_attribute :search_image, params[:image]
    render nothing: true
  end

  def new_paragraph
    paragraph = listing.paragraphs.create
    while !paragraph.save
      paragraph.order += 1
    end
    render json: paragraph.to_json(include: :image)
  end

  def new_room
    listing.rooms.create(name: params[:name])
    render nothing: true
  end

  def update_features
    listing.features = params[:features].map {|name| Feature.where(name: name).first}
    render nothing: true
  end

  def update_room
    images = params[:images].split(' ').map {|n| room.listing.images.sort_by(&:created_at)[n.to_i-1]}
    features = params[:features].map {|name| Feature.where(name: name).first}

    room.images.each { |image| image.update_attribute :room_id, nil if images.select {|i| i.id == image.id}.empty? }
    images.each do |image|
      image.update_attribute :room_id, room.id if room.images.select {|i| i.id == image.id}.empty?
    end

    room.features = features

    render nothing: true
  end

end
