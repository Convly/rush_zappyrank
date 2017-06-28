require 'net/http'
require 'json'

class AuthController < ApplicationController
  include AuthHelper

  def get_user_data(user_name, user)
    url = 'https://intra.epitech.eu/auth-ded102aa843dc494f2e69873c00fc05194d95a64/user/' + user_name +'/?format=json'
    '''
    uri = URI(url)

    res = Net::HTTP.get(uri)
    '''
    content = open(url).read
    data = JSON.parse(content)
    puts data

    city = data["location"].split("/")[1]
    promo = data["promo"]

    if city.nil?
      user.city = "Ghost"
    else
      user.city = city
    end
    if promo.nil?
      user.promo = "NC"
    else
      user.promo = promo
    end

#    user.promo = "NC"
#    user.city = "NC"
  end


  def gettoken
    token = get_token_from_code params[:code]
    session[:azure_token] = token.to_hash
    session[:user_email] = get_user_email token.token

    @user = User.find_by_email(session[:user_email])
    if @user.nil? # Never use
      @user = User.new
      @user.email = session[:user_email]
      @user.admin = 0
      @user.ranking = -1
      @user.score = 0
      get_user_data(@user.email, @user)
      @user.save
    end
    redirect_to root_path
  end

  def login
  end

  def logout
    session[:azure_token] = nil
    session[:user_email] = nil
    redirect_to auth_login_path
  end
end
