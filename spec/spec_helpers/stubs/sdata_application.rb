module SData
  class TestApplication
    include SData::ControllerMixin::Actions
    include SData::Application::ResourceFromParams
    include SData::Application::OldDslSupport
  end
end
