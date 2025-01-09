require 'rails_helper'

RSpec.describe DocumentGenerator, type: :service do
  let(:replacements) do
    [
      {
        'num_act' => '12345',
        'date_compilation' => '10.01.2025',
        'basis_tech_examination' => 'Основание для экспертизы',
        'inn' => '1234567890',
        'kpp' => '987654321',
        'customer' => 'ООО Пример',
        'control_address' => 'г. Москва, ул. Примерная, д. 1',
        'product' => 'Продукт',
        'inventory_number' => '123-456-789',
        'date_manufacture' => '2024-12-01',
        'balance_cost' => '10000',
        'diagnostic' => 'Диагностика проведена успешно',
        'summary' => 'Вывод по акту',
        'business_case' => 'Экономическое обоснование',
        'conclusion' => 'Заключение',
        'note' => 'Примечание',
        'director' => 'Иванов И.И.',
        'expert' => 'Сидоров С.С.'
      }
    ]
  end

  let(:doc) { DocumentGenerator.new('last_template.docx', replacements) }

  describe '#init' do
    it '@template_path' do
      expect(doc.template_path).to be_present
    end

    it '@placeholders' do
      expect(doc.placeholders).to be_present
    end
  end

  describe '#generate' do
    it 'Генерация документа' do
      expect { doc.generate }.not_to raise_error
    end
  end
end
