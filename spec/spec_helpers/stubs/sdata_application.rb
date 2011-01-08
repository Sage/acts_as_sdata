module SData
  class TestApplication
    include SData::Application::Actions
    include SData::Application::ResourceFromParams
  end
end
