module SData
  class Collection
    class Entry < Struct.new(:resource, :context, :options)
      attr_accessor :diagnosis
      attr_accessor :atom_entry

      def initialize(*args)
        super(*args)

        self.diagnosis = false
        self.options = {
          :atom_show_categories => true,
          :atom_show_links => true,
          :atom_show_authors => true
        }.merge(options || {})

        begin
          self.atom_entry = compose_atom_entry(resource)
        rescue Exception => exception
          self.diagnosis = true
          self.atom_entry = compose_diagnosis(exception)
        end
      end

      alias_method :diagnosis?, :diagnosis

      protected

      def show_categories?
        options[:show_catories]
      end

      def show_links?
        options[:show_links]
      end

      def show_authors?
        options[:show_authors]
      end

      def compose_diagnosis(exception)
        ApplicationDiagnosis.new(:exception => exception).to_xml(:feed)
      end

      def compose_atom_entry(resource)
        Atom::Entry.new do |entry|
          entry.id = resource.instance_url(context)
          entry.title = resource.entry_title
          entry.updated = resource.class.sdata_date(resource.updated_at)
          
          entry.authors << Atom::Person.new(:name => resource.respond_to?('author') ? resource.author : resource.sdata_default_author) if show_authors?
          
          entry.links << Atom::Link.new(:rel => 'self', 
                                        :href => resource.instance_url(context),
                                        :type => 'application/atom+xml; type=entry', 
                                        :title => 'Refresh') if show_links?
          
          entry.categories << Atom::Category.new(:scheme => 'http://schemas.sage.com/sdata/categories',
                                                 :term   => resource.sdata_node_name,
                                                 :label  => resource.sdata_node_name.underscore.humanize.titleize) if show_categories?

          if context.maximum_precedence > 0
            begin
              payload = Payload.new(:included => context.included,
                                    :selected => context.selected, 
                                    :maximum_precedence => context.maximum_precedence,
                                    :sync => context.sync?,
                                    :contract => resource.sdata_contract_name,
                                    :entity => resource,
                                    :expand => context.expand?,
                                    :dataset => context.dataset)
              payload.generate!
              entry.sdata_payload = payload
            rescue Exception => e
              entry.diagnosis = Atom::Content::Diagnosis.new(ApplicationDiagnosis.new(:exception => e).to_xml(:entry))
            end
          end
          
          entry.content = resource.sdata_content
        end
      end
    end
  end
end
