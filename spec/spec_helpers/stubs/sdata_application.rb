module SData
  class TestApplication
    include SData::Application::Actions
    include SData::Application::ResourceFromParams
    include SData::Application::OldDslSupport
  end
end
