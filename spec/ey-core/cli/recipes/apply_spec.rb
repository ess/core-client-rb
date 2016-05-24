require 'spec_helper'
require 'ey-core/cli'
require 'ey-core/cli/recipes/apply'

describe Ey::Core::Cli::Recipes::Apply do
  let(:argv) {[]}
  let(:apply) {described_class.new(argv)}

  describe '#run_type' do
    let(:run_type) {apply.instance_eval {run_type}}

    # By default, we want to assume that no switches are active
    before(:each) do
      allow(apply).to receive(:switch_active?).and_return(nil)
    end

    it 'is a string' do
      expect(run_type).to be_a(String)
    end

    context 'when the main switch is active' do
      before(:each) do
        [:main, :custom, :quick, :full].each do |switch|
          allow(apply).to receive(:switch_active?).with(switch).and_return(true)
        end
      end

      it 'is main' do
        expect(run_type).to eql('main')
      end
    end

    context 'when the main switch is not active' do
      context 'but the custom switch is active' do
        before(:each) do
          [:custom, :quick, :full].each do |switch|
            allow(apply).to receive(:switch_active?).with(switch).and_return(true)
          end
        end

        it 'is custom' do
          expect(run_type).to eql('custom')
        end
      end

      context 'and the custom switch is not active' do
        context 'but the quick switch is active' do
          before(:each) do
            [:quick, :full].each do |switch|
              allow(apply).to receive(:switch_active?).with(switch).and_return(true)
            end
          end

          it 'is quick' do
            expect(run_type).to eql('quick')
          end
        end

        context 'and the quick switch is not active' do
          context 'but the full switch is active' do
            before(:each) do
              [:full].each do |switch|
                allow(apply).to receive(:switch_active?).with(switch).and_return(true)
              end
            end

            it 'is main' do
              expect(run_type).to eql('main')
            end
          end
        end
      end
    end

    context 'when no run type switches are active' do
      it 'is main' do
        expect(run_type).to eql('main')
      end
    end
  end
end
