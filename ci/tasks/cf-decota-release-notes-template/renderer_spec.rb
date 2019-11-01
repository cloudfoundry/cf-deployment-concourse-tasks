require 'rspec'
require_relative './renderer.rb'

describe 'Renderer' do
  describe '#render' do
    subject(:renderer) { Renderer.new }

    let(:binary_update_1) do
      update = double('BinaryUpdate')
      allow(update).to receive(:old_version) { '1.1.0' }
      allow(update).to receive(:new_version) { '1.3.0' }
      update
    end

    let(:binary_update_2) do
      update = double('BinaryUpdate')
      allow(update).to receive(:old_version) { '1.2.0' }
      allow(update).to receive(:new_version) { '1.4.0' }
      update
    end

    let(:binary_updates) do
      updates = double('BinaryUpdates')
      allow(updates).to receive(:each).and_yield('binary-1', binary_update_1).and_yield('binary-2', binary_update_2)
      updates
    end

    let(:task_updates) do
      updates = double('TaskUpdates')
      allow(updates).to receive(:new_tasks).and_return(['new-task'])
      allow(updates).to receive(:deleted_tasks).and_return(['deleted-task'])
      allow(updates).to receive(:updated_tasks).and_return(['updated-task'])
      updates
    end

    it 'includes a section header for Notices' do
      rendered_output = renderer.render(binary_updates: binary_updates, task_updates: task_updates)
      expect(rendered_output).to include ("## Notices")
    end

    it 'includes a section header for Notices, as well as sub-headers for New and Updated Tasks' do
      rendered_output = renderer.render(binary_updates: binary_updates, task_updates: task_updates)
      expect(rendered_output).to include (
<<-NOTICES
## Notices
### :point_right: New Tasks :point_left:
-**`new-task`**

### :point_right: Updated Tasks :point_left:
-**`updated-task`**

### :point_right: Deleted Tasks :point_left:
-**`deleted-task`**

NOTICES
      )
    end

    it 'inlcudes a section header for Binary Updates' do
      rendered_output = renderer.render(binary_updates: binary_updates, task_updates: task_updates)
      expect(rendered_output).to include ("## Binary Updates\n")
    end

    describe 'Binary table' do
      it 'includes a header' do
        rendered_output = renderer.render(binary_updates: binary_updates, task_updates: task_updates)
        expect(rendered_output).to include(
<<-HEADER
| Binary | Old Version | New Version |
| ------- | ----------- | ----------- |
HEADER
        )
      end

      it 'places the table header immediately after the section header' do
        rendered_output = renderer.render(binary_updates: binary_updates, task_updates: task_updates)
        expect(rendered_output).to include ("## Binary Updates\n| Binary | Old Version | New Version |")
      end

      it 'shows the binary name, old version, and new version for each binary' do
        rendered_output = renderer.render(binary_updates: binary_updates, task_updates: task_updates)
        expect(rendered_output).to include('| binary-1 | 1.1.0 | 1.3.0 |')
        expect(rendered_output).to include('| binary-2 | 1.2.0 | 1.4.0 |')
      end

      context 'when some versions are nil' do
        let(:binary_update_1) do
          update = double('BinaryUpdate')
          allow(update).to receive(:old_version) { '1.1.0' }
          allow(update).to receive(:new_version) { nil }
          update
        end

        let(:binary_update_2) do
          update = double('BinaryUpdate')
          allow(update).to receive(:old_version) { nil }
          allow(update).to receive(:new_version) { '1.4.0' }
          update
        end

        it 'renders them as empty strings' do
          rendered_output = renderer.render(binary_updates: binary_updates, task_updates: task_updates)
          expect(rendered_output).to include('| binary-1 | 1.1.0 |  |')
          expect(rendered_output).to include('| binary-2 |  | 1.4.0 |')
        end
      end
    end
  end
end
