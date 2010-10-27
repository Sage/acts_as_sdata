require File.join(File.dirname(__FILE__), '..', 'spec_helper')

describe SData::Diagnosis do
  context "when exception is raised at the action method level" do    
    before do
      exception = raised_exception(RuntimeError, "Something went wrong")
      standalone_diagnosis = SData::ApplicationDiagnosis.new(:exception => exception)
      @diagnosis_xml = parse_xml(standalone_diagnosis.to_xml.to_s)
    end

    describe "XML output of a diagnosis" do
      subject { @diagnosis_xml }

      it "should have diagnoses container as a root node" do
        subject.xpath('/sdata:diagnoses').should_not be_empty
      end

      it "should contain sdata:diagnosis node" do
        subject.xpath('/sdata:diagnoses/sdata:diagnosis').should_not be_empty
      end

      describe "sdata:diagnosis node" do
        subject { @diagnosis_xml.xpath('/sdata:diagnoses/sdata:diagnosis')  }

        it "should fill sdata:message with exception message" do
          subject.xpath('sdata:message/text()').to_s.should == "Something went wrong"
        end

        it "should fill sdat:sdataCode with a exception class" do
          subject.xpath('sdata:sdataCode/text()').to_s.should == "ApplicationDiagnosis"
        end

        it "should fill sdata:stackTrace with exception stacktrace" do
          subject.xpath('sdata:stackTrace/text()').to_s.should include('standalone_diagnosis_spec.rb')
        end

        it "should set 'error' severity" do
          subject.xpath("sdata:severity/text()").to_s.should == "error"
        end
      end
    end
  end
end
