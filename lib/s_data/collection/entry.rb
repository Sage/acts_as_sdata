module SData
  module Collection
    class Entries < Struct.new(:scope, :params, :query_params, :options)
      attr_accessor :entries, :diagnoses, :count

      def initialize(*args)
        super(*args)

        self.entries = []
        self.diagnoses = []
        self.count = scope.count
        self.options = {
          :atom_show_categories => true,
          :atom_show_links => true,
          :atom_show_authors => true
        }.merge(options)

        scope.resources.each do |resource|
          begin
            self.entries << compose_atom_entry(resource)
          rescue Exception => exception
            self.diagnoses << compose_diagnosis(exception)
          end
        end
      end

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

      def sync?
        params[:sync].to_s == 'true'
      end

      def dataset
        params[:dataset]
      end

      def selected
        params[:select].to_s.split(',')
      end

      def included
        params[:include].to_s.split(',')
      end

      def maximum_precedence
        params[:precedence].blank? ? params[:precedence].to_i : 100
      end

      def expand?
        (sync || included.include?('$children')) ? :all_children : :immediate_children
      end

      def base_url
        self.sdata_resource_url(dataset)
      end

      def current_url
        base_url + "?#{query_params.to_param}"
      end

      def compose_diagnosis(exception)
        ApplicationDiagnosis.new(:exception => exception).to_xml(:feed)
      end

      def compose_atom_entry(resource)
        Atom::Entry.new.tap do |entry|
          entry.id = base_url
          entry.title = resource.entry_title
          entry.updated = resource.class.sdata_date(resource.updated_at)
          
          entry.authors << Atom::Person.new(:name => resource.respond_to?('author') ? resource.author : resource.sdata_default_author) if show_authors?
          
          entry.links << Atom::Link.new(:rel => 'self', 
                                        :href => current_url,
                                        :type => 'application/atom+xml; type=entry', 
                                        :title => 'Refresh') if show_links?
          
          entry.categories << Atom::Category.new(:scheme => 'http://schemas.sage.com/sdata/categories',
                                                 :term   => resource.sdata_node_name,
                                                 :label  => resource.sdata_node_name.underscore.humanize.titleize) if show_categories?
          
          if maximum_precedence > 0
            begin
              payload = Payload.new(:included => included?, 
                                    :selected => selected?, 
                                    :maximum_precedence => maximum_precedence,
                                    :sync => sync?,
                                    :contract => resource.sdata_contract_name,
                                    :entity => resource,
                                    :expand => expand?,
                                    :dataset => dataset)
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
