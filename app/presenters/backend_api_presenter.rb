class BackendApiPresenter
  def name
    'backend_00'
  end

  def to_param
    name
  end

  def private_url
    'http://www.example.com'
  end
end