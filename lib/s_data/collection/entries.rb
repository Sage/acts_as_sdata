module SData
  module Collection
    class Entries < Struct.new(:scope, :params, :query_params, :options)
      attr_accessor :entries, :diagnoses, :count

      def initialize(*args)
        super(*args)

        self.entries = []
        self.diagnoses = []
        self.count = scope.count

        scope.entries.each do |entry|
          begin
            self.entries << compose_atom_entry(entry)
          rescue Exception => exception
            self.diagnoses << compose_diagnosis(exception)
          end
        end
      end

      protected

      def compose_diagnosis(exception)
        ApplicationDiagnosis.new(:exception => exception).to_xml(:feed)
      end

      def compose_atom_entry(entry)
        opts = {
          :atom_show_categories => true,
          :atom_show_links => true,
          :atom_show_authors => true
        }.merge(opts)
        maximum_precedence = (!params[:precedence].blank? ? params[:precedence].to_i : 100)
        included = params[:include].to_s.split(',')
        selected = params[:select].to_s.split(',')
        dataset = params[:dataset] #Maybe || '-' but I don't think it's a good idea to imply a default dataset at this level

        base_url = self.sdata_resource_url(dataset), 
        current_url = base_url + "?#{query_params.to_param}"
        
        sync = (params[:sync].to_s == 'true')
        expand = ((sync || included.include?('$children')) ? :all_children : :immediate_children)
        
        Atom::Entry.new.tap do |entry|
          entry.id = self.sdata_resource_url(dataset)
          entry.title = entry_title
          entry.updated = self.class.sdata_date(self.updated_at)
          entry.authors << Atom::Person.new(:name => self.respond_to?('author') ? self.author : sdata_default_author)  if opts[:atom_show_authors]
          entry.links << Atom::Link.new(:rel => 'self', 
                                        :href => current_url,
                                        :type => 'application/atom+xml; type=entry', 
                                        :title => 'Refresh') if opts[:atom_show_links] 
          entry.categories << Atom::Category.new(:scheme => 'http://schemas.sage.com/sdata/categories',
                                                 :term   => self.sdata_node_name,
                                                 :label  => self.sdata_node_name.underscore.humanize.titleize) if opts[:atom_show_categories] 
          
          yield entry if block_given?
          
          if maximum_precedence > 0
            begin
              payload = Payload.new(:included => included, 
                                    :selected => selected, 
                                    :maximum_precedence => maximum_precedence, 
                                    :sync => sync,
                                    :contract => self.sdata_contract_name,
                                    :entity => self,
                                    :expand => expand,
                                    :dataset => dataset)
              payload.generate!
              entry.sdata_payload = payload
            rescue Exception => e
              entry.diagnosis = Atom::Content::Diagnosis.new(ApplicationDiagnosis.new(:exception => e).to_xml(:entry))
            end
          end
          entry.content = sdata_content
        end
      end
    end
  end
end
