require 'spec_helper'
require 'ey-core/cli'
require 'ey-core/cli/recipes/apply'

describe Ey::Core::Cli::Recipes::Apply do
  let(:argv) {[]}
  let(:apply) {described_class.new(argv)}

  describe '#run_type' do
    let(:run_type) {apply.instance_eval {run_type}}

    it 'is a string' do
      expect(run_type).to be_a(String)
    end

    context 'when the main switch is active' do
      before(:each) do
        apply.switches.merge!(
          main: true, custom: true, quick: true, full: true
        )
      end

      it 'is main' do
        expect(run_type).to eql('main')
      end
    end

    context 'when the main switch is not active' do
      context 'when the custom switch is active' do
        before(:each) do
          apply.switches.merge!(
            custom: true, quick: true, full: true
          )
        end

        it 'is custom' do
          expect(run_type).to eql('custom')
        end
      end

      context 'when the custom switch is not active' do
        context 'when the quick switch is active' do
          before(:each) do
            apply.switches.merge!(
              quick: true, full: true
            )
          end

          it 'is quick' do
            expect(run_type).to eql('quick')
          end
        end

        context 'when the quick switch is not active' do
          context 'when the full switch is active' do
            before(:each) do
              apply.switches.merge!(
                full: true
              )
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
        expect(apply.switches).to be_empty
        expect(run_type).to eql('main')
      end
    end
  end
end
