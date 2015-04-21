require 'sinatra'
require_relative './lib/credit_card.rb'
require_relative 'model/operation'

# Credit Card Web Service
class CreditCardAPI < Sinatra::Base

  get '/' do
    'The CreditCardAPI is up and running!'
  end

  get '/api/v1/credit_card/validate' do
    c = CreditCard.new(params[:card_number],nil,nil,nil)

    # Method to convert string to integer
    # Returns false if string is not only digits
    result = Integer(params[:card_number]) rescue false

    # Validate for string length and correct type
    if result == false || params[:card_number].length < 2
      return {"Card" => params[:card_number], "validated" => "false"}.to_json
    end

    {"Card" => params[:card_number], "validated" => c.validate_checksum}.to_json
  end

  post '/api/v1/credit_card' do
    request_json = request.body.read
    req = JSON.parse(request_json)
    creditCard = CreditCard.new(req['number'], req['expiration_date'], req['owner'], req['credit_network'])

    begin
      unless creditCard.validate_checksum
        halt 400
      else
        op = Operation.new(operation: 'credit_card', parameters: request_json)
        puts op.save
        status 201
      end
    rescue
      halt 410
    end
  end
end
