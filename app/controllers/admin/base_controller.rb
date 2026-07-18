# Admin is the Devise model class; controllers nest under it as an explicit
# Zeitwerk namespace, hence the compact class style.
class Admin::BaseController < ApplicationController
  layout "admin"

  before_action :authenticate_admin!
end
