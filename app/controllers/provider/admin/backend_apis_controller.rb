# frozen_string_literal: true

class Provider::Admin::BackendApisController < FrontendController
  before_action :ensure_provider_domain

  activate_menu :dashboard
  layout 'provider'

  def index
    @backends = [BackendApiPresenter.new]
  end

  def show
    @backend = BackendApiPresenter.new
  end
end
