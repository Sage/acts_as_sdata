module SData
  module Application
    module Traits
      AtomEntryRecognition = Trait.new do
        before do
          if request.env["Content-Type"] == "application/atom+xml"
            params[:entry] = Atom::Entry.load_entry(request.env['rack.request.form_vars'])
          end
        end
      end
    end
  end
end
