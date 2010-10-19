require File.join(File.dirname(__FILE__), '..', 'spec_helper')

describe SData::Diagnosis do
  context "when exception is raised at the action method level" do
    before do
      @exception = raised_exception(RuntimeError, "Something went wrong")
      @diagnosis = SData::ApplicationDiagnosis.new(:exception => @exception)
    end

    it "should produce correct XML output" do
      xml = parse_xml(@diagnosis.to_xml.to_s)
      xml.xpath('/sdata:diagnoses/sdata:diagnosis').count.should == 1
      diagnosis_xml = xml.xpath('/sdata:diagnoses/sdata:diagnosis').first
      diagnosis_xml.xpath('./node()').map(&:name_with_ns).to_set.should == ["sdata:message", "sdata:sdataCode", "sdata:severity", "sdata:stackTrace"].to_set
      diagnosis_xml.xpath("sdata:message/text()").to_s.should == "Something went wrong"
      diagnosis_xml.xpath("sdata:sdataCode/text()").to_s.should == "ApplicationDiagnosis"
      diagnosis_xml.xpath("sdata:severity/text()").to_s.should == "error"
    end
  end
end
