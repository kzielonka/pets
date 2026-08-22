# frozen_string_literal: true

class MapAnnouncementsController < ApplicationController
  def index
    bb = BoundingBoxParams.new(params)
    pins = announcements_map.search(bb.top, bb.right, bb.bottom, bb.left).map { |p| PinJson.new(p).json }
    render status: 200, json: { pins: pins }
  rescue BoundingBoxParams::ValidationError
    render status: 400, json: { error: 'bounding-box-validation-error' }
  end

  private

  def announcements_map
    Rails.application.config.announcements_map
  end

  class PinJson
    def initialize(pin)
      @pin = pin
    end

    def json
      if @pin.type == :single_pin
        {
          type: 'single_pin',
          announcement_id: @pin.announcement_id,
          location: {
            latitude: @pin.latitude.to_f,
            longitude: @pin.longitude.to_f
          }
        }
      else
        {
          type: 'group_pin',
          number_of_pins: @pin.number_of_pins,
          location: {
            latitude: @pin.latitude.to_f,
            longitude: @pin.longitude.to_f
          }
        }
      end
    end
  end
  private_constant :PinJson

  class BoundingBoxParams
    ValidationError = Class.new(StandardError)

    def initialize(params)
      @params = params
    end

    def top
      parse_coord(:top)
    end

    def right
      parse_coord(:right)
    end

    def bottom
      parse_coord(:bottom)
    end

    def left
      parse_coord(:left)
    end

    private

    def parse_coord(key)
      val = @params[key]
      raise ValidationError, "missing #{key}" if val.nil?
      raise ValidationError, "invalid #{key}" unless number?(val.to_s)

      val.to_f
    end

    def number?(number)
      /^-?\d+(\.\d+)?$/.match(number)
    end
  end
  private_constant :BoundingBoxParams
end
