# frozen_string_literal: true

RSpec.describe Subreddits::Update do
  let(:bot)             { create(:bot)                                              }
  let(:subreddit)       { create(:subreddit, bot:, options: initial_options)        }
  let(:initial_options) { {}                                                        }
  let(:params)          { ActionController::Parameters.new(subreddit: { options: }) }
  let(:options)         { {}                                                        }

  before do
    allow(Current).to receive(:params).and_return(params)
  end

  describe '#call' do
    subject(:service) { described_class.new.call(subreddit) }

    context 'when updating game thread settings' do
      let(:options) do
        {
          game_threads: {
            enabled: true,
            sticky_comment: 'Test sticky comment',
            post_at: '7:00',
            sticky: true
          }
        }
      end

      it 'updates all game thread options' do
        service
        subreddit.reload

        expect(subreddit.options['game_threads']['enabled']).to be true
        expect(subreddit.options['game_threads']['sticky_comment']).to eq('Test sticky comment')
        expect(subreddit.options['game_threads']['post_at']).to eq('7:00')
        expect(subreddit.options['game_threads']['sticky']).to be true
      end

      it 'saves the subreddit' do
        expect { service }
          .to(change { subreddit.reload.options })
      end

      context 'with valid flair_id GUID' do
        let(:options) do
          {
            game_threads: {
              flair_id: '12345678-1234-1234-1234-123456789abc',
              post_at: '7:00'
            }
          }
        end

        it 'accepts the GUID' do
          service
          subreddit.reload

          expect(subreddit.options['game_threads']['flair_id']).to eq('12345678-1234-1234-1234-123456789abc')
        end
      end

      context 'with invalid flair_id' do
        let(:options) do
          {
            game_threads: {
              flair_id: 'not-a-guid',
              post_at: '7:00'
            }
          }
        end

        it 'raises an error' do
          expect { service }
            .to raise_error(ArgumentError, /game_threads\.flair_id must be a GUID/)
        end
      end

      context 'when post_at is missing and enabled is true' do
        let(:initial_options) do
          {
            'game_threads' => {
              'enabled' => false
            }
          }
        end

        let(:options) do
          {
            game_threads: {
              enabled: true
            }
          }
        end

        it 'raises an error about missing post_at' do
          expect { service }
            .to raise_error(ArgumentError, /game_threads\.post_at is required/)
        end
      end

      context 'when post_at has invalid value' do
        let(:options) do
          {
            game_threads: {
              post_at: 'invalid'
            }
          }
        end

        it 'raises an error' do
          expect { service }
            .to raise_error(ArgumentError, /game_threads\.post_at must be one of/)
        end
      end

      context 'when enabled is false and post_at is not provided' do
        let(:options) do
          {
            game_threads: {
              enabled: false
            }
          }
        end

        it 'does not raise an error' do
          expect { service }
            .not_to raise_error
        end
      end

      context 'when updating only one field' do
        let(:initial_options) do
          {
            'game_threads' => {
              'enabled' => true,
              'post_at' => '8:00',
              'sticky' => false
            }
          }
        end

        let(:options) do
          {
            game_threads: {
              sticky_comment: 'New comment'
            }
          }
        end

        it 'preserves other existing fields' do
          service
          subreddit.reload

          expect(subreddit.options['game_threads']['sticky_comment']).to eq('New comment')
          expect(subreddit.options['game_threads']['enabled']).to be true
          expect(subreddit.options['game_threads']['post_at']).to eq('8:00')
          expect(subreddit.options['game_threads']['sticky']).to be false
        end
      end
    end

    context 'when updating pregame settings' do
      let(:options) do
        {
          pregame: {
            enabled: true,
            sticky_comment: 'Pregame sticky',
            post_at: '-3',
            sticky: false
          }
        }
      end

      it 'updates all pregame options' do
        service
        subreddit.reload

        expect(subreddit.options['pregame']['enabled']).to be true
        expect(subreddit.options['pregame']['sticky_comment']).to eq('Pregame sticky')
        expect(subreddit.options['pregame']['post_at']).to eq('-3')
        expect(subreddit.options['pregame']['sticky']).to be false
      end

      context 'with valid flair_id GUID' do
        let(:options) do
          {
            pregame: {
              flair_id: 'aaaaaaaa-bbbb-cccc-dddd-eeeeeeeeeeee',
              post_at: '-1'
            }
          }
        end

        it 'accepts the GUID' do
          service
          subreddit.reload

          expect(subreddit.options['pregame']['flair_id']).to eq('aaaaaaaa-bbbb-cccc-dddd-eeeeeeeeeeee')
        end
      end

      context 'when post_at is required but missing' do
        let(:initial_options) do
          {
            'pregame' => {
              'enabled' => false
            }
          }
        end

        let(:options) do
          {
            pregame: {
              enabled: true
            }
          }
        end

        it 'raises an error' do
          expect { service }
            .to raise_error(ArgumentError, /pregame\.post_at is required/)
        end
      end
    end

    context 'when updating postgame settings' do
      let(:options) do
        {
          postgame: {
            enabled: true,
            sticky_comment: 'Postgame sticky',
            sticky: true
          }
        }
      end

      it 'updates all postgame options' do
        service
        subreddit.reload

        expect(subreddit.options['postgame']['enabled']).to be true
        expect(subreddit.options['postgame']['sticky_comment']).to eq('Postgame sticky')
        expect(subreddit.options['postgame']['sticky']).to be true
      end
    end

    context 'when updating off day settings' do
      let(:options) do
        {
          off_day: {
            enabled: true,
            sticky_comment: 'Off day sticky',
            sticky: true,
            title: 'Custom off day title',
            post_at: '10:00'
          }
        }
      end

      it 'updates all off day options' do
        service
        subreddit.reload

        expect(subreddit.options['off_day']['enabled']).to be true
        expect(subreddit.options['off_day']['sticky_comment']).to eq('Off day sticky')
        expect(subreddit.options['off_day']['sticky']).to be true
        expect(subreddit.options['off_day']['title']).to eq('Custom off day title')
        expect(subreddit.options['off_day']['post_at']).to eq('10:00')
      end

      context 'with valid flair_id GUID' do
        let(:options) do
          {
            off_day: {
              flair_id: 'ffffffff-ffff-ffff-ffff-ffffffffffff',
              title: 'Off Day',
              post_at: '12:00'
            }
          }
        end

        it 'accepts the GUID' do
          service
          subreddit.reload

          expect(subreddit.options['off_day']['flair_id']).to eq('ffffffff-ffff-ffff-ffff-ffffffffffff')
        end
      end

      context 'when title is required but missing' do
        let(:initial_options) do
          {
            'off_day' => {
              'enabled' => false
            }
          }
        end

        let(:options) do
          {
            off_day: {
              enabled: true,
              post_at: '10:00'
            }
          }
        end

        it 'raises an error' do
          expect { service }
            .to raise_error(ArgumentError, /off_day\.title is required/)
        end
      end

      context 'when post_at is required but missing' do
        let(:initial_options) do
          {
            'off_day' => {
              'enabled' => false
            }
          }
        end

        let(:options) do
          {
            off_day: {
              enabled: true,
              title: 'Off Day'
            }
          }
        end

        it 'raises an error' do
          expect { service }
            .to raise_error(ArgumentError, /off_day\.post_at is required/)
        end
      end

      context 'when post_at has invalid value' do
        let(:options) do
          {
            off_day: {
              title: 'Off Day',
              post_at: 'invalid'
            }
          }
        end

        it 'raises an error' do
          expect { service }
            .to raise_error(ArgumentError, /off_day\.post_at must be one of/)
        end
      end
    end

    context 'when updating sidebar settings' do
      let(:options) do
        {
          sidebar: {
            enabled: true
          }
        }
      end

      it 'updates the sidebar options' do
        service
        subreddit.reload

        expect(subreddit.options['sidebar']['enabled']).to be true
      end
    end

    context 'when updating general settings' do
      let(:options) do
        {
          general: {
            sticky_slot: 2
          }
        }
      end

      it 'updates the general options' do
        service
        subreddit.reload

        expect(subreddit.options['general']['sticky_slot']).to eq(2)
      end
    end

    context 'when updating multiple sections' do
      let(:options) do
        {
          game_threads: {
            enabled: true,
            sticky_comment: 'Game thread comment',
            post_at: '7:00'
          },
          postgame: {
            enabled: true,
            sticky_comment: 'Postgame comment'
          },
          sidebar: {
            enabled: false
          }
        }
      end

      it 'updates all provided sections' do
        service
        subreddit.reload

        expect(subreddit.options['game_threads']['enabled']).to be true
        expect(subreddit.options['game_threads']['sticky_comment']).to eq('Game thread comment')
        expect(subreddit.options['postgame']['enabled']).to be true
        expect(subreddit.options['postgame']['sticky_comment']).to eq('Postgame comment')
        expect(subreddit.options['sidebar']['enabled']).to be false
      end
    end

    context 'when merging with existing options' do
      let(:initial_options) do
        {
          'game_threads' => {
            'sticky_comment' => 'Existing comment',
            'enabled' => true,
            'post_at' => '8:00'
          },
          'sidebar' => {
            'enabled' => true
          }
        }
      end

      let(:options) do
        {
          game_threads: {
            sticky_comment: 'Updated comment',
            post_at: '9:00'
          }
        }
      end

      it 'preserves existing options in the same category' do
        service
        subreddit.reload

        expect(subreddit.options['game_threads']['sticky_comment']).to eq('Updated comment')
        expect(subreddit.options['game_threads']['post_at']).to eq('9:00')
        expect(subreddit.options['game_threads']['enabled']).to be true
      end

      it 'preserves options in other categories' do
        service
        subreddit.reload

        expect(subreddit.options['sidebar']['enabled']).to be true
      end
    end

    context 'when removing blank values' do
      let(:options) do
        {
          game_threads: {
            sticky_comment: '  ',
            post_at: '7:00'
          },
          pregame: {
            sticky_comment: '',
            post_at: '-1'
          }
        }
      end

      it 'compacts the hash by removing blank string values' do
        service
        subreddit.reload

        expect(subreddit.options['game_threads']).not_to have_key('sticky_comment')
        expect(subreddit.options['pregame']).not_to have_key('sticky_comment')
      end
    end

    context 'with boolean conversions' do
      let(:test_cases) do
        {
          'true' => true,
          'false' => false,
          '1' => true,
          '0' => false,
          1 => true,
          0 => false,
          true => true,
          false => false,
          nil => false
        }
      end

      it 'correctly converts all boolean formats' do
        test_cases.each do |input, expected|
          subreddit.options = {}
          subreddit.save!
          params[:subreddit] = { options: { sidebar: { enabled: input } } }

          described_class.new.call(subreddit)
          subreddit.reload

          expect(subreddit.options['sidebar']['enabled'])
            .to eq(expected), "Expected #{input.inspect} to convert to #{expected}"
        end
      end
    end

    context 'when no options are provided' do
      let(:params) { {} }

      it 'does not raise an error' do
        expect { service }
          .not_to raise_error
      end

      it 'does not modify existing options' do
        initial_options['sidebar'] = { 'enabled' => true }

        expect { service }
          .not_to(change { subreddit.reload.options })
      end
    end

    context 'with whitespace in string values' do
      let(:options) do
        {
          game_threads: {
            sticky_comment: '  Comment with spaces  ',
            post_at: '  7:00  '
          }
        }
      end

      it 'strips whitespace from string values' do
        service
        subreddit.reload

        expect(subreddit.options['game_threads']['sticky_comment']).to eq('Comment with spaces')
        expect(subreddit.options['game_threads']['post_at']).to eq('7:00')
      end
    end

    context 'with nil values' do
      let(:options) do
        {
          game_threads: {
            sticky_comment: nil,
            post_at: '7:00'
          }
        }
      end

      it 'removes nil values from the hash' do
        service
        subreddit.reload

        expect(subreddit.options['game_threads']).not_to have_key('sticky_comment')
        expect(subreddit.options['game_threads']['post_at']).to eq('7:00')
      end
    end

    context 'when GUID is empty string' do
      let(:options) do
        {
          game_threads: {
            flair_id: '',
            post_at: '7:00'
          }
        }
      end

      it 'removes the empty flair_id' do
        service
        subreddit.reload

        expect(subreddit.options['game_threads']).not_to have_key('flair_id')
      end
    end

    context 'when GUID is blank after stripping' do
      let(:options) do
        {
          game_threads: {
            flair_id: '   ',
            post_at: '7:00'
          }
        }
      end

      it 'removes the blank flair_id' do
        service
        subreddit.reload

        expect(subreddit.options['game_threads']).not_to have_key('flair_id')
      end
    end

    context 'when only providing a subset of fields in a category' do
      let(:initial_options) do
        {
          'game_threads' => {
            'enabled' => true,
            'post_at' => '8:00',
            'sticky' => true,
            'sticky_comment' => 'Old comment'
          }
        }
      end

      let(:options) do
        {
          game_threads: {
            sticky_comment: 'New comment'
          }
        }
      end

      it 'only updates the provided fields' do
        service
        subreddit.reload

        expect(subreddit.options['game_threads']['sticky_comment']).to eq('New comment')
        expect(subreddit.options['game_threads']['enabled']).to be true
        expect(subreddit.options['game_threads']['post_at']).to eq('8:00')
        expect(subreddit.options['game_threads']['sticky']).to be true
      end
    end

    context 'when disabling a previously enabled category' do
      let(:initial_options) do
        {
          'game_threads' => {
            'enabled' => true,
            'post_at' => '8:00',
            'sticky_comment' => 'Old comment'
          }
        }
      end

      let(:options) do
        {
          game_threads: {
            enabled: false
          }
        }
      end

      it 'disables the category but preserves other fields' do
        service
        subreddit.reload

        expect(subreddit.options['game_threads']['enabled']).to be false
        expect(subreddit.options['game_threads']['post_at']).to eq('8:00')
        expect(subreddit.options['game_threads']['sticky_comment']).to eq('Old comment')
      end
    end

    context 'when clearing a field by setting it to empty string' do
      let(:initial_options) do
        {
          'game_threads' => {
            'sticky_comment' => 'Old comment',
            'post_at' => '8:00'
          }
        }
      end

      let(:options) do
        {
          game_threads: {
            sticky_comment: ''
          }
        }
      end

      it 'removes the field from options' do
        service
        subreddit.reload

        expect(subreddit.options['game_threads']).not_to have_key('sticky_comment')
        expect(subreddit.options['game_threads']['post_at']).to eq('8:00')
      end
    end
  end
end
