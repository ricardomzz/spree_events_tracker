require 'spec_helper'

RSpec.describe Spree::ArchiveDataService, type: :service do

  let(:service) { Spree::ArchiveDataService.new }

  describe '#initialize' do
    it 'is expected to initialize @events to an array' do
      expect(service.instance_variable_get(:@events)).to eq([Spree::CartEvent, Spree::CheckoutEvent, Spree::PageEvent])
    end
  end

  describe '#perform' do
    before do
      service.instance_variable_set(:@events, [Spree::PageEvent])
    end

    it 'is expected to call archive data on Spree::PageEvent' do
      expect(service).to receive(:archive_data).with(Spree::PageEvent, Spree::ArchivedPageEvent)
    end

    after { service.perform }
  end

  describe '#get_archived_event' do
    it 'is expected to return archived event constant' do
      expect(service.get_archived_event(Spree::PageEvent)).to eq(Spree::ArchivedPageEvent)
    end
  end

  describe '#archive_data' do
    let!(:record) { Spree::PageEvent.create(activity: 'view', session_id: 'session_id', created_at: 1.year.ago) }
    let!(:archived_record) { Spree::ArchivedPageEvent.new(record.attributes) }

    before do
      allow(service).to receive(:event).and_return(Spree::PageEvent)
      allow(service).to receive(:archived_event).and_return(Spree::ArchivedPageEvent)
      allow(Spree::ArchivedPageEvent).to receive(:new).and_return(archived_record)
    end

    it 'is expected to call save on archived_record' do
      expect(archived_record).to receive(:save)
    end

    context 'when record is archived' do
      before do
        allow(archived_record).to receive(:save).and_return(true)
      end

      it 'is expected to delete record' do
        expect_any_instance_of(Spree::PageEvent).to receive(:delete)
      end
    end

    context 'when record is not archived' do
      before do
        allow(archived_record).to receive(:save).and_return(false)
      end

      it 'is not expected to delete record' do
        expect_any_instance_of(Spree::PageEvent).not_to receive(:delete)
      end
    end

    after { service.archive_data(Spree::PageEvent, Spree::ArchivedPageEvent) }

  end

end
